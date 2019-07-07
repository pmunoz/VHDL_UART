----------------------------------------------------------------------------------
--| Author: Pablo Muñoz Galindo 
--|
--| Project Name:   VHDL Simple UART
--| Module Name:    Registry_gen - Behavioral 
--| Description:    Generic registry 
--|
--| Created:    	  12:29:00 07/07/2019 
--| Tested using: 
--|
--| (c)2019 Pablo Muñoz
--| This code is licensed under MIT license (see LICENSE.md for details)
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Registry_gen is
    Port ( Clk : in STD_LOGIC;
			  Reset : in STD_LOGIC;
			  input : in  STD_LOGIC_VECTOR;
			  output : out STD_LOGIC_VECTOR		   
	 );
end Registry_gen;

architecture Behavioral of Registry_gen is
	signal D : std_logic_vector(input'range):= (others => '0');
	signal Q : std_logic_vector(input'range):=(others => '0'); 
	
begin	
	D <= input;
	output <= Q;
	
	-- Input register behavior
	process(Clk) is begin
		if rising_edge(Clk) then
			if(Reset = '1') then
				Q <= (others => '0');
			else
				Q <= D;
			end if;
		end if;
	end process;
	
end Behavioral;
