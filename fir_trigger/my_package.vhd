------------------------------------------------------------------------------------------------------
-- filename: my_package.vhd
-- author: martin lauer
-- description: package 
-- Purpose: This package defines supplemental types, subtypes, constants, and functions 
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
-- history:
-------------------------------------------------------------------------------------------------------
-- Version  |  Author |  Date   |  changes    | 
-------------------------------------------------------------------------------------------------------
-- 1.0      |  mlauer | 19.05.04| created     |                
-------------------------------------------------------------------------------------------------------
--          |         |         |             |
-------------------------------------------------------------------------------------------------------

library IEEE; 
use IEEE.STD_LOGIC_1164.all;

package my_pack is
constant ADCw		: integer := 14;
constant busw 		: integer := 16;
constant NCHN		: integer := 1;

constant Nibble	: integer	:= 4;
constant Byte		: integer := 8;
constant Word		: integer := 16;
constant Long		: integer := 32;
----------------------------- DECIMATION ----------------------------------------------
constant DECwidth	: integer := 2;
constant DEClen	: integer := 4;
----------------------------- trapezoidal shaper --------------------------------------
constant MAUlen 	: integer := 256;
constant MAUwidth : integer := 8;
constant BITGAIN	: integer := 5;
----------------------------- Baseline Restorer ---------------------------------------
constant Base_Sens: integer :=5;
constant FRAC_BITS: integer :=4;


function to_stdlogic (v: character) return std_logic; -- taken from: vhdl primer
function to_stdlogicvector(v:string) return std_logic_vector;
function to_stdlogicvector(opd: natural; no_bits: natural) return std_logic_vector;
function to_integer(opd: std_logic_vector(31 downto 0); no_bits:natural) return integer;

end my_pack;

package body my_pack is

function to_integer(opd: std_logic_vector(31 downto 0); no_bits:natural) return integer is
	variable ret: integer;
	variable wert: integer;
	variable local:std_logic_vector(31 downto 0); 
begin
	wert:=1;
	ret:=0;
	for j in 0 to no_bits-1 loop
		if opd(j) = '1' then
			ret := ret + wert;
		end if;
		wert:=wert*2;
	end loop;
	return ret;
end to_integer;

function to_stdlogicvector(opd: natural; no_bits:natural) return std_logic_vector is
	variable m1: integer;
	variable ret:std_logic_vector(no_bits-1 downto 0);
begin
	m1 := opd;
	for j in ret'reverse_range loop
		if (m1 mod 2) = 1 then
			ret(j) := '1';
		else 
			ret(j) := '0';
		end if;
		m1 := m1/2;
	end loop;
	return ret;
end to_stdlogicvector;

function to_stdlogic(v:character) return std_logic is
begin
	case v is
		when 'X' => return 'X';
		when '0' => return '0';
		when '1' => return '1';
		when 'Z' => return 'Z';
		when 'U' => return 'U';
		when 'W' => return 'W';
		when 'L' => return 'L';
		when 'H' => return 'H';
		when '-' => return '-';
		when others => 
			--assert false
			--	report "a character other than u,x,z,0,1,w,l,h- found"
			--	severity error;
			return '-';
	end case;
end to_stdlogic;

function to_stdlogicvector(v: string) return std_logic_vector is
	variable ret: std_logic_vector(0 to v'length-1);
	variable k:integer;
begin
	for j in v'range loop
		k := j-1;
		ret(k) := to_stdlogic(v(j));
	end loop;
	return ret;
end to_stdlogicvector;
end my_pack;
