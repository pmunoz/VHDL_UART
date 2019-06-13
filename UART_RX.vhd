----------------------------------------------------------------------------------
--| Author: Pablo Muñoz Galindo 
--|
--| Project Name:   VHDL Simple UART
--| Module Name:    UART_RX - Behavioral
--| Description:    UART receiver (includes state machine to control block's 
--|                 operation) 
--|
--| Created:    	  17:43:08 06/04/2019
--| Tested using: 
--|
--| (c)2019 Pablo Muñoz
--| This code is licensed under MIT license (see LICENSE.md for details)
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;

entity UART_RX is
    Port ( Clk : in  STD_LOGIC;	
			  Reset : in STD_LOGIC;
			  Serial_in : in STD_LOGIC;
			  Data_out : out STD_LOGIC_VECTOR(7 downto 0);
			  Correct_rx : out std_logic
			  );
end UART_RX;

architecture Behavioral of UART_RX is

------------------------------------------------------------------------
-- Components for UART receiver
------------------------------------------------------------------------
component Shift_Registry_8bit_counter is
    Port ( Clk : in  STD_LOGIC;
           CLR : in  STD_LOGIC;
			  Hold : in STD_LOGIC;
           Ser_in : in  STD_LOGIC;
			  Carry_out : out STD_LOGIC;
           Par_out : out  STD_LOGIC_VECTOR (7 downto 0);
			  Counter_out : out STD_LOGIC_VECTOR (7 downto 0)
	 );
end component;

------------------------------------------------------------------------
-- Type definitions
------------------------------------------------------------------------
TYPE state IS (standby, startBit, waitForBit, sampleBit, stopAndStore); -- definition of states for the FSM

------------------------------------------------------------------------
-- Internal signals
------------------------------------------------------------------------
signal current_state, next_state : state := standby; -- Initialize state registries to standby	constant Freq_base_Clk_FPGA : unsigned(31 downto 0) := x"02FAF080"; -- 50e6 Hz;
constant Freq_base_Clk_FPGA : unsigned(31 downto 0) := x"02FAF080"; -- 50e6 Hz;
constant default_baudrate : unsigned(31 downto 0) := x"00002580"; -- 9600 bauds;	
constant clk_multiplier : unsigned(31 downto 0) := x"00000010"; -- x16;
signal tmp_calc : unsigned(31 downto 0) := x"00000000"; -- x16;
signal TIMER_PS : unsigned(15 downto 0) := x"0000";
signal TIMER_PS_threshold : unsigned(15 downto 0):=x"0001"; 
signal TIMER_BIT : unsigned(7 downto 0);
signal TIMER_BIT_threshold : unsigned(7 downto 0) := x"00";
signal TIMER_BIT_expired : std_logic := '0';
signal TIMER_BIT_reset : std_logic := '1';

signal Clk_FSM : std_logic := '0';

signal ShiftReg_capture : std_logic := '0';
signal ShiftReg_hold : std_logic := '0';
signal ShiftReg_reset : std_logic := '1';
signal ShiftReg_data_out : std_logic_vector(7 downto 0);
signal ShiftReg_bitcount : std_logic_vector(7 downto 0);
signal stopBit : std_logic := '0';

signal par_data : std_logic_vector(7 downto 0) := x"00";

begin

Data_out <= par_data;

-- Shift registry for UART
SHIFT_REGISTRY : Shift_Registry_8bit_counter
    port map (
		Clk => ShiftReg_capture,
		CLR => ShiftReg_reset,
		Hold => ShiftReg_hold,
		Ser_in => Serial_in,
		Carry_out => open,
		Par_out => ShiftReg_data_out,
		Counter_out => ShiftReg_bitcount);


-- Clock prescaler for state machine
tmp_calc <= Freq_base_Clk_FPGA/(clk_multiplier*default_baudrate);
TIMER_PS_threshold <= tmp_calc(16 downto 1);
	
CLOCK_PS : process(Clk) is begin
		if rising_edge(Clk) then
			if(TIMER_PS = TIMER_PS_threshold) then
				TIMER_PS <= x"0000";
				Clk_FSM <= NOT Clk_FSM;
			else
				TIMER_PS <= TIMER_PS+1;			
			end if;
		end if;
end process;

-- Timer to count for bit periods and half-periods with asynchronous reset
BIT_PERIOD_TIMER : process (Clk_FSM, TIMER_BIT_reset, TIMER_bit) is begin	
	if TIMER_BIT_reset = '1' then
		TIMER_BIT <= x"00";
	else
		if rising_edge(Clk_FSM) then		
			TIMER_BIT <= TIMER_BIT + 1;
			if TIMER_BIT >= TIMER_BIT_threshold-x"01" then
				TIMER_BIT_expired <= '1';
			else
				TIMER_BIT_expired <= '0';
			end if; 
		end if;
	end if;
	
	
end process;

-- Status registry
STATE_REG : process (Clk_FSM) is begin
	if rising_edge(Clk_FSM) then
		if Reset = '1' then
			current_state <= standby;
		else
			current_state <= next_state;
		end if;
	end if;
end process;

-- Transition logic
TRANSITION_LOG : process(current_state, Serial_in, TIMER_BIT_expired, Reset) is begin
	next_state <= current_state;
	case current_state is
		when standby =>
			if Reset = '0' and falling_edge(Serial_in) then next_state <= waitForBit; 
			end if;
		when startBit =>
			if rising_edge(TIMER_BIT_expired) then 
				next_state <= waitForBit;
			else
				next_state <= startBit;
			end if;
		when waitForBit =>
			if rising_edge(TIMER_BIT_expired) then 
				if ShiftReg_bitcount < x"08" then
					next_state <= sampleBit;
			   else
					next_state <= stopAndStore;
				end if;
			end if;
		when sampleBit =>
			next_state <= waitForBit; 
      when stopAndStore =>
			next_state <= standby;
	end case;
end process;

-- Output generation
OUTPUT_GEN : process(current_state, Serial_in, Reset,ShiftReg_data_out) is begin
	
	ShiftReg_capture <= '0';
	ShiftReg_hold <= '0';
	ShiftReg_reset <= '0';
	Correct_rx <= '0';
	TIMER_BIT_reset <= '1';
	TIMER_BIT_threshold <= x"00";	
	par_data <= x"00";
	
	case current_state is
		when standby =>
			ShiftReg_reset <= '1';
		when startBit =>		
--			TIMER_BIT_threshold <= clk_multiplier(8 downto 1);
--			TIMER_BIT_reset <= '0';
		when waitForBit =>
			if ShiftReg_bitcount = x"00" then
				TIMER_BIT_threshold <= clk_multiplier(8 downto 1)+clk_multiplier(7 downto 0)-x"01";
			else
				TIMER_BIT_threshold <= clk_multiplier(7 downto 0)-x"02";
			end if;
			TIMER_BIT_reset <= '0';
		when sampleBit =>
			ShiftReg_capture <= '1';		
      when stopAndStore =>
			ShiftReg_hold <= '1';
			if Serial_in = '1' then Correct_rx <= '1'; end if;
			par_data <= ShiftReg_data_out;
	end case;
end process;

end Behavioral;

