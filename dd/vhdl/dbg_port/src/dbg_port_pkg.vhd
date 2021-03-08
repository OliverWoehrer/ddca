library ieee;
use ieee.std_logic_1164.all;
use work.nes_controller_pkg.all;

package dbg_port_pkg is

	component dbg_port is
		port (
			clk   : in std_logic;
			res_n : in std_logic;
			rx    : in std_logic;
			tx    : out std_logic;
			switches : out std_logic_vector(17 downto 0);
			keys : out std_logic_vector(3 downto 0);
			ledr : in std_logic_vector(17 downto 0);
			ledg : in std_logic_vector(8 downto 0);
			dsc : out std_logic;
			gfx_instr : out std_logic_vector(7 downto 0);
			gfx_instr_wr : out std_logic;
			gfx_instr_full : in std_logic;
			gfx_data : out std_logic_vector(15 downto 0);
			gfx_data_wr : out std_logic;
			gfx_data_full : in std_logic;
			nes_buttons : out nes_buttons_t;
			nes_clk : in std_logic;
			nes_data : out std_logic;
			nes_latch : in std_logic;
			hex0 : in std_logic_vector(6 downto 0);
			hex1 : in std_logic_vector(6 downto 0);
			hex2 : in std_logic_vector(6 downto 0);
			hex3 : in std_logic_vector(6 downto 0);
			hex4 : in std_logic_vector(6 downto 0);
			hex5 : in std_logic_vector(6 downto 0);
			hex6 : in std_logic_vector(6 downto 0);
			hex7 : in std_logic_vector(6 downto 0)
		);
	end component;
	
	
	component dbg_port_top is
		port (
			clk : in std_logic;
			res_n : in std_logic;
			rx : in std_logic;
			tx : out std_logic;
			switches : out std_logic_vector(17 downto 0);
			keys : out std_logic_vector(3 downto 0);
			ledr : in std_logic_vector(17 downto 0);
			ledg : in std_logic_vector(8 downto 0);
			dsc : out std_logic;
			gfx_instr : out std_logic_vector(7 downto 0);
			gfx_instr_wr : out std_logic;
			gfx_instr_full : in std_logic;
			gfx_data : out std_logic_vector(15 downto 0);
			gfx_data_wr : out std_logic;
			gfx_data_full : in std_logic;
			nes_buttons_btn_up : out std_logic;
			nes_buttons_btn_down : out std_logic;
			nes_buttons_btn_left : out std_logic;
			nes_buttons_btn_right : out std_logic;
			nes_buttons_btn_start : out std_logic;
			nes_buttons_btn_select : out std_logic;
			nes_buttons_btn_a : out std_logic;
			nes_buttons_btn_b : out std_logic;
			nes_clk : in std_logic;
			nes_data : out std_logic;
			nes_latch : in std_logic;
			hex0 : in std_logic_vector(6 downto 0);
			hex1 : in std_logic_vector(6 downto 0);
			hex2 : in std_logic_vector(6 downto 0);
			hex3 : in std_logic_vector(6 downto 0);
			hex4 : in std_logic_vector(6 downto 0);
			hex5 : in std_logic_vector(6 downto 0);
			hex6 : in std_logic_vector(6 downto 0);
			hex7 : in std_logic_vector(6 downto 0)
		);
	end component;
end package;

