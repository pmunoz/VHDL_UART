----------------------------------------------------------------------------------
--| Author: Pablo Mu�oz Galindo 
--|
--| Project Name:   VHDL Simple UART
--| Module Name:    Shift-Registry_8bit_counter - Behavioral
--| Description:    Shift registry to do serial/parallel conversion (includes 
--| 					  bit counter)
--|
--| Created:    	  09:08:58 05/22/2019
--| Tested using: 
--|
--| (c)2019 Pablo Mu�oz
--| This code is licensed under MIT license (see LICENSE.md for details)
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Shift_Registry_8bit_counter is
    Port ( Clk : in  STD_LOGIC;
           CLR : in  STD_LOGIC;
			  Hold : in STD_LOGIC;
           Ser_in : in  STD_LOGIC;
			  Carry_out : out STD_LOGIC;
           Par_out : out  STD_LOGIC_VECTOR (7 downto 0);
			  Counter_out : out STD_LOGIC_VECTOR (7 downto 0)
	 );
end Shift_Registry_8bit_counter;

architecture Behavioral of Shift_Registry_8bit_counter is
	signal tmp_reg : STD_LOGIC_VECTOR (7 downto 0) := "00000000";
	signal tmp_counter : STD_LOGIC_VECTOR (7 downto 0) := "00000000";
	signal tmp_Carry : STD_LOGIC := '0';

begin	

	-- Shift register behavior
	process(Clk, CLR, Hold) is begin
		if CLR = '1' then
			tmp_reg <= (others => '0');			
			tmp_counter <= (others => '0');			
			tmp_Carry <= '0';
		elsif rising_edge(Clk) then
			if Hold = '0' then
				tmp_Carry <= tmp_reg(0);
				tmp_reg <= std_logic_vector(shift_right(unsigned(tmp_reg),1));
				tmp_reg(7) <= Ser_in;
				tmp_counter <= std_logic_vector(unsigned(tmp_counter)+1);		  
			end if;
		end if; 
	end process;
		
	Carry_out <= tmp_Carry;
	Par_out <= tmp_reg;
	Counter_out <= tmp_counter;
	
end Behavioral;

