--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:06:01 07/08/2019
-- Design Name:   
-- Module Name:   E:/Desarrollo/Workspace_ISE/VHDL_UART/test/Edge_detector_tb.vhd
-- Project Name:  UART
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Edge_detector
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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY Edge_detector_tb IS
END Edge_detector_tb;
 
ARCHITECTURE behavior OF Edge_detector_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Edge_detector
    PORT(
         Signal_in : IN  std_logic;
         Clk : IN  std_logic;
         Reset : IN  std_logic;			
			Clear : in STD_LOGIC;
         rise_edge : OUT  std_logic;
         fall_edge : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal Signal_in : std_logic := '0';
   signal Clk : std_logic := '0';
   signal Reset : std_logic := '1';
	signal Clear : STD_LOGIC := '0';

 	--Outputs
   signal rise_edge : std_logic;
   signal fall_edge : std_logic;

   -- Clock period definitions
   constant Clk_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Edge_detector PORT MAP (
          Signal_in => Signal_in,
          Clk => Clk,
          Reset => Reset,
			 Clear => Clear,
          rise_edge => rise_edge,
          fall_edge => fall_edge
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
		
		Signal_in <= '1';
      wait for Clk_period*10;
		
		Clear<='1';
		wait for Clk_period;
		clear<='0';
		wait for Clk_period*11;
		
		Signal_in <= '0';
      wait for Clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
