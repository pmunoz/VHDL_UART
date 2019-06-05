----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:09:47 05/22/2019 
-- Design Name: 
-- Module Name:    Rx_controller - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Rx_controller is
    Port ( Clk : in  STD_LOGIC;	
			  Clk_TEST : out STD_LOGIC
	 );
end Rx_controller;

architecture Behavioral of Rx_controller is

	TYPE states IS (Standby, StartBit, ReceivingData, StopBit);
	constant Freq_base_Clk_FPGA : unsigned(31 downto 0) := x"02FAF080"; -- 50e6 Hz;
	constant default_baudrate : unsigned(31 downto 0) := x"00002580"; -- 9600 bauds;	
	constant clk_multiplier : unsigned(31 downto 0) := x"00000010"; -- x16;
	signal tmp_calc : unsigned(31 downto 0) := x"00000000"; -- x16;
	signal TIMER_1_threshold : unsigned(15 downto 0):=x"0001"; 
	signal TIMER_1 : unsigned(15 downto 0) := x"0000";
	signal TIMER_2 : unsigned(7 downto 0) := x"00";
	signal TIMER_2_threshold : unsigned(7 downto 0) :=x"01";
	signal Clk_SM : std_logic := '0';
	signal Clk_BitSample : std_logic := '0';
	signal Reset_BitCounter : std_logic := '0';
	
begin
	tmp_calc <= Freq_base_Clk_FPGA/(clk_multiplier*default_baudrate);
	TIMER_1_threshold <= tmp_calc(15 downto 0);
	TIMER_2_threshold <= Shift_right(clk_multiplier,1)(7 downto 0);
	Clk_TEST <= Clk_SM;

	-- Clock generator for state machine
	clk_PS : process(Clk) is begin
		if rising_edge(Clk) then
			if(TIMER_1 = TIMER_1_threshold) then
				TIMER_1 <= x"0000";
				Clk_SM <= NOT Clk_SM;
			else
				TIMER_1 <= TIMER_1+1;			
			end if;
		end if;
	end process;
	
	-- Counter for shift register timing
	bit_counter : process(Clk_SM,Reset_BitCounter) is begin
		if rising_edge(Clk_SM) then
			if(Reset_BitCounter='1') then
				TIMER_2 <= x"00";
		   else
			   TIMER_2 <= TIMER_2+1;
		   end if;
		end if;
	end process;
	
	gen_clk_Bit : process(Clk_SM) is begin		
		Reset_BitCounter <= '0';
		if(TIMER_2 = x"08") then
			Reset_BitCounter <= '1';
			Clk_BitSample <= NOT Clk_bitSample;
		end if;
	end process;
	
	
	-- Transitions
	
	
	
--	process(BaudRate_sel) is begin
--		case BaudRate_sel is
--			when "0000" =>
--				divider_val = 50e9
--		end case;
--	end procress;

end Behavioral;

