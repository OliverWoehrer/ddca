library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mem_pkg.all;
use work.cache_pkg.all;
use work.tb_util_pkg.all;

entity tb is
end entity;

architecture bench of tb is
	--Basic instance signals
	constant CLK_PERIOD : time := 10 ns;
	signal clk : std_logic;
	signal res_n : std_logic := '0';
	signal cpu_to_cache : mem_out_type := MEM_OUT_NOP2;
	signal cache_to_cpu : mem_in_type := MEM_IN_NOP2;
	signal cache_to_mem : mem_out_type := MEM_OUT_NOP2;
	signal mem_to_cache : mem_in_type := MEM_IN_NOP2;
	signal stop : boolean := false;

begin
	--Instance of UUT:
	cache_inst : entity work.cache(impl)
	generic map(
		SETS_LD   =>SETS_LD,
		WAYS_LD  =>WAYS_LD,
		ADDR_MASK =>(others => '1')
	)
	port map(
		clk   => clk,
		res_n => res_n,

		mem_out_cpu => cpu_to_cache,
		mem_in_cpu  => cache_to_cpu,
		mem_out_mem => cache_to_mem,
		mem_in_mem  => mem_to_cache
	);
	
	--Read and apply input data:
	stimulus : process
		variable fstatus: file_open_status;
	begin
		--First iteration
		res_n <= '0';
		timeout(5, CLK_PERIOD);
		res_n <= '1';
		timeout(2, CLK_PERIOD);
		
		cpu_to_cache.rd <= '1';
		cpu_to_cache.address <= (others => '0');
		timeout(1, CLK_PERIOD);
		cpu_to_cache.rd <= '0';
		cpu_to_cache.address <= (others => 'X');
		
		timeout(2, CLK_PERIOD);
		cpu_to_cache.rd <= '1';
		cpu_to_cache.address <= (others => '0');
		timeout(3, CLK_PERIOD);
		cpu_to_cache.rd <= '0';
		cpu_to_cache.address <= (others => 'X');
		
		timeout(2, CLK_PERIOD);
		cpu_to_cache.rd <= '1';
		cpu_to_cache.address <= 14x"0F00";
		timeout(1, CLK_PERIOD);
		cpu_to_cache.rd <= '0';
		cpu_to_cache.address <= (others => 'X');
		
		wait for 10*CLK_PERIOD;
		stop <= true;
		wait;
	end process;
	

	generate_clk : process
	begin
		clk_generate(clk, CLK_PERIOD, stop);
		wait;
	end process;

end architecture;
