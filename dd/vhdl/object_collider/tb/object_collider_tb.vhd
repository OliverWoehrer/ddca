library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.object_collider_pkg.all;

entity object_collider_tb is
end entity;

architecture bench of object_collider_tb is

	constant DISPLAY_WIDTH : integer := 400;
	constant DISPLAY_HEIGHT : integer := 240;
	signal clk : std_logic;
	signal res_n : std_logic;
	signal start : std_logic;
	signal done : std_logic;
	signal player : game_object_t;
	signal player_speed : std_logic_vector(GAME_OBJECT_SPEED_WIDTH-1 downto 0);
	signal player_dir : std_logic;
	signal apply_gravity : std_logic;
	signal apply_movement : std_logic;
	signal gravity : std_logic_vector(GAME_OBJECT_SPEED_WIDTH-1 downto 0);
	signal object : game_object_t;
	signal object_req : std_logic;
	signal object_valid : std_logic;
	signal object_is_blocking : std_logic;
	signal object_eol : std_logic;
	signal collision_detected : std_logic;
	signal player_x : std_logic_vector(COORDINATE_WIDTH-1 downto 0);
	signal player_y : std_logic_vector(COORDINATE_WIDTH-1 downto 0);

	
	type game_object_vec_t is array(integer range<>) of game_object_t;
	
	-- the game object list
	constant GAME_OBJECTS : game_object_vec_t (0 to 2) := (
		create_game_object(x=>20, y=>50, w=>100, h=>10,  id => "00"),
		create_game_object(x=>120, y=>80, w=>100, h=>10, id => "00"),
		create_game_object(x=>200, y=>75, w=>4, h=>4, id => "11")
	);
	
	
	-- simple sketch of the simulation scenario
	--------------------------------
	--            P ->             
	--  50-    ┌────────┐           
	--         └────────┘           
	--                         []   
	--  80-             ┌────────┐  
	--                  └────────┘  
	--         '        '        '   
	--         20      120      220  
	---------------------------------

	constant CLK_PERIOD : time := 10 ns;
	signal stop_clock : boolean := false;
begin

	uut : object_collider
	generic map (
		DISPLAY_WIDTH  => DISPLAY_WIDTH,
		DISPLAY_HEIGHT => DISPLAY_HEIGHT
	)
	port map (
		clk                => clk,
		res_n              => res_n,
		start              => start,
		done               => done,
		player_x           => player_x,
		player_y           => player_y,
		player             => player,
		player_speed       => player_speed,
		player_dir         => player_dir,
		gravity            => gravity,
		apply_movement     => apply_movement,
		apply_gravity      => apply_gravity,
		object             => object,
		object_req         => object_req,
		object_valid       => object_valid,
		object_is_blocking => object_is_blocking,
		object_eol         => object_eol,
		collision_detected => collision_detected
	);

	stimulus : process
	begin
		res_n <= '0';
		start <= '0';
		player_dir <= '0';
		gravity <= (others=>'0');
		player_speed <= (others=>'0');
		player <= GAME_OBJECT_NULL;
		apply_gravity <= '0';
		apply_movement <= '0';
		
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		res_n <= '1';
		
		player <= create_game_object(x=>50, y=>40, w=>8, h=>8, id=>"00");
		gravity <= std_logic_vector(to_unsigned(4, gravity'length));
		player_speed <= std_logic_vector(to_unsigned(4, player_speed'length));
		player_dir <= DIR_RIGHT;
		apply_gravity <= '1';
		apply_movement <= '1';
		
		loop
			wait until rising_edge(clk);
			start <= '1';
			wait until rising_edge(clk);
			start <= '0';
		
			wait until done = '1';
		
			player.x <= player_x;
			player.y <= player_y;
			wait until rising_edge(clk);
			wait for CLK_PERIOD*10;
			
			if (signed(player.y) > 100) then
				exit;
			end if;
		end loop;
		
		stop_clock <= true;
		wait;
	end process;

	object_list : process
		variable obj_idx : integer := 0;
	begin
		object_valid <= '0';
		object_is_blocking <= '0';
		object_eol <= '0';
		object <= GAME_OBJECT_NULL;
		wait until rising_edge(res_n);
	
		loop
			if (object_req /= '1') then
				wait until object_req = '1';
			end if;
			
			wait until rising_edge(clk);
	
			if (obj_idx = GAME_OBJECTS'length) then
				obj_idx := 0;
				object_is_blocking <= '0';
				object_eol <= '1';
				wait until rising_edge(clk);
				object_eol <= '0';
			else
				object <= GAME_OBJECTS(obj_idx);
				if (GAME_OBJECTS(obj_idx).id = "00") then
					object_is_blocking <= '1';
				else
					object_is_blocking <= '0';
				end if;
				object_valid <= '1';
				wait until rising_edge(clk);
				object_valid <= '0';
				obj_idx := obj_idx + 1;
			end if;
			
			wait until rising_edge(clk);
		end loop;
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

