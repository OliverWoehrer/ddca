library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.vbs_graphics_controller_pkg.all;
use work.ram_pkg.all;
use work.math_pkg.all;
use work.gfx_util_pkg.all;
use work.gfx_if_pkg.all;

entity vbs_graphics_controller_tb is
end entity;

architecture bench of vbs_graphics_controller_tb is
	--clock and reset
	signal frame_dump_s: std_logic := '0';
	signal clk_s : std_logic;
	signal res_n_s : std_logic;
	
	--instructions signals
	signal gfx_instr_s : std_logic_vector(7 downto 0) := (others => '0');
	signal gfx_instr_wr_s : std_logic := '0';
	signal gfx_instr_full_s : std_logic;
	signal gfx_data_s : std_logic_vector(15 downto 0) := (others => '0');
	signal gfx_data_wr_s : std_logic := '0';
	signal gfx_data_full_s : std_logic;
	signal gfx_frame_sync_s : std_logic := '0';
	
	--interface to ADV7123
	signal vga_r_s: std_logic_vector(7 downto 0);
	signal vga_g_s: std_logic_vector(7 downto 0);
	signal vga_b_s: std_logic_vector(7 downto 0);
	signal vga_clk: std_logic;
	signal vga_sync_n_s: std_logic;
	signal vga_blank_n_s: std_logic;

	constant CLK_PERIOD : time := 20 ns;
	signal stop_clock : boolean := false;
	
begin
	
	uut : vbs_graphics_controller
	port map (
		clk 				=> clk_s,
		res_n				=> res_n_s,
		gfx_instr		=> gfx_instr_s,
		gfx_instr_wr	=> gfx_instr_wr_s,
		gfx_instr_full	=> gfx_instr_full_s,
		gfx_data			=> gfx_data_s,
		gfx_data_wr		=> gfx_data_wr_s,
		gfx_data_full	=> gfx_data_full_s,
		gfx_frame_sync	=> gfx_frame_sync_s,
		vga_r				=> vga_r_s,
		vga_g				=> vga_g_s,
		vga_b				=> vga_b_s,
		vga_clk			=> vga_clk,
		vga_sync_n		=> vga_sync_n_s,
		vga_blank_n		=> vga_blank_n_s
	);
	
	--processes:
	test_vbs : process
	begin
		--apply reset for 5 clock periods
		res_n_s <= '0'; -- apply reset
		wait for 5*CLK_PERIOD;
		wait until rising_edge(clk_s);
		res_n_s <= '1'; -- release reset
		
		--Set initial signal values
		wait until rising_edge(clk_s);
		
		--Clear image
		gfx_instr_s <= GFX_INSTR_CLEAR;
		gfx_instr_wr_s <= '1'; --enable write mode
		wait until rising_edge(clk_s);
		gfx_instr_wr_s <= '0';
		
		wait for 3.9 ms;
		wait until rising_edge(clk_s);
		
		--Set single pixel at x=0 y=0:
		gfx_instr_s <= GFX_INSTR_SET_PIXEL;
		gfx_instr_wr_s <= '1'; -- enable write mode
		wait until rising_edge(clk_s);
		gfx_instr_wr_s <= '0';
		gfx_data_wr_s <= '1'; -- enable data write mode
		gfx_data_s <= x"0000"; --(x=0)
		wait until rising_edge(clk_s);
		gfx_data_s <= x"0000"; --(y=0)
		wait until rising_edge(clk_s);
		gfx_data_wr_s <= '0'; -- disable data write mode
		
		--Draw line from (0|0) to (399|239):
		gfx_instr_s <= GFX_INSTR_DRAW_LINE;
		gfx_instr_wr_s <= '1';
		wait until rising_edge(clk_s);
		gfx_instr_wr_s <= '0';
		gfx_data_wr_s <= '1';
		gfx_data_s <= x"0000"; --(x0=0)
		wait until rising_edge(clk_s);
		gfx_data_s <= x"0000"; --(y0=0)
		wait until rising_edge(clk_s);
		gfx_data_s <= x"018F"; --(x1=399)
		wait until rising_edge(clk_s);
		gfx_data_s <= x"00EF"; --(y1=239)
		wait until rising_edge(clk_s);
		gfx_data_wr_s <= '0';
		
		--Draw line from (399|0) to (0|239):
		gfx_instr_s <= GFX_INSTR_DRAW_LINE;
		gfx_instr_wr_s <= '1';
		wait until rising_edge(clk_s);
		gfx_instr_wr_s <= '0';
		gfx_data_wr_s <= '1';
		gfx_data_s <= x"018F"; --(x0=399)
		wait until rising_edge(clk_s);
		gfx_data_s <= x"0000"; --(y0=0)
		wait until rising_edge(clk_s);
		gfx_data_s <= x"0000"; --(x1=0)
		wait until rising_edge(clk_s);
		gfx_data_s <= x"00EF"; --(=y1=239)
		wait until rising_edge(clk_s);
		gfx_data_wr_s <= '0';
		
		wait for 10 us;
		wait until rising_edge(clk_s);
		
		--Draw circel at x=200 y=120 and r=20:
		gfx_instr_s <= GFX_INSTR_DRAW_CIRCLE;
		gfx_instr_wr_s <= '1';
		wait until rising_edge(clk_s);
		gfx_instr_wr_s <= '0';
		gfx_data_wr_s <= '1';
		gfx_data_s <= x"00C8"; -- (x=200)
		wait until rising_edge(clk_s);
		gfx_data_s <= x"0078"; -- (y=120)
		wait until rising_edge(clk_s);
		gfx_data_s <= x"0032"; -- (r=20)
		wait until rising_edge(clk_s);
		gfx_data_wr_s <= '0';
		
		wait for 7 us;
		wait until rising_edge(clk_s);
		
		--Set a pattern:
		gfx_instr_s <= GFX_INSTR_SET_PATTERN(1);
		gfx_instr_wr_s <= '1';
		wait until rising_edge(clk_s);
		gfx_instr_wr_s <= '0';
		gfx_data_wr_s <= '1';
		gfx_data_s <= "0100000100100010"; -- (p0)
		wait until rising_edge(clk_s);
		gfx_data_s <= "0000000000000011"; -- (p1)
		wait until rising_edge(clk_s);
		gfx_data_wr_s <= '0';
		
		--Draw rectangle at (20|20) with w=30,h=20:
		gfx_instr_s <= GFX_INSTR_DRAW_RECT(false, true, 1);
		gfx_instr_wr_s <= '1';
		wait until rising_edge(clk_s);
		gfx_instr_wr_s <= '0';
		gfx_data_wr_s <= '1';
		gfx_data_s <= x"0014"; -- (x=20)
		wait until rising_edge(clk_s);
		gfx_data_s <= x"0014"; -- (y=20)
		wait until rising_edge(clk_s);
		gfx_data_s <= x"0064"; -- (w=100)
		wait until rising_edge(clk_s);
		gfx_data_s <= x"0032"; -- (h=50)
		wait until rising_edge(clk_s);
		gfx_data_wr_s <= '0';
		
		wait for 7 us;
		wait until rising_edge(clk_s);
		
		--Set color to dark gray:
		gfx_instr_s <= GFX_INSTR_SET_COLOR(true);
		gfx_instr_wr_s <= '1';
		wait until rising_edge(clk_s);
		gfx_instr_wr_s <= '0';
		gfx_data_wr_s <= '1';
		gfx_data_s <= x"0001"; -- (dark gray)
		wait until rising_edge(clk_s);
		gfx_data_wr_s <= '0';
		wait until rising_edge(clk_s);
		gfx_instr_s <= GFX_INSTR_SET_COLOR(false);
		gfx_instr_wr_s <= '1';
		wait until rising_edge(clk_s);
		gfx_instr_wr_s <= '0';
		gfx_data_wr_s <= '1';
		gfx_data_s <= x"0002"; -- (light gray)
		wait until rising_edge(clk_s);
		gfx_data_wr_s <= '0';
		
		--Enable frame sync:
		gfx_instr_s <= GFX_INSTR_SET_CFG(true);
		gfx_instr_wr_s <= '1';
		wait until rising_edge(clk_s);
		gfx_instr_wr_s <= '0';
		wait until rising_edge(clk_s);
		gfx_instr_s <= GFX_INSTR_FRAME_SYNC;
		gfx_instr_wr_s <= '1';
		wait until rising_edge(clk_s);
		gfx_instr_wr_s <= '0';
		
		--Draw rectangle at (50|30) with w=20,h=20:
		gfx_instr_s <= GFX_INSTR_DRAW_RECT(false, true, 1);
		gfx_instr_wr_s <= '1'; -- enable write mode
		wait until rising_edge(clk_s);
		gfx_instr_wr_s <= '0';
		gfx_data_wr_s <= '1'; -- enable data write mode
		gfx_data_s <= x"001E"; -- (x=50)
		wait until rising_edge(clk_s);
		gfx_data_s <= x"0032"; -- (y=30)
		wait until rising_edge(clk_s);
		gfx_data_s <= x"0020"; -- (w=32)
		wait until rising_edge(clk_s);
		gfx_data_s <= x"0020"; -- (h=32)
		wait until rising_edge(clk_s);
		gfx_data_wr_s <= '0'; -- disable data write mode
		
		
		wait for 4 ms;
		wait until rising_edge(clk_s);
		gfx_instr_s <= GFX_INSTR_FRAME_SYNC;
		gfx_instr_wr_s <= '1';
		wait until rising_edge(clk_s);
		gfx_instr_wr_s <= '0';
		
		--Draw circel at x=200 y=120 and r=20:
		gfx_instr_s <= GFX_INSTR_DRAW_CIRCLE;
		gfx_instr_wr_s <= '1';
		wait until rising_edge(clk_s);
		gfx_instr_wr_s <= '0';
		gfx_data_wr_s <= '1';
		gfx_data_s <= x"012C"; -- (x=300)
		wait until rising_edge(clk_s);
		gfx_data_s <= x"00C8"; -- (y=200)
		wait until rising_edge(clk_s);
		gfx_data_s <= x"0032"; -- (r=10)
		wait until rising_edge(clk_s);
		gfx_data_wr_s <= '0';
		
		--Terminate clock signal:
		wait for 10 ms;
		wait until rising_edge(clk_s);
		
		--stop_clock <= true;
		wait;
	end process;
	
	
	clk_generator : process
	begin --run clock until sto_clock is true
		clk_s <= '1';
		wait for CLK_PERIOD / 2;
		clk_s <= '0';
		wait for CLK_PERIOD / 2;
		if stop_clock then
			wait;
		end if;
	end process;

end architecture;
