----------------------------------------------------------------------------------
--                                LIBRARIES                                     --
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.prng_pkg.all;

--------------------------------------------------------------------------------
--                                 TEST BENCH											--
--------------------------------------------------------------------------------
entity prng_tb is
begin
end entity;

--------------------------------------------------------------------------------
--                               ARCHITECTURE                                 --
--------------------------------------------------------------------------------
architecture bench of prng_tb is

	--prng signals
	signal clk_s : std_logic;
	signal res_n_s : std_logic;
	signal load_seed_s: std_logic;
	signal seed_s : std_logic_vector(7 downto 0) := (others=>'0');
	signal en_s : std_logic;
	signal prdata_s : std_logic;
	
	--shift register
	constant SHIFT_WIDTH : integer := 16;
	signal seq : unsigned (SHIFT_WIDTH-1 downto 0) := (others=>'0'); -- 16 bit wide shift register
	signal shift_s : std_logic := '0';
	
	--for clock generator
	constant CLK_PERIOD : time := 20 ns;
	signal stop_clock : boolean := false;

begin

	uut : prng
	port map (
		clk			=> clk_s,
		res_n			=> res_n_s,
		load_seed	=> load_seed_s,
		seed			=> seed_s,
		en				=> en_s,
		prdata		=> prdata_s
	);
	
	beh : process --process for behavioral simulation
		variable period : unsigned (SHIFT_WIDTH-1 downto 0); -- period length for each test seed
		variable periodMax : unsigned (SHIFT_WIDTH-1 downto 0) := to_unsigned(0, period'length);
		variable periodMin : unsigned (SHIFT_WIDTH-1 downto 0) := to_unsigned(65535, period'length);
		variable initial : unsigned (SHIFT_WIDTH-1 downto 0);
		variable seed : unsigned (7 downto 0);
	begin
		--apply reset for 5 clock periods
		res_n_s <= '0'; -- apply reset
		wait for 5*CLK_PERIOD;
		wait until rising_edge(clk_s);
		res_n_s <= '1'; -- release reset
		
		--set initial seed
		seed := to_unsigned(144, seed'length);
		
		--iterate for all 16 test seeds
		for i in 0 to 15 loop
			--load new seed
			seed_s <= std_logic_vector(seed);
			wait until rising_edge(clk_s);
			load_seed_s <= '1';
			wait until rising_edge(clk_s);
			load_seed_s <= '0';
			
			--fill shift register with initial value
			en_s <= '1';
			shift_s <= '1';
			wait for (2*SHIFT_WIDTH)*CLK_PERIOD;
			shift_s <= '0';
			initial := seq;
			period := x"0000";

			--loop for one prng period
			shift_s <= '1';
			wait until rising_edge(clk_s);
			while true loop
				wait until rising_edge(clk_s);
				period := period + 1;
				if (seq = initial) then --end of period: report and set values
					report "SEED: "&INTEGER'image(to_integer(seed))&", PERIOD: "&INTEGER'image(to_integer(period));
					if (period > periodMax) then periodMax := period; end if;
					if (period < periodMin) then periodMin := period; end if;
					exit;
				end if;
			end loop;
			
			en_s <= '0';
			shift_s <= '0';
			seed := seed+1;
		end loop;
		
		--terminate simulation
		report "min period: "&INTEGER'image(to_integer(periodMin))&", max period: "&INTEGER'image(to_integer(periodMax));
		stop_clock <= true;
		wait for 1 us;
	end process;
	
	shift_register : process(clk_s)
	begin --shift new data into shift register
		if rising_edge(clk_s) and (shift_s = '1') then
			seq <= shift_left(seq, 1);
			seq(seq'low) <= prdata_s;
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