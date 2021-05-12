----------------------------------------------------------------------------------
--                                LIBRARIES                                     --
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.nes_controller_pkg.all;
use work.ball_game_pkg.all;
use work.ssd_controller_pkg.all;

--------------------------------------------------------------------------------
--                                 TEST BENCH											--
--------------------------------------------------------------------------------
entity ssd_controller_tb is
begin
end entity;

--------------------------------------------------------------------------------
--                               ARCHITECTURE                                 --
--------------------------------------------------------------------------------
architecture bench of ssd_controller_tb is
	--clock and reset signals
	signal clk_s : std_logic;
	signal res_n_s : std_logic;
	
	--ssd controller signals
	signal game_state_s : ball_game_state_t;
	signal player_points_s : std_logic_vector(15 downto 0) := (others => '0');
	signal controller_s : nes_buttons_t;
	signal hex0_s : std_logic_vector(6 downto 0);
	signal hex1_s : std_logic_vector(6 downto 0);
	signal hex2_s : std_logic_vector(6 downto 0);
	signal hex3_s : std_logic_vector(6 downto 0);
	signal hex4_s : std_logic_vector(6 downto 0);
	signal hex5_s : std_logic_vector(6 downto 0);
	signal hex6_s : std_logic_vector(6 downto 0);
	signal hex7_s : std_logic_vector(6 downto 0);
	
	--generic constants
	constant BLINK_INTERVAL : natural := 6;
	constant BLINK_COUNT : natural := 3;
	constant ANIMATION_INTERVAL : natural := 4;
	
	--for clock generator
	constant DELAY : time := 100 us;
	constant CLK_PERIOD : time := 20 ns;
	signal stop_clock : boolean := false;
begin
	uut: ssd_controller
	generic map (
		BLINK_INTERVAL, --BLINK_INTERVAL
		BLINK_COUNT,--BLINK_COUNT
		ANIMATION_INTERVAL
	)
	port map (
		clk 				=> clk_s,
		res_n				=> res_n_s,
		game_state		=> game_state_s,
		player_points	=> player_points_s,
		controller		=> controller_s,
		hex0				=> hex0_s,
		hex1				=> hex1_s,
		hex2				=> hex2_s,
		hex3				=> hex3_s,
		hex4				=> hex4_s,
		hex5				=> hex5_s,
		hex6				=> hex6_s,
		hex7				=> hex7_s
	);
	
	--behavioral simulation
	beh: process

	begin
		--apply reset for 5 clock periods
		res_n_s <= '0'; -- apply reset
		wait for 5*CLK_PERIOD;
		wait until rising_edge(clk_s);
		res_n_s <= '1'; -- release reset
		
		--set initial values
		wait for 1*CLK_PERIOD;
		
		--test animation
		game_state_s <= IDLE;
		wait for 5*ANIMATION_INTERVAL*CLK_PERIOD;
		game_state_s <= PAUSED;
		wait for 5*ANIMATION_INTERVAL*CLK_PERIOD;
		game_state_s <= RUNNING;
		wait for 5*ANIMATION_INTERVAL*CLK_PERIOD;
		
		
		
		--test player points
		player_points_s <= x"0511"; --test value: 1297
		wait for 3*BLINK_COUNT*BLINK_INTERVAL*CLK_PERIOD;
		player_points_s <= x"A123"; --test value: 41251
		wait for 3*BLINK_COUNT*BLINK_INTERVAL*CLK_PERIOD;
		player_points_s <= x"0AF2"; --test value: 2802
		wait for 3*BLINK_COUNT*BLINK_INTERVAL*CLK_PERIOD;
		
		
		
		--terminate simulation
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