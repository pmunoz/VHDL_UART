----------------------------------------------------------------------------------
--| Author: Pablo Muñoz Galindo 
--|
--| Project Name:   VHDL Simple UART
--| Module Name:    Counter_bidir_tb
--| Description:    VHDL Test Bench for generic & bi-directional counter
--|
--| Created:    	  13:00:00 07/07/2019
--| Tested using:   isim
--|
--| (c)2019 Pablo Muñoz
--| This code is licensed under MIT license (see LICENSE.md for details)
----------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY Counter_bidir_tb IS
END Counter_bidir_tb;
 
ARCHITECTURE behavior OF Counter_bidir_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Counter_bidir
    PORT(
         Reset : IN  std_logic;
         Clk : IN  std_logic;
         dir : IN  std_logic;
         Count : OUT  unsigned
        );
    END COMPONENT;
    

   --Inputs
   signal Reset : std_logic := '1';
   signal Clk : std_logic := '0';
   signal dir : std_logic := '1';

 	--Outputs
   signal Count : unsigned(4 downto 0);

   -- Clock period definitions
   constant Clk_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Counter_bidir PORT MAP (
          Reset => Reset,
          Clk => Clk,
          dir => dir,
          Count => Count
        );

   -- Clock process definitions
   Clk_process :process
   begin
		Clk <= '0';
		wait for Clk_period/2;
		Clk <= '1';
		wait for Clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for Clk_period*10;

      -- insert stimulus here 
		Reset <= '0';
		wait for Clk_period*32;
		
		dir <= '0';
		wait for Clk_period*32;
		

      wait;
   end process;

END;
