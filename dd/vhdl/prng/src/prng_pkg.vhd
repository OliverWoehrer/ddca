library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package prng_pkg is
	component prng is
		port (
			clk : in std_logic;
			res_n : in std_logic;
			load_seed : in std_logic;
			seed   : in std_logic_vector(7 downto 0) := (others=>'0');
			en : in std_logic;
			prdata : out std_logic
		);
	end component;
end package;

