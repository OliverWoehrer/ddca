library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use ieee.std_logic_textio.all;

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
		gfx_frame_sync  : out std_logic;
		
		-- interface to ADV7123
		vga_r : out std_logic_vector(7 downto 0) := (others => '0');
		vga_g : out std_logic_vector(7 downto 0) := (others => '0');
		vga_b : out std_logic_vector(7 downto 0) := (others => '0');
		vga_clk : out std_logic := '0';
		vga_sync_n : out std_logic := '0';
		vga_blank_n : out std_logic := '0'
	);
end entity;


architecture arch of vbs_graphics_controller is
	--Instruction FIFO Buffer:
	constant INSTR_FIFO_DEPTH: integer := 8;
	signal instr_fifo_s: std_logic_vector(GFX_INSTR_WIDTH - 1 downto 0); -- outputs buffered instructions
	signal instr_fifo_read_s: std_logic := '0'; -- enable read out of buffered instuctions
	signal instr_fifo_empty_s: std_logic; -- '1' when fifo buffer is emtpy

	--Data FIFO Buffer:
	constant DATA_FIFO_DEPTH: integer := 8;
	signal data_fifo_s: std_logic_vector(GFX_DATA_WIDTH - 1 downto 0); -- outputs buffered data
	signal data_fifo_read_s: std_logic := '0'; -- enable read out of buffered data
	signal data_fifo_empty_s: std_logic; -- '1' when fifo buffer is emtpy
	
	--Frame Attributes:
	constant FRAME_WIDTH: integer := 400;
	constant FRAME_HEIGHT: integer := 240;
	constant BLACK: std_logic_vector(1 downto 0) := "00";
	constant DARK_GRAY: std_logic_vector(1 downto 0) := "01";
	constant LIGHT_GRAY: std_logic_vector(1 downto 0) := "10";
	constant WHITE: std_logic_vector(1 downto 0) := "11";
	
	--GFX Line Drawer:
	signal line_drawer_start_s: std_logic := '0';
	signal line_drawer_stall_s: std_logic := '0';
	signal line_drawer_busy_s: std_logic;
	signal line_drawer_x0_s: std_logic_vector(log2c(FRAME_WIDTH)-1 downto 0) := (others => '0');
	signal line_drawer_x1_s: std_logic_vector(log2c(FRAME_WIDTH)-1 downto 0) := (others => '0');
	signal line_drawer_y0_s: std_logic_vector(log2c(FRAME_HEIGHT)-1 downto 0) := (others => '0');
	signal line_drawer_y1_s: std_logic_vector(log2c(FRAME_HEIGHT)-1 downto 0) := (others => '0');
	signal line_drawer_valid_s: std_logic;
	signal line_drawer_pixel_x_s: std_logic_vector(log2c(FRAME_WIDTH)-1 downto 0);
	signal line_drawer_pixel_y_s: std_logic_vector(log2c(FRAME_HEIGHT)-1 downto 0);
	
	--GFX Circle Drawer:
	signal circle_drawer_start_s: std_logic := '0';
	signal circle_drawer_stall_s: std_logic := '0';
	signal circle_drawer_busy_s: std_logic;
	signal circle_drawer_x_center_s: std_logic_vector(log2c(FRAME_WIDTH)-1 downto 0) := (others => '0');
	signal circle_drawer_y_center_s: std_logic_vector(log2c(FRAME_HEIGHT)-1 downto 0) := (others => '0');
	signal circle_drawer_radius_s: std_logic_vector(log2c(FRAME_WIDTH)-1 downto 0) := (others => '0');
	signal circle_drawer_valid_s: std_logic;
	signal circle_drawer_pixel_x_s: std_logic_vector(log2c(FRAME_WIDTH)-1 downto 0);
	signal circle_drawer_pixel_y_s: std_logic_vector(log2c(FRAME_HEIGHT)-1 downto 0);
	
	--GFX Rectangle Drawer:
	signal rect_drawer_start_s: std_logic := '0';
	signal rect_drawer_stall_s: std_logic := '0';
	signal rect_drawer_busy_s: std_logic;
	signal rect_drawer_x_s: std_logic_vector(log2c(FRAME_WIDTH)-1 downto 0) := (others => '0');
	signal rect_drawer_y_s: std_logic_vector(log2c(FRAME_HEIGHT)-1 downto 0) := (others => '0');
	signal rect_drawer_w_s: std_logic_vector(log2c(FRAME_WIDTH)-1 downto 0) := (others => '0');
	signal rect_drawer_h_s: std_logic_vector(log2c(FRAME_HEIGHT)-1 downto 0) := (others => '0');
	signal rect_drawer_bw_s: std_logic_vector(3 downto 0) := (others => '0');
	signal rect_drawer_bh_s: std_logic_vector(3 downto 0) := (others => '0');
	signal rect_drawer_dx_s: std_logic_vector(3 downto 0) := (others => '0');
	signal rect_drawer_dy_s: std_logic_vector(3 downto 0) := (others => '0');
	signal rect_drawer_ls_s: std_logic_vector(4 downto 0) := (others => '0');
	signal rect_drawer_fill_s: std_logic := '0';
	signal rect_drawer_draw_s: std_logic := '0';
	signal rect_drawer_valid_s: std_logic;
	signal rect_drawer_pixel_x_s: std_logic_vector(log2c(FRAME_WIDTH)-1 downto 0);
	signal rect_drawer_pixel_y_s: std_logic_vector(log2c(FRAME_HEIGHT)-1 downto 0);
	signal rect_drawer_color_s: std_logic;
	
	--Video RAM:
	constant VRAM_ADDR_WIDTH: integer := 20; -- address width of 2^20 allows for all 400x240 = 96000
	constant VRAM_DATA_WIDTH: integer := COLOR_DEPTH; -- holds up to four values (white, light gray, dark gray, black)
	signal vram_rd_addr_s: std_logic_vector(VRAM_ADDR_WIDTH - 1 downto 0) := (others => '0');
	signal vram_rd_data_s: std_logic_vector(VRAM_DATA_WIDTH - 1 downto 0);
	signal vram_rd_s: std_logic := '0';
	signal vram_wr_addr:	std_logic_vector(VRAM_ADDR_WIDTH - 1 downto 0) := (others => '0');
	signal vram_wr_data: std_logic_vector(VRAM_DATA_WIDTH - 1 downto 0) := (others => '0');
	signal vram_wr_s: std_logic := '0';
	signal vram_base_addr_s: std_logic_vector(VRAM_ADDR_WIDTH-1 downto 0) := (others => '0');
	
	--Frame Reader: reads frame data from the Video RAM
	signal frame_start_s: std_logic;
	signal frame_pix_rd_s: std_logic := '0';
	signal frame_pix_data_s: std_logic_vector(VRAM_DATA_WIDTH-1 downto 0);
	
	signal tpg_pix_rd_s: std_logic := '0';
	signal tpg_pix_data_s: std_logic_vector(1 downto 0);
	
	--Internal Interface FSM:
	type ir_state_t is (READY,READ_INSTR,READ_DA4,READ_DA3,READ_DA2,READ_DA1,WRITE_FRAME);
	type pattern_t is record
		bw: std_logic_vector(3 downto 0); -- pattern width
		bh: std_logic_vector(3 downto 0); -- pattzern height
		dx: std_logic_vector(3 downto 0); -- pattern x gap
		dy: std_logic_vector(3 downto 0); -- pattern y gap
		ls: std_logic_vector(4 downto 0); -- pattern shift
	end record;
	type pattern_array_t is array (7 downto 0) of pattern_t; -- holds the patterns for IDs 0...7
	type ir_signals_t is record
		state: ir_state_t;
		clk_cnt: natural;
		x: natural;
		y: natural;
		primary_color: std_logic_vector(1 downto 0);
		secondary_color: std_logic_vector(1 downto 0);
		patterns: pattern_array_t;
		db: boolean;
		ba: std_logic;
	end record;
	constant IR_RESET: ir_signals_t := (state=>READY,clk_cnt=>0,
													x=>0,y=>0,
													primary_color => WHITE,
													secondary_color => BLACK,
													patterns => (0 => (bw => x"0", bh => x"0", dx => x"1", dy => x"1", ls => "00000"),
																	7 => (bw => x"1", bh => x"1", dx => x"0", dy => x"0", ls => "00000"),
																	others => (bw => x"1", bh => x"1", dx => x"0", dy => x"0", ls => "00000")),
													db => false,
													ba => '0');
	signal ir: ir_signals_t := IR_RESET;
	signal write_frame_s: std_logic := '0';
	signal da1_s,da2_s,da3_s,da4_s: std_logic_vector(GFX_DATA_WIDTH-1 downto 0) := (others => '0');
	
	--External Interface FSM:
	type ei_state_t is (	BROAD_SYNC1,SHORT_SYNC1,
								BLANK_1,DISPLAY_1,BLANK_2,
								SHORT_SYNC2,BROAD_SYNC2,SHORT_SYNC3,GAP_1,
								BLANK_3,DISPLAY_2,BLANK_4,
								GAP_2,SHORT_SYNC4);
	type ei_signals_t is record
		state: ei_state_t;
		clk_cnt: natural;
		pix_cnt: natural;
		frame: natural;
	end record;
	constant EI_RESET: ei_signals_t := (	state => BROAD_SYNC1,
														clk_cnt => 1,
														pix_cnt => 0,
														frame => 1
														);
	signal ei: ei_signals_t := EI_RESET;
	type bit_map_t is array (3 downto 0) of std_logic_vector(vga_g'length-1 downto 0);
	constant BIT_MAP: bit_map_t := (0=> x"00",1=>x"55",2=>x"AA",3=>x"FF");
	
begin
	--Instruction FIFO: --holds input of instruction
	instr_fifo_inst: fifo_1c1r1w
	generic map (
		DEPTH          => INSTR_FIFO_DEPTH,
		DATA_WIDTH     => GFX_INSTR_WIDTH
	)
	port map (
		clk        => clk,
		res_n      => res_n,
		rd_data    => instr_fifo_s,
		rd         => instr_fifo_read_s,
		wr_data    => gfx_instr,
		wr         => gfx_instr_wr,
		empty      => instr_fifo_empty_s,
		full       => gfx_instr_full,
		half_full  => open
	);
	
	--Data FIFO: holds (buffers) input of data
	data_fifo_inst: fifo_1c1r1w
	generic map (
		DEPTH     	=> DATA_FIFO_DEPTH,
		DATA_WIDTH	=> GFX_DATA_WIDTH
	)
	port map (
		clk        	=> clk,
		res_n      	=> res_n,
		rd_data    	=> data_fifo_s,
		rd         	=> data_fifo_read_s,
		wr_data    	=> gfx_data,
		wr         	=> gfx_data_wr,
		empty      	=> data_fifo_empty_s,
		full       	=> gfx_data_full,
		half_full  	=> open
	);
	
	--GFX Line Drawer: generates a line
	line_drawer_inst: gfx_line
	generic map (
		WIDTH			=> FRAME_WIDTH,
		HEIGHT		=> FRAME_HEIGHT
	)
	port map (
		clk			=> clk,
		res_n			=> res_n,
		start			=> line_drawer_start_s,
		stall			=> '0',
		busy			=> line_drawer_busy_s,
		x0				=> line_drawer_x0_s,
		x1				=> line_drawer_x1_s,
		y0				=> line_drawer_y0_s,
		y1				=> line_drawer_y1_s,
		pixel_valid	=> line_drawer_valid_s,
		pixel_x		=> line_drawer_pixel_x_s,
		pixel_y		=> line_drawer_pixel_y_s
	);
	
	--GFX Circle Drawer: generates a circle
	circle_drawer_inst: gfx_circle
	generic map (
		WIDTH 		=> FRAME_WIDTH,
		HEIGHT 		=> FRAME_HEIGHT
	)
	port map (
		clk 			=> clk,
		res_n 		=> res_n,
		start 		=> circle_drawer_start_s,
		stall			=> '0',
		busy			=> circle_drawer_busy_s,
		x_center		=> circle_drawer_x_center_s,
		y_center		=> circle_drawer_y_center_s,
		radius		=> circle_drawer_radius_s,
		pixel_valid	=> circle_drawer_valid_s,
		pixel_x		=> circle_drawer_pixel_x_s,
		pixel_y		=> circle_drawer_pixel_y_s
	);
	
	--GFX Rectangle Drawer: generates a rectangle
	rect_drawer_inst: gfx_rect
	generic map (
		WIDTH 		=> FRAME_WIDTH,
		HEIGHT 		=> FRAME_HEIGHT
	)
	port map (
		clk 			=> clk,
		res_n 		=> res_n,
		start 		=> rect_drawer_start_s,
		stall			=> '0',
		busy			=> rect_drawer_busy_s,
		x				=> rect_drawer_x_s,
		y				=> rect_drawer_y_s,
		w				=> rect_drawer_w_s,
		h				=> rect_drawer_h_s,
		bw				=> rect_drawer_bw_s,
		bh				=> rect_drawer_bh_s,
		dx				=> rect_drawer_dx_s,
		dy				=> rect_drawer_dy_s,
		ls				=> rect_drawer_ls_s,
		fill			=> rect_drawer_fill_s,
		draw			=> rect_drawer_draw_s,
		pixel_valid => rect_drawer_valid_s,
		pixel_x		=> rect_drawer_pixel_x_s,
		pixel_y		=> rect_drawer_pixel_y_s,
		pixel_color	=> rect_drawer_color_s
	);
	
	--Finte State Machine (ASYNC):
	internal_interface_async: process(clk)
	begin
		if rising_edge(clk) then
			if (res_n = '0') then
				ir <= IR_RESET;
			else
				case ir.state is
					when READY =>
						if (instr_fifo_empty_s = '0') then
							instr_fifo_read_s <= '1';
							ir.state <= READ_INSTR;
						else
							ir.state <= READY;
						end if;
					when READ_INSTR =>
						if (ir.clk_cnt = 1) then -- read instruction from fifo after one clock cycle
							instr_fifo_read_s <= '0';
							ir.clk_cnt <= 0;
							if (instr_fifo_s = GFX_INSTR_NOP) then
								ir.state <= READY;
							elsif (instr_fifo_s = GFX_INSTR_CLEAR) then
								--instr_s <= instr_fifo_s;
								ir.state <= WRITE_FRAME;
							elsif (instr_fifo_s = GFX_INSTR_SET_PIXEL) then
								--instr_s <= instr_fifo_s;
								ir.state <= READ_DA2;
							elsif (instr_fifo_s = GFX_INSTR_DRAW_LINE) then
								--instr_s <= instr_fifo_s;
								ir.state <= READ_DA4;
							elsif (instr_fifo_s = GFX_INSTR_DRAW_CIRCLE) then
								--instr_s <= instr_fifo_s;
								ir.state <= READ_DA3;
							elsif (instr_fifo_s = GFX_INSTR_FRAME_SYNC) then
								--instr_s <= instr_fifo_s;
								ir.state <= WRITE_FRAME;
							elsif (instr_fifo_s(7 downto 4) = "01"&OPCODE_SET_PATTERN) then
								--instr_s <= instr_fifo_s;
								ir.state <= READ_DA2;
							elsif (instr_fifo_s(7 downto 4) = "01"&OPCODE_SET_COLOR) then
								--instr_s <= instr_fifo_s;
								ir.state <= READ_DA1;
							elsif (instr_fifo_s(7 downto 4) = "01"&OPCODE_SET_CFG) then	
								--instr_s <= instr_fifo_s;
								ir.state <= WRITE_FRAME;
							elsif (instr_fifo_s(7 downto 5) = "1"&OPCODE_DRAW_RECT) then	
								--instr_s <= instr_fifo_s;
								ir.state <= READ_DA4;
							else -- do nothing
								ir.state <= READY;
							end if;
						else -- enable fifo read out
							instr_fifo_read_s <= '0';
							ir.clk_cnt <= ir.clk_cnt + 1;
							ir.state <= READ_INSTR;
						end if;
					when READ_DA4 =>
						if (data_fifo_empty_s = '0') and (ir.clk_cnt = 0) then -- enable read impuls, when fifo not empty
							data_fifo_read_s <= '1'; -- enable read impuls
							ir.clk_cnt <= ir.clk_cnt + 1;
							ir.state <= READ_DA4;
						elsif (ir.clk_cnt = 1) then
							data_fifo_read_s <= '0';
							ir.clk_cnt <= ir.clk_cnt + 1;
							ir.state <= READ_DA4;
						elsif (ir.clk_cnt = 2) then -- read operand after one clock cycle
							data_fifo_read_s <= '0';
							da4_s <= data_fifo_s;
							ir.clk_cnt <= 0;
							ir.state <= READ_DA3;
						else -- wait till data is ready
							data_fifo_read_s <= '0';
							ir.state <= READ_DA4;
						end if;
					when READ_DA3 =>
						if (data_fifo_empty_s = '0') and (ir.clk_cnt = 0) then -- enable read impuls, when fifo not empty
							data_fifo_read_s <= '1'; -- enable read impuls
							ir.clk_cnt <= ir.clk_cnt + 1;
							ir.state <= READ_DA3;
						elsif (ir.clk_cnt = 1) then
							data_fifo_read_s <= '0';
							ir.clk_cnt <= ir.clk_cnt + 1;
							ir.state <= READ_DA3;
						elsif (ir.clk_cnt = 2) then -- read operand after one clock cycle
							data_fifo_read_s <= '0';
							da3_s <= data_fifo_s;
							ir.clk_cnt <= 0;
							ir.state <= READ_DA2;
						else -- wait till data is ready
							data_fifo_read_s <= '0';
							ir.state <= READ_DA3;
						end if;
					when READ_DA2 =>
						if (data_fifo_empty_s = '0') and (ir.clk_cnt = 0) then -- enable read impuls, when fifo not empty
							data_fifo_read_s <= '1'; -- enable read impuls
							ir.clk_cnt <= ir.clk_cnt + 1;
							ir.state <= READ_DA2;
						elsif (ir.clk_cnt = 1) then
							data_fifo_read_s <= '0';
							ir.clk_cnt <= ir.clk_cnt + 1;
							ir.state <= READ_DA2;
						elsif (ir.clk_cnt = 2) then -- read operand after one clock cycle --ir.clk_cnt = 1
							data_fifo_read_s <= '0';
							da2_s <= data_fifo_s;
							ir.clk_cnt <= 0;
							ir.state <= READ_DA1;
						else -- wait till data is ready
							data_fifo_read_s <= '0';
							ir.state <= READ_DA2;
						end if;
					when READ_DA1 =>
						if (data_fifo_empty_s = '0') and (ir.clk_cnt = 0) then -- enable read impuls, when fifo not empty
							data_fifo_read_s <= '1'; 
							ir.clk_cnt <= ir.clk_cnt + 1;
							ir.state <= READ_DA1;
						elsif (ir.clk_cnt = 1) then
							data_fifo_read_s <= '0';
							ir.clk_cnt <= ir.clk_cnt + 1;
							ir.state <= READ_DA1;
						elsif (ir.clk_cnt = 2) then -- read last operand after one clock cycle
							data_fifo_read_s <= '0';
							da1_s <= data_fifo_s;
							ir.clk_cnt <= 0;
							ir.state <= WRITE_FRAME;
						else -- wait till data is available
							data_fifo_read_s <= '0';
							ir.state <= READ_DA1;
						end if;
					when WRITE_FRAME =>
						if (instr_fifo_s = GFX_INSTR_NOP) then
							ir.state <= READY;
						elsif (instr_fifo_s = GFX_INSTR_CLEAR) then
							--instr_s <= instr_fifo_s;
							vram_wr_s <= '1'; --enable write mode
							if (ir.y < FRAME_HEIGHT) then
								if (ir.x < FRAME_WIDTH) then
									if (ir.clk_cnt = 0) then
										vram_wr_addr <= std_logic_vector(unsigned(vram_base_addr_s)+ir.x+ir.y*FRAME_WIDTH);
										ir.clk_cnt <= ir.clk_cnt + 1;
									else
										vram_wr_data <= ir.secondary_color;
										ir.clk_cnt <= 0;
										ir.x <= ir.x + 1;
									end if;
									ir.state <= WRITE_FRAME;
								else
									ir.x <= 0;
									ir.y <= ir.y + 1;
								end if;
							else -- done with loop
								vram_wr_s <= '0'; --disable write mode
								ir.y <= 0;
								ir.state <= READY;
							end if;
						elsif (instr_fifo_s = GFX_INSTR_SET_PIXEL) then
							--instr_s <= instr_fifo_s;
							if (ir.clk_cnt = 0) then
								vram_wr_s <= '1'; --enable write mode
								vram_wr_addr <= std_logic_vector(to_unsigned(
														(to_integer(unsigned(vram_base_addr_s)+unsigned(da2_s))+to_integer(unsigned(da1_s))*FRAME_WIDTH)
														,VRAM_ADDR_WIDTH));
								vram_wr_data <= ir.primary_color;
								ir.clk_cnt <= ir.clk_cnt + 1;
								ir.state <= WRITE_FRAME;
							else
								vram_wr_s <= '0'; --disable write mode
								ir.clk_cnt <= 0;
								ir.state <= READY;
							end if;
						elsif (instr_fifo_s = GFX_INSTR_DRAW_LINE) then
							--Assign operand data signals to line_drawer:
							--instr_s <= instr_fifo_s;
							line_drawer_x0_s <= da4_s(log2c(FRAME_WIDTH)-1 downto 0);
							line_drawer_y0_s <= da3_s(log2c(FRAME_HEIGHT)-1 downto 0);
							line_drawer_x1_s <= da2_s(log2c(FRAME_WIDTH)-1 downto 0);
							line_drawer_y1_s <= da1_s(log2c(FRAME_HEIGHT)-1 downto 0);
							--Write genrated pixel to video RAM:
							if (line_drawer_busy_s = '0') and (ir.clk_cnt = 0) then
								line_drawer_start_s <= '1'; -- set start impuls
								ir.clk_cnt <= ir.clk_cnt + 1;
								ir.state <= WRITE_FRAME;
							elsif (line_drawer_busy_s = '0') and (ir.clk_cnt = 1) then
								line_drawer_start_s <= '0';
								ir.state <= WRITE_FRAME;
							elsif (line_drawer_busy_s = '1') and (ir.clk_cnt > 0) then
								--if (line_drawer_busy_s = '1') then
									vram_wr_s <= '1'; -- enable write mode
									if (line_drawer_valid_s = '1') then
										vram_wr_addr <= std_logic_vector(to_unsigned(
																(to_integer(unsigned(vram_base_addr_s)+unsigned(line_drawer_pixel_x_s))+to_integer(unsigned(line_drawer_pixel_y_s))*FRAME_WIDTH)
																,VRAM_ADDR_WIDTH));
										vram_wr_data <= ir.primary_color;
									end if;
									ir.clk_cnt <= ir.clk_cnt + 1;
									ir.state <= WRITE_FRAME;
							else -- line drawer done
								vram_wr_s <= '0'; -- disable write mode
								ir.clk_cnt <= 0;
								ir.state <= READY;
							end if;
						elsif (instr_fifo_s = GFX_INSTR_DRAW_CIRCLE) then
							--Assign operand data signals to circle_drawer:
							--instr_s <= instr_fifo_s;
							circle_drawer_x_center_s <= da3_s(log2c(FRAME_WIDTH)-1 downto 0);
							circle_drawer_y_center_s <= da2_s(log2c(FRAME_HEIGHT)-1 downto 0);
							circle_drawer_radius_s <= da1_s(log2c(FRAME_WIDTH)-1 downto 0);
							--Write genrated pixel to video RAM:
							if (circle_drawer_busy_s = '0') and (ir.clk_cnt = 0) then
								circle_drawer_start_s <= '1'; -- set start impuls
								ir.clk_cnt <= ir.clk_cnt + 1;
								ir.state <= WRITE_FRAME;
							elsif (circle_drawer_busy_s = '0') and (ir.clk_cnt = 1) then
								circle_drawer_start_s <= '0';
								ir.state <= WRITE_FRAME;
							elsif (circle_drawer_busy_s = '1') and (ir.clk_cnt > 0) then
								circle_drawer_start_s <= '0';
								vram_wr_s <= '1'; -- enable write mode
								if (circle_drawer_valid_s = '1') then
									vram_wr_addr <= std_logic_vector(to_unsigned(
															(to_integer(unsigned(vram_base_addr_s)+unsigned(circle_drawer_pixel_x_s))+to_integer(unsigned(circle_drawer_pixel_y_s))*FRAME_WIDTH)
															,VRAM_ADDR_WIDTH));
									vram_wr_data <= ir.primary_color;
								end if;
								ir.clk_cnt <= ir.clk_cnt + 1;
								ir.state <= WRITE_FRAME;
							else -- circle drawer done
								vram_wr_s <= '0'; -- disable write mode
								ir.clk_cnt <= 0;
								ir.state <= READY;
							end if;
						elsif (instr_fifo_s = GFX_INSTR_FRAME_SYNC) then
							if (frame_start_s = '1') and (ir.clk_cnt = 0) then
								gfx_frame_sync <= '1';
								ir.clk_cnt <= ir.clk_cnt + 1;
								ir.state <= WRITE_FRAME;
							elsif (ir.clk_cnt = 1) then
								gfx_frame_sync <= '0';
								if (ir.db) then
									if ((ir.ba = '0')) then
										vram_base_addr_s <= std_logic_vector(to_unsigned(FRAME_HEIGHT*FRAME_WIDTH, VRAM_ADDR_WIDTH));
										ir.ba <= '1';
									else
										vram_base_addr_s <= (others => '0');
										ir.ba <= '0';
									end if;	 
								end if;
								ir.clk_cnt <= 0;
								ir.state <= READY;
							else
								ir.state <= WRITE_FRAME;
							end if;
						elsif (instr_fifo_s(7 downto 4) = "01"&OPCODE_SET_PATTERN) then
							if (to_integer(unsigned(instr_fifo_s(2 downto 0))) /= 0) and (to_integer(unsigned(instr_fifo_s(2 downto 0))) /= 7) then
								-- only IDs other then 0 and 7 are allowed to be changed.
								ir.patterns(to_integer(unsigned(instr_fifo_s(2 downto 0)))).bw <= da2_s(15 downto 15)&da2_s(14 downto 14)&da2_s(13 downto 13)&da2_s(12 downto 12);
								ir.patterns(to_integer(unsigned(instr_fifo_s(2 downto 0)))).bh <= da2_s(11 downto 11)&da2_s(10 downto 10)&da2_s(9 downto 9)&da2_s(8 downto 8);
								ir.patterns(to_integer(unsigned(instr_fifo_s(2 downto 0)))).dx <= da2_s(7 downto 7)&da2_s(6 downto 6)&da2_s(5 downto 5)&da2_s(4 downto 4);
								ir.patterns(to_integer(unsigned(instr_fifo_s(2 downto 0)))).dy <= da2_s(3 downto 3)&da2_s(2 downto 2)&da2_s(1 downto 1)&da2_s(0 downto 0);
								ir.patterns(to_integer(unsigned(instr_fifo_s(2 downto 0)))).ls <= da1_s(4 downto 0);
							end if;
							ir.state <= READY;
						elsif (instr_fifo_s(7 downto 4) = "01"&OPCODE_SET_COLOR) then
							if (instr_fifo_s(0) = '1') then
								ir.primary_color <= da1_s(1 downto 0);
							else
								ir.secondary_color <= da1_s(1 downto 0);
							end if;
							ir.state <= READY;
						elsif (instr_fifo_s(7 downto 4) = "01"&OPCODE_SET_CFG) then
							if (instr_fifo_s(0) = '1') then
								ir.db <= true;
							else
								ir.db <= false;
							end if;
							ir.state <= READY;
						elsif (instr_fifo_s(7 downto 5) = "1"&OPCODE_DRAW_RECT) then	
							--Assign operand data signals to rect_drawer:
							rect_drawer_x_s <= da4_s(log2c(FRAME_WIDTH)-1 downto 0);
							rect_drawer_y_s <= da3_s(log2c(FRAME_HEIGHT)-1 downto 0);
							rect_drawer_w_s <= da2_s(log2c(FRAME_WIDTH)-1 downto 0);
							rect_drawer_h_s <= da1_s(log2c(FRAME_HEIGHT)-1 downto 0);
							rect_drawer_bw_s <= ir.patterns(to_integer(unsigned(instr_fifo_s(2 downto 0)))).bw;
							rect_drawer_bh_s <= ir.patterns(to_integer(unsigned(instr_fifo_s(2 downto 0)))).bh;
							rect_drawer_dx_s <= ir.patterns(to_integer(unsigned(instr_fifo_s(2 downto 0)))).dy;
							rect_drawer_dy_s <= ir.patterns(to_integer(unsigned(instr_fifo_s(2 downto 0)))).dy;
							rect_drawer_ls_s <= ir.patterns(to_integer(unsigned(instr_fifo_s(2 downto 0)))).ls;
							rect_drawer_fill_s <= '1';
							rect_drawer_draw_s <= instr_fifo_s(3);
							--Write genrated pixel to video RAM:
							if (rect_drawer_busy_s = '0') and (ir.clk_cnt = 0) then
								rect_drawer_start_s <= '1'; -- set start impuls
								ir.clk_cnt <= ir.clk_cnt + 1;
								ir.state <= WRITE_FRAME;
							elsif (rect_drawer_busy_s = '0') and (ir.clk_cnt = 1) then
								rect_drawer_start_s <= '0';
								ir.state <= WRITE_FRAME;
							elsif (rect_drawer_busy_s = '1') and (ir.clk_cnt > 0) then
								rect_drawer_start_s <= '0';
								vram_wr_s <= '1'; -- enable write mode
								if (rect_drawer_valid_s = '1') then
									if (rect_drawer_color_s = '1') or (instr_fifo_s(4) = '0') or (instr_fifo_s(2 downto 0) = "000" ) then
										vram_wr_addr <= std_logic_vector(to_unsigned(
														(to_integer(unsigned(vram_base_addr_s)+unsigned(rect_drawer_pixel_x_s))+to_integer(unsigned(rect_drawer_pixel_y_s))*FRAME_WIDTH)
														,VRAM_ADDR_WIDTH));
										if (rect_drawer_color_s = '1') then
											vram_wr_data <= ir.primary_color;
										else
											vram_wr_data <= ir.secondary_color;
										end if;
									end if;
								end if;
								ir.clk_cnt <= ir.clk_cnt + 1;
								ir.state <= WRITE_FRAME;
							else -- rect drawer done
								vram_wr_s <= '0'; -- disable write mode
								ir.clk_cnt <= 0;
								ir.state <= READY;
							end if;			
						else -- do nothing
							ir.state <= READY;
						end if;
					when others =>
						ir <= ir;
				end case;
			end if;
		end if;
	end process;
	
	--Video Ram: holds the frame data
	vram_inst: dp_ram_1c1r1w
	generic map (
		ADDR_WIDTH => VRAM_ADDR_WIDTH,
		DATA_WIDTH => VRAM_DATA_WIDTH
	)
	port map (
		clk		=> clk,
		rd1_addr	=> vram_rd_addr_s,
		rd1_data => vram_rd_data_s,
		rd1 		=> vram_rd_s,
		wr2_addr	=> vram_wr_addr,
		wr2_data => vram_wr_data,
		wr2 		=> vram_wr_s
	);
	
	frame_reader_inst: frame_reader
	generic map (
		WIDTH					=> FRAME_WIDTH,
		HEIGHT				=> FRAME_HEIGHT,
		VRAM_ADDR_WIDTH	=> VRAM_ADDR_WIDTH,
		VRAM_DATA_WIDTH	=> VRAM_DATA_WIDTH
	)
	port map (
		clk				=> clk,
		res_n				=> res_n,
		frame_start		=> frame_start_s,
		vram_base_addr	=> vram_base_addr_s,
		vram_rd			=> vram_rd_s,
		vram_addr		=> vram_rd_addr_s,
		vram_data		=> vram_rd_data_s,
		pix_rd			=> frame_pix_rd_s,
		pix_data			=> frame_pix_data_s
	);
	
	--Extern Interface FSM:
	external_interface_async: process(all)
		constant BS_T: natural := 1365;
		constant SS_T: natural := 118;
		constant HS_T: natural := 235;
		constant BP_T: natural := 620;
		constant FP_T: natural := 3020;
		constant HALF_LINE_T: natural := 1600;
		constant FULL_LINE_T: natural := 3200;
	begin
		if rising_edge(clk) then
			if (res_n = '0') then
				ei <= EI_RESET;
			else
				case ei.state is
					when BROAD_SYNC1 =>
						if (ei.clk_cnt < BS_T) then -- SYNC level
							vga_sync_n <= '0';
							vga_blank_n <= '0';
							vga_g <= x"00";
							ei.clk_cnt <= ei.clk_cnt + 1;
							ei.state <= BROAD_SYNC1;
						elsif (ei.clk_cnt < HALF_LINE_T) then -- BLANK level
							vga_sync_n <= '1';
							vga_blank_n <= '0';
							vga_g <= x"00";
							ei.clk_cnt <= ei.clk_cnt + 1;
							ei.state <= BROAD_SYNC1;
						else -- determine next step after 1600 clk cylces
							if (ei.frame < 5) then -- continue another frame
								vga_sync_n <= '0';
								vga_blank_n <= '0';
								vga_g <= x"00";
								ei.frame <= ei.frame + 1;
								ei.clk_cnt <= 1;
								ei.state <= BROAD_SYNC1;
							else -- done five frames
								vga_sync_n <= '0';
								vga_blank_n <= '0';
								vga_g <= x"00";
								ei.frame <= 1;
								ei.clk_cnt <= 1;
								ei.state <= SHORT_SYNC1;
							end if;
						end if;
					when SHORT_SYNC1 =>
						if (ei.clk_cnt < SS_T) then -- SYNC level
							vga_sync_n <= '0';
							vga_blank_n <= '0';
							vga_g <= x"00";
							ei.clk_cnt <= ei.clk_cnt + 1;
							ei.state <= SHORT_SYNC1;
						elsif (ei.clk_cnt < HALF_LINE_T) then -- BLANK level
							vga_sync_n <= '1';
							vga_blank_n <= '0';
							vga_g <= x"00";
							ei.clk_cnt <= ei.clk_cnt + 1;
							ei.state <= SHORT_SYNC1;
						else -- determine next step after 1600 clk cylces
							if (ei.frame < 5) then -- continue another frame
								vga_sync_n <= '0';
								vga_blank_n <= '0';
								vga_g <= x"00";
								ei.frame <= ei.frame + 1;
								ei.clk_cnt <= 1;
								ei.state <= SHORT_SYNC1;
							else -- done five frames
								vga_sync_n <= '0';
								vga_blank_n <= '0';
								vga_g <= x"00";
								ei.frame <= 1;
								ei.clk_cnt <= 1;
								ei.state <= BLANK_1;
							end if;
						end if;
					when BLANK_1 =>
						if (ei.clk_cnt < HS_T) then -- SYNC level
							vga_sync_n <= '0';
							vga_blank_n <= '0';
							vga_g <= x"00";
							ei.clk_cnt <= ei.clk_cnt + 1;
							ei.state <= BLANK_1;
						elsif (ei.clk_cnt < FULL_LINE_T) then -- BLANK level
							vga_sync_n <= '1';
							vga_blank_n <= '0';
							vga_g <= x"00";
							ei.clk_cnt <= ei.clk_cnt + 1;
							ei.state <= BLANK_1;
						else -- determine next step after 3200 clk cylces
							if (ei.frame < 41) then -- send another blank line
								vga_sync_n <= '0';
								vga_blank_n <= '0';
								vga_g <= x"00";
								ei.frame <= ei.frame + 1;
								ei.clk_cnt <= 1;
								ei.state <= BLANK_1;
							else -- done five frames
								vga_sync_n <= '0';
								vga_blank_n <= '0';
								vga_g <= x"00";
								ei.frame <= 1;
								ei.clk_cnt <= 1;
								ei.state <= DISPLAY_1;
							end if;
						end if;
					when DISPLAY_1 =>
						if (ei.clk_cnt < HS_T) then -- H-SYNC level section
							vga_sync_n <= '0';
							vga_blank_n <= '0';
							vga_g <= x"00";
							ei.clk_cnt <= ei.clk_cnt + 1;
							ei.state <= DISPLAY_1;
						elsif (ei.clk_cnt < BP_T) then -- Back Porch level
							vga_sync_n <= '1';
							vga_blank_n <= '0';
							vga_g <= x"00";
							ei.clk_cnt <= ei.clk_cnt + 1;
							ei.state <= DISPLAY_1;
						elsif (ei.clk_cnt < FP_T) then -- display data
							vga_sync_n <= '1';
							vga_blank_n <= '1';
							if (ei.pix_cnt = 0) then -- enabel pix_data read out
								frame_pix_rd_s <= '1';
								ei.pix_cnt <= ei.pix_cnt + 1;
							elsif (ei.pix_cnt = 1) then -- set pix_read for one clock cycle
								frame_pix_rd_s <= '0';
								ei.pix_cnt <= ei.pix_cnt + 1;
							elsif (ei.pix_cnt = 5) then -- reset after 6 clock cycles
								ei.pix_cnt <= 0;
							else
								frame_pix_rd_s <= '0';
								vga_g <= BIT_MAP(to_integer(unsigned(frame_pix_data_s)));
								ei.pix_cnt <= ei.pix_cnt + 1;
							end if;
							ei.clk_cnt <= ei.clk_cnt + 1;
							ei.state <= DISPLAY_1;
						elsif (ei.clk_cnt < FULL_LINE_T) then -- Font Porch level
							vga_sync_n <= '1';
							vga_blank_n <= '0';
							vga_g <= x"00";
							ei.clk_cnt <= ei.clk_cnt + 1;
							ei.state <= DISPLAY_1;
						else -- determine next step after 3200 clk cylces
							if (ei.frame < 240) then -- send another display line
								vga_sync_n <= '0';
								vga_blank_n <= '0';
								vga_g <= x"00";
								ei.frame <= ei.frame + 1;
								ei.clk_cnt <= 1;
								ei.state <= DISPLAY_1;
							else -- done 240 lines
								vga_sync_n <= '0';
								vga_blank_n <= '0';
								vga_g <= x"00";
								ei.frame <= 1;
								ei.clk_cnt <= 1;
								ei.state <= BLANK_2;
							end if;
						end if;
					when BLANK_2 =>
						if (ei.clk_cnt < HS_T) then -- SYNC level
							vga_sync_n <= '0';
							vga_blank_n <= '0';
							vga_g <= x"00";
							ei.clk_cnt <= ei.clk_cnt + 1;
							ei.state <= BLANK_2;
						elsif (ei.clk_cnt < FULL_LINE_T) then -- BLANK level
							vga_sync_n <= '1';
							vga_blank_n <= '0';
							vga_g <= x"00";
							ei.clk_cnt <= ei.clk_cnt + 1;
							ei.state <= BLANK_2;
						else -- determine next step after 3200 clk cylces
							if (ei.frame < 24) then -- send another blank line
								vga_sync_n <= '0';
								vga_blank_n <= '0';
								vga_g <= x"00";
								ei.frame <= ei.frame + 1;
								ei.clk_cnt <= 1;
								ei.state <= BLANK_2;
							else -- done five frames
								vga_sync_n <= '0';
								vga_blank_n <= '0';
								vga_g <= x"00";
								ei.frame <= 1;
								ei.clk_cnt <= 1;
								ei.state <= SHORT_SYNC2;
							end if;
						end if;
					when SHORT_SYNC2 =>
						if (ei.clk_cnt < SS_T) then -- SYNC level
							vga_sync_n <= '0';
							vga_blank_n <= '0';
							vga_g <= x"00";
							ei.clk_cnt <= ei.clk_cnt + 1;
							ei.state <= SHORT_SYNC2;
						elsif (ei.clk_cnt < HALF_LINE_T) then -- BLANK level
							vga_sync_n <= '1';
							vga_blank_n <= '0';
							vga_g <= x"00";
							ei.clk_cnt <= ei.clk_cnt + 1;
							ei.state <= SHORT_SYNC2;
						else -- determine next step after 1600 clk cylces
							if (ei.frame < 5) then -- continue another frame
								vga_sync_n <= '0';
								vga_blank_n <= '0';
								vga_g <= x"00";
								ei.frame <= ei.frame + 1;
								ei.clk_cnt <= 1;
								ei.state <= SHORT_SYNC2;
							else -- done five frames
								vga_sync_n <= '0';
								vga_blank_n <= '0';
								vga_g <= x"00";
								ei.frame <= 1;
								ei.clk_cnt <= 1;
								ei.state <= BROAD_SYNC2;
							end if;
						end if;
					when BROAD_SYNC2 =>
						if (ei.clk_cnt < BS_T) then -- SYNC level
							vga_sync_n <= '0';
							vga_blank_n <= '0';
							vga_g <= x"00";
							ei.clk_cnt <= ei.clk_cnt + 1;
							ei.state <= BROAD_SYNC2;
						elsif (ei.clk_cnt < HALF_LINE_T) then -- BLANK level
							vga_sync_n <= '1';
							vga_blank_n <= '0';
							vga_g <= x"00";
							ei.clk_cnt <= ei.clk_cnt + 1;
							ei.state <= BROAD_SYNC2;
						else -- determine next step after 1600 clk cylces
							if (ei.frame < 5) then -- continue another frame
								vga_sync_n <= '0';
								vga_blank_n <= '0';
								vga_g <= x"00";
								ei.frame <= ei.frame + 1;
								ei.clk_cnt <= 1;
								ei.state <= BROAD_SYNC2;
							else -- done five frames
								vga_sync_n <= '0';
								vga_blank_n <= '0';
								vga_g <= x"00";
								ei.frame <= 1;
								ei.clk_cnt <= 1;
								ei.state <= SHORT_SYNC3;
							end if;
						end if;
					when SHORT_SYNC3 =>
						if (ei.clk_cnt < SS_T) then -- SYNC level
							vga_sync_n <= '0';
							vga_blank_n <= '0';
							vga_g <= x"00";
							ei.clk_cnt <= ei.clk_cnt + 1;
							ei.state <= SHORT_SYNC3;
						elsif (ei.clk_cnt < HALF_LINE_T) then -- BLANK level
							vga_sync_n <= '1';
							vga_blank_n <= '0';
							vga_g <= x"00";
							ei.clk_cnt <= ei.clk_cnt + 1;
							ei.state <= SHORT_SYNC3;
						else -- determine next step after 1600 clk cylces
							if (ei.frame < 5) then -- continue another frame
								vga_sync_n <= '0';
								vga_blank_n <= '0';
								vga_g <= x"00";
								ei.frame <= ei.frame + 1;
								ei.clk_cnt <= 1;
								ei.state <= SHORT_SYNC3;
							else -- done five frames
								vga_sync_n <= '1';
								vga_blank_n <= '0';
								vga_g <= x"00";
								ei.frame <= 1;
								ei.clk_cnt <= 1;
								ei.state <= GAP_1;
							end if;
						end if;
					when GAP_1 =>
						if (ei.clk_cnt < HALF_LINE_T) then
							ei.clk_cnt <= ei.clk_cnt + 1;
							ei.state <= GAP_1;
						else -- waitd for half a line (32us)
							ei.clk_cnt <= 1;
							ei.state <= BLANK_3;
						end if;
					when BLANK_3 =>
						if (ei.clk_cnt < HS_T) then -- SYNC level
							vga_sync_n <= '0';
							vga_blank_n <= '0';
							vga_g <= x"00";
							ei.clk_cnt <= ei.clk_cnt + 1;
							ei.state <= BLANK_3;
						elsif (ei.clk_cnt < FULL_LINE_T) then -- BLANK level
							vga_sync_n <= '1';
							vga_blank_n <= '0';
							vga_g <= x"00";
							ei.clk_cnt <= ei.clk_cnt + 1;
							ei.state <= BLANK_3;
						else -- determine next step after 3200 clk cylces
							if (ei.frame < 40) then -- send another blank line (=black top border)
								vga_sync_n <= '0';
								vga_blank_n <= '0';
								vga_g <= x"00";
								ei.frame <= ei.frame + 1;
								ei.clk_cnt <= 1;
								ei.state <= BLANK_3;
							else -- done five frames
								vga_sync_n <= '0';
								vga_blank_n <= '0';
								vga_g <= x"00";
								ei.frame <= 1;
								ei.clk_cnt <= 1;
								ei.state <= DISPLAY_2;
							end if;
						end if;
					when DISPLAY_2 =>
						if (ei.clk_cnt < HS_T) then -- H-SYNC level section
							vga_sync_n <= '0';
							vga_blank_n <= '0';
							vga_g <= x"00";
							ei.clk_cnt <= ei.clk_cnt + 1;
							ei.state <= DISPLAY_2;
						elsif (ei.clk_cnt < BP_T) then -- Back Porch level
							vga_sync_n <= '1';
							vga_blank_n <= '0';
							vga_g <= x"00";
							ei.clk_cnt <= ei.clk_cnt + 1;
							ei.state <= DISPLAY_2;
						elsif (ei.clk_cnt < FP_T) then -- display data
							vga_sync_n <= '1';
							vga_blank_n <= '1';
							if (ei.pix_cnt = 0) then -- enabel pix_data read out
								frame_pix_rd_s <= '1';
								ei.pix_cnt <= ei.pix_cnt + 1;
							elsif (ei.pix_cnt = 1) then -- set pix_read for one clock cycle
								frame_pix_rd_s <= '0';
								ei.pix_cnt <= ei.pix_cnt + 1;
							elsif (ei.pix_cnt = 5) then -- reset after 6 clock cycles
								ei.pix_cnt <= 0;
							else
								frame_pix_rd_s <= '0';
								vga_g <= BIT_MAP(to_integer(unsigned(frame_pix_data_s)));
								ei.pix_cnt <= ei.pix_cnt + 1;
							end if;
							ei.clk_cnt <= ei.clk_cnt + 1;
							ei.state <= DISPLAY_2;
						elsif (ei.clk_cnt < FULL_LINE_T) then -- Font Porch level
							vga_sync_n <= '1';
							vga_blank_n <= '0';
							vga_g <= x"00";
							ei.clk_cnt <= ei.clk_cnt + 1;
							ei.state <= DISPLAY_2;
						else -- determine next step after 3200 clk cylces
							if (ei.frame < 240) then -- send another display line
								vga_sync_n <= '0';
								vga_blank_n <= '0';
								vga_g <= x"00";
								ei.frame <= ei.frame + 1;
								ei.clk_cnt <= 1;
								ei.state <= DISPLAY_2;
							else -- done 240 lines
								vga_sync_n <= '0';
								vga_blank_n <= '0';
								vga_g <= x"00";
								ei.frame <= 1;
								ei.clk_cnt <= 1;
								ei.state <= BLANK_4;
							end if;
						end if;
					when BLANK_4 =>
						if (ei.clk_cnt < HS_T) then -- SYNC level
							vga_sync_n <= '0';
							vga_blank_n <= '0';
							vga_g <= x"00";
							ei.clk_cnt <= ei.clk_cnt + 1;
							ei.state <= BLANK_4;
						elsif (ei.clk_cnt < FULL_LINE_T) then -- BLANK level
							vga_sync_n <= '1';
							vga_blank_n <= '0';
							vga_g <= x"00";
							ei.clk_cnt <= ei.clk_cnt + 1;
							ei.state <= BLANK_4;
						else -- determine next step after 3200 clk cylces
							if (ei.frame < 24) then -- send another blank line (=black top border)
								vga_sync_n <= '0';
								vga_blank_n <= '0';
								vga_g <= x"00";
								ei.frame <= ei.frame + 1;
								ei.clk_cnt <= 1;
								ei.state <= BLANK_4;
							else -- done five frames
								vga_sync_n <= '0';
								vga_blank_n <= '0';
								vga_g <= x"00";
								ei.frame <= 1;
								ei.clk_cnt <= 1;
								ei.state <= GAP_2;
							end if;
						end if;
					when GAP_2 =>
						if (ei.clk_cnt < HALF_LINE_T) then
							ei.clk_cnt <= ei.clk_cnt + 1;
							ei.state <= GAP_2;
						else -- waitd for half a line (32us)
							ei.clk_cnt <= 1;
							ei.state <= SHORT_SYNC4;
						end if;
					when SHORT_SYNC4 =>
						if (ei.clk_cnt < SS_T) then -- SYNC level
							vga_sync_n <= '0';
							vga_blank_n <= '0';
							vga_g <= x"00";
							ei.clk_cnt <= ei.clk_cnt + 1;
							ei.state <= SHORT_SYNC4;
						elsif (ei.clk_cnt < HALF_LINE_T) then -- BLANK level
							vga_sync_n <= '1';
							vga_blank_n <= '0';
							vga_g <= x"00";
							ei.clk_cnt <= ei.clk_cnt + 1;
							ei.state <= SHORT_SYNC4;
						else -- determine next step after 1600 clk cylces
							if (ei.frame < 5) then -- continue another frame
								vga_sync_n <= '0';
								vga_blank_n <= '0';
								vga_g <= x"00";
								ei.frame <= ei.frame + 1;
								ei.clk_cnt <= 1;
								ei.state <= SHORT_SYNC4;
							else -- done five frames
								vga_sync_n <= '0';
								vga_blank_n <= '0';
								vga_g <= x"00";
								ei.frame <= 1;
								ei.clk_cnt <= 1;
								ei.state <= BROAD_SYNC1;
							end if;
						end if;
					when others =>
						ei.state <= ei.state;
				end case;
			end if;
		end if;
	end process;
	
	vga_clk <= clk;
	vga_r <= (others => '0');
	vga_b <= (others => '0');
	
	
	/*file_dump: process
		--frame dump file
		file outfile : text;
		variable l: line;
		variable status: FILE_OPEN_STATUS;
		variable fileCounter : natural := 0;
		
		--temporary variables
		variable colorValue : std_logic_vector(1 downto 0);
	begin
		wait for 20 ms;
		report "Dumping storage to file";
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		file_open(status,outfile, "./frame_dump_"&NATURAL'image(fileCounter)&".ppm", write_mode);
		write(l, string'("P3"));
		writeline(outfile,l);
		write(l, string'("400 240"));
		writeline(outfile,l);
		write(l, string'("3"));
		writeline(outfile,l);
		for y in 0 to (FRAME_HEIGHT-1) loop
			for x in 0 to (FRAME_WIDTH-1) loop
				frame_pix_rd_s <= '1'; -- enable frame reader
				wait until rising_edge(clk);
				frame_pix_rd_s <= '0'; 
				wait until rising_edge(clk);
				colorValue := frame_pix_data_s;
				
				--write colors to dump file
				--report "X := "&natural'image(x)&" Y := "&natural'image(y);
				--report "ColorValue: "&integer'image(to_integer(unsigned(colorValue)));
				write(l, string'(integer'image(to_integer(unsigned(colorValue)))&" ") );
				write(l, string'(integer'image(to_integer(unsigned(colorValue)))&" ") );
				write(l, string'(integer'image(to_integer(unsigned(colorValue)))&" ") );
				wait until rising_edge(clk);
			end loop;
			writeline(outfile,l);
		end loop;
		report "dumped ./frame_dump_"&NATURAL'image(fileCounter)&".ppm";
		frame_pix_rd_s <= '0';
		file_close(outfile);
		fileCounter := fileCounter + 1;
		--wait;
	end process;*/

end architecture;
