----------------------------------------------------------------------------------
--| Author: Pablo Muñoz Galindo 
--|
--| Project Name:   VHDL Simple UART
--| Module Name:    Edge_detector - Behavioral 
--| Description:    Edge detector
--|
--| Created:    	  12:57:00 07/07/2019
--| Tested using: 
--| Notes: initial version based in description found in 
--|          https://surf-vhdl.com/how-to-design-a-good-edge-detector/
--|
--| (c)2019 Pablo Muñoz
--| This code is licensed under MIT license (see LICENSE.md for details)
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;


entity Edge_detector is
    Port ( Signal_in : in  STD_LOGIC;
           Clk : in  STD_LOGIC;
           Reset : in  STD_LOGIC;
			  Clear : in STD_LOGIC;
           rise_edge : out  STD_LOGIC;
           fall_edge : out  STD_LOGIC);
end Edge_detector;

architecture Behavioral of Edge_detector is
			  
------------------------------------------------------------------------
-- Components for Edge detector
------------------------------------------------------------------------
component d_FF_asyncReset is
	 Port ( Clk : in  STD_LOGIC;	
		  Reset : in STD_LOGIC;
		  Reset_val : in STD_LOGIC;
		  D : in STD_LOGIC;
		  Q : out STD_LOGIC
		  );
end component;

component JK_FF_asyncReset is
	 Port ( J : in  STD_LOGIC;	
			  K : in STD_LOGIC;
			  Reset : in STD_LOGIC;
			  Clk : in STD_LOGIC;
			  Q : out STD_LOGIC;
			  Qn : out STD_LOGIC
			  );
end component;

------------------------------------------------------------------------
-- Internal signals
------------------------------------------------------------------------
signal t1_ff_D : std_logic := '0'; 
signal t1_ff_Q : std_logic := '0'; 
signal RE_ff_J : std_logic := '0';
signal RE_ff_K : std_logic := '0';
signal FE_ff_J : std_logic := '0'; 
signal FE_ff_K : std_logic := '0'; 

begin

-- Internal flip-flops
T0_FF : d_FF_asyncReset
	port map (
		Clk => Clk,
		Reset => Reset,
		Reset_val => '0',
		D => Signal_in,
		Q => t1_ff_D);
		
T1_FF : d_FF_asyncReset
	port map (
		Clk => Clk,
		Reset => Reset,
		Reset_val => '0',
		D => t1_ff_D,
		Q => t1_ff_Q);
		
RE_FF : JK_FF_asyncReset
	port map ( 
		J => RE_ff_J,
		K => RE_ff_K,
	   Reset => Reset,
	   Clk => Clk,
	   Q => rise_edge,
		Qn => open);

FE_FF : JK_FF_asyncReset
	port map ( 
		J => FE_ff_J,
		K => FE_ff_K,
	   Reset => Reset,
	   Clk => Clk,
	   Q => fall_edge,
		Qn => open);
			  

-- Combinational logic
RE_ff_J <= (t1_ff_D AND (NOT t1_ff_Q)) AND (NOT Clear);
RE_ff_K <= Clear;
FE_ff_J <= (t1_ff_Q AND (NOT t1_ff_D)) AND (NOT CLEAR);
FE_ff_K <= Clear;

end Behavioral;

