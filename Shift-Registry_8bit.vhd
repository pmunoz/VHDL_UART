----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:08:58 05/22/2019 
-- Design Name: 
-- Module Name:    Shift-Registry_8bit - Behavioral 
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

entity Shift_Registry_8bit is
    Port ( OE : in  STD_LOGIC;
           R_Clk : in  STD_LOGIC;
           SR_Clk : in  STD_LOGIC;
           SR_CLR : in  STD_LOGIC;
           Ser_in : in  STD_LOGIC;
           Par_out : out  STD_LOGIC_VECTOR (7 downto 0)
	 );
end Shift_Registry_8bit;

architecture Behavioral of Shift_Registry_8bit is
	signal tmp_input_reg : STD_LOGIC_VECTOR (7 downto 0) := "00000000";	
	signal tmp_output_reg : STD_LOGIC_VECTOR (7 downto 0) := "00000000";

begin	
	-- Input register behavior
	process(SR_Clk) is begin
		if rising_edge(SR_Clk) then
				if SR_CLR = '1' then
					tmp_input_reg <= "00000000";
				else
					tmp_input_reg <= std_logic_vector(shift_left(unsigned(tmp_input_reg),1));
					tmp_input_reg(0) <= Ser_in;
				end if;
		end if;
	end process;
	
	-- Output register behavior		
	process(R_Clk) is begin
			if rising_edge(R_Clk) then
				tmp_output_reg <= tmp_input_reg;
			end if;
	end process;

	-- Output selection behavior	
	process(OE,tmp_output_reg) is begin
		if OE = '0' then
			Par_out <= "ZZZZZZZZ";
		else
			Par_out <= tmp_output_reg;
	   end if;
	end process;	
	
end Behavioral;

