--***********************************************
--* TITLE: Transmitter TESTBENCH (transmitter) 	*
--* TYPE: Top File				*
--* AUTHOR: Dylan Van Assche 			*
--* DATE: 25/10/2017 				*
--***********************************************
--***************
--* DESCRIPTION *
--***************
--1)Purpose:
-- TESTBENCH: Connect all the layers into 1 VHDL file.
--2)Principle:
-- Connect every layer API.
--3)Inputs:
-- up, down, pn_select, rst, clk, clk_en
--4)Outputs:
-- tx
--**********************
--* LIBRARIES & ENTITY *
--**********************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;
ENTITY transmitter_test IS
END transmitter_test;
--*********************************************
--* ARCHITECTURE, SIGNALS, TYPES & COMPONENTS *
--*********************************************
ARCHITECTURE structural OF transmitter_test IS
	--initialize signals & constants
	CONSTANT PERIOD   : TIME := 100 ns;
	CONSTANT DELAy    : TIME := 10 ns;
	SIGNAL end_of_sim : BOOLEAN := false;
	SIGNAL clk        : std_logic := '0';
	SIGNAL rst        : std_logic := '0';
	SIGNAL up         : std_logic := '0';
	SIGNAL down       : std_logic := '0';
	SIGNAL tx	  : std_logic := '0';
	SIGNAL pn_select  : std_logic_vector(1 DOWNTO 0) := "00";
	SIGNAL display_b  : std_logic_vector(6 DOWNTO 0) := "1111111";
BEGIN
--***********
--* MAPPING *
--***********
uut : ENTITY work.transmitter(behavior)
	PORT MAP
	(
		clk       => clk,
		rst       => rst,
		up        => up,
		down      => down,
		pn_select => pn_select,
		display_b => display_b,
		tx        => tx
	);
-- Only for synchronous components
clock : PROCESS
BEGIN
	clk <= '0';
	WAIT FOR PERIOD/2;
	LOOP
		clk <= '0';
		WAIT FOR PERIOD/2;
		clk <= '1';
		WAIT FOR PERIOD/2;
		EXIT WHEN end_of_sim;
	END LOOP;
	WAIT;
	END PROCESS clock;
-- Testbench
tb : PROCESS
	-- Reset procedure to initialize the component
	PROCEDURE reset IS
	BEGIN
		rst <= '1';
		WAIT FOR PERIOD * 2;
		rst <= '0';
		WAIT FOR PERIOD;
	END reset;
	-- Test data procedure
	PROCEDURE test (CONSTANT testdata : IN std_logic_vector(1 DOWNTO 0)) IS
	BEGIN
		up   <= testdata(0);
		down <= testdata(1);
		WAIT FOR PERIOD*100; -- fool the debouncer
	END test;
BEGIN
	-- Reset at startup
	reset;
	-- Test data
	-- test("00"); -- needed to fool the edge detector
	FOR mux_state IN 0 TO 3 LOOP
		pn_select <= CONV_STD_LOGIC_VECTOR(mux_state, 2); -- loop through all MUX states
		test("01"); -- up=1, down=0
		test("00"); -- nothing
		test("11"); -- nothing
		test("00"); -- nothing
		test("10"); -- up=0, down=1
		test("00");
	END LOOP;
	end_of_sim <= true;
	WAIT;
END PROCESS;
END;