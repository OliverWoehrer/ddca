library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package nes_controller_pkg is

	type nes_buttons_t is record
		btn_up     : std_logic;
		btn_down   : std_logic;
		btn_left   : std_logic;
		btn_right  : std_logic;
		btn_a      : std_logic;
		btn_b      : std_logic;
		btn_start  : std_logic;
		btn_select : std_logic;
	end record;

	constant NES_BUTTONS_RESET_VALUE : nes_buttons_t := (others=>'0');

	component nes_controller is
		generic (
			CLK_FREQ : integer := 50000000;
			CLK_OUT_FREQ : integer := 1000000;
			REFRESH_TIMEOUT : integer := 1000
		);
		port (
			clk : in std_logic;
			res_n : in std_logic;
			nes_clk : out std_logic;
			nes_latch : out std_logic;
			nes_data : in std_logic;
			button_state : out nes_buttons_t
		);
	end component;
end package;
