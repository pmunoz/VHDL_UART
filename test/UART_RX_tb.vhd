----------------------------------------------------------------------------------
--| Author: Pablo Muñoz Galindo 
--|
--| Project Name:   VHDL Simple UART
--| Module Name:    UART_RX_tb
--| Description:    VHDL Test Bench for module UART_RX
--|
--| Created:    	  11:02:29 06/13/2019
--| Tested using:   isim
--|
--| (c)2019 Pablo Muñoz
--| This code is licensed under MIT license (see LICENSE.md for details)
----------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY UART_RX_tb IS
END UART_RX_tb;
 
ARCHITECTURE behavior OF UART_RX_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT UART_RX
    PORT(
         Clk : IN  std_logic;
         Reset : IN  std_logic;
         Serial_in : IN  std_logic;
         Data_out : OUT  std_logic_vector(7 downto 0);
         Correct_rx : OUT  std_logic
        );
    END COMPONENT;
    

   -- Inputs
   signal Clk : std_logic := '0';
   signal Reset : std_logic := '1';
   signal Serial_in : std_logic := '1';

 	-- Outputs
   signal Data_out : std_logic_vector(7 downto 0);
   signal Correct_rx : std_logic;

   -- Clock period definitions
   constant Clk_period : time := 20 ns;
	
	-- Procedures
	procedure Gen_UART_Data_Transfer(constant baudrate : in integer;
												constant payload : in std_logic_vector (7 downto 0);
												signal ser_out : out std_logic
												) is
	variable bit_period_ns  : time;
	begin
			-- period calculation in ns
			bit_period_ns := (1e9/baudrate)*1ns;
			
			-- Startbit
			ser_out <= '0';
			wait for bit_period_ns;
			
			-- Data			
			for i in payload'RANGE loop
				ser_out <= payload(i);			
				wait for bit_period_ns;	
			end loop;
			
			-- Stopbit
			ser_out <= '1';
			wait for bit_period_ns;
	end procedure;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: UART_RX PORT MAP (
          Clk => Clk,
          Reset => Reset,
          Serial_in => Serial_in,
          Data_out => Data_out,
          Correct_rx => Correct_rx
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
	constant baudrate_RX : integer := 9600;
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		
		-- Empty data transfer with Reset = '1'
		Reset <= '1';		
		Gen_UART_Data_Transfer(baudrate_RX, "00000000", Serial_in);
		
		-- Data transfer with Reset = '0'
		Reset <= '0';
		wait for 100 ns;		
		Gen_UART_Data_Transfer(baudrate_RX, "10101011", Serial_in);
		
      wait;
   end process;

END;
