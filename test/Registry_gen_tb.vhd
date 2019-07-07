----------------------------------------------------------------------------------
--| Author: Pablo Muñoz Galindo 
--|
--| Project Name:   VHDL Simple UART
--| Module Name:    Registry_gen_tb
--| Description:    VHDL Test Bench for generic registry
--|
--| Created:    	  13:12:00 07/07/2019
--| Tested using:   isim
--|
--| (c)2019 Pablo Muñoz
--| This code is licensed under MIT license (see LICENSE.md for details)
----------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY Registry_gen_tb IS
END Registry_gen_tb;
 
ARCHITECTURE behavior OF Registry_gen_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Registry_gen
    PORT(
         Clk : IN  std_logic;
         Reset : IN  std_logic;
         input : IN  std_logic_vector;
         output : OUT  std_logic_vector
        );
    END COMPONENT;
    

   --Inputs
   signal Clk : std_logic := '0';
   signal Reset : std_logic := '0';
   signal input : std_logic_vector(4 downto 0) := (others => '0');

 	--Outputs
   signal output : std_logic_vector(4 downto 0) := (others => '0');
	
	--Other signals
   signal next_addr : std_logic_vector(4 downto 0) := (others => '0');

   -- Clock period definitions
   constant Clk_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Registry_gen PORT MAP (
          Clk => Clk,
          Reset => Reset,
          input => input,
          output => output
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
		Reset <= '0';

      wait for Clk_period*10;
		wait for Clk_period*0.5;
		
		-- Test 1: counter implementation using 5 bit registry and combinational logic
      for i in 0 to 64 loop		
			next_addr <= std_logic_vector(unsigned(output)+1);			
			input <= next_addr;
			wait for Clk_period;
		end loop;

      wait;
   end process;

END;
