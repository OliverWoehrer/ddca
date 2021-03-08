library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.gfx_if_pkg.all;
use work.math_pkg.all;
use work.nes_controller_pkg.all;
use work.audio_cntrl_pkg.all;
use work.ball_game_pkg.all;

entity ball_game is
	generic (
		DISPLAY_WIDTH : integer;
		DISPLAY_HEIGHT : integer
	);
	port (
		clk : in std_logic;
		res_n : in std_logic;
		
		--connection to the graphics controller
		gfx_instr       : out std_logic_vector(7 downto 0);
		gfx_instr_wr    : out std_logic;
		gfx_instr_full  : in std_logic;
		gfx_data        : out std_logic_vector(15 downto 0);
		gfx_data_wr     : out std_logic;
		gfx_data_full   : in std_logic;
		gfx_frame_sync  : in std_logic;
		
		--connections to the NES controller
		controller : in nes_buttons_t;
		
		--connection to the audio controller
		synth_cntrl : out synth_cntrl_vec_t(0 to 1);
		
		--misc
		player_points : out std_logic_vector(15 downto 0);
		game_state : out ball_game_state_t
	); 
end entity;

