----------------------------------------------------------------------------------
--| Author: Pablo Muñoz Galindo 
--|
--| Project Name:   VHDL Simple UART
--| Module Name:    Shift_Registry_8bit_counter_tb
--| Description:    VHDL Test Bench Shift_Registry_8bit_counter
--|
--| Created:    	  18:08:40 05/23/2019
--| Tested using:   isim
--|
--| (c)2019 Pablo Muñoz
--| This code is licensed under MIT license (see LICENSE.md for details)
----------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY Shift_Registry_8bit_counter_testbench IS
END Shift_Registry_8bit_counter_testbench;
 
ARCHITECTURE behavior OF Shift_Registry_8bit_counter_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Shift_Registry_8bit_counter
    PORT(
         OE : IN  std_logic;
         R_Clk : IN  std_logic;
         SR_Clk : IN  std_logic;
         SR_CLR : IN  std_logic;
         Ser_in : IN  std_logic;
         Carry_out : OUT  std_logic;
         Par_out : OUT  std_logic_vector(7 downto 0);
         Counter : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal OE : std_logic := '0';
   signal R_Clk : std_logic := '0';
   signal SR_Clk : std_logic := '0';
   signal SR_CLR : std_logic := '1';
   signal Ser_in : std_logic := '0';

 	--Outputs
   signal Carry_out : std_logic;
   signal Par_out : std_logic_vector(7 downto 0);
   signal Counter : std_logic_vector(7 downto 0);

   -- Clock period definitions
   --constant R_Clk_period : time := 10 ns;
   constant SR_Clk_period : time := 10 ns;
	
	procedure Gen_Clk_Pulse_Train(constant Clk_period : in time;
												constant n_pulses : in integer;
												signal Clk_output : out std_logic
												) is
	begin
			for item in 1 to n_pulses loop
				Clk_output <= '0';			
				wait for Clk_period/2;
				Clk_output <= '1';		
				wait for Clk_period/2;	
			end loop;
	end procedure;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Shift_Registry_8bit_counter PORT MAP (
          OE => OE,
          R_Clk => R_Clk,
          SR_Clk => SR_Clk,
          SR_CLR => SR_CLR,
          Ser_in => Ser_in,
          Carry_out => Carry_out,
          Par_out => Par_out,
          Counter => Counter
        );

   -- Clock process definitions
   --R_Clk_process :process
   --begin
	--	R_Clk <= '0';
	--	wait for R_Clk_period/2;
	--	R_Clk <= '1';
	--	wait for R_Clk_period/2;
   --end process;
 
   SR_Clk_process :process
   begin
	   SR_Clk <= '0';
		wait for SR_Clk_period/2;
		SR_Clk <= '1';
		wait for SR_Clk_period/2;
   end process;
 

    -- Stimulus process
   stim_proc: process	
		variable tmp_bit_val : std_logic := '1';
   begin			
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for SR_Clk_period*8;

		-- TEST 1: activate output with no extra stimulus (expected ZZZZZZZZ to 00000000)
		OE <= '1';
		wait for SR_Clk_period*8;
		
		-- TEST 2: Fill registry with 1 and update value at the end of each SR_Clk pulse(expected 00000000 to 11111111)
		OE <= '1';
		SR_CLR <= '0';
		Ser_in <= '1';
		Gen_Clk_Pulse_Train(SR_Clk_period, 8, R_Clk);
		
		-- TEST 3: Fill registry with alternating 0-1 and update value at the end of each SR_Clk pulse(expected 00000000 to 11111111)
		OE <= '1';		
		SR_CLR <= '1';
		Gen_Clk_Pulse_Train(SR_Clk_period, 1, R_Clk);
		SR_CLR <= '0';
		for item in 1 to 8 loop		
			tmp_bit_val := not tmp_bit_val;			
			Ser_in <= tmp_bit_val;
			Gen_Clk_Pulse_Train(SR_Clk_period, 1, R_Clk);
		end loop;
		
		
		-- TEST 4: Clear output registry and wait for 8 Clk pulses, then update value at the output;
		OE <= '1';	
		SR_CLR <= '1';
		Gen_Clk_Pulse_Train(SR_Clk_period, 1, R_Clk);
		SR_CLR <= '0';
		wait for SR_Clk_period*8;
		Gen_Clk_Pulse_Train(SR_Clk_period, 1, R_Clk);		
		wait for SR_Clk_period*8;
		
		-- TEST 5: Leave output in high impedance and wait for 8 Clk pulses
		OE <= '0';	
		SR_CLR <= '1';
		Gen_Clk_Pulse_Train(SR_Clk_period, 1, R_Clk);
		SR_CLR <= '0';
		wait for SR_Clk_period*8;		
		wait;
		
		
   end process;

END;
