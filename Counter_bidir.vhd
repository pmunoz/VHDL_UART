----------------------------------------------------------------------------------
--| Author: Pablo Muñoz Galindo 
--|
--| Project Name:   VHDL Simple UART
--| Module Name:    Counter_bidir - Behavioral 
--| Description:    Bi-directional counter with asynchronous reset
--|
--| Created:    	  12:57:00 07/07/2019
--| Tested using: 
--|
--| (c)2019 Pablo Muñoz
--| This code is licensed under MIT license (see LICENSE.md for details)
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Counter_bidir is
    Port ( Reset : in  STD_LOGIC;
           Clk : in  STD_LOGIC;
			  dir : in  STD_LOGIC;
			  Count : out unsigned);
end Counter_bidir;

architecture Behavioral of Counter_bidir is

	signal tmp_count : unsigned(Count'range) := (others => '0');
	
begin
	Count <= tmp_count;
	
	process(Reset,Clk) is begin
		if Reset='1' then
			tmp_count <= (others => '0');
		else
			if rising_edge(Clk) then
				if dir='1' then
					tmp_count <= tmp_count + 1;
				else
					tmp_count <= tmp_count -1;
				end if;
			end if;
		end if;
	end process;
end Behavioral;

