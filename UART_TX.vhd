----------------------------------------------------------------------------------
--| Author: Pablo Muñoz Galindo 
--|
--| Project Name:   VHDL Simple UART
--| Module Name:    UART_TX - Behavioral
--| Description:    UART transmitter (includes state machine to control block's 
--|                 operation) 
--|
--| Created:    	  21:20:34 06/14/2019 
--| Tested using:   untested
--|
--| (c)2019 Pablo Muñoz
--| This code is licensed under MIT license (see LICENSE.md for details)
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;

entity UART_TX is
    Port ( Clk : in  STD_LOGIC;	
			  Reset : in STD_LOGIC;
			  Write_en : in STD_LOGIC;
			  Data_in : in STD_LOGIC_VECTOR(7 downto 0);
			  Serial_out : out STD_LOGIC
			  );
end UART_TX;

architecture Behavioral of UART_TX is

------------------------------------------------------------------------
-- Components for UART transmitter
------------------------------------------------------------------------
component Registry_8bit is
    Port ( Clk : in STD_LOGIC;
			  Reset : in STD_LOGIC;
			  input : in  STD_LOGIC_VECTOR (7 downto 0);
			  output : out STD_LOGIC_VECTOR (7 downto 0)
	 );
end component;

------------------------------------------------------------------------
-- Type definitions
------------------------------------------------------------------------
TYPE state IS (standby, startBit, txDataBit, incPointer, stopBit); -- definition of states for the FSM

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

signal Reg_capture : std_logic := '0';
--signal Reg_reset : std_logic := '1';
signal Reg_input : std_logic_vector (7 downto 0);
signal Reg_output : std_logic_vector (7 downto 0);

signal bit_pointer : unsigned(4 downto 0):= "00000";

signal output_bs_D : std_logic := '1';
signal output_bs_Q : std_logic := '1';
signal output_bs_Clk : std_logic := '0'; 

begin

	
-- Input registry
INPUT_REGISTRY : Registry_8bit
	port map (
		Clk => Reg_capture,
		Reset => Reset  ,
		input => Data_in,
		output => Reg_output);

-- Other connections
--Reg_input <= ShiftReg_data_out;
--Data_out <= Reg_output;

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

-- Output bistable
OUTPUT_BS : process (output_bs_Clk) is begin
	if rising_edge(output_bs_Clk) then
		output_bs_Q <= output_bs_D;
	end if;
end process;

-- Transition logic
TRANSITION_LOG : process(current_state,Reset,TIMER_BIT_expired,Write_en) is begin
	next_state <= current_state;
	case current_state is
		when standby =>
			if Reset = '0' and falling_edge(Write_en) then next_state <= startBit; 
			end if;
		when startBit =>
			if rising_edge(TIMER_BIT_expired) then 
				next_state <=  txDataBit;
			end if;
		when txDataBit =>
			if rising_edge(TIMER_BIT_expired) then 
				if bit_pointer < x"08" then
					next_state <= incPointer;
				else
					next_state <= stopBit;
				end if;
			end if;
		when incPointer =>
			next_state <=  txDataBit; 
      when stopBit =>
			if rising_edge(TIMER_BIT_expired) then 
				next_state <= standby;
			end if;
	end case;
end process;

-- Output generation
OUTPUT_GEN : process(current_state,output_bs_Q,Reg_output,bit_pointer) is begin
	TIMER_BIT_reset <= '1';
	TIMER_BIT_threshold <= x"00";	
	Reg_capture <= '0';
	--Reg_reset <= '0';
	Serial_out <= '1';
	output_bs_Clk <= '0';
	output_bs_D <= '0';	
	Serial_out <= output_bs_Q; 
	
	case current_state is
		when standby =>				
			--Reg_reset <= '1';
		when startBit =>					
			Reg_capture <= '1';
			TIMER_BIT_threshold <= clk_multiplier(7 downto 0);
			TIMER_BIT_reset <= '0';
		when txDataBit =>
			TIMER_BIT_threshold <= clk_multiplier(7 downto 0);
			TIMER_BIT_reset <= '0';
			output_bs_D <= Reg_output(to_integer(bit_pointer));			
			output_bs_Clk <= '1';	
		when incPointer =>
			TIMER_BIT_reset <= '1';
			bit_pointer<=bit_pointer+1;
      when stopBit =>
			Reg_capture <= '1';
			TIMER_BIT_threshold <= clk_multiplier(7 downto 0);
			TIMER_BIT_reset <= '0';
	end case;		
end process;

end Behavioral;