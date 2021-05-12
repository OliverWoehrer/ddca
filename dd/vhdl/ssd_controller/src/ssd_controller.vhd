----------------------------------------------------------------------------------
--                                LIBRARIES                                     --
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ball_game_pkg.all;
use work.nes_controller_pkg.all;

--------------------------------------------------------------------------------
--                                 ENTITY                                     --
--------------------------------------------------------------------------------
entity ssd_controller is
	generic (
		BLINK_INTERVAL : integer := 12500000;
		BLINK_COUNT : integer := 3;
		ANIMATION_INTERVAL : integer := 50000000
	);
	port (
		clk : in std_logic;
		res_n : in std_logic;
		
		game_state : in ball_game_state_t;
		player_points : in std_logic_vector(15 downto 0) := (others => '0');
		controller : in nes_buttons_t;
		hex0 : out std_logic_vector(6 downto 0) := (others => '0');
		hex1 : out std_logic_vector(6 downto 0) := (others => '0');
		hex2 : out std_logic_vector(6 downto 0) := (others => '0');
		hex3 : out std_logic_vector(6 downto 0) := (others => '0');
		hex4 : out std_logic_vector(6 downto 0) := (others => '0');
		hex5 : out std_logic_vector(6 downto 0) := (others => '0');
		hex6 : out std_logic_vector(6 downto 0) := (others => '0');
		hex7 : out std_logic_vector(6 downto 0) := (others => '0')
	);

end entity;

--------------------------------------------------------------------------------
--                               ARCHITECTURE                                 --
--------------------------------------------------------------------------------
architecture arch of ssd_controller is
	--states of FSM
	type state_t is (WAITING, GET_THOUSENDS, GET_HUNDREDS, GET_TENS, LED_ON, LED_OFF, OVERFLOW);
	signal state : state_t := WAITING;
	
	--constants for hex displays
	type hex_t is array (9 downto 0) of std_logic_vector(6 downto 0);
	constant HEX_DIGITS: hex_t := (
		0 	=> "1000000", -- DIGIT 0
		1 	=> "1111001", -- DIGIT 1
		2 	=> "0100100", -- DIGIT 2
		3	=> "0110000", -- DIGIT 3
		4 	=> "0011001", -- DIGIT 4
		5 	=> "0010010", -- DIGIT 5
		6 	=> "0000010", -- DIGIT 6
		7 	=> "1111000", -- DIGIT 7
		8 	=> "0000000", -- DIGIT 8
		9 	=> "0011000"  -- DIGIT 9
	);
	constant HEX_DASH : std_logic_vector(6 downto 0) := "0111111"; -- DASH
	constant HEX_OFF : std_logic_vector(6 downto 0) := "1111111"; -- LEDs OFF
begin
	--single process fsm
	points_display: process(clk)
		--digits array holds value to be displayed for every digit
		variable thousands : unsigned(3 downto 0) := "0000";
		variable hundreds : unsigned(3 downto 0) := "0000";
		variable tens : unsigned(3 downto 0) := "0000";
		variable digits : unsigned(3 downto 0) := "0000";
		
		--counter variables
		variable clk_cnt : natural := 0;
		variable bli_cnt : natural := 0;
		
		--intern variables
		variable player_points_old : unsigned(15 downto 0) := (others => '0');
		variable player_points_temp : unsigned(15 downto 0) := (others => '0');
	begin
		if rising_edge(clk) then
			if res_n = '0' then --reset values and signals
				state <= WAITING;
			else
				case state is
					when WAITING =>
						----reset intern values
						thousands := "0000";
						hundreds := "0000";
						tens := "0000";
						digits := "0000";
						player_points_temp := unsigned(player_points);
						if player_points_temp /= player_points_old then	--new input value
							if (player_points_temp < player_points_old + 25) then
								bli_cnt := BLINK_COUNT; -- set no blinking
							end if;
							player_points_old := unsigned(player_points);
							if player_points_temp > 9999 then --check input value
								state <= OVERFLOW; --points number to big to display
							else
								state <= GET_THOUSENDS;
							end if;
						else --player points unchanged
							
							state <= WAITING;
						end if;
					when GET_THOUSENDS =>
						if player_points_temp < 1000 then
							state <= GET_HUNDREDS;
						else
							player_points_temp := player_points_temp - 1000;
							thousands := thousands + 1;
						end if;
					when GET_HUNDREDS =>
						if player_points_temp < 100 then
							state <= GET_TENS;
						else
							player_points_temp := player_points_temp - 100;
							hundreds := hundreds + 1;
						end if;
					when GET_TENS =>
						if player_points_temp < 10 then
							digits := player_points_temp(3 downto 0);
							state <= LED_ON;
						else
							player_points_temp := player_points_temp - 10;
							tens := tens + 1;
						end if;
					when LED_ON =>
						hex0 <= HEX_DIGITS(to_integer(digits));
						hex1 <= HEX_DIGITS(to_integer(tens));
						hex2 <= HEX_DIGITS(to_integer(hundreds));
						hex3 <= HEX_DIGITS(to_integer(thousands));
						if (bli_cnt < BLINK_COUNT) and (clk_cnt = BLINK_INTERVAL) then
							clk_cnt := 0;
							state <= LED_OFF;
						elsif bli_cnt = BLINK_COUNT then
							bli_cnt := 0;
							state <= WAITING; -- no blinking
						else
							clk_cnt := clk_cnt + 1;
						end if;
					when LED_OFF =>
						hex0 <= HEX_OFF;
						hex1 <= HEX_OFF;
						hex2 <= HEX_OFF;
						hex3 <= HEX_OFF;
						if clk_cnt = BLINK_INTERVAL then
							bli_cnt := bli_cnt + 1;
							clk_cnt := 0;
							state <= LED_ON;
						else
							clk_cnt := clk_cnt + 1;
						end if;
					when OVERFLOW =>
						hex0 <= HEX_DASH;
						hex1 <= HEX_DASH;
						hex2 <= HEX_DASH;
						hex3 <= HEX_DASH;
						state <= WAITING;
					--when others => 
						--default case, when no case is valid
				end case;
			end if;
		end if;
	end process;

	
	--display direction patterns on button press
	direction_display: process(controller)
	begin
		if (controller.btn_left = '1') and (controller.btn_right = '1') then
			hex5 <= "0000110"; --error, "E"
			hex4 <= "0101111"; --error, "r"
		elsif controller.btn_left = '1' then
			hex5 <= "1000111"; --left, "L"
			hex4 <= "0000110"; --left, "E"
		elsif controller.btn_right = '1' then
			hex5 <= "0101111"; --right, "r"
			hex4 <= "1101111"; --right, "i"
		else
			hex4 <= "1111111";
			hex5 <= "1111111";
		end if;
	end process;
	
	--display game state
	game_state_display: process(game_state, clk)
		variable animation_state : unsigned(1 downto 0) := "00";
		variable clk_cnt : natural := 0;
	begin
		if rising_edge(clk) then --update counter on rising_edge(clk)
			clk_cnt := clk_cnt + 1;
			if clk_cnt = ANIMATION_INTERVAL then
				clk_cnt := 0;
				animation_state := animation_state + 1;
			end if;
		end if;
		case game_state is
			when IDLE =>
				hex7 <= "0111111"; --idle, "-"
				hex6 <= "0111111"; --idle, "-"
			when RUNNING =>
				if (animation_state = 0 or animation_state = 1) then
					hex7 <= "0011100";
				else
					hex7 <= "0100011";
				end if;
				if (animation_state = 1 or animation_state = 2) then
					hex6 <= "0011100";
				else
					hex6 <= "0100011";
				end if;
				/*hex7 <= "0011100"; --running, "°"
				hex6 <= "0100011"; --running, "o"*/
			when PAUSED =>
				hex7 <= "1110000"; --paused, "]"
				hex6 <= "1000110"; --paused, "["
			when GAME_OVER =>
				hex7 <= "1000010"; --gameover, "G"
				hex6 <= "1000000"; --gameover, "O"
			when others =>
				hex6 <= "1111111";
				hex7 <= "1111111";
		end case;
	end process;
	
	
end architecture;