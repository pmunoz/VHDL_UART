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
USE ieee.numeric_std.ALL;

LIBRARY work;
use work.txt_util.all;

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
			for i in payload'REVERSE_RANGE loop
				ser_out <= payload(i);			
				wait for bit_period_ns;	
			end loop;
			
			-- Stopbit
			ser_out <= '1';
			wait for bit_period_ns;
	end procedure;
	
	procedure test_checker(constant condition : in boolean; constant msg_ok , msg_fail : in string) is
	begin
		assert condition;
		if condition = true then
			report msg_ok severity note;
		else
			report msg_fail severity error;
		end if;
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
	variable test_data : std_logic_vector(7 downto 0) :=x"00";
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		
--		-- Empty data transfer with Reset = '1'
--		Reset <= '1';		
--		Gen_UART_Data_Transfer(baudrate_RX, "00000000", Serial_in);
		
		-- TEST 1: Data transfer with Reset = '0', "10101011"
		Reset <= '0';
		wait for 100 ns;		
		test_data := "10101011";
		Gen_UART_Data_Transfer(baudrate_RX, test_data, Serial_in);
		
		test_checker(
			Data_out=test_data,
			" >>>>>>>>>>>>>>>>>> [ Test 1 ==> OK!    ]: Gen: 0x" & hstr(test_data) & " , Rcv: 0x" & hstr(Data_out),
			" >>>>>>>>>>>>>>>>>> [ Test 1 ==> ERROR! ]: Gen: 0x" & hstr(test_data) & " , Rcv: 0x" & hstr(Data_out)
		);
		
		-- TEST 2: Data transfer with Reset = '0', "11111111"
		Reset <= '0';
		wait for 100 ns;		
		test_data := "11111111";
		Gen_UART_Data_Transfer(baudrate_RX, test_data, Serial_in);
		
		test_checker(
			Data_out=test_data,
			" >>>>>>>>>>>>>>>>>> [ Test 2 ==> OK!    ]: Gen: 0x" & hstr(test_data) & " , Rcv: 0x" & hstr(Data_out),
			" >>>>>>>>>>>>>>>>>> [ Test 2 ==> ERROR! ]: Gen: 0x" & hstr(test_data) & " , Rcv: 0x" & hstr(Data_out)
		);
		
		-- TEST 3: Data transfer with Reset = '0', "00000000"
		Reset <= '0';
		wait for 100 ns;		
		test_data := "00000000";
		Gen_UART_Data_Transfer(baudrate_RX, test_data, Serial_in);
		
		test_checker(
			Data_out=test_data,
			" >>>>>>>>>>>>>>>>>> [ Test 3 ==> OK!    ]: Gen: 0x" & hstr(test_data) & " , Rcv: 0x" & hstr(Data_out),
			" >>>>>>>>>>>>>>>>>> [ Test 3 ==> ERROR! ]: Gen: 0x" & hstr(test_data) & " , Rcv: 0x" & hstr(Data_out)
		);
		
		-- TEST 4: Data transfer with Reset = '1', "11111111"
		Reset <= '1';
		wait for 100 ns;		
		--test_data := "11111111";
		Gen_UART_Data_Transfer(baudrate_RX, "11111111", Serial_in);
		
		test_checker(
			Data_out=test_data,
			" >>>>>>>>>>>>>>>>>> [ Test 4 ==> OK!    ]: Gen: 0x" & hstr(test_data) & " , Rcv: 0x" & hstr(Data_out),
			" >>>>>>>>>>>>>>>>>> [ Test 4 ==> ERROR! ]: Gen: 0x" & hstr(test_data) & " , Rcv: 0x" & hstr(Data_out)
		);
		
		-- TEST 5: Data transfer with Reset = '0', "01010101"
		Reset <= '0';
		wait for 100 ns;		
		test_data := "01010101";
		Gen_UART_Data_Transfer(baudrate_RX, test_data, Serial_in);
		
		test_checker(
			Data_out=test_data,
			" >>>>>>>>>>>>>>>>>> [ Test 5 ==> OK!    ]: Gen: 0x" & hstr(test_data) & " , Rcv: 0x" & hstr(Data_out),
			" >>>>>>>>>>>>>>>>>> [ Test 5 ==> ERROR! ]: Gen: 0x" & hstr(test_data) & " , Rcv: 0x" & hstr(Data_out)
		);
		
      wait;
   end process;

END;
