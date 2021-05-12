library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use ieee.std_logic_textio.all;


entity sram is
	generic (
		OUTPUT_DIR   : string  := "./"
	);
	port (
		-- SRAM interface
		dq     : inout std_logic_vector(15 downto 0);
		addr   : in	std_logic_vector(19 downto 0);
		lb_n   : in	std_logic;
		ub_n   : in	std_logic;
		ce_n   : in	std_logic;
		oe_n   : in	std_logic;
		we_n   : in	std_logic;

		-- on rising_edge: dump frame to file
		write_file : in std_logic;
		base_address : natural := 0;
		width        : natural := 400;
		height       : natural := 240
	);
end entity;


architecture arch of sram is
begin
	--add your implementation here
end architecture;
