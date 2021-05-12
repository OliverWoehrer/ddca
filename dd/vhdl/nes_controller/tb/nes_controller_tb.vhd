----------------------------------------------------------------------------------
--                                LIBRARIES                                     --
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.nes_controller_pkg.all;

--------------------------------------------------------------------------------
--                                 TEST BENCH											--
--------------------------------------------------------------------------------
entity nes_controller_tb is
begin
end entity;

--------------------------------------------------------------------------------
--                               ARCHITECTURE                                 --
--------------------------------------------------------------------------------
architecture bench of nes_controller_tb is
	--nes controller signal
	signal clk_s : std_logic;
	signal res_n_s : std_logic;
	signal nes_clk_s : std_logic;
	signal nes_latch_s : std_logic;
	signal nes_data_s : std_logic;
	signal button_state_s : nes_buttons_t;
	
	--for clock generator
	constant CLK_PERIOD : time := 20 ns;
	signal stop_clock : boolean := false;
begin

	uut: nes_controller
	generic map (
		50000000, --clk:=50MHz
		1000000,	 --clk_out:=1MHz
		200 --time out
	)
	port map (
		clk			=> clk_s,
		res_n			=> res_n_s,
		nes_clk		=> nes_clk_s,
		nes_latch	=> nes_latch_s,
		nes_data		=> nes_data_s,
		button_state=> button_state_s
	);
	
	--behavioral simulation
	beh: process
		--button state values
		variable b0 : std_logic_vector(7 downto 0) := x"EB"; --originally EB
		variable b1 : std_logic_vector(7 downto 0) := x"B1"; --originally B1
	begin
		--apply reset for 5 clock periods
		res_n_s <= '0'; -- apply reset
		wait for 5*CLK_PERIOD;
		wait until rising_edge(clk_s);
		res_n_s <= '1'; -- release reset
		
		--set initial values
		nes_data_s <= '0';
		wait until rising_edge(clk_s);
		
		--wait for latch
		wait until rising_edge(nes_latch_s);
		
		--shift nes data b0 (MSB first)
		report "shifting data out of device";
		for i in 7 downto 0 loop
			wait until falling_edge(nes_clk_s);
			nes_data_s <= not b0(i);
			wait until rising_edge(nes_clk_s);
		end loop;
		
		--shift nes data b1 (MSB first)
		report "shifting data out of device";
		for i in 7 downto 0 loop
			wait until falling_edge(nes_clk_s);
			nes_data_s <= not b1(i);
			wait until rising_edge(nes_clk_s);
		end loop;
		
		--terminate simulation
		wait for 200*2*CLK_PERIOD;
		report "Terminating behavioral simulation";
		stop_clock <= true;
	end process;
	

	--generate clock cycles
	clk_generator: process
	begin
		clk_s <= '1';
		wait for CLK_PERIOD / 2;
		clk_s <= '0';
		wait for CLK_PERIOD / 2;
		if stop_clock then
			wait;
		end if;
	end process;
	
end architecture;