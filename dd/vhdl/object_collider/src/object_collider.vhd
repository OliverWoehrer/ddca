
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use work.math_pkg.all;

use work.object_collider_pkg.all;

entity object_collider is
	generic(
		DISPLAY_WIDTH    : integer := 400;
		DISPLAY_HEIGHT   : integer := 240
	);
	port (
		clk   : in std_logic;
		res_n : in std_logic;
		
		--control signals
		start : in std_logic;
		done  : out std_logic;
		apply_movement : in std_logic;
		apply_gravity : in std_logic;
		
		-- player information
		player : in game_object_t;
		player_speed : in std_logic_vector(GAME_OBJECT_SPEED_WIDTH-1 downto 0);
		player_dir : in std_logic;
		gravity : in std_logic_vector(GAME_OBJECT_SPEED_WIDTH-1 downto 0);
		player_x : out std_logic_vector(COORDINATE_WIDTH-1 downto 0);
		player_y : out std_logic_vector(COORDINATE_WIDTH-1 downto 0);

		-- block information
		object : in game_object_t;
		object_req : out std_logic;
		object_valid : in std_logic;
		object_is_blocking : in std_logic;
		object_eol : in std_logic;

		collision_detected  : out std_logic
	);
end entity;

architecture arch of object_collider is 
	type state_t is (
		IDLE, READY,
		MOVE_PLAYER_GRAVITY, G_REQ_OBJ, G_WAIT_OBJ, G_CHECK_OBJ,
		MOVE_PLAYER, P_REQ_OBJ, P_WAIT_OBJ, P_CHECK_OBJ);
	signal state : state_t;
	
	signal player_int : game_object_t;
	signal gravity_int : std_logic_vector(gravity'range);
	signal player_speed_int : std_logic_vector(player_speed'range);
	signal player_dir_int : std_logic;
	
	signal apply_movement_int : std_logic;
	signal apply_gravity_int : std_logic;
	
	signal collision : std_logic;
	signal blocked : std_logic;
	
	
	
begin
	sync : process(clk, res_n)
	begin
		if (res_n = '0') then
			state <= IDLE;
			done <= '0';
			object_req <= '0';
			gravity_int <= (others=>'0');
			player_int <= GAME_OBJECT_NULL;
			player_speed_int <= (others=>'0');
			player_dir_int <= '0';
			blocked <= '0';
			player_x <= (others=>'0');
			player_y <= (others=>'0');
			collision_detected <= '0';
			apply_movement_int <= '0';
			apply_gravity_int <= '0';
		elsif (rising_edge(clk)) then
			collision_detected <= '0';
			done <= '0';
			case state is
				when IDLE =>
					done <= '0';
					object_req <= '0';
					if(start = '1') then
						state <= MOVE_PLAYER_GRAVITY;
						gravity_int <= gravity;
						player_speed_int <= player_speed;
						player_dir_int <= player_dir;
						player_int <= player;
						apply_movement_int <= apply_movement;
						apply_gravity_int <= apply_gravity;
						blocked <= '0';
					end if;
					
				when MOVE_PLAYER_GRAVITY =>
					if (apply_gravity_int = '0' or unsigned(gravity_int) = 0 or blocked = '1') then
						state <= MOVE_PLAYER;
						blocked <= '0';
					else
						state <= G_REQ_OBJ;
						blocked <= '0';
						player_int.y <= std_logic_vector(signed(player_int.y) + 1);
						gravity_int <= std_logic_vector(unsigned(gravity_int) - 1);
					end if;
				
				when G_REQ_OBJ =>
					object_req <= '1';
					state <= G_WAIT_OBJ;
				
				when G_WAIT_OBJ =>
					if (object_eol = '1') then
						state <= MOVE_PLAYER_GRAVITY;
						object_req <= '0';
					elsif (object_valid = '1') then
						state <= G_CHECK_OBJ;
						object_req <= '0';
					end if;
					
				when G_CHECK_OBJ =>
					if (collision = '1') then
						if (object_is_blocking = '1') then
							player_int.y <= std_logic_vector(signed(player_int.y) - 1);
							blocked <= '1';
						else
							collision_detected <= '1';
						end if;
					end if;
					state <= G_REQ_OBJ;
				
				when MOVE_PLAYER =>
					if (apply_movement_int = '0') then
						state <= READY;
						blocked <= '0';
					elsif (player_dir_int = DIR_LEFT and signed(player_int.x) <= 0) then
						state <= READY;
						player_int.x <= (others=>'0');
						blocked <= '0';
					elsif (player_dir_int = DIR_RIGHT and signed(player_int.x) + signed(player_int.w) >= DISPLAY_WIDTH) then
						state <= READY;
						player_int.x <= std_logic_vector(DISPLAY_WIDTH - signed(player_int.w));
						blocked <= '0';
					elsif(unsigned(player_speed_int) = 0 or blocked = '1') then
						state <= READY;
						blocked <= '0';
					else
						state <= P_REQ_OBJ;
						blocked <= '0';
						if (player_dir_int = '1') then
							player_int.x <= std_logic_vector(signed(player_int.x) + 1);
						else
							player_int.x <= std_logic_vector(signed(player_int.x) - 1);
						end if;
						player_speed_int <= std_logic_vector(unsigned(player_speed_int) - 1);
					end if;
				
				when P_REQ_OBJ =>
					object_req <= '1';
					state <= P_WAIT_OBJ;
				
				when P_WAIT_OBJ =>
					if (object_eol = '1') then
						state <= MOVE_PLAYER;
						object_req <= '0';
					elsif (object_valid = '1') then
						state <= P_CHECK_OBJ;
						object_req <= '0';
					end if;
					
				when P_CHECK_OBJ =>
					if (collision = '1') then
						if (object_is_blocking = '1') then
							if (player_dir_int = '1') then
								player_int.x <= std_logic_vector(signed(player_int.x) - 1);
							else
								player_int.x <= std_logic_vector(signed(player_int.x) + 1);
							end if;
							blocked <= '1';
						else
							collision_detected <= '1';
						end if;
					end if;
					state <= P_REQ_OBJ;
				
				when READY =>
					state <= IDLE;
					done <= '1';
					player_x <= player_int.x;
					player_y <= player_int.y;
				
			end case;
		end if;
	end process;

	collide : process(all)
	begin
		collision <= '0';
		if (signed(player_int.x) < signed(object.x) + signed(object.w) and
			signed(player_int.x) + signed(player_int.w) > signed(object.x) and
			signed(player_int.y) < signed(object.y) + signed(object.h) and
			signed(player_int.y) + signed(player_int.h) > signed(object.y)) then
			collision <= '1';
		end if;
	end process; 

end architecture;
