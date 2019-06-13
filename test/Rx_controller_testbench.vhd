--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:00:24 05/30/2019
-- Design Name:   
-- Module Name:   E:/Desarrollo/Workspace_ISE/VHDL_UART/test/Rx_controller_testbench.vhd
-- Project Name:  UART
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Rx_controller
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY Rx_controller_testbench IS
END Rx_controller_testbench;
 
ARCHITECTURE behavior OF Rx_controller_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Rx_controller
    PORT(
         Clk : IN  std_logic;
         Clk_TEST : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal Clk : std_logic := '0';

 	--Outputs
   signal Clk_TEST : std_logic;

   -- Clock period definitions
   constant Clk_period : time := 10 ns;
--   constant Clk_TEST_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Rx_controller PORT MAP (
          Clk => Clk,
          Clk_TEST => Clk_TEST
        );

   -- Clock process definitions
   Clk_process :process
   begin
		Clk <= '0';
		wait for Clk_period/2;
		Clk <= '1';
		wait for Clk_period/2;
   end process;
 
--   Clk_TEST_process :process
--   begin
--		Clk_TEST <= '0';
--		wait for Clk_TEST_period/2;
--		Clk_TEST <= '1';
--		wait for Clk_TEST_period/2;
--   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for Clk_period*100000;

      -- insert stimulus here 

      wait;
   end process;

END;
