------------------------------------------------------------------------------------------------------
-- filename: trigdb.vhd
-- author: martin lauer, mlauer@opencores.org
-- description:  debounce trigger  
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
-- To Do:	
-- 
-- 
-- history:
-------------------------------------------------------------------------------------------------------
-- Version  |  Author |  Date   |  changes    | 
-------------------------------------------------------------------------------------------------------
-- 1.0      | mlauer  | 19.05.04| created     |                
-------------------------------------------------------------------------------------------------------
--          |         |         |             |
-------------------------------------------------------------------------------------------------------

library IEEE, WORK;
use WORK.my_pack.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
 
entity trigdb is
Generic(width: IN positive:=16);
Port (D_IN	: in STD_LOGIC;
      RESET	: in STD_LOGIC;
      CLK	: in STD_LOGIC;
      Q_OUT	: out STD_LOGIC_VECTOR(width-1 downto 0));
end trigdb;


architecture behavioral of trigdb is
signal Q: STD_LOGIC_VECTOR(width-1 downto 0);
begin
process(CLK, RESET)
begin
	if (RESET = '1') then
  		Q <= (others => '0');
	elsif (CLK'event and CLK = '1') then
		Q(0) <= D_IN;
		for i in 1 to width-1 loop
    		Q(i) <= Q(i-1);
   	end loop;	
  end if;
end process;

Q_OUT <= Q;
end behavioral; 
