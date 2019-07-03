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
			  Serial_out : out STD_LOGIC;
			  Busy : out STD_LOGIC
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

component d_FF_asyncReset is
	 Port ( Clk : in  STD_LOGIC;	
		  Reset : in STD_LOGIC;
		  Reset_val : in STD_LOGIC;
		  D : in STD_LOGIC;
		  Q : out STD_LOGIC
		  );
end component;


component Counter is
    Port ( Reset : in  STD_LOGIC;
           Clk : in  STD_LOGIC;
			  Count : out unsigned);
end component;

------------------------------------------------------------------------
-- Type definitions
------------------------------------------------------------------------
TYPE state IS (standby, loadStartBit, loadDataBit, loadStopBit, waitForBitTX); -- definition of states for the FSM

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

--signal bit_pointer : unsigned(4 downto 0):= "00000";

signal output_ff_Clk : std_logic := '0';
signal output_ff_D : std_logic := '1'; 

signal bitPointer_Clk : std_logic := '0';
signal bitPointer_Reset : std_logic := '1';
signal bitPointer_Count : unsigned (3 downto 0);

begin

	
-- Input registry
INPUT_REGISTRY : Registry_8bit
	port map (
		Clk => Reg_capture,
		Reset => Reset  ,
		input => Data_in,
		output => Reg_output);
		
-- Output flip-flop
OUTPUT_FF : d_FF_asyncReset
	port map (
		Clk => output_ff_Clk,
		Reset => Reset,
		Reset_val => '1',
		D => output_ff_D,
		Q => Serial_out);

-- BIT POINTER
BIT_POINTER : Counter
	port map (
		Reset => bitPointer_Reset,
		Clk => bitPointer_Clk,
		Count => bitPointer_Count
		);
			  
		
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
		TIMER_BIT_expired <= '0';
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
TRANSITION_LOG : process(current_state,Reset,TIMER_BIT_expired,Write_en, bitPointer_Count) is begin
	next_state <= current_state;
	
	case current_state is
		when standby =>
			if Reset = '0' and rising_edge(Write_en) then next_state <= loadStartBit; 
			end if;
		when loadStartBit => 
			next_state <= waitForBitTX;
		when loadDataBit =>
			next_state <= waitForBitTX;
		when loadStopBit =>
			next_state <= waitForBitTX;
		when waitForBitTX =>
			if TIMER_BIT_expired='1' then 
				if bitPointer_Count < x"09" then
					next_state <= loadDataBit;
				elsif bitPointer_Count = x"09" then
					next_state <= loadStopBit;
				else 
					next_state <= standby;
				end if;
			end if;
	end case;	
end process;

-- Output generation
OUTPUT_GEN : process(current_state,Reg_output,bitPointer_Count) is begin

	TIMER_BIT_reset <= '1';
	TIMER_BIT_threshold <= clk_multiplier(7 downto 0)-2;	
	Reg_capture <= '0';
	output_ff_Clk <= '0';
	output_ff_D <= '0'; 	
	bitPointer_Reset <= '0';
	bitPointer_Clk <= '0';
	busy <= '1';

	case current_state is
			when standby =>				
				bitPointer_Reset <= '1';
				busy <= '0';
			when loadStartBit => 		
				output_ff_Clk <= '1';
				output_ff_D <= '0'; 
				Reg_capture <= '1';
			when loadDataBit =>			
				output_ff_Clk <= '1';
				output_ff_D <= Reg_output(to_integer(bitPointer_Count)-1);	
			when loadStopBit =>			
				output_ff_Clk <= '1';
				output_ff_D <= '1'; 			
			when waitForBitTX =>
				TIMER_BIT_reset <= '0';
				bitPointer_Clk <= '1';				
	end case;	
end process;

end Behavioral;