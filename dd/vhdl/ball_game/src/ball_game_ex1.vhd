library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.gfx_if_pkg.all;
use work.math_pkg.all;
use work.nes_controller_pkg.all;
use work.audio_cntrl_pkg.all;
use work.ball_game_pkg.all;
use work.prng_pkg.all;

architecture arch_ex1 of ball_game is
	
	type state_t is (
		RESET, ENABLE_DB,
		PERFORM_FRAME_SYNC, WAIT_FRAME_SYNC, 
		DRAW_TEST_IMAGE_BACKGROUND, WAIT_DRAW_TEST_IMAGE_BACKGROUND,
		PROCESS_INPUT,
		DRAW_BALL, DRAW_BALL_X, DRAW_BALL_Y, DRAW_BALL_RADIUS
	);
	
	signal state : state_t;
	signal state_next : state_t;
	
	signal test_image_gfx_instr : std_logic_vector(GFX_INSTR_WIDTH-1 downto 0);
	signal test_image_gfx_instr_wr : std_logic;
	signal test_image_gfx_data : std_logic_vector(GFX_DATA_WIDTH-1 downto 0);
	signal test_image_gfx_data_wr : std_logic;
	signal test_image_start : std_logic;
	signal test_image_busy : std_logic;

	constant BALL_RADIUS : integer := 6;
	constant BALL_SPEED : integer := 4;
	constant COORDINATE_WIDTH : integer := 12;
	
	signal ball_x, ball_x_nxt : std_logic_vector(COORDINATE_WIDTH-1 downto 0);
	signal ball_y, ball_y_nxt : std_logic_vector(COORDINATE_WIDTH-1 downto 0);
	
	signal random_game_state : ball_game_state_t;
begin

	sync : process(clk, res_n)
	begin
		if (res_n = '0') then
			state <= RESET;
			ball_x <= std_logic_vector(to_unsigned(DISPLAY_WIDTH/2,COORDINATE_WIDTH));
			ball_y <= std_logic_vector(to_unsigned(DISPLAY_HEIGHT/2,COORDINATE_WIDTH));
		elsif (rising_edge(clk)) then
			state <= state_next;
			ball_x <= ball_x_nxt;
			ball_y <= ball_y_nxt;
		end if;
	end process;
	
	next_state_logic : process(all)
		variable ball_x_temp : integer range -2**COORDINATE_WIDTH to 2**COORDINATE_WIDTH-1 := 0;
		variable ball_y_temp : integer range -2**COORDINATE_WIDTH to 2**COORDINATE_WIDTH-1 := 0;
	begin
		gfx_instr <= (others=>'0');
		gfx_instr_wr <= '0';
		gfx_data <= (others=>'0');
		gfx_data_wr <= '0';
		test_image_start <= '0';
		state_next <= state;
		
		ball_x_nxt <= ball_x;
		ball_y_nxt <= ball_y;
		
		case state is
			when RESET =>
				state_next <= ENABLE_DB;
			
			when ENABLE_DB =>
				if (gfx_instr_full = '0') then
					gfx_instr <= GFX_INSTR_SET_CFG(enable_double_buffering => true);
					gfx_instr_wr <= '1';
					state_next <= PERFORM_FRAME_SYNC;
				end if;
			
			when PERFORM_FRAME_SYNC =>
				--check if the gfx instr interface is ready and issue a frame sync instruction
				if (gfx_instr_full = '0') then
					gfx_instr <= GFX_INSTR_FRAME_SYNC;
					gfx_instr_wr <= '1';
					state_next <= WAIT_FRAME_SYNC;
				end if;
			
			when WAIT_FRAME_SYNC =>
				if (gfx_frame_sync = '1') then
					state_next <= DRAW_TEST_IMAGE_BACKGROUND;
				end if;
				
			when DRAW_TEST_IMAGE_BACKGROUND =>
				test_image_start <= '1';
				state_next <= WAIT_DRAW_TEST_IMAGE_BACKGROUND;

			when WAIT_DRAW_TEST_IMAGE_BACKGROUND => 
				gfx_instr <= test_image_gfx_instr;
				gfx_instr_wr <= test_image_gfx_instr_wr;
				gfx_data <= test_image_gfx_data;
				gfx_data_wr <= test_image_gfx_data_wr;
				if(test_image_busy = '0') then
					state_next <= PROCESS_INPUT;
				end if;
			
			when PROCESS_INPUT => 
				ball_y_temp := to_integer(unsigned(ball_y));
				if(controller.btn_up = '1') then
					ball_y_temp := ball_y_temp - BALL_SPEED;
				elsif(controller.btn_down = '1') then
					ball_y_temp := ball_y_temp + BALL_SPEED;
				end if;
				
				if (ball_y_temp < BALL_RADIUS+1) then
					ball_y_temp := BALL_RADIUS + 1;
				elsif (ball_y_temp > DISPLAY_HEIGHT-BALL_RADIUS-2) then
					ball_y_temp := DISPLAY_HEIGHT-BALL_RADIUS-2;
				end if;
				
				ball_y_nxt <= std_logic_vector(to_unsigned(ball_y_temp, COORDINATE_WIDTH));
				
				ball_x_temp := to_integer(unsigned(ball_x));
				if(controller.btn_left = '1') then
					ball_x_temp := ball_x_temp - BALL_SPEED;
					
				elsif(controller.btn_right = '1') then
					ball_x_temp := ball_x_temp + BALL_SPEED;
				end if;

				if (ball_x_temp < BALL_RADIUS+1) then
					ball_x_temp := BALL_RADIUS + 1;
				elsif (ball_x_temp > DISPLAY_WIDTH-BALL_RADIUS-2) then
					ball_x_temp := DISPLAY_WIDTH-BALL_RADIUS-2;
				end if;
				
				ball_x_nxt <= std_logic_vector(to_unsigned(ball_x_temp, COORDINATE_WIDTH));
				state_next <= DRAW_BALL;
			
			when DRAW_BALL => 
				if (gfx_instr_full = '0') then
					gfx_instr <= GFX_INSTR_DRAW_CIRCLE;
					gfx_instr_wr <= '1';
					state_next <= DRAW_BALL_X;
				end if;
				
			when DRAW_BALL_X =>
				if (gfx_data_full = '0') then
					gfx_data(ball_x'range) <= ball_x;
					gfx_data_wr <= '1';
					state_next <= DRAW_BALL_Y;
				end if;
			
			when DRAW_BALL_Y =>
				if (gfx_data_full = '0') then
					gfx_data(ball_y'range) <= ball_y;
					gfx_data_wr <= '1';
					state_next <= DRAW_BALL_RADIUS;
				end if;

			when DRAW_BALL_RADIUS =>
				if (gfx_data_full = '0') then
					gfx_data <= std_logic_vector(to_unsigned(BALL_RADIUS, gfx_data'length));
					gfx_data_wr <= '1';
					state_next <= PERFORM_FRAME_SYNC;
				end if;
			
			when others =>
				null;
		end case;
	end process;
	
	synth_cntrl(0).high_time <= x"20";
	synth_cntrl(0).low_time <= x"20"; 
	synth_cntrl(0).play <= controller.btn_up or controller.btn_down;

	synth_cntrl(1).high_time <= x"10";
	synth_cntrl(1).low_time <= x"10"; 
	synth_cntrl(1).play <= controller.btn_left or controller.btn_right;
	
	process(all)
	begin
		game_state <= IDLE;
		if (controller.btn_start = '1') then
			game_state <= IDLE;
		elsif (controller.btn_select = '1') then
			game_state <= RUNNING;
		elsif(controller.btn_a = '1') then
			game_state <= PAUSED;
		elsif(controller.btn_b = '1') then
			game_state <= GAME_OVER;
		else
			game_state <= random_game_state;
		end if;
	end process;
	
	random_state_generator : block 
		signal rdm_state_cnt : std_logic_vector (3 downto 0);
		signal prdata : std_logic_vector(1 downto 0);
	begin
		process(clk, res_n)
		begin
			if (res_n = '0') then
				rdm_state_cnt <= (others=>'0');
				random_game_state <= IDLE;
			elsif (rising_edge(clk)) then
				if(rdm_state_cnt = x"f") then
					case prdata is
						when "00" => random_game_state <= IDLE;
						when "01" => random_game_state <= RUNNING;
						when "10" => random_game_state <= PAUSED;
						when "11" => random_game_state <= GAME_OVER;
						when others => random_game_state <= IDLE;
					end case;
					rdm_state_cnt <= (others=>'0');
				else
					rdm_state_cnt <= std_logic_vector(unsigned(rdm_state_cnt) + 1);
				end if;
			end if;
		end process;
		
		prng_inst0 : prng
		port map (
			clk       => clk,
			res_n     => res_n,
			load_seed => '0',
			seed      => (others=>'0'),
			en        => '1',
			prdata    => prdata(0)
		);

		prng_inst1 : prng
		port map (
			clk       => clk,
			res_n     => res_n,
			load_seed => '0',
			seed      => (others=>'0'),
			en        => prdata(0),
			prdata    => prdata(1)
		);
	end block;

	player_points_generation : block
		signal last_a : std_logic;
		signal cnt : integer range 0 to 50_000_000;
	begin
	
		sync : process(clk, res_n)
		begin
			if (res_n = '0') then
				player_points <= (others=>'0');
				last_a <= '0';
				cnt <= 0;
			elsif (rising_edge(clk)) then
				last_a <= controller.btn_a;
				if (cnt = 50_000_000) then
					cnt <= 0;
					player_points <= std_logic_vector(unsigned(player_points) + 1);
				else
					cnt <= cnt + 1;
				end if;
				if (last_a = '0' and controller.btn_a = '1') then
					player_points <= std_logic_vector(unsigned(player_points) + 50);
				end if;
			end if;
		end process;
	
	end block;


	test_image_writer : block 
		constant TEST_IMAGE_INSTR : gfx_instr_array_t(0 to 5) := (
			GFX_INSTR_DRAW_LINE,
			GFX_INSTR_CLEAR,
			GFX_INSTR_DRAW_LINE,
			GFX_INSTR_DRAW_LINE,
			GFX_INSTR_DRAW_LINE,
			GFX_INSTR_DRAW_LINE
		);
		constant TEST_IMAGE_DATA : gfx_data_array_t(0 to 19) := (
			--line: diagonal
			x"0000", --x0
			x"0000", --y0
			x"018f", --x1
			x"00ef", --y1
			--line: top
			x"0000", --x0
			x"0000", --y0
			x"018f", --x1
			x"0000", --y1
			--line: right
			x"018f", --x0
			x"0000", --y0
			x"018f", --x1
			x"00ef", --y1
			--line: bottom
			x"018f", --x0
			x"00ef", --y0
			x"0000", --x1
			x"00ef", --y1
			--line: left
			x"0000", --x0
			x"00ef", --y0
			x"0000", --x1
			x"0000" --y1
		);
		
		signal instr_cnt : integer := 0;
		signal instr_cnt_next : integer := 0;
		signal data_cnt : integer := 0;
		signal data_cnt_next : integer := 0;
		
		signal test_image_gfx_data_next : std_logic_vector(GFX_DATA_WIDTH-1 downto 0);
		signal test_image_gfx_instr_next : std_logic_vector(GFX_INSTR_WIDTH-1 downto 0);
		
		signal instr_busy, instr_busy_next, data_busy, data_busy_next : std_logic;
	begin
		process(clk, res_n)
		begin
			if (res_n = '0') then
				instr_cnt <= 0;
				data_cnt <= 0;
				test_image_gfx_instr <= (others=>'0');
				test_image_gfx_data <= (others=>'0');
				instr_busy <= '0';
				data_busy <= '0';
			elsif (rising_edge(clk)) then
				test_image_gfx_instr <= test_image_gfx_instr_next;
				test_image_gfx_data <= test_image_gfx_data_next;
				instr_cnt <= instr_cnt_next;
				data_cnt <= data_cnt_next;
				instr_busy <= instr_busy_next;
				data_busy <= data_busy_next;
			end if;
		end process;
		
		output : process(all)
		begin
			test_image_gfx_instr_wr <= '0';
			test_image_gfx_data_wr <= '0';
			
			test_image_busy <= '0';
			
			instr_cnt_next <= instr_cnt;
			data_cnt_next <= data_cnt;
			
			test_image_gfx_instr_next <= test_image_gfx_instr;
			test_image_gfx_data_next <= test_image_gfx_data;
			
			instr_busy_next <= instr_busy;
			data_busy_next <= data_busy;
			
			if (test_image_start = '1') then
				test_image_busy <= '1';
				instr_cnt_next <= 1;
				data_cnt_next <= 1;
				instr_busy_next <= '1';
				data_busy_next <= '1';
				test_image_gfx_instr_next <= TEST_IMAGE_INSTR(0);
				test_image_gfx_data_next <= TEST_IMAGE_DATA(0);
			end if;
			
			if(instr_busy = '1' or data_busy = '1') then
				test_image_busy <= '1';
			end if;
			
			if (instr_busy = '1') then
				if (gfx_instr_full = '0') then
					test_image_gfx_instr_wr <= '1';
					
					if (instr_cnt = 0) then
						instr_busy_next <= '0';
					elsif (instr_cnt = TEST_IMAGE_INSTR'length-1) then
						instr_cnt_next <= 0;
					else
						test_image_gfx_instr_next <= TEST_IMAGE_INSTR(instr_cnt);
						instr_cnt_next <= instr_cnt + 1;
					end if;
				end if;
			end if;
			
			if (data_busy = '1') then
				if (gfx_data_full = '0') then
					test_image_gfx_data_wr <= '1';
					
					if (data_cnt = 0) then
						data_busy_next <= '0';
					elsif (data_cnt = TEST_IMAGE_DATA'length-1) then
						data_cnt_next <= 0;
					else
						test_image_gfx_data_next <= TEST_IMAGE_DATA(data_cnt);
						data_cnt_next <= data_cnt + 1;
					end if;
				end if;
			end if;
			
		end process;
	end block;
end architecture;
