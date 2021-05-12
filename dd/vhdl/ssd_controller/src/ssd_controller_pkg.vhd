library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ball_game_pkg.all;
use work.nes_controller_pkg.all;

package ssd_controller_pkg is

	component ssd_controller is
		generic (
			BLINK_INTERVAL : integer := 12500000;
			BLINK_COUNT : integer := 3;
			ANIMATION_INTERVAL : integer := 50000000
		);
		port(
			clk : in std_logic;
			res_n : in std_logic;
			
			game_state : in ball_game_state_t;
			player_points : in std_logic_vector(15 downto 0);
			controller : in nes_buttons_t;
			hex0 : out std_logic_vector(6 downto 0);
			hex1 : out std_logic_vector(6 downto 0);
			hex2 : out std_logic_vector(6 downto 0);
			hex3 : out std_logic_vector(6 downto 0);
			hex4 : out std_logic_vector(6 downto 0);
			hex5 : out std_logic_vector(6 downto 0);
			hex6 : out std_logic_vector(6 downto 0);
			hex7 : out std_logic_vector(6 downto 0)
		);
	end component;

end package;