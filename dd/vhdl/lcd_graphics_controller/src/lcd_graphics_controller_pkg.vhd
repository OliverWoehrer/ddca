library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package lcd_graphics_controller_pkg is

	constant SRAM_ADDRESS_WIDTH : integer := 20;
	constant SRAM_DATA_WIDTH : integer := 16;


	component lcd_graphics_controller is
		port (
			clk : in std_logic;
			res_n : in std_logic;
			display_clk : in std_logic;
			display_res_n : in std_logic;
			gfx_instr : in std_logic_vector(7 downto 0);
			gfx_instr_wr : in std_logic;
			gfx_instr_full : out std_logic;
			gfx_data : in std_logic_vector(15 downto 0);
			gfx_data_wr : in std_logic;
			gfx_data_full : out std_logic;
			gfx_frame_sync : out std_logic;
			sram_dq : inout std_logic_vector(SRAM_DATA_WIDTH-1 downto 0);
			sram_addr : out std_logic_vector(SRAM_ADDRESS_WIDTH-1 downto 0);
			sram_ub_n : out std_logic;
			sram_lb_n : out std_logic;
			sram_we_n : out std_logic;
			sram_ce_n : out std_logic;
			sram_oe_n : out std_logic;
			nclk : out std_logic;
			hd : out std_logic;
			vd : out std_logic;
			den : out std_logic;
			r : out std_logic_vector(7 downto 0);
			g : out std_logic_vector(7 downto 0);
			b : out std_logic_vector(7 downto 0);
			grest : out std_logic;
			sclk : out std_logic;
			sda : inout std_logic;
			scen : out std_logic
		);
	end component;


	constant LGC_COLOR_DEPTH : integer := 16;
	constant LGC_COLOR_RED_WIDTH : integer := 5;
	constant LGC_COLOR_GREEN_WIDTH : integer := 6;
	constant LGC_COLOR_BLUE_WIDTH : integer := 5;

	function get_blue(color : std_logic_vector) return std_logic_vector;
	function get_green(color : std_logic_vector) return std_logic_vector;
	function get_red(color : std_logic_vector) return std_logic_vector;
end package;

package body lcd_graphics_controller_pkg  is

	function get_blue(color : std_logic_vector) return std_logic_vector is
		variable blue : std_logic_vector(LGC_COLOR_BLUE_WIDTH-1 downto 0);
	begin
		blue := color(LGC_COLOR_BLUE_WIDTH-1 downto 0);
		return blue;
	end function;
	
	function get_green(color : std_logic_vector) return std_logic_vector is
		variable green : std_logic_vector(LGC_COLOR_GREEN_WIDTH-1 downto 0);
	begin
		green := color(LGC_COLOR_GREEN_WIDTH+LGC_COLOR_BLUE_WIDTH-1 downto LGC_COLOR_BLUE_WIDTH);
		return green;
	end function;

	function get_red(color : std_logic_vector) return std_logic_vector is
		variable red : std_logic_vector(LGC_COLOR_RED_WIDTH-1 downto 0);
	begin
		red := color(LGC_COLOR_RED_WIDTH+LGC_COLOR_GREEN_WIDTH+LGC_COLOR_BLUE_WIDTH-1 downto LGC_COLOR_BLUE_WIDTH+LGC_COLOR_GREEN_WIDTH);
		return red;
	end function;

end package body;

