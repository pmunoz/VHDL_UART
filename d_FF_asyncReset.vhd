----------------------------------------------------------------------------------
--| Author: Pablo Muñoz Galindo 
--|
--| Project Name:   VHDL Simple UART
--| Module Name:    d_FF_asyncReset - Behavioral 
--| Description:    D flip-flop with asynchronous reset
--|
--| Created:    	  13:07:37 06/23/2019 
--| Tested using: 
--|
--| (c)2019 Pablo Muñoz
--| This code is licensed under MIT license (see LICENSE.md for details)
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity d_FF_asyncReset is
	 Port ( Clk : in  STD_LOGIC;	
			  Reset : in STD_LOGIC;
			  Reset_val : in STD_LOGIC;
			  D : in STD_LOGIC;
			  Q : out STD_LOGIC
			  );
end d_FF_asyncReset;

architecture Behavioral of d_FF_asyncReset is

begin

	process(Reset,Reset_val,Clk) is begin	
		if Reset='1' then
			Q <= Reset_val;
		else
			if rising_edge(Clk) then
				Q <= D;
			end if;
		end if;
	end process;
	
end Behavioral;

