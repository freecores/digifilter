------------------------------------------------------------------------------------------------------
-- filename: tb_firtrigger.vhd
-- author: martin lauer, mlauer@opencores.org
-- description: test bench code
-- created: 19.05.2004
--
-- Copyright (C) 2004 Martin Lauer
--
-- This source file may be used and distributed without 
-- restriction provided that this copyright statement is not
-- removed from the file and that any derivative work contains
-- the original copyright notice and the associated disclaimer.
-- 
-- This source file is free software; you can redistribute it
-- and/or modify it under the terms of the GNU Lesser General
-- Public License as published by the Free Software Foundation;
-- either version 2.1 of the License, or (at your option) any
-- later version.
--
-- This source is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE. See the GNU Lesser General Public License for more
-- details.
-- 
-- You should have received a copy of the GNU Lesser General
-- Public License along with this source; if not, download it
-- from http://www.opencores.org/lgpl.shtml 
--
--
-- To Do:
--
--	
-- history:
-------------------------------------------------------------------------------------------------------
-- Version  |  Author |  Date   |  changes    					| 
-------------------------------------------------------------------------------------------------------
-- 1.0      |mlauer   |19.05.04 | 	created				      |              
-------------------------------------------------------------------------------------------------------
-- 	      |		    |		     | 									|
-------------------------------------------------------------------------------------------------------

LIBRARY  IEEE,  WORK;
use WORK.my_pack.all;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

LIBRARY  UNISIM;
USE UNISIM.VComponents.all;

LIBRARY ieee;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE STD.TEXTIO.ALL;

ENTITY testbench_firtrigger IS
END testbench_firtrigger;

ARCHITECTURE testbench_arch  OF testbench_firtrigger IS 
	FILE in_file: text is in "C:\OC_Project\data\waveforms\event_1.dat";
	FILE out_file: text is out "C:\OC_Project\data\waveforms\energy_mwd.dat";
		
Component fir_trigger is
-- use GENERIC if doing functional simulation -- 
--Generic(width: Integer:=14);
Port ( 	adc 		: in std_logic_vector(13 downto 0);
			thresh 	: in std_logic_vector(Word-1 downto 0);			-- threshold
        	diff 		: in std_logic_vector(Nibble-1 downto 0);			-- differentiation time
        	int 		: in std_logic_vector(Nibble-1 downto 0);			-- integration time
			tot		: in std_logic_vector(Nibble-1 downto 0);			-- time-over-threshold
			trigger	: out std_logic;											-- short trigger signal
        	enable 	: in std_logic;
        	reset 	: in std_logic;
        	clk 		: in std_logic);
end Component;

SIGNAL 	adc 		: std_logic_vector(ADCw-1 downto 0);
SIGNAL 	thresh 	: std_logic_vector(Word-1 downto 0);			-- threshold
SIGNAL 	diff 		: std_logic_vector(Nibble-1 downto 0);			-- differentiation time
SIGNAL  	int 		: std_logic_vector(Nibble-1 downto 0);			-- integration time
SIGNAL	tot		: std_logic_vector(Nibble-1 downto 0);			-- time-over-threshold
SIGNAL	trigger	: std_logic;											-- short trigger signal
SIGNAL  	enable 	: std_logic;
SIGNAL  	reset 	: std_logic;
SIGNAL   clk 		: std_logic;			 
			
BEGIN	
							  	
uut : fir_trigger
-- use GENERIC if doing functional simulation -- 
--Generic Map(width => ADCw)
Port Map(adc 		=> adc,
     		thresh 	=> thresh,							-- threshold
         diff 		=> diff,								-- differentiation time
        	int 		=> int,								-- integration time
			tot		=> tot,								-- time-over-threshold
			trigger	=> trigger,							-- short trigger signal
        	enable 	=> enable,
        	reset 	=> reset,
        	clk 		=> clk);

PROCESS -- clock process for clk
BEGIN
	CLOCK_LOOP : LOOP
		clk <= transport '0';
		WAIT FOR 1 ns;
		clk <= transport '1';
		WAIT FOR 6 ns;
		clk <= transport '0';
		WAIT FOR 5 ns;
	END LOOP CLOCK_LOOP;
END PROCESS;



-- testbench process
tb : PROCESS
 Variable line_in: line;
 Variable line_out: line;
 Variable trace: integer;
 Variable armed: integer;
 Variable counter: integer;

BEGIN
	armed:=1;
	adc <= (others =>'0');

	thresh <= "0000000010000000";
  	diff <= "1000"; 	
  	int <= "0100";
	tot <= "0100";

-- read file header
   readline(in_file, line_in);
	readline(in_file, line_in);
	readline(in_file, line_in);
	readline(in_file, line_in);
	
	reset<='1';
	WAIT for 12 ns;
	reset <= '0';
	WAIT for 48 ns;
	enable <= '1';
	WAIT for 12 ns;


-- read waveform data from file
	while(endfile(in_file)=false) loop
		readline(in_file, line_in);
		read(line_in, trace);
		if(counter=2000) then
			armed:=0;
		end if;

--	TEST the trapezoidal shaper
-- a) load file data into input vector
		adc <= to_stdlogicvector(trace, 14);

-- b) apply a step signal
--	if(armed = 1) then
--		ADC1 <= to_stdlogicvector(10, 14);
--else
--		ADC1 <= to_stdlogicvector(500, 14);
--end if;

-- c) apply a ramp signal
--	if(armed = 1) then
--		ADC1 <= (others => '0');
--	else
--		ADC1 <=	to_stdlogicvector((1000-counter/4), 14);
--	end if;

		counter:=counter+1;

		WAIT for 12 ns;
	end loop;
	WAIT;
END PROCESS;

END testbench_arch ;

CONFIGURATION trig_cfg OF testbench_firtrigger IS
	FOR testbench_arch
		for all: fir_trigger use entity WORK.fir_trigger;
		end for;
	END FOR;
END trig_cfg;
