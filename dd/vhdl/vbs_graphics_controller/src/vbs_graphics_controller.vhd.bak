library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.vbs_graphics_controller_pkg.all;
use work.ram_pkg.all;
use work.math_pkg.all;
use work.gfx_util_pkg.all;
use work.gfx_if_pkg.all;

entity vbs_graphics_controller is
	generic (
		CLK_FREQ : integer := 50_000_000
	);
	port (
		clk   : in std_logic;
		res_n : in std_logic;
		
		--instruction interface
		gfx_instr       : in std_logic_vector(GFX_INSTR_WIDTH-1 downto 0);
		gfx_instr_wr    : in std_logic;
		gfx_instr_full  : out std_logic;
		gfx_data        : in std_logic_vector(GFX_DATA_WIDTH-1 downto 0);
		gfx_data_wr     : in std_logic;
		gfx_data_full   : out std_logic;
		
		gfx_frame_sync    : out std_logic;
		
		-- interface to ADV7123
		vga_r : out std_logic_vector(7 downto 0);
		vga_g : out std_logic_vector(7 downto 0);
		vga_b : out std_logic_vector(7 downto 0);
		vga_clk : out std_logic;
		vga_sync_n : out std_logic;
		vga_blank_n : out std_logic
	);
end entity;



