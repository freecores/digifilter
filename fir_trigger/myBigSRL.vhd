------------------------------------------------------------------------------------------------------
-- filename: myBigSRL.vhd
-- author: martin lauer, mlauer@opencores.org
-- description:  SRL for vectors  
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
-- Cell Usage :
-- # Shifters                         : 16
-- #      SRL16E                      : 16
-- Number of Slices:                       8  out of   3072     0%  
-- Number of 4 input LUTs:                16  out of   6144     0% 
--
-- history:
-------------------------------------------------------------------------------------------------------
-- Version  |  Author |  Date   |  changes    | 
-------------------------------------------------------------------------------------------------------
-- 1.0      |  mlauer | 19.05.04|  created	 |                
-------------------------------------------------------------------------------------------------------
-- 		   |		    |		     | 			    | 
-------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity myBigSRL is
Generic(width: Integer:= 16; delay: Integer:=16; widthA: Integer:=4);
port(	CLK : in std_logic;
		DATA : in std_logic_vector(width-1 downto 0);
		CE : in std_logic;
		A : in std_logic_vector(widthA-1 downto 0);
		Q : out std_logic_vector(width-1 downto 0));
end myBigSRL;

architecture Behavioral of myBigSRL is

component mySRL is
Generic(delay: Integer:=16; widthA: Integer:=4);
port(	CLK : in std_logic;
		DATA : in std_logic;
		CE : in std_logic;
		A : in std_logic_vector(widthA-1 downto 0);
		Q : out std_logic);
end component;

begin

bigsrl: FOR i IN 0 TO (width-1) GENERATE 
instanz: mySRL
Generic Map(delay => delay, widthA => widthA)
port map(	CLK => CLK,
		DATA => DATA(i),
		CE => CE,
		A  => A,
		Q => Q(i));
END GENERATE;

end Behavioral;