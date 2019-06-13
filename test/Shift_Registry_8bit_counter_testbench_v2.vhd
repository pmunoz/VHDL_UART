----------------------------------------------------------------------------------
--| Author: Pablo Muñoz Galindo 
--|
--| Project Name:   VHDL Simple UART
--| Module Name:    Shift_Registry_8bit_counter_tb_v2
--| Description:    VHDL Test Bench for Shift_Registry_8bit_counter
--|
--| Created:    	  09:48:25 05/24/2019
--| Tested using:   isim
--|
--| (c)2019 Pablo Muñoz
--| This code is licensed under MIT license (see LICENSE.md for details)
----------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY Shift_Registry_8bit_counter_testbench_v2 IS
END Shift_Registry_8bit_counter_testbench_v2;
 
ARCHITECTURE behavior OF Shift_Registry_8bit_counter_testbench_v2 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Shift_Registry_8bit_counter
    PORT(
         Clk : IN  std_logic;
         CLR : IN  std_logic;
         Hold : IN  std_logic;
         Ser_in : IN  std_logic;
         Carry_out : OUT  std_logic;
         Par_out : OUT  std_logic_vector(7 downto 0);
         Counter_out : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal Clk : std_logic := '0';
   signal CLR : std_logic := '1';
   signal Hold : std_logic := '1';
   signal Ser_in : std_logic := '0';

 	--Outputs
   signal Carry_out : std_logic;
   signal Par_out : std_logic_vector(7 downto 0);
   signal Counter_out : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant Clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Shift_Registry_8bit_counter PORT MAP (
          Clk => Clk,
          CLR => CLR,
          Hold => Hold,
          Ser_in => Ser_in,
          Carry_out => Carry_out,
          Par_out => Par_out,
          Counter_out => Counter_out
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
		variable tmp_bit_val : std_logic := '0';
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for Clk_period*8;

		-- TEST 1: Fill registry with 1 and update value at the end of each SR_Clk pulse(expected 00000000 to 11111111)
		CLR <= '0';
		Hold <= '0';
		Ser_in <= '1';
		wait for Clk_period*8;
		Hold <= '1';		
		wait for Clk_period*4;
		
		-- TEST 2: Fill registry with alternating 0-1 and update value at the end of each SR_Clk pulse(expected 00000000 to 11111111)
		CLR <= '1';		
		Hold <= '0';
		wait for Clk_period*1;
		Ser_in <= '1';
		CLR <= '0';
		for item in 1 to 8 loop		
			tmp_bit_val := not tmp_bit_val;			
			Ser_in <= tmp_bit_val;
			wait for Clk_period*1;
		end loop;			
		Hold <= '1';		
		wait for Clk_period*4;
		
		-- TEST 3: Clear output registry and wait for 8 Clk pulses, then update value at the output;
		CLR <= '1';		
		Hold <= '1';
		wait for Clk_period*8;
		
		-- TEST 4: Capture a byte in the shift_registry
		CLR <= '1';		
		Hold <= Counter_out(3);
		Ser_in <= '1';
		wait for Clk_period*1;
		CLR <= '0';
		for item in 1 to 20 loop
			Hold <= Counter_out(3);		
			wait for Clk_period*1;
		end loop;		
		wait;
      
		
   end process;

END;
