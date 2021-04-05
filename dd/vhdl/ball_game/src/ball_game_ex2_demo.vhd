library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.gfx_if_pkg.all;
use work.math_pkg.all;
use work.nes_controller_pkg.all;
use work.audio_cntrl_pkg.all;
use work.object_collider_pkg.all;
use work.object_fifo_pkg.all;
use work.ball_game_pkg.all;
use work.prng_pkg.all;
use work.ram_pkg.all;

architecture arch_ex2_demo of ball_game is
	
	constant PLAYER_BALL_RADIUS : integer := 6;
	constant PLAYER_SPEED : integer := 4;
	
	constant BG_COLOR    : std_logic_vector(15 downto 0) := x"0000";
	constant BRICK_COLOR : std_logic_vector(15 downto 0) := x"ff03";
	
	type fsm_state_t is (
		RESET, 
		INIT_GFX_CNTRL, INIT_GFX_CNTRL_WAIT,
		SEED_PRNG,
		PLACE_ITEM_AND_PLAYER,
		PERFORM_FRAME_SYNC, WAIT_FRAME_SYNC,
		MOVE_PLAYER,
		MOVE_PLAYER_WAIT_OBJECT_REQ,
		MOVE_PLAYER_OBJECT_VALID,
		MOVE_PLAYER_WAIT_CYCLE,
		MOVE_PLAYER_CHECK_COLLISION,
		MOVE_PLAYER_DONE,
		CLEAR_SCREEN,
		DRAW_BRICK1_INSTR, 
		B1_X, B1_Y, B1_WIDTH, B1_HEIGHT,
		DRAW_BRICK2_INSTR, 
		B2_X, B2_Y, B2_WIDTH, B2_HEIGHT,
		DRAW_ITEM_INSTR, 
		ITEM_X, ITEM_Y, ITEM_WIDTH, ITEM_HEIGHT,
		DRAW_PLAYER_INSTR,
		DRAW_PLAYER_X, DRAW_PLAYER_Y, DRAW_PLAYER_RADIUS,
		FRAME_DONE
	);
	
	constant BRICK1 : game_object_t := create_game_object(DISPLAY_WIDTH/2-32, 80, 64, 12, "00");
	constant BRICK2 : game_object_t := create_game_object(4, 200, DISPLAY_WIDTH-8, 12, "00");
	
	signal fsm_state, fsm_state_next : fsm_state_t;
	signal player, player_next : game_object_t;
	signal game_object_cnt, game_object_cnt_next : integer range 0 to 3 := 0;
	signal item, item_next : game_object_t;
	signal item_collected, item_collected_next : std_logic;
	
	signal player_points_next : std_logic_vector(player_points'range);
	
	--gfx controller initializer
	signal init_gfx_instr : std_logic_vector(GFX_INSTR_WIDTH-1 downto 0);
	signal init_gfx_instr_wr : std_logic;
	signal init_gfx_data : std_logic_vector(GFX_DATA_WIDTH-1 downto 0);
	signal init_gfx_data_wr : std_logic;
	signal gfx_initializer_start : std_logic;
	signal gfx_initializer_busy : std_logic;

	
	-- object collider
	signal oc_start : std_logic;
	signal oc_done : std_logic;
	signal oc_apply_movement : std_logic;
	signal oc_apply_gravity : std_logic;
	signal oc_player_speed : std_logic_vector(GAME_OBJECT_SPEED_WIDTH-1 downto 0);
	signal oc_player_dir : std_logic;
	signal oc_gravity :  std_logic_vector(GAME_OBJECT_SPEED_WIDTH-1 downto 0);
	signal oc_object_req : std_logic;
	signal oc_object_valid : std_logic;
	signal oc_object_eol : std_logic;
	signal oc_object : game_object_t;
	signal oc_object_is_blocking : std_logic;
	signal oc_collision_detected : std_logic;
	signal oc_player_x : std_logic_vector(COORDINATE_WIDTH-1 downto 0);
	signal oc_player_y : std_logic_vector(COORDINATE_WIDTH-1 downto 0);
	
	-- random number generation related signals
	signal prdata : std_logic_vector(9 downto 0);
	signal load_seed : std_logic;
	
	-- signals providing a random (x) position for the item placed on BRICK2
	signal random_x_pos : std_logic_vector(log2c(DISPLAY_WIDTH)-1 downto 0);
	signal random_x_pos_valid : std_logic;
begin

	game_state <= RUNNING;

	sync : process(clk, res_n)
	begin
		if (res_n = '0') then
			fsm_state  <= RESET;
			player <= GAME_OBJECT_NULL;
			item <= GAME_OBJECT_NULL;
			game_object_cnt <= 0;
			item_collected <= '0';
			player_points <= (others=>'0');
		elsif (rising_edge(clk)) then
			fsm_state <= fsm_state_next;
			player <= player_next;
			item <= item_next;
			game_object_cnt <= game_object_cnt_next;
			player_points <= player_points_next;
			item_collected <= item_collected_next;
		end if;
	end process;
	
	next_state_logic : process(all)
		-- utility functions to write to the graphics controller
		procedure write_gfx_data_and_goto(data : std_logic_vector; state : fsm_state_t) is
		begin
			if (gfx_data_full = '0') then
				gfx_data(data'range) <= data;
				gfx_data_wr <= '1';
				fsm_state_next <= state;
			end if;
		end procedure;
		
		procedure write_gfx_instr_and_goto(instr : std_logic_vector; state : fsm_state_t) is
		begin
			if (gfx_instr_full = '0') then
				gfx_instr <= instr;
				gfx_instr_wr <= '1';
				fsm_state_next <= state;
			end if;
		end procedure;
	begin
		-- prepare next state signals 
		fsm_state_next <= fsm_state;
		item_next <= item;
		player_next <= player;
		game_object_cnt_next <= game_object_cnt;
		player_points_next <= player_points;
		item_collected_next <= item_collected;
		
		-- the size of the player never changes
		player_next.w <= std_logic_vector(to_unsigned(2*PLAYER_BALL_RADIUS+1,COORDINATE_WIDTH));
		player_next.h <= std_logic_vector(to_unsigned(2*PLAYER_BALL_RADIUS+1,COORDINATE_WIDTH));
	
		--only set once when the core comes out of reset
		load_seed <= '0';
		
		-- interface to graphics controller
		gfx_instr <= (others=>'0');
		gfx_instr_wr <= '0';
		gfx_data <= (others=>'0');
		gfx_data_wr <= '0';
		
		--object collider signal
		oc_start <= '0';
		oc_object_valid <= '0';
		oc_object_eol <= '0';
		oc_player_dir <= '0';
		oc_player_speed <= std_logic_vector(to_unsigned(4, oc_gravity'length));
		oc_gravity <= std_logic_vector(to_unsigned(4, oc_gravity'length));
		oc_apply_gravity <= '0';
		oc_apply_movement <= '0';
		
		gfx_initializer_start <= '0';
		
		case fsm_state is
			when RESET =>
				fsm_state_next <= INIT_GFX_CNTRL;
			
			when INIT_GFX_CNTRL =>
				gfx_initializer_start <= '1';
				fsm_state_next <= INIT_GFX_CNTRL_WAIT;
			
			when INIT_GFX_CNTRL_WAIT =>
				gfx_instr <= init_gfx_instr;
				gfx_instr_wr <= init_gfx_instr_wr;
				gfx_data <= init_gfx_data;
				gfx_data_wr <= init_gfx_data_wr;
				if (gfx_initializer_busy = '0') then
					fsm_state_next <= SEED_PRNG;
				end if;
			
			when SEED_PRNG =>
				-- initialize the PRNG
				load_seed <= '1';
				fsm_state_next <= PLACE_ITEM_AND_PLAYER;
			
			when PLACE_ITEM_AND_PLAYER => 
				-- wait for a valid random position
				if (random_x_pos_valid = '1') then
					item_collected_next <= '0'; -- reset the flag that indicated that a collision with the item happend 
					
					item_next.id <= "11"; -- use an id different form 00, because 00 identifies blocking game objects
					item_next.y <= std_logic_vector(to_unsigned(190, item.y'length)); -- place item on the lower brick (BRICK2)
					item_next.w <= std_logic_vector(to_unsigned(8, item.w'length));
					item_next.h <= std_logic_vector(to_unsigned(8, item.h'length));
					item_next.x <= (others=>'0');
					item_next.x(random_x_pos'range) <= random_x_pos; -- use the random value for the x position
					
					-- reset player position
					player_next.x <= std_logic_vector(to_unsigned(DISPLAY_WIDTH/2-PLAYER_BALL_RADIUS, player.x'length));
					player_next.y <= std_logic_vector(to_unsigned(0, player.y'length));
					
					fsm_state_next <= PERFORM_FRAME_SYNC;
				end if;
			
			when PERFORM_FRAME_SYNC =>
				--check if the gfx instr interface is ready and issue a frame sync instruction
				if (gfx_instr_full = '0') then
					gfx_instr <= GFX_INSTR_FRAME_SYNC;
					gfx_instr_wr <= '1';
					fsm_state_next <= WAIT_FRAME_SYNC;
				end if;
			
			when WAIT_FRAME_SYNC =>
				if (gfx_frame_sync = '1') then
					fsm_state_next <= MOVE_PLAYER;
				end if;
			
			when MOVE_PLAYER =>
				if ( (controller.btn_left or controller.btn_right) = '1') then
					oc_apply_movement <= '1';
				end if;
				oc_player_dir <= controller.btn_right;
				oc_apply_gravity <= '1';
				
				fsm_state_next <= MOVE_PLAYER_WAIT_OBJECT_REQ;
				game_object_cnt_next <= 0;
				
				oc_start <= '1'; -- start the object collider
				
			when MOVE_PLAYER_WAIT_OBJECT_REQ =>
				-- wait for the object collider to either
				--  (a) request a game object to check for collision or
				--  (b) indicate that it has completed its operation
				if (oc_object_req = '1') then
					fsm_state_next <= MOVE_PLAYER_OBJECT_VALID;
				elsif (oc_done = '1') then
					fsm_state_next <= MOVE_PLAYER_DONE;
				end if;
			
			when MOVE_PLAYER_OBJECT_VALID =>
				-- in this demo there are 3 game objects (2 bricks and one item)
				-- if game_object_cnt is 3 all objects have been processed
				-- by the object collider, hence we have to notify it that 
				-- there are no more objects left.
				if (game_object_cnt = 3) then
					oc_object_eol <= '1';
					fsm_state_next <= MOVE_PLAYER_WAIT_OBJECT_REQ;
					game_object_cnt_next <= 0;
				else
					oc_object_valid <= '1';
					fsm_state_next <= MOVE_PLAYER_WAIT_CYCLE;
				end if;
			
			when MOVE_PLAYER_WAIT_CYCLE =>
				fsm_state_next <= MOVE_PLAYER_CHECK_COLLISION;
			
			when MOVE_PLAYER_CHECK_COLLISION =>
				-- check if there was a collision with the item currently applied
				-- to the input of the object collider (oc_object)
				-- since the bricks are marked as blocking (oc_object_is_blocking = '1'),
				-- collisions with them will not be reported
				if (oc_collision_detected = '1' and item_collected = '0') then
					player_points_next <= std_logic_vector(unsigned(player_points) + 1);
					item_collected_next <= '1';
				end if;
				game_object_cnt_next <= game_object_cnt + 1;
				fsm_state_next <= MOVE_PLAYER_WAIT_OBJECT_REQ;
			
			when MOVE_PLAYER_DONE =>
				player_next.x <= oc_player_x;
				player_next.y <= oc_player_y;
				fsm_state_next <= CLEAR_SCREEN;
			
			--██████╗ ██████╗  █████╗ ██╗    ██╗
			--██╔══██╗██╔══██╗██╔══██╗██║    ██║
			--██║  ██║██████╔╝███████║██║ █╗ ██║
			--██║  ██║██╔══██╗██╔══██║██║███╗██║
			--██████╔╝██║  ██║██║  ██║╚███╔███╔╝
			--╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚══╝╚══╝ 
			when CLEAR_SCREEN =>
				write_gfx_instr_and_goto(GFX_INSTR_CLEAR, DRAW_BRICK1_INSTR);
			
			-- draw the rectangle representing BRICK1
			when DRAW_BRICK1_INSTR =>
				write_gfx_instr_and_goto(GFX_INSTR_DRAW_RECT(enable_alpha=>true, draw_border=>true, pattern_id=>0), B1_X);
			when B1_X      => write_gfx_data_and_goto(BRICK1.x, B1_Y);
			when B1_Y      => write_gfx_data_and_goto(BRICK1.y, B1_WIDTH);
			when B1_WIDTH  => write_gfx_data_and_goto(BRICK1.w, B1_HEIGHT);
			when B1_HEIGHT => write_gfx_data_and_goto(BRICK1.h, DRAW_BRICK2_INSTR);
			
			-- draw the rectangle representing BRICK2
			when DRAW_BRICK2_INSTR =>
				write_gfx_instr_and_goto(GFX_INSTR_DRAW_RECT(enable_alpha=>true, draw_border=>true, pattern_id=>0), B2_X);
			when B2_X      => write_gfx_data_and_goto(BRICK2.x, B2_Y);
			when B2_Y      => write_gfx_data_and_goto(BRICK2.y, B2_WIDTH);
			when B2_WIDTH  => write_gfx_data_and_goto(BRICK2.w, B2_HEIGHT);
			when B2_HEIGHT => write_gfx_data_and_goto(BRICK2.h, DRAW_ITEM_INSTR);
			
			-- draw the rectangle representing the randomly placed item
			when DRAW_ITEM_INSTR => 
				write_gfx_instr_and_goto(GFX_INSTR_DRAW_RECT(enable_alpha=>true, draw_border=>true, pattern_id=>7), ITEM_X);
			when ITEM_X      => write_gfx_data_and_goto(item.x, ITEM_Y);
			when ITEM_Y      => write_gfx_data_and_goto(item.y, ITEM_WIDTH);
			when ITEM_WIDTH  => write_gfx_data_and_goto(item.w, ITEM_HEIGHT);
			when ITEM_HEIGHT => write_gfx_data_and_goto(item.h, DRAW_PLAYER_INSTR);
			
			--draw a circle representing the player
			when DRAW_PLAYER_INSTR =>
				write_gfx_instr_and_goto(GFX_INSTR_DRAW_CIRCLE, DRAW_PLAYER_X);
			
			when DRAW_PLAYER_X =>
				write_gfx_data_and_goto(std_logic_vector(unsigned(player.x)+PLAYER_BALL_RADIUS), DRAW_PLAYER_Y);
			
			when DRAW_PLAYER_Y =>
				write_gfx_data_and_goto(std_logic_vector(unsigned(player.y)+PLAYER_BALL_RADIUS), DRAW_PLAYER_RADIUS);
			
			when DRAW_PLAYER_RADIUS =>
				write_gfx_data_and_goto(std_logic_vector(to_unsigned(PLAYER_BALL_RADIUS, gfx_data'length)), FRAME_DONE);
			
			when FRAME_DONE => 
				if (item_collected = '1') then
					-- if the player collided with the item,
					-- reset the player and the item position
					fsm_state_next <= PLACE_ITEM_AND_PLAYER;
				else
					fsm_state_next <= PERFORM_FRAME_SYNC;
				end if;
			
			when others =>
				null;
		end case;
	end process;
	
	random_number_generation : block 
		-- This function uses the parameter random_source to try to generate
		-- a random numbers in the range [a:b] and stores it in the output 
		-- signal vector random_value.
		-- If no valid random number could be obtained the output 
		-- signal random_valid will be set to '0', otherwise it is set 
		-- to '1'
		procedure random_slv(
			random_source : std_logic_vector;
			a, b : integer;
			signal random_value : out std_logic_vector;
			signal random_valid : out std_logic) is
		begin
			random_value <= std_logic_vector(to_unsigned(a + to_integer(unsigned(random_source(log2c(b-a)-1 downto 0))), random_value'length));
			if(unsigned(random_source(log2c(b-a)-1 downto 0))>(b-a)) then
				random_valid <= '0';
			else
				random_valid <= '1';
			end if;
		end procedure;
	begin
		gen_prngs : for i in prdata'range generate
		begin
			prng_inst : prng
			port map (
				clk       => clk,
				res_n     => res_n,
				load_seed => load_seed,
				seed      => std_logic_vector(to_unsigned(i+3,8)),
				en        => '1',
				prdata    => prdata(i)
			);
		end generate;
		
		sync : process(clk, res_n)
		begin
			if (res_n = '0') then
				random_x_pos_valid <= '0';
				random_x_pos <= (others=>'0');
			elsif (rising_edge(clk)) then
				-- generate a random number in the range [4:DISPLAY_WIDTH-12]
				random_slv(prdata, 4, DISPLAY_WIDTH-12, random_x_pos, random_x_pos_valid);
			end if;
		end process;
		
	end block;


	object_collider_block : block
	begin
		oc_object_mux : process(all)
		begin
			-- the game_object_cnt signal determines which game object
			-- is relayed to the input of the object collider 
			case game_object_cnt is
				when 0 =>
					oc_object <= BRICK1;
				when 1 => 
					oc_object <= BRICK2;
				when 2 =>
					oc_object <= item;
				when others =>
					oc_object <= GAME_OBJECT_NULL;
			end case;
		end process;
		
		-- bricks are blocking, all other objects are non-blocking
		oc_object_is_blocking <= '1' when oc_object.id = "00" else '0';
	
		object_collider_inst : object_collider
		generic map (
			DISPLAY_WIDTH  => DISPLAY_WIDTH,
			DISPLAY_HEIGHT => DISPLAY_HEIGHT
		)
		port map (
			clk                => clk,
			res_n              => res_n,
			start              => oc_start,
			done               => oc_done,
			apply_movement     => oc_apply_movement,
			apply_gravity      => oc_apply_gravity,
			player_x           => oc_player_x,
			player_y           => oc_player_y,
			player             => player,
			player_speed       => oc_player_speed,
			player_dir         => oc_player_dir,
			gravity            => oc_gravity,
			object             => oc_object,
			object_req         => oc_object_req,
			object_valid       => oc_object_valid,
			object_is_blocking => oc_object_is_blocking,
			object_eol         => oc_object_eol,
			collision_detected => oc_collision_detected
		);
		
	end block;
	
	gfx_initializer : block 
		constant INIT_INSTR : gfx_instr_array_t(0 to 3) := (
			GFX_INSTR_SET_CFG(enable_double_buffering=>true),
			GFX_INSTR_SET_COLOR(true), -- set primary drawing color
			GFX_INSTR_SET_COLOR(false), -- set secondary drawing color
			GFX_INSTR_CLEAR
		);
		constant INIT_DATA : gfx_data_array_t(0 to 1) := (
			BRICK_COLOR, -- primary color information
			BG_COLOR  -- secondary color information
		);
		
		signal instr_cnt : integer := 0;
		signal instr_cnt_next : integer := 0;
		signal data_cnt : integer := 0;
		signal data_cnt_next : integer := 0;
		
		signal init_gfx_data_next : std_logic_vector(GFX_DATA_WIDTH-1 downto 0);
		signal init_gfx_instr_next : std_logic_vector(GFX_INSTR_WIDTH-1 downto 0);
		
		signal instr_busy, instr_busy_next, data_busy, data_busy_next : std_logic;
	begin
		process(clk, res_n)
		begin
			if (res_n = '0') then
				instr_cnt <= 0;
				data_cnt <= 0;
				init_gfx_instr <= (others=>'0');
				init_gfx_data <= (others=>'0');
				instr_busy <= '0';
				data_busy <= '0';
			elsif (rising_edge(clk)) then
				init_gfx_instr <= init_gfx_instr_next;
				init_gfx_data <= init_gfx_data_next;
				instr_cnt <= instr_cnt_next;
				data_cnt <= data_cnt_next;
				instr_busy <= instr_busy_next;
				data_busy <= data_busy_next;
			end if;
		end process;
		
		output : process(all)
		begin
			init_gfx_instr_wr <= '0';
			init_gfx_data_wr <= '0';
			
			gfx_initializer_busy <= '0';
			
			instr_cnt_next <= instr_cnt;
			data_cnt_next <= data_cnt;
			
			init_gfx_instr_next <= init_gfx_instr;
			init_gfx_data_next <= init_gfx_data;
			
			instr_busy_next <= instr_busy;
			data_busy_next <= data_busy;
			
			if (gfx_initializer_start = '1') then
				gfx_initializer_busy <= '1';
				instr_cnt_next <= 1;
				data_cnt_next <= 1;
				instr_busy_next <= '1';
				data_busy_next <= '1';
				init_gfx_instr_next <= INIT_INSTR(0);
				init_gfx_data_next <= INIT_DATA(0);
			end if;
			
			if(instr_busy = '1' or data_busy = '1') then
				gfx_initializer_busy <= '1';
			end if;
			
			if (instr_busy = '1') then
				if (gfx_instr_full = '0') then
					init_gfx_instr_wr <= '1';
					
					if (instr_cnt = 0) then
						instr_busy_next <= '0';
					elsif (instr_cnt = INIT_INSTR'length-1) then
						instr_cnt_next <= 0;
						init_gfx_instr_next <= INIT_INSTR(instr_cnt);
					else
						init_gfx_instr_next <= INIT_INSTR(instr_cnt);
						instr_cnt_next <= instr_cnt + 1;
					end if;
				end if;
			end if;
			
			if (data_busy = '1') then
				if (gfx_data_full = '0') then
					init_gfx_data_wr <= '1';
					
					if (data_cnt = 0) then
						data_busy_next <= '0';
					elsif (data_cnt = INIT_DATA'length-1) then
						data_cnt_next <= 0;
						init_gfx_data_next <= INIT_DATA(data_cnt);
					else
						init_gfx_data_next <= INIT_DATA(data_cnt);
						data_cnt_next <= data_cnt + 1;
					end if;
				end if;
			end if;
			
		end process;
	end block;
	
	synth_cntrl(0).high_time <= x"20";
	synth_cntrl(0).low_time <= x"20"; 
	synth_cntrl(0).play <= controller.btn_left;

	synth_cntrl(1).high_time <= x"10";
	synth_cntrl(1).low_time <= x"10"; 
	synth_cntrl(1).play <= controller.btn_right;
	
end architecture;
