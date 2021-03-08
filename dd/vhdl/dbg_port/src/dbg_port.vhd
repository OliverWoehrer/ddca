
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.nes_controller_pkg.all;
use work.dbg_port_pkg.all;

entity dbg_port is
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
end entity;


architecture arch of dbg_port is
begin
	dbg_port_inst : dbg_port_top
	port map (
		clk              => clk,
		res_n            => res_n,
		rx               => rx,
		tx               => tx,
		switches         => switches,
		keys             => keys,
		ledr             => ledr,
		ledg             => ledg,
		dsc              => dsc,
		gfx_instr        => gfx_instr,
		gfx_instr_wr     => gfx_instr_wr,
		gfx_instr_full   => gfx_instr_full,
		gfx_data         => gfx_data,
		gfx_data_wr      => gfx_data_wr,
		gfx_data_full    => gfx_data_full,
		nes_buttons_btn_up     => nes_buttons.btn_up,
		nes_buttons_btn_down   => nes_buttons.btn_down,
		nes_buttons_btn_left   => nes_buttons.btn_left,
		nes_buttons_btn_right  => nes_buttons.btn_right,
		nes_buttons_btn_start  => nes_buttons.btn_start,
		nes_buttons_btn_select => nes_buttons.btn_select,
		nes_buttons_btn_a      => nes_buttons.btn_a,
		nes_buttons_btn_b      => nes_buttons.btn_b,
		nes_clk          => nes_clk,
		nes_data         => nes_data,
		nes_latch        => nes_latch,
		hex0 => hex0,
		hex1 => hex1,
		hex2 => hex2,
		hex3 => hex3,
		hex4 => hex4,
		hex5 => hex5,
		hex6 => hex6,
		hex7 => hex7
	);

end architecture;

