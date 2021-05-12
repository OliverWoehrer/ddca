library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.lcd_graphics_controller_pkg.all;
use work.gfx_if_pkg.all;

entity lcd_graphics_controller_tb is
end entity;

architecture bench of lcd_graphics_controller_tb is
	--clock and reset
	signal clk_s : std_logic;
	signal res_n_s : std_logic;
	signal display_clk_s : std_logic;
	signal display_res_n_s : std_logic;
	
	--instructions signals
	signal gfx_instr_s : std_logic_vector(7 downto 0) := (others => '0');
	signal gfx_instr_wr_s : std_logic := '0';
	signal gfx_instr_full_s : std_logic;
	signal gfx_data_s : std_logic_vector(15 downto 0) := (others => '0');
	signal gfx_data_wr_s : std_logic := '0';
	signal gfx_data_full_s : std_logic;
	signal gfx_frame_sync_s : std_logic;
	
	--sram signals
	signal sram_dq_s : std_logic_vector(SRAM_DATA_WIDTH-1 downto 0);
	signal sram_addr_s : std_logic_vector(SRAM_ADDRESS_WIDTH-1 downto 0);
	signal sram_ub_n_s : std_logic;
	signal sram_lb_n_s : std_logic;
	signal sram_we_n_s : std_logic;
	signal sram_ce_n_s : std_logic;
	signal sram_oe_n_s : std_logic;
	signal write_file_s : std_logic := '0';
	signal data : std_logic_vector(SRAM_DATA_WIDTH-1 downto 0);
	
	--LCD interface signals
	signal nclk_s : std_logic;
	signal hd_s : std_logic;
	signal vd_s : std_logic;
	signal den_s : std_logic;
	signal r_s : std_logic_vector(7 downto 0);
	signal g_s : std_logic_vector(7 downto 0);
	signal b_s : std_logic_vector(7 downto 0);
	signal grest_s : std_logic;
	
	--serial interface signals
	signal sclk_s : std_logic;
	signal sda_s : std_logic;
	signal scen_s : std_logic;
	
	--debug signals
	signal debug_1_s : std_logic_vector(15 downto 0);

	constant CLK_PERIOD : time := 20 ns;
	signal stop_clock : boolean := false;
	
	--componenent declaration
	component sram
	generic (
		OUTPUT_DIR   : string  := "./"
	);
	port (
		-- SRAM interface
		dq     : inout std_logic_vector(15 downto 0);
		addr   : in	std_logic_vector(19 downto 0);
		lb_n   : in	std_logic;
		ub_n   : in	std_logic;
		ce_n   : in	std_logic;
		oe_n   : in	std_logic;
		we_n   : in	std_logic;

		-- on rising_edge: dump frame to file
		write_file : in std_logic;
		base_address : natural := 0;
		width        : natural := 400;
		height       : natural := 240
	);
	end component;
