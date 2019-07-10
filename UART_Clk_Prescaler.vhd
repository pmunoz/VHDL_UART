----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:49:24 07/10/2019 
-- Design Name: 
-- Module Name:    UART_Clk_Prescaler - Behavioral 
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


-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity UART_Clk_Prescaler is
	Port ( Clk : in  STD_LOGIC;
			 Reset : in STD_LOGIC;
			 baudrate_selection : in std_logic_vector(3 downto 0);
			 FSM_clk_multiplier : in unsigned (31 downto 0);
			 Clk_PS : out STD_LOGIC
			  );
end UART_Clk_Prescaler;

architecture Behavioral of UART_Clk_Prescaler is

------------------------------------------------------------------------
-- Internal signals
------------------------------------------------------------------------
constant Freq_base_Clk_FPGA : unsigned(31 downto 0) := x"02FAF080"; -- 50e6 Hz;
--constant default_baudrate : unsigned(31 downto 0) := x"00002580"; -- 9600 bauds;	
--constant clk_multiplier : unsigned(31 downto 0) := x"00000010"; -- x16;

signal selected_baudrate : unsigned(31 downto 0);
signal tmp_calc : unsigned(31 downto 0) := x"00000000"; -- x16;
signal TIMER_PS : unsigned(15 downto 0) := x"0000";
signal TIMER_PS_threshold : unsigned(15 downto 0); 
signal CLK_FSM : std_logic := '0';

begin


tmp_calc <= Freq_base_Clk_FPGA/(FSM_clk_multiplier*selected_baudrate);
TIMER_PS_threshold <= tmp_calc(16 downto 1);

CLK_PS <= CLK_FSM;

-- Baudrate selector and counter threshold value calculation
BAUDRATE_SELECTOR : process(baudrate_selection) is begin
		selected_baudrate <= x"00002580"; -- 9600 bauds		
end process;
		
-- Counter
COUNTER : process(Clk, Reset) is begin		
			if rising_edge(Clk) then
				if Reset = '1' then
					TIMER_PS <= x"0000";
					Clk_FSM <= '0';
				else 
					if(TIMER_PS = TIMER_PS_threshold) then
						TIMER_PS <= x"0000";
						Clk_FSM <= NOT Clk_FSM;
					else
						TIMER_PS <= TIMER_PS+1;			
					end if;				
				end if;		
			end if;
end process;

end Behavioral;

