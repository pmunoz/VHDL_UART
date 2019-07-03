----------------------------------------------------------------------------------
--| Author: Pablo Muñoz Galindo 
--|
--| Project Name:   VHDL Simple UART
--| Module Name:    UART_TX_tb
--| Description:    VHDL Test Bench for module UART_TX
--|
--| Created:    	  10:20:00 02/07/2019
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

ENTITY UART_TX_tb IS
END UART_TX_tb;
 
ARCHITECTURE behavior OF UART_TX_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT UART_TX
    PORT(
         Clk : in  STD_LOGIC;	
		   Reset : in STD_LOGIC;
		   Write_en : in STD_LOGIC;
		   Data_in : in STD_LOGIC_VECTOR(7 downto 0);
		   Serial_out : out STD_LOGIC;			
		   Busy : out STD_LOGIC
        );
    END COMPONENT;
    

   -- Inputs
   signal Clk : std_logic := '0';
   signal Reset : std_logic := '1';
   signal Write_en : std_logic := '0';	
   signal Data_in: STD_LOGIC_VECTOR(7 downto 0) := (others=>'0');	

 	-- Outputs
   signal Serial_out : std_logic := '1';	
   signal Busy : std_logic := '1';
	
	-- Test signals
	signal sampled_data : std_logic_vector(7 downto 0):=x"00";
	signal sampled_start_bit : std_logic:='1';
	signal sampled_stop_bit : std_logic:='0';
	

   -- Clock period definitions
   constant Clk_period : time := 20 ns;
	
	-- Procedures
	procedure Sample_UART_Data_Transfer(constant baudrate : in integer;
												signal TX_line : in std_logic;
												signal start_bit : out std_logic;
												signal sampled_value : out std_logic_vector(7 downto 0);
												signal stop_bit : out std_logic										
												) is
	variable bit_period_ns  : time;
	variable clk_fsm_period_ns  : time;
	constant clk_mult : integer := 16;
	begin
			-- period calculation in ns
			bit_period_ns := (1e9/baudrate)*1ns;
			clk_fsm_period_ns := (bit_period_ns/clk_mult);
			
			-- Startbit
			wait for bit_period_ns/2;
			start_bit <= TX_line;
						
			-- Data			
			for i in sampled_value'REVERSE_RANGE loop
				wait for bit_period_ns;
				sampled_value(i) <= TX_line;
			end loop;
			
			-- Stopbit
			wait for bit_period_ns;
			stop_bit <= TX_line;						
			wait for bit_period_ns/2;
			
			-- If FSM is still busy due to bit period mismatch then we wait until machine is back to standby
			if Busy='1' then
				wait until Busy='0';
			end if;
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
	uut: UART_TX PORT MAP (	
			Clk => Clk,
			Reset => Reset,
			Write_en => Write_en,
			Data_in => Data_in,
			Serial_out => Serial_out,
			Busy => Busy
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
		constant baudrate_TX : integer := 9600;	
		variable test_data : std_logic_vector(7 downto 0) :=x"00";
		
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;			
		Reset <= '0';
		
		-- TEST 1: Transmit word "11111111"
		test_data := x"FF";
		Write_en <= '1';
		Data_in <= test_data;
		Sample_UART_Data_Transfer(baudrate_TX, Serial_out, sampled_start_bit, sampled_data, sampled_stop_bit);
		test_checker(
			sampled_start_bit='0' AND sampled_data=test_data AND sampled_stop_bit = '1',
			" >>>>>>>>>>>>>>>>>> [ Test 1 ==> OK!    ]: Gen: 0x" & hstr(test_data) & " , Tx: 0x" & hstr(sampled_data) 
			& " , Start bit: " & str(sampled_start_bit) & " , Stop bit: " & str(sampled_stop_bit),
			" >>>>>>>>>>>>>>>>>> [ Test 1 ==> Error!    ]: Gen: 0x" & hstr(test_data) & " , Tx: 0x" & hstr(sampled_data) 
			& " , Start bit: " & str(sampled_start_bit) & " , Stop bit: " & str(sampled_stop_bit)
		);
		Write_en <= '0'; wait for 100 ns; 
		
		-- TEST 2: Wait one TX period without TX
		test_data := x"FF";
		Data_in <= x"CC";
		
		Sample_UART_Data_Transfer(baudrate_TX, Serial_out, sampled_start_bit, sampled_data, sampled_stop_bit);
		test_checker(
			sampled_start_bit='1' AND sampled_data=test_data AND sampled_stop_bit = '1',
			" >>>>>>>>>>>>>>>>>> [ Test 2 ==> OK!    ]: Gen: 0x" & hstr(test_data) & " , Tx: 0x" & hstr(sampled_data) 
			& " , Start bit: " & str(sampled_start_bit) & " , Stop bit: " & str(sampled_stop_bit),
			" >>>>>>>>>>>>>>>>>> [ Test 2 ==> Error!    ]: Gen: 0x" & hstr(test_data) & " , Tx: 0x" & hstr(sampled_data) 
			& " , Start bit: " & str(sampled_start_bit) & " , Stop bit: " & str(sampled_stop_bit)
		);
		
		-- TEST 3: Transmit word "10101010"
		test_data := x"AA";
		Write_en <= '1';
		Data_in <= test_data;
		Sample_UART_Data_Transfer(baudrate_TX, Serial_out, sampled_start_bit, sampled_data, sampled_stop_bit);
		test_checker(
			sampled_start_bit='0' AND sampled_data=test_data AND sampled_stop_bit = '1',
			" >>>>>>>>>>>>>>>>>> [ Test 3 ==> OK!    ]: Gen: 0x" & hstr(test_data) & " , Tx: 0x" & hstr(sampled_data) 
			& " , Start bit: " & str(sampled_start_bit) & " , Stop bit: " & str(sampled_stop_bit),
			" >>>>>>>>>>>>>>>>>> [ Test 3 ==> Error!    ]: Gen: 0x" & hstr(test_data) & " , Tx: 0x" & hstr(sampled_data) 
			& " , Start bit: " & str(sampled_start_bit) & " , Stop bit: " & str(sampled_stop_bit)
		);
		Write_en <= '0'; wait for 100 ns;
		
		-- TEST 4: Transmit word "11001100"
		test_data := x"CC";
		Write_en <= '1';
		Data_in <= test_data;
		Sample_UART_Data_Transfer(baudrate_TX, Serial_out, sampled_start_bit, sampled_data, sampled_stop_bit);
		test_checker(
			sampled_start_bit='0' AND sampled_data=test_data AND sampled_stop_bit = '1',
			" >>>>>>>>>>>>>>>>>> [ Test 4 ==> OK!    ]: Gen: 0x" & hstr(test_data) & " , Tx: 0x" & hstr(sampled_data) 
			& " , Start bit: " & str(sampled_start_bit) & " , Stop bit: " & str(sampled_stop_bit),
			" >>>>>>>>>>>>>>>>>> [ Test 4 ==> Error!    ]: Gen: 0x" & hstr(test_data) & " , Tx: 0x" & hstr(sampled_data) 
			& " , Start bit: " & str(sampled_start_bit) & " , Stop bit: " & str(sampled_stop_bit)
		);
		Write_en <= '0'; wait for 100 ns;
		
      wait;
   end process;

END;
