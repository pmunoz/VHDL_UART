--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:10:05 07/10/2019
-- Design Name:   
-- Module Name:   E:/Desarrollo/Workspace_ISE/VHDL_UART/UART_Clk_Prescaler_tb.vhd
-- Project Name:  UART
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: UART_Clk_Prescaler
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
USE ieee.numeric_std.ALL;
 
ENTITY UART_Clk_Prescaler_tb IS
END UART_Clk_Prescaler_tb;
 
ARCHITECTURE behavior OF UART_Clk_Prescaler_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT UART_Clk_Prescaler
    PORT(
         Clk : IN  std_logic;
			Reset : IN std_logic;
         baudrate_selection : IN  std_logic_vector(3 downto 0);
         FSM_clk_multiplier : IN  unsigned(31 downto 0);
         Clk_PS : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal Clk : std_logic := '0';
   signal Reset : std_logic := '1';
   signal baudrate_selection : std_logic_vector(3 downto 0) := "0000";
   signal FSM_clk_multiplier : unsigned(31 downto 0) := x"00000010";

 	--Outputs
   signal Clk_PS : std_logic;

   -- Clock period definitions
   constant Clk_period : time := 20 ns;
	constant Expected_FSM_Clk_period : time := 105 us;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: UART_Clk_Prescaler PORT MAP (
          Clk => Clk,
			 Reset => Reset,
          baudrate_selection => baudrate_selection,
          FSM_clk_multiplier => FSM_clk_multiplier,
          Clk_PS => Clk_PS
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
      -- hold reset state for 10 Clk_period.
		Reset <= '1';
      wait for Clk_period*10;
		Reset <= '0';
		
		-- Test 1 : Clk_multiplier = 1
		Reset <= '1';		
      wait for Clk_period*2;
		baudrate_selection <= "0001";
		FSM_clk_multiplier <= x"00000001";
		Reset <= '0';	
		wait for Expected_FSM_Clk_period*4;
		
		-- hold reset state for 10 Clk_period.
		Reset <= '1';		
      wait for Clk_period*2;
		baudrate_selection <= "0001";
		FSM_clk_multiplier <= x"00000010";
		Reset <= '0';	
		wait for Expected_FSM_Clk_period*4;
		
		-- insert stimulus here 
      wait;
   end process;

END;
