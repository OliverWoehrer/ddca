library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package audio_cntrl_pkg is

	type synth_cntrl_t is record 
		play : std_logic;
		high_time : std_logic_vector(7 downto 0);
		low_time : std_logic_vector(7 downto 0);
	end record;

	type synth_cntrl_vec_t is array(natural range <>) of synth_cntrl_t;

	component audio_cntrl_2s is
		port (
			clk : in std_logic;
			res_n : in std_logic;
			wm8731_sdat : inout std_logic;
			wm8731_sclk : inout std_logic;
			wm8731_xck : out std_logic;
			wm8731_dacdat : out std_logic;
			wm8731_daclrck : out std_logic;
			wm8731_bclk : out std_logic;
			synth_cntrl : in synth_cntrl_vec_t(0 to 1)
		);
	end component;
end package;

