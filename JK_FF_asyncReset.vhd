----------------------------------------------------------------------------------
--| Author: Pablo Muñoz Galindo 
--|
--| Project Name:   VHDL Simple UART
--| Module Name:    JK_FF_asyncReset - Behavioral 
--| Description:    JK flip-flop with asynchronous reset
--|
--| Created:    	  13:00:00 08/07/2019 
--| Tested using: 
--|
--| (c)2019 Pablo Muñoz
--| This code is licensed under MIT license (see LICENSE.md for details)
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity JK_FF_asyncReset is
	 Port ( J : in  STD_LOGIC;	
			  K : in STD_LOGIC;
			  Reset : in STD_LOGIC;
			  Clk : in STD_LOGIC;
			  Q : out STD_LOGIC;
			  Qn : out STD_LOGIC
			  );
end JK_FF_asyncReset;

architecture Behavioral of JK_FF_asyncReset is
	signal int_val : std_logic := '0';
begin
	
	Q <= int_val;
	Qn <= NOT int_val;
	
	process(Clk, Reset) is begin
		if Reset = '1' then
			int_val <= '0';
		elsif rising_edge(Clk) then				
			if J='1' AND K= '0' then
				int_val <= '1';
			elsif J='0' AND K= '1' then
				int_val <= '0';
			elsif J='1' AND K= '1' then
				int_val <= NOT int_val;
			else 
			   int_val <= int_val;
			end if;
		end if;
	end process;
	
end Behavioral;

