----------------------------------------------------------------------------------
--                                LIBRARIES                                     --
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.nes_controller_pkg.all;

--------------------------------------------------------------------------------
--                                 ENTITY                                     --
--------------------------------------------------------------------------------
entity nes_controller is
	generic(
		CLK_FREQ : integer := 50000000;
		CLK_OUT_FREQ : integer := 1000000;
		REFRESH_TIMEOUT : integer := 400000
	);
	port(
		clk : in std_logic;
		res_n : in std_logic;
		nes_clk : out std_logic;
		nes_latch : out std_logic;
		nes_data : in std_logic;
		button_state : out nes_buttons_t
	);
end entity;

--------------------------------------------------------------------------------
--                               ARCHITECTURE                                 --
--------------------------------------------------------------------------------
architecture arch of nes_controller is
	--states of FSM
	type state_t is (WAIT_TIMEOUT, LATCH, LATCH_WAIT, CLK_LOW, SAMPLE, CLK_HIGH);
	signal state : state_t := WAIT_TIMEOUT;
	signal state_next : state_t; --only used for two process fsm
	
	--shift register for input data
	signal shiftreg : std_logic_vector(7 downto 0) := (others => '0');
	
	--intern constants and signals
	constant BIT_TIME : integer := CLK_FREQ / CLK_OUT_FREQ; -- correction nessesary!
begin
	--single process fsm
	fsm: process(clk)
		variable clk_cnt : integer := 0;
		variable bit_cnt : integer := 0;
		variable debug : std_logic_vector(7 downto 0) := (others => '0');
	begin
		if rising_edge(clk) then
			if res_n = '0' then --reset values and signals
				state <= WAIT_TIMEOUT;
				button_state <= (others => '0');
			else
				case state is
					when WAIT_TIMEOUT =>
						nes_latch <= '0';
						nes_clk <= '1';
						button_state.btn_right <= shiftreg(0);
						button_state.btn_left <= shiftreg(1);
						button_state.btn_down <= shiftreg(2);
						button_state.btn_up <= shiftreg(3);
						button_state.btn_start <= shiftreg(4);
						button_state.btn_select <= shiftreg(5);
						button_state.btn_b <= shiftreg(6);
						button_state.btn_a <= shiftreg(7);
						if clk_cnt = REFRESH_TIMEOUT then
							clk_cnt := 0;
							state <= LATCH;
						else
							clk_cnt := clk_cnt + 1;
							state <= WAIT_TIMEOUT;
						end if;
					when LATCH =>
						nes_latch <= '1';
						nes_clk <= '1';
						if clk_cnt = BIT_TIME/2 then
							clk_cnt := 0;
							state <= LATCH_WAIT;
						else
							clk_cnt := clk_cnt + 1;
							state <= LATCH;
						end if;
					when LATCH_WAIT =>
						nes_latch <= '0';
						nes_clk <= '1';
						if clk_cnt = BIT_TIME/2 then
							clk_cnt := 0;
							state <= CLK_LOW;
						else
							clk_cnt := clk_cnt + 1;
							state <= LATCH_WAIT;
						end if;
					when CLK_LOW =>
						nes_latch <= '0';
						nes_clk <= '0';
						if clk_cnt = (BIT_TIME/2)-1 then
							clk_cnt := 0;
							state <= SAMPLE;
						else
							clk_cnt := clk_cnt + 1;
							state <= CLK_LOW;
						end if;
					when SAMPLE =>
						nes_latch <= '0';
						nes_clk <= '0';
						shiftreg <= shiftreg(6 downto 0) & not nes_data;
						state <= CLK_HIGH;
					when CLK_HIGH =>
						nes_latch <= '0';
						nes_clk <= '1';
						if (bit_cnt /= 7) and (clk_cnt = BIT_TIME/2) then
							bit_cnt := bit_cnt + 1;
							clk_cnt := 0;
							state <= CLK_LOW;
						elsif (bit_cnt = 7) and (clk_cnt = BIT_TIME/2) then
							bit_cnt := 0;
							clk_cnt := 0;
							state <= WAIT_TIMEOUT;
						else
							clk_cnt := clk_cnt + 1;
							state <= CLK_HIGH;
						end if;
				end case;
			end if;
		end if;
	end process;

	/* 2 process fsm (incomplete); stuggle to find sensitivity arguments
	sync: process(clk, res_n)
	begin
		if res_n = '0' then --reset values and signals
			state <= WAIT_TIMEOUT;
			button_state <= (others => '0');
		elsif rising_edge(clk) then
			state <= state_next;
		end if;
	end process;

	async: process(state) -- stuggle to find sensitivity arguments
		variable clk_cnt : integer := 0;
		variable bit_cnt : integer := 0;
		variable debug : std_logic_vector(7 downto 0) := (others => '0');
	begin
		state_next <= state; --fallback (default case, when no case is valid)
		case state is
			when WAIT_TIMEOUT =>
				nes_latch <= '0';
				nes_clk <= '1';
				button_state.btn_right <= shiftreg(0);
				button_state.btn_left <= shiftreg(1);
				button_state.btn_down <= shiftreg(2);
				button_state.btn_up <= shiftreg(3);
				button_state.btn_start <= shiftreg(4);
				button_state.btn_select <= shiftreg(5);
				button_state.btn_b <= shiftreg(6);
				button_state.btn_a <= shiftreg(7);
				if clk_cnt = REFRESH_TIMEOUT then
					clk_cnt := 0;
					state_next <= LATCH;
				else
					clk_cnt := clk_cnt + 1;
					state_next <= WAIT_TIMEOUT;
				end if;
			when LATCH =>
				nes_latch <= '1';
				nes_clk <= '1';
				if clk_cnt = BIT_TIME/2 then
					clk_cnt := 0;
					state_next <= LATCH_WAIT;
				else
					clk_cnt := clk_cnt + 1;
					state_next <= LATCH;
				end if;
			when LATCH_WAIT =>
				nes_latch <= '0';
				nes_clk <= '1';
				if clk_cnt = BIT_TIME/2 then
					clk_cnt := 0;
					state_next <= CLK_LOW;
				else
					clk_cnt := clk_cnt + 1;
					state_next <= LATCH_WAIT;
				end if;
			when CLK_LOW =>
				nes_latch <= '0';
				nes_clk <= '0';
				if clk_cnt = (BIT_TIME/2)-1 then
					clk_cnt := 0;
					state_next <= SAMPLE;
				else
					clk_cnt := clk_cnt + 1;
					state_next <= CLK_LOW;
				end if;
			when SAMPLE =>
				nes_latch <= '0';
				nes_clk <= '0';
				shiftreg <= shiftreg(6 downto 0) & not nes_data;
				state_next <= CLK_HIGH;
			when CLK_HIGH =>
				nes_latch <= '0';
				nes_clk <= '1';
				if (bit_cnt /= 7) and (clk_cnt = BIT_TIME/2) then
					bit_cnt := bit_cnt + 1;
					clk_cnt := 0;
					state_next <= CLK_LOW;
				elsif (bit_cnt = 7) and (clk_cnt = BIT_TIME/2) then
					bit_cnt := 0;
					clk_cnt := 0;
					state_next <= WAIT_TIMEOUT;
				else
					clk_cnt := clk_cnt + 1;
					state_next <= CLK_HIGH;
				end if;
			when others =>
					state_next <= state; --fallback (default case, when no case is valid)
		end case;
	end process;*/
end architecture;

