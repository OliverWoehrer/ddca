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
		
		-------- TEST SUIT START --------
		timeout(5, CLK_PERIOD);
		
		--Read Miss (MEM READ):
		timeout(3, CLK_PERIOD);
		cpu_to_cache.address <= 14x"0000";
		cpu_to_cache.rd <= '1';
		timeout(1, CLK_PERIOD); -- assert rd for 1 cycle
		cpu_to_cache.rd <= '0';
		timeout(2, CLK_PERIOD); -- wait for cache
		mem_to_cache.busy <= '1';
		timeout(3, CLK_PERIOD); -- wait while mem busy
		mem_to_cache.busy <= '0';
		mem_to_cache.rddata <= 32x"12345678";
		timeout(1, CLK_PERIOD); -- data valid cycle
		mem_to_cache.rddata <= (others => 'X');
		
		--Read Miss (MEM READ):
		timeout(3, CLK_PERIOD);
		cpu_to_cache.address <= 14x"0012";
		cpu_to_cache.rd <= '1';
		timeout(1, CLK_PERIOD); -- assert rd for 1 cycle
		cpu_to_cache.rd <= '0';
		timeout(2, CLK_PERIOD); -- wait for cache
		mem_to_cache.busy <= '1';
		timeout(3, CLK_PERIOD); -- simulate wait while mem busy
		mem_to_cache.busy <= '0';
		mem_to_cache.rddata <= 32x"0000000A";
		timeout(1, CLK_PERIOD); -- data valid cycle
		mem_to_cache.rddata <= (others => 'X');
		
		--Read Miss (MEM READ):
		timeout(3, CLK_PERIOD);
		cpu_to_cache.address <= 14x"0016";
		cpu_to_cache.rd <= '1';
		timeout(1, CLK_PERIOD); -- assert rd for 1 cycle
		cpu_to_cache.rd <= '0';
		timeout(2, CLK_PERIOD); -- wait for cache
		mem_to_cache.busy <= '1';
		timeout(3, CLK_PERIOD); -- wait while mem busy
		mem_to_cache.busy <= '0';
		mem_to_cache.rddata <= 32x"0000000B";
		timeout(1, CLK_PERIOD); -- data valid cycle
		mem_to_cache.rddata <= (others => 'X');
		
		--Read Hit (READ CACHE):
		timeout(3, CLK_PERIOD);
		cpu_to_cache.address <= 14x"0012";
		cpu_to_cache.rd <= '1';
		timeout(1, CLK_PERIOD); -- assert rd for 1 cycle
		cpu_to_cache.rd <= '0';
		timeout(1, CLK_PERIOD); -- wait for cache
		mem_to_cache.rddata <= 32x"000000FF"; -- should not be used, cache value (0x0A) should be read instead!
		timeout(1, CLK_PERIOD); -- data valid cycle
		mem_to_cache.rddata <= (others => 'X');
		
		--Read Miss (READ MEM):
		timeout(3, CLK_PERIOD);
		cpu_to_cache.address <= 14x"0022";
		cpu_to_cache.rd <= '1';
		timeout(1, CLK_PERIOD); -- assert rd for 1 cycle
		cpu_to_cache.rd <= '0';
		timeout(2, CLK_PERIOD); -- wait for cache
		mem_to_cache.busy <= '1';
		timeout(3, CLK_PERIOD); -- wait while mem busy
		mem_to_cache.busy <= '0';
		mem_to_cache.rddata <= 32x"0000000C";
		timeout(1, CLK_PERIOD); -- data valid cycle
		mem_to_cache.rddata <= (others => 'X');
		
		
		
		--Write Hit (Dirty):
		timeout(3, CLK_PERIOD);
		cpu_to_cache.address <= 14x"0016";
		cpu_to_cache.wr <= '1';
		cpu_to_cache.wrdata <= 32x"000000BB";
		timeout(1, CLK_PERIOD); -- assert wr for 1 cycle
		cpu_to_cache.wr <= '0';
		cpu_to_cache.wrdata <= (others => 'X');
		
		--Read Hit (READ CACHE):
		timeout(3, CLK_PERIOD);
		cpu_to_cache.address <= 14x"0016";
		cpu_to_cache.rd <= '1';
		timeout(1, CLK_PERIOD); -- assert rd for 1 cycle
		cpu_to_cache.rd <= '0';
		mem_to_cache.rddata <= 32x"000000FF"; -- should not be used, cache value (0xBB) should be read instead!
		timeout(1, CLK_PERIOD); -- data valid cycle
		mem_to_cache.rddata <= (others => 'X');
		
		--Write Miss (WB):
		timeout(3, CLK_PERIOD);
		cpu_to_cache.address <= 14x"0026";
		cpu_to_cache.wr <= '1';
		cpu_to_cache.wrdata <= 32x"000000CC";
		timeout(1, CLK_PERIOD); -- assert wr for 1 cycle
		cpu_to_cache.wr <= '0';
		cpu_to_cache.wrdata <= (others => 'X');
		
		--Read Hit (READ CACHE):
		timeout(3, CLK_PERIOD);
		cpu_to_cache.address <= 14x"0026";
		cpu_to_cache.rd <= '1';
		timeout(1, CLK_PERIOD); -- assert rd for 1 cycle
		cpu_to_cache.rd <= '0';
		mem_to_cache.rddata <= 32x"000000FF"; -- should not be used, cache value (0xCC) should be read instead!
		timeout(1, CLK_PERIOD); -- data valid cycle
		mem_to_cache.rddata <= (others => 'X');
		
		--Read Miss (WB & READ MEM):
		timeout(3, CLK_PERIOD);
		cpu_to_cache.address <= 14x"0016";
		cpu_to_cache.rd <= '1';
		timeout(1, CLK_PERIOD); -- assert rd for 1 cycle
		cpu_to_cache.rd <= '0';
		timeout(2, CLK_PERIOD); -- wait for cache
		mem_to_cache.busy <= '1';
		timeout(3, CLK_PERIOD); -- wait while mem busy
		mem_to_cache.busy <= '0';
		mem_to_cache.rddata <= 32x"000000BB"; -- should not be used, cache value (0xBB) should be read instead!
		timeout(1, CLK_PERIOD); -- data valid cycle
		mem_to_cache.rddata <= (others => 'X');
		
		timeout(8, CLK_PERIOD);
		-------- TEST SUIT END --------
		
		
		timeout(3, CLK_PERIOD);
		cpu_to_cache.rd <= '1';
		cpu_to_cache.address <= 14x"0000";
		timeout(3, CLK_PERIOD);
		cpu_to_cache.rd <= '0';
		cpu_to_cache.address <= (others => 'X');
		mem_to_cache.rddata <= 32x"12345678";
		timeout(1, CLK_PERIOD);
		mem_to_cache.rddata <= (others => 'X');
		
		timeout(3, CLK_PERIOD);
		cpu_to_cache.rd <= '1';
		cpu_to_cache.address <= 14x"0F0B";
		wait until falling_edge(cache_to_cpu.busy);
		cpu_to_cache.rd <= '0';
		cpu_to_cache.address <= (others => 'X');
		mem_to_cache.rddata <= 32x"12345678";
		timeout(1, CLK_PERIOD);
		mem_to_cache.rddata <= (others => 'X');
		
		timeout(3, CLK_PERIOD);
		cpu_to_cache.rd <= '1';
		cpu_to_cache.address <= 14x"0AAB";
		wait until falling_edge(cache_to_cpu.busy);
		cpu_to_cache.rd <= '0';
		cpu_to_cache.address <= (others => 'X');
		mem_to_cache.rddata <= 32x"87654321";
		timeout(1, CLK_PERIOD);
		mem_to_cache.rddata <= (others => 'X');
		
		timeout(3, CLK_PERIOD);
		cpu_to_cache.wr <= '1';
		cpu_to_cache.address <= 14x"0AAB";
		cpu_to_cache.wrdata <= 32x"44444444";
		timeout(1, CLK_PERIOD);
		cpu_to_cache.wr <= '0';
		cpu_to_cache.address <= (others => 'X');
		
		timeout(3, CLK_PERIOD);
		cpu_to_cache.rd <= '1';
		cpu_to_cache.address <= 14x"0CCB";
		wait until falling_edge(cache_to_cpu.busy);
		cpu_to_cache.rd <= '0';
		cpu_to_cache.address <= (others => 'X');
		mem_to_cache.rddata <= 32x"87654321";
		timeout(1, CLK_PERIOD);
		mem_to_cache.rddata <= (others => 'X');
		
		timeout(3, CLK_PERIOD);
		cpu_to_cache.rd <= '1';
		cpu_to_cache.address <= 14x"0AAB";
		wait until falling_edge(cache_to_cpu.busy);
		cpu_to_cache.rd <= '0';
		cpu_to_cache.address <= (others => 'X');
		mem_to_cache.rddata <= 32x"12345678";
		timeout(1, CLK_PERIOD);
		mem_to_cache.rddata <= (others => 'X');
		
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