begin

	--instances:
	sram_inst : sram
	generic map (
		OUTPUT_DIR => "./"
	)
	port map (
		-- SRAM interface
		dq				=> sram_dq_s,
		addr			=> sram_addr_s,
		lb_n			=> sram_lb_n_s,
		ub_n			=> sram_ub_n_s,
		ce_n			=> sram_ce_n_s,
		oe_n			=> sram_oe_n_s,
		we_n			=> sram_we_n_s,

		-- on rising_edge: dump frame to file
		write_file	=> write_file_s
	);
	
	
	lcd_controller_inst : lcd_graphics_controller
	port map (
		clk 				=> clk_s,
		res_n				=> res_n_s,
		display_clk		=> display_clk_s,
		display_res_n	=> display_res_n_s,
		gfx_instr		=> gfx_instr_s,
		gfx_instr_wr	=> gfx_instr_wr_s,
		gfx_instr_full	=> gfx_instr_full_s,
		gfx_data			=> gfx_data_s,
		gfx_data_wr		=> gfx_data_wr_s,
		gfx_data_full	=> gfx_data_full_s,
		gfx_frame_sync	=> gfx_frame_sync_s,
		sram_dq			=> sram_dq_s,
		sram_addr		=> sram_addr_s,
		sram_ub_n		=> sram_ub_n_s,
		sram_lb_n		=> sram_lb_n_s,
		sram_we_n		=> sram_we_n_s,
		sram_ce_n		=> sram_ce_n_s,
		sram_oe_n		=> sram_oe_n_s,
		nclk				=> nclk_s,
		hd					=> hd_s,
		vd					=> vd_s,
		den				=> den_s,
		r					=> r_s,
		g					=> g_s,
		b					=> b_s,
		grest				=> grest_s,
		sclk				=> sclk_s,
		sda				=> sda_s,
		scen				=> scen_s
	);
	
	--processes:
	test_sram : process		
	begin
		--apply reset for 5 clock periods
		res_n_s <= '0'; -- apply reset
		wait for 5*CLK_PERIOD;
		wait until rising_edge(clk_s);
		res_n_s <= '1'; -- release reset
		
		--set initial signal values
		wait until rising_edge(clk_s);
		
		
		--set pattern
		gfx_instr_s <= GFX_INSTR_SET_PATTERN(1);
		wait until rising_edge(clk_s);
		gfx_instr_wr_s <= '1'; --enable write mode
		wait until rising_edge(clk_s);
		gfx_instr_wr_s <= '0';
		wait until rising_edge(clk_s);
		
		gfx_data_s <= x"4122"; --set pattern data p0
		wait until rising_edge(clk_s);
		gfx_data_wr_s <= '1';
		wait until rising_edge(clk_s);
		gfx_data_wr_s <= '0';
		wait until rising_edge(clk_s);
		gfx_data_s <= x"0003"; --set pattern data p1
		wait until rising_edge(clk_s);
		gfx_data_wr_s <= '1';
		wait until rising_edge(clk_s);
		gfx_data_wr_s <= '0';
		wait until rising_edge(clk_s);
		
		--draw gfx rect
		gfx_instr_s <= GFX_INSTR_DRAW_RECT(false,true,1);
		wait until rising_edge(clk_s);
		gfx_instr_wr_s <= '1'; --enable write mode
		wait until rising_edge(clk_s);
		gfx_instr_wr_s <= '0';
		wait until rising_edge(clk_s);
		gfx_data_s <= x"0000"; --set x0 to 0
		wait until rising_edge(clk_s);
		gfx_data_wr_s <= '1';
		wait until rising_edge(clk_s);
		gfx_data_wr_s <= '0';
		wait until rising_edge(clk_s);
		gfx_data_s <= x"0000"; --set y0 to 0
		wait until rising_edge(clk_s);
		gfx_data_wr_s <= '1';
		wait until rising_edge(clk_s);
		gfx_data_wr_s <= '0';
		wait until rising_edge(clk_s);
		gfx_data_s <= x"0010"; --set width to 64
		wait until rising_edge(clk_s);
		gfx_data_wr_s <= '1';
		wait until rising_edge(clk_s);
		gfx_data_wr_s <= '0';
		wait until rising_edge(clk_s);
		gfx_data_s <= x"0010"; --set hight to 64
		wait until rising_edge(clk_s);
		gfx_data_wr_s <= '1';
		wait until rising_edge(clk_s);
		gfx_data_wr_s <= '0';
		wait until rising_edge(clk_s);
		
		--draw gfx rect
		gfx_instr_s <= GFX_INSTR_DRAW_RECT(false,true,1);
		wait until rising_edge(clk_s);
		gfx_instr_wr_s <= '1'; --enable write mode
		wait until rising_edge(clk_s);
		gfx_instr_wr_s <= '0';
		wait until rising_edge(clk_s);
		gfx_data_s <= x"0180"; --set x0 to 384
		wait until rising_edge(clk_s);
		gfx_data_wr_s <= '1';
		wait until rising_edge(clk_s);
		gfx_data_wr_s <= '0';
		wait until rising_edge(clk_s);
		gfx_data_s <= x"00E0"; --set y0 to 224
		wait until rising_edge(clk_s);
		gfx_data_wr_s <= '1';
		wait until rising_edge(clk_s);
		gfx_data_wr_s <= '0';
		wait until rising_edge(clk_s);
		gfx_data_s <= x"0010"; --set width to 16
		wait until rising_edge(clk_s);
		gfx_data_wr_s <= '1';
		wait until rising_edge(clk_s);
		gfx_data_wr_s <= '0';
		wait until rising_edge(clk_s);
		gfx_data_s <= x"0010"; --set hight to 16
		wait until rising_edge(clk_s);
		gfx_data_wr_s <= '1';
		wait until rising_edge(clk_s);
		gfx_data_wr_s <= '0';
		wait until rising_edge(clk_s);
		
		wait;
	end process;
	
	end_simulation : process
		variable idleCounter : natural := 0;
	begin
		wait until rising_edge(clk_s);
		if sram_we_n_s = '0' then
			idleCounter := 0;
		else
			idleCounter := idleCounter + 1;
		end if;
		
		if idleCounter = 100 then --terminate simulation
			report "Dumping storage to file";
			wait until rising_edge(clk_s);
			write_file_s <= '1';
			wait until rising_edge(clk_s);
			write_file_s <= '0';
			report "Terminating behavioral simulation";
			stop_clock <= true;
		end if;
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