library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.math_pkg.all;

package gfx_util_pkg is

	component gfx_line is
		generic (
			WIDTH : integer;
			HEIGHT : integer
		);
		port (
			clk : in std_logic;
			res_n : in std_logic;
			start : in std_logic;
			stall : in std_logic;
			busy : out std_logic;
			x0 : in std_logic_vector(log2c(WIDTH)-1 downto 0);
			x1 : in std_logic_vector(log2c(WIDTH)-1 downto 0);
			y0 : in std_logic_vector(log2c(HEIGHT)-1 downto 0);
			y1 : in std_logic_vector(log2c(HEIGHT)-1 downto 0);
			pixel_valid : out std_logic;
			pixel_x : out std_logic_vector(log2c(WIDTH)-1 downto 0);
			pixel_y : out std_logic_vector(log2c(HEIGHT)-1 downto 0)
		);
	end component;
	
	component gfx_circle is
		generic (
			WIDTH : integer;
			HEIGHT : integer
		);
		port (
			clk : in std_logic;
			res_n : in std_logic;
			start : in std_logic;
			stall : in std_logic;
			busy : out std_logic;
			x_center : in std_logic_vector(log2c(WIDTH)-1 downto 0);
			y_center : in std_logic_vector(log2c(HEIGHT)-1 downto 0);
			radius : in std_logic_vector(log2c(WIDTH)-1 downto 0);
			pixel_valid : out std_logic;
			pixel_x : out std_logic_vector(log2c(WIDTH)-1 downto 0);
			pixel_y : out std_logic_vector(log2c(HEIGHT)-1 downto 0)
		);
	end component;
	
	component gfx_rect is
		generic (
			WIDTH : integer;
			HEIGHT : integer
		);
		port (
			clk : in std_logic;
			res_n : in std_logic;
			start : in std_logic;
			stall : in std_logic;
			busy : out std_logic;
			x : in std_logic_vector(log2c(WIDTH)-1 downto 0);
			y : in std_logic_vector(log2c(HEIGHT)-1 downto 0);
			w : in std_logic_vector(log2c(WIDTH)-1 downto 0);
			h : in std_logic_vector(log2c(HEIGHT)-1 downto 0);
			bw : in std_logic_vector(3 downto 0);
			bh : in std_logic_vector(3 downto 0);
			dx : in std_logic_vector(3 downto 0);
			dy : in std_logic_vector(3 downto 0);
			ls : in std_logic_vector(4 downto 0);
			fill : in std_logic;
			draw : in std_logic;
			pixel_valid : out std_logic;
			pixel_x : out std_logic_vector(log2c(WIDTH)-1 downto 0);
			pixel_y : out std_logic_vector(log2c(HEIGHT)-1 downto 0);
			pixel_color : out std_logic
		);
	end component;
	
end package;

