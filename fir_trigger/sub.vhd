------------------------------------------------------------------------------------------------------
-- filename: sub.vhd
-- author: martin lauer, mlauer@opencores.org
-- description: subtraction
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
-- To Do:	    
-- carry in is ignored
--
--
-- history:
-------------------------------------------------------------------------------------------------------
-- Version  |  Author |  Date   |  changes    | 
-------------------------------------------------------------------------------------------------------
--          |   ml    | 19.05.04|   out reg   |                
-------------------------------------------------------------------------------------------------------
--          |         |         |             |
-------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity sub is
    Generic(width: Integer:=16);
    Port ( A 		: in std_logic_vector(width-1 downto 0);
           B 		: in std_logic_vector(width-1 downto 0);
			  clk		: in std_logic;
			  enable	: in std_logic;
			  reset	: in std_logic;
			  signed	: in std_logic;
           DIFF 	: out std_logic_vector(width-1 downto 0);
           CarryOut : out std_logic);
end sub;

architecture Behavioral of sub is
				  
SIGNAL temp: std_logic_vector(width downto 0); 
SIGNAL ta: std_logic_vector(width downto 0); 
SIGNAL tb: std_logic_vector(width downto 0); 

begin

temp <= ta - tb;

process(signed, A, B)
begin
	case signed is
		-- signed input
 		when '1'	=> 	ta(width-1 downto 0) <=	A;	
					ta(width) <= A(width-1);
					tb(width-1 downto 0) <=	B;
					tb(width) <= B(width-1);										
		-- unsigned input													
		when others => ta(width-1 downto 0) <=	A;	
					ta(width) <= '0';
					tb(width-1 downto 0) <=	B;
					tb(width) <= '0';										
	end case;
end process;

process(reset, clk)									-- output reg
begin
	if reset = '1' then
		DIFF <= (others => '0');
		CarryOut <= '0';
	elsif(clk='1' and clk'event) then
		if(enable = '1') then
			DIFF <= temp(width-1 downto 0);
			CarryOut <= temp(width);
	 	end if;
	end if;
end process;

end Behavioral;
