----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:43:13 06/14/2019 
-- Design Name: 
-- Module Name:    Registry_8bit - Behavioral 
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

----------------------------------------------------------------------------------
--| Author: Pablo Muñoz Galindo 
--|
--| Project Name:   VHDL Simple UART
--| Module Name:    Shift-Registry_8bit - Behavioral 
--| Description:    Shift registry to do serial/parallel conversion
--|
--| Created:    	  09:08:58 05/22/2019
--| Tested using: 
--|
--| (c)2019 Pablo Muñoz
--| This code is licensed under MIT license (see LICENSE.md for details)
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Registry_8bit is
    Port ( Clk : in STD_LOGIC;
			  Reset : in STD_LOGIC;
			  input : in  STD_LOGIC_VECTOR (7 downto 0);
			  output : out STD_LOGIC_VECTOR (7 downto 0)		   
	 );
end Registry_8bit;

architecture Behavioral of Registry_8bit is
	signal D : std_logic_vector(7 downto 0):=x"00";
	signal Q : std_logic_vector(7 downto 0):=x"00"; 
	
begin	
	D <= input;
	output <= Q;
	
	-- Input register behavior
	process(Clk) is begin
		if rising_edge(Clk) then
			if(Reset = '1') then
				Q <= x"00";
			else
				Q <= D;
			end if;
		end if;
	end process;
	
end Behavioral;
