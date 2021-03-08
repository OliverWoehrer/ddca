library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_tb is
end entity;

architecture bench of top_tb is

	component top is
		port (
			clk : in std_logic;
			keys : in std_logic_vector(3 downto 0);
			switches : in std_logic_vector(17 downto 0);
			hex0 : out std_logic_vector(6 downto 0);
			hex1 : out std_logic_vector(6 downto 0);
			hex2 : out std_logic_vector(6 downto 0);
			hex3 : out std_logic_vector(6 downto 0);
			hex4 : out std_logic_vector(6 downto 0);
			hex5 : out std_logic_vector(6 downto 0);
			hex6 : out std_logic_vector(6 downto 0);
			hex7 : out std_logic_vector(6 downto 0);
			ledg : out std_logic_vector(8 downto 0);
			ledr : out std_logic_vector(17 downto 0);
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
			scen : out std_logic;
			rx : in std_logic;
			tx : out std_logic;
			emulated_nes_clk : in std_logic;
			emulated_nes_latch : in std_logic;
			emulated_nes_data : out std_logic;
			nes_clk : out std_logic;
			nes_latch : out std_logic;
			nes_data : in std_logic;
			sram_dq : inout std_logic_vector(15 downto 0);
			sram_addr : out std_logic_vector(19 downto 0);
			sram_ub_n : out std_logic;
			sram_lb_n : out std_logic;
			sram_we_n : out std_logic;
			sram_ce_n : out std_logic;
			sram_oe_n : out std_logic;
			wm8731_xck : out std_logic;
			wm8731_sdat : inout std_logic;
			wm8731_sclk : inout std_logic;
			wm8731_dacdat : out std_logic;
			wm8731_daclrck : out std_logic;
			wm8731_bclk : out std_logic;
			osci_ch2 : out std_logic;
			osci_ch3 : out std_logic;
			osci_ch4 : out std_logic;
			vga_r : out std_logic_vector(7 downto 0);
			vga_g : out std_logic_vector(7 downto 0);
			vga_b : out std_logic_vector(7 downto 0);
			vga_clk : out std_logic;
			vga_sync_n : out std_logic;
			vga_blank_n : out std_logic
		);
	end component;

	signal clk : std_logic;
	signal keys : std_logic_vector(3 downto 0);
	signal switches : std_logic_vector(17 downto 0);
	signal hex0 : std_logic_vector(6 downto 0);
	signal hex1 : std_logic_vector(6 downto 0);
	signal hex2 : std_logic_vector(6 downto 0);
	signal hex3 : std_logic_vector(6 downto 0);
	signal hex4 : std_logic_vector(6 downto 0);
	signal hex5 : std_logic_vector(6 downto 0);
	signal hex6 : std_logic_vector(6 downto 0);
	signal hex7 : std_logic_vector(6 downto 0);
	signal ledg : std_logic_vector(8 downto 0);
	signal ledr : std_logic_vector(17 downto 0);
	signal nclk : std_logic;
	signal hd : std_logic;
	signal vd : std_logic;
	signal den : std_logic;
	signal r : std_logic_vector(7 downto 0);
	signal g : std_logic_vector(7 downto 0);
	signal b : std_logic_vector(7 downto 0);
	signal grest : std_logic;
	signal sclk : std_logic;
	signal sda : std_logic;
	signal scen : std_logic;
	signal rx : std_logic;
	signal tx : std_logic;
	signal emulated_nes_clk : std_logic;
	signal emulated_nes_latch : std_logic;
	signal emulated_nes_data : std_logic;
	signal nes_clk : std_logic;
	signal nes_latch : std_logic;
	signal nes_data : std_logic;
	signal sram_dq : std_logic_vector(15 downto 0);
	signal sram_addr : std_logic_vector(19 downto 0);
	signal sram_ub_n : std_logic;
	signal sram_lb_n : std_logic;
	signal sram_we_n : std_logic;
	signal sram_ce_n : std_logic;
	signal sram_oe_n : std_logic;
	signal wm8731_xck : std_logic;
	signal wm8731_sdat : std_logic;
	signal wm8731_sclk : std_logic;
	signal wm8731_dacdat : std_logic;
	signal wm8731_daclrck : std_logic;
	signal wm8731_bclk : std_logic;
	signal vga_r : std_logic_vector(7 downto 0);
	signal vga_g : std_logic_vector(7 downto 0);
	signal vga_b : std_logic_vector(7 downto 0);
	signal vga_clk : std_logic;
	signal vga_sync_n : std_logic;
	signal vga_blank_n : std_logic;

	constant CLK_PERIOD : time := 20 ns;
	signal stop_clock : boolean := false;
begin

	uut : top
		port map (
			clk                => clk,
			keys               => keys,
			switches           => switches,
			hex0               => hex0,
			hex1               => hex1,
			hex2               => hex2,
			hex3               => hex3,
			hex4               => hex4,
			hex5               => hex5,
			hex6               => hex6,
			hex7               => hex7,
			ledg               => ledg,
			ledr               => ledr,
			nclk               => nclk,
			hd                 => hd,
			vd                 => vd,
			den                => den,
			r                  => r,
			g                  => g,
			b                  => b,
			grest              => grest,
			sclk               => sclk,
			sda                => sda,
			scen               => scen,
			rx                 => rx,
			tx                 => tx,
			emulated_nes_clk   => emulated_nes_clk,
			emulated_nes_latch => emulated_nes_latch,
			emulated_nes_data  => emulated_nes_data,
			nes_clk            => nes_clk,
			nes_latch          => nes_latch,
			nes_data           => nes_data,
			sram_dq            => sram_dq,
			sram_addr          => sram_addr,
			sram_ub_n          => sram_ub_n,
			sram_lb_n          => sram_lb_n,
			sram_we_n          => sram_we_n,
			sram_ce_n          => sram_ce_n,
			sram_oe_n          => sram_oe_n,
			wm8731_xck         => wm8731_xck,
			wm8731_sdat        => wm8731_sdat,
			wm8731_sclk        => wm8731_sclk,
			wm8731_dacdat      => wm8731_dacdat,
			wm8731_daclrck     => wm8731_daclrck,
			wm8731_bclk        => wm8731_bclk,
			vga_r              => vga_r,
			vga_g              => vga_g,
			vga_b              => vga_b,
			vga_clk            => vga_clk,
			vga_sync_n         => vga_sync_n,
			vga_blank_n        => vga_blank_n,
			osci_ch2           => open,
			osci_ch3           => open,
			osci_ch4           => open
		);

	stimulus : process
	begin
		keys <= (others=>'0');
		switches <= (others=>'0');
		rx <= '0';
		emulated_nes_clk <= '0';
		emulated_nes_latch <= '0';
		nes_data <= '0';
		keys(0) <= '0'; -- apply reset
		wait for 250 ns;
		wait until rising_edge(clk);
		keys(0) <= '1'; -- release reset
		
		wait for 50 us;
		
		stop_clock <= true;
		wait;
	end process;

	generate_clk : process
	begin
		while not stop_clock loop
			clk <= '0', '1' after CLK_PERIOD / 2;
			wait for CLK_PERIOD;
		end loop;
		wait;
	end process;

end architecture;

