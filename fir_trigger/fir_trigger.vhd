------------------------------------------------------------------------------------------------------
-- filename: fir_trigger.vhd
-- author: martin lauer, mlauer@opencores.org
-- description: simple FIR shaping using SRL, threshold and time-over-threshold  
-- created: 19.05.2004
-- 
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
--	SRL max. delay = 16 => 400 ns @ 40 MHz
--
--
-- Number of Slices:                      68  out of   3072     2%  
-- Number of Slice Flip Flops:            58  out of   6144     0%  
-- Number of 4 input LUTs:               102  out of   6144     1% 
-- history:
-------------------------------------------------------------------------------------------------------
-- Version  |  Author |  Date   |  changes    		| 
-------------------------------------------------------------------------------------------------------
-- 1.0      |  mlauer | 19.05.04| created				|                
-------------------------------------------------------------------------------------------------------
-- 	      |     	 | 		  |     					|
-------------------------------------------------------------------------------------------------------

library IEEE, WORK;
use WORK.my_pack.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity fir_trigger is
	 Generic(width: Integer:=14);
    Port ( adc 		: in std_logic_vector(width-1 downto 0);
           thresh 	: in std_logic_vector(Word-1 downto 0);			-- threshold
           diff 		: in std_logic_vector(Nibble-1 downto 0);			-- differentiation time
           int 		: in std_logic_vector(Nibble-1 downto 0);			-- integration time
			  tot			: in std_logic_vector(Nibble-1 downto 0);			-- time-over-threshold
			  trigger	: out std_logic;											-- short trigger signal
           enable 	: in std_logic;
           reset 		: in std_logic;
           clk 		: in std_logic);
end fir_trigger;

architecture Behavioral of fir_trigger is

component myBigSRL is
Generic(width: Integer:= 16; delay: Integer:=16; widthA: Integer:=4);
port(	CLK : in std_logic;
		DATA : in std_logic_vector(width-1 downto 0);
		CE : in std_logic;
		A : in std_logic_vector(widthA-1 downto 0);
		Q : out std_logic_vector(width-1 downto 0));
end component;

component mySRL is
Generic(delay: Integer:=16; widthA: Integer:=4);
port(CLK : in std_logic;
	DATA : in std_logic;
	CE : in std_logic;
	A : in std_logic_vector(widthA-1 downto 0);
	Q : out std_logic);
end component;

component sub is
    Generic(width: Integer:=16);
    Port ( A 		: in std_logic_vector(width-1 downto 0);
           B 		: in std_logic_vector(width-1 downto 0);
			  clk		: in std_logic;
			  enable	: in std_logic;
			  reset	: in std_logic;
			  signed	: in std_logic;
           DIFF 	: out std_logic_vector(width-1 downto 0);
           CarryOut : out std_logic);
end component;

component add_signed is
    Generic(width: Integer:=16);
    Port ( A 			: in std_logic_vector(width-1 downto 0);
           B 			: in std_logic_vector(width-1 downto 0);
			  clk			: in std_logic;
			  enable 	: in std_logic;
			  reset 		: in std_logic;
			  signed 	: in std_logic;
           CarryIn 	: in std_logic;
           SUM 		: out std_logic_vector(width-1 downto 0);
           CarryOut 	: out std_logic);
end component;

component trigdb
Generic(width: IN positive:=16);
Port (D_IN	: in STD_LOGIC;
      RESET	: in STD_LOGIC;
      CLK	: in STD_LOGIC;
      Q_OUT	: out STD_LOGIC_VECTOR(width-1 downto 0));
end component;

signal adc_delayed					: std_logic_vector(width-1 downto 0);
signal diffo, diffo_delayed		: std_logic_vector(width downto 0);
signal accudiff						: std_logic_vector(width+1 downto 0);
signal big_accudiff					: std_logic_vector(Word-1 downto 0);
signal addo								: std_logic_vector(Word downto 0);
signal mytrigger, pre_trigger		: std_logic;
signal q									: std_logic_vector(Word-1 downto 0);
signal q_sel							: std_logic;
signal db1, db2, db3					: std_logic;
signal reset_del, accu_res			: std_logic;


begin

--****************************************************************************
--********* ACCUMULATOR NEEDS LATE RESET (AFTER FILTER FLUSHED) **************
--****************************************************************************
delres1: mySRL
Generic Map(delay => 16, widthA => 4)
Port Map(CLK  => clk,
			DATA  =>	reset,
			CE  => '1',
			A  =>	"1111",
			Q  => reset_del);

delres2: mySRL
Generic Map(delay => 16, widthA => 4)
Port Map(CLK  => clk,
			DATA  =>	reset_del,
			CE  => '1',
			A  =>	"1111",
			Q  => accu_res);


--****************************************************************************
--***************** DIFFERENTIATION -  REMOVES OFFSET ************************
--****************************************************************************

diffdelay: myBigSRL
Generic Map(width => width, delay => Word, widthA => Nibble)
Port Map(CLK => clk,
			DATA => adc,
			CE => enable,
			A => diff,
			Q => adc_delayed);

-- A - B
mydiff: sub
Generic Map(width => width)
Port Map( A => adc,
          B  => adc_delayed,
			 clk => clk,
			 enable => enable,
			 reset => reset,
			 signed => '0',
          DIFF => diffo(width-1 downto 0),
          CarryOut => diffo(width));

--****************************************************************************
--********************** ACCUMULATOR - MOVING AVERAGE ************************
--****************************************************************************
accdelay: myBigSRL
Generic Map(width => width+1, delay => Word, widthA => Nibble)
Port Map(CLK => clk,
			DATA => diffo,
			CE => enable,
			A => int,
			Q => diffo_delayed);

-- A - B
accusub: sub
Generic Map(width => width+1)
Port Map( A => diffo,
          B  => diffo_delayed,
			 clk => clk,
			 enable => enable,
			 reset => reset,
			 signed => '1',
          DIFF => accudiff(width downto 0),
          CarryOut => accudiff(width+1));

big_accudiff(width+1 downto 0)  <= accudiff(width+1 downto 0);
--big_accudiff(Word-1 downto width+2) <= (others => accudiff(width+1));	 -- sign extension

-- A + B
accumulator: add_signed
Generic Map(width => Word)
Port Map(A => addo(Word-1 downto 0),
        	B => big_accudiff,
			clk => clk,
			enable => enable,
			reset => accu_res,
			signed => '1', 
        	CarryIn => '0',
        	SUM => addo(Word-1 downto 0),
        	CarryOut => addo(Word));

--****************************************************************************
--************************** COMPARE THRESHOLD *******************************
--****************************************************************************
process(addo, thresh)
begin
	if(thresh(Word-1) ='0') then
		if(addo(Word-1) ='1') then
			mytrigger <= '0';
		elsif	(addo(Word-2 downto 0) > thresh(Word-2 downto 0)) then
			mytrigger <= '1';
		else
			mytrigger <= '0';
		end if;
	else
		if(addo(Word-1) = '0') then
			mytrigger <= '0';
		elsif	(addo(Word-2 downto 0) < thresh(Word-2 downto 0)) then
			mytrigger <= '1';
		else 
			mytrigger <= '0'; 
		end if;
	end if;
end process;

--****************************************************************************
--********************* DONT REACT ON SHORT TRIGGERS *************************
--****************************************************************************

sr4ce: trigdb
generic map(Word)
Port map(D_IN => mytrigger,
      	RESET => reset,
      	CLK => clk,
      	Q_OUT => q);

--+++++++++++++++++++++

process(q, tot)
begin
	case tot is
 		when "0000"	=> q_sel <=	q(0);
		when "0001"	=> q_sel <=	q(1);
		when "0010"	=> q_sel <=	q(2);
		when "0011"	=> q_sel <=	q(3);
		when "0100"	=> q_sel <=	q(4);
		when "0101"	=> q_sel <=	q(5);
		when "0110"	=> q_sel <=	q(6);
		when "0111"	=> q_sel <=	q(7);
		when "1000"	=> q_sel <=	q(8);
		when "1001"	=> q_sel <=	q(9);
		when "1010"	=> q_sel <=	q(10);
		when "1011"	=> q_sel <=	q(11);
		when "1100"	=> q_sel <=	q(12);
		when "1101"	=> q_sel <=	q(13);
		when "1110"	=> q_sel <=	q(14);
		when "1111"	=> q_sel <=	q(15);
		when others => q_sel <=	q(15);				
	end case;
end process;

pre_trigger <= mytrigger AND q_sel;				-- time-over-threshold, deglitches trigger 

-- debounce, short trigger signal
process(clk, reset)
begin
  if (reset = '1') then
    db1 <= '0';
    db2 <= '0';
    db3 <= '0';
  elsif (clk'event and clk = '1') then
    db1 <= pre_trigger;
    db2 <= db1;
    db3 <= db2;
  end if;
end process;
 
trigger <= db1 and db2 and (not db3);

end Behavioral;
