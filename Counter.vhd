----------------------------------------------------------------------------------
--| Author: Pablo Muñoz Galindo 
--|
--| Project Name:   VHDL Simple UART
--| Module Name:    Counter - Behavioral 
--| Description:    Counter with asynchronous reset
--|
--| Created:    	  13:34:53 06/23/2019
--| Tested using: 
--|
--| (c)2019 Pablo Muñoz
--| This code is licensed under MIT license (see LICENSE.md for details)
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Counter is
    Port ( Reset : in  STD_LOGIC;
           Clk : in  STD_LOGIC;
			  Count : out unsigned);
end Counter;

architecture Behavioral of Counter is

	signal tmp_count : unsigned(Count'range) := (others => '0');
	
begin
	Count <= tmp_count;
	
	process(Reset,Clk) is begin
		if Reset='1' then
			tmp_count <= (others => '0');
		else
			if rising_edge(Clk) then
				tmp_count <= tmp_count + 1;
			end if;
		end if;
	end process;
end Behavioral;

