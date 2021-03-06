library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.mem_pkg.all;
use work.cache_pkg.all;

entity cache is
	generic (
		SETS_LD   : natural          := SETS_LD;
		WAYS_LD   : natural          := WAYS_LD;
		ADDR_MASK : mem_address_type := (others => '1')
	);
	port (
		clk   : in std_logic;
		res_n : in std_logic;

		mem_out_cpu : in  mem_out_type;
		mem_in_cpu  : out mem_in_type := MEM_IN_NOP2;
		mem_out_mem : out mem_out_type := MEM_OUT_NOP2;
		mem_in_mem  : in  mem_in_type
	);
end entity;

architecture bypass of cache is --bypass cache for exIII and testing
	alias cpu_to_cache : mem_out_type is mem_out_cpu; 
	alias cache_to_cpu : mem_in_type is mem_in_cpu;   
	alias cache_to_mem : mem_out_type is mem_out_mem; 
	alias mem_to_cache : mem_in_type is mem_in_mem;   
begin
	cache_to_mem <= cpu_to_cache; 
	cache_to_cpu <= mem_to_cache; 
end architecture;

architecture impl of cache is
	signal cpu_to_cache : mem_out_type :=MEM_OUT_NOP2; 
	alias cache_to_cpu : mem_in_type is mem_in_cpu;   
	alias cache_to_mem : mem_out_type is mem_out_mem; 
	alias mem_to_cache : mem_in_type is mem_in_mem;  
	
	type state_t is (IDLE, READ_CACHE, READ_MEM_START, READ_MEM, WRITE_BACK_START, WRITE_BACK);
	signal state  								: state_t := IDLE;
	signal state_next							: state_t := IDLE;
	
	signal cpu_to_cache_s 					: mem_out_type := MEM_OUT_NOP;
	--mgmt_st
	signal mgmt_st_index_s					: c_index_type := (others => '0');
	signal mgmt_st_wr_s						: std_logic := '0';
	signal mgmt_st_rd_s						: std_logic := '0';
	
	signal mgmt_st_valid_in_s				: std_logic := '0';
	signal mgmt_st_dirty_in_s				: std_logic := '0';
	signal mgmt_st_tag_in_s					: c_tag_type := (others => '0');
	signal mgmt_st_way_out_s				: c_way_type := (others => '0');
	signal mgmt_st_valid_out_s				: std_logic := '0';
	signal mgmt_st_dirty_out_s				: std_logic	:= '0';
	signal mgmt_st_tag_out_s				: c_tag_type := (others => '0');
	signal mgmt_st_hit_out_s				: std_logic := '0';
	
	--data_st
	signal data_st_we_s						: std_logic := '0';
	signal data_st_rd_s						: std_logic := '0';
	signal data_st_way_s						: c_way_type := (others => '0');
	signal data_st_index_s					: c_index_type := (others => '0');
	signal data_st_byteena_s				: mem_byteena_type := (others => '0');
	
	signal data_st_data_in_s				: mem_data_type := (others => '0');
	signal data_st_data_out_s				: mem_data_type := (others => '0');
	
	
begin
	cpu_to_cache <= mem_out_cpu;

	sync: process(clk, res_n)
	begin
		if res_n = '0' then
			state <= IDLE;
		elsif rising_edge(clk) then
			state <= state_next;
			cpu_to_cache_s <= cpu_to_cache;
		end if;
	end process;
	
	fsm: process(all)
	begin
		--Fallback cases:
		state_next <= state;
		cache_to_cpu <= MEM_IN_NOP;
		cache_to_mem <= MEM_OUT_NOP;
		
		--Managment Fallback values:
		mgmt_st_wr_s <= '0';
		mgmt_st_valid_in_s <= '0';
		mgmt_st_dirty_in_s <= '0';
		mgmt_st_index_s <= (others => '0');
		
		mgmt_st_index_s <= cpu_to_cache.address(INDEX_SIZE-1 downto 0);
		mgmt_st_tag_in_s <= cpu_to_cache.address(ADDR_WIDTH-1 downto ADDR_WIDTH-TAG_SIZE);
		
		--Data Fallback values:
		data_st_we_s <= '0';
		data_st_data_in_s <= (others => '0');
	
		data_st_index_s <= cpu_to_cache.address(INDEX_SIZE-1 downto 0);
		
		case state is
			when IDLE =>
				if (cpu_to_cache.address and not ADDR_MASK) /= 14x"0000" then
					cache_to_mem <= cpu_to_cache;
					cache_to_cpu <= mem_to_cache;
					state_next <= IDLE;
				elsif cpu_to_cache.rd = '1' and cpu_to_cache.wr = '0' then
					--read access
					state_next <= READ_CACHE;
				elsif cpu_to_cache.rd = '0' and cpu_to_cache.wr = '1' then
					--write access
					mgmt_st_index_s <= cpu_to_cache.address(INDEX_SIZE-1 downto 0);
					mgmt_st_tag_in_s <= cpu_to_cache.address(ADDR_WIDTH-1 downto ADDR_WIDTH-TAG_SIZE);
					data_st_index_s <= cpu_to_cache.address(INDEX_SIZE-1 downto 0);
					if mgmt_st_hit_out_s = '1' then
						mgmt_st_wr_s <= '1';
						mgmt_st_valid_in_s <= '1';
						mgmt_st_dirty_in_s <= '1';
						data_st_we_s <= '1';
						data_st_data_in_s <= cpu_to_cache.wrdata;
					else -- write miss
						cache_to_mem <= cpu_to_cache;
					end if;
					state_next <= IDLE;
				else 
					state_next <= IDLE;
				end if;
				
			when READ_CACHE =>
				cache_to_cpu.busy <= '1';
				if mgmt_st_hit_out_s = '1' and cpu_to_cache.rd = '0' then
					cache_to_cpu.rddata <= data_st_data_out_s;
					state_next <= IDLE;
				elsif mgmt_st_hit_out_s = '1' and cpu_to_cache.rd = '1' then
					cache_to_cpu.rddata <= data_st_data_out_s;
					state_next <= READ_CACHE;
				else
					--miss
					if mgmt_st_dirty_out_s = '1' then
						state_next <= WRITE_BACK_START;
					else
						state_next <= READ_MEM_START;
					end if;
				end if;
				
			when READ_MEM_START =>
				cache_to_cpu.busy <= '1'; --safety busy
				cache_to_mem <= cpu_to_cache;
				cache_to_mem.rd <= '1';
				state_next <= READ_MEM;
				
			when READ_MEM =>
				cache_to_cpu <= mem_to_cache;
				cache_to_cpu.busy <= '1'; --safety busy
				if mem_to_cache.busy = '1' then
					state_next <= READ_MEM;
				else
					mgmt_st_wr_s <= '1';
					mgmt_st_valid_in_s <= '1';
					data_st_data_in_s <= mem_to_cache.rddata;
					data_st_we_s <= '1';
					if cpu_to_cache.rd = '1' and cpu_to_cache.wr = '0' then
						state_next <= READ_CACHE;
					elsif cpu_to_cache.rd = '0' and cpu_to_cache.wr = '1' then
						--write access
						state_next <= IDLE;
					else
						state_next <= IDLE;
					end if;
				end if;
				
			when WRITE_BACK_START =>
				cache_to_cpu.busy <= '1'; --safety busy
				cache_to_mem.address <= mgmt_st_tag_out_s & cpu_to_cache_s.address(INDEX_SIZE-1 downto 0);
				cache_to_mem.wr <= '1';
				cache_to_mem.wrdata <= data_st_data_out_s;
				state_next <= WRITE_BACK;
				
			when WRITE_BACK =>
				cache_to_cpu <= mem_to_cache; --change when mem used
				cache_to_cpu.busy <= '1'; --safety busy for tb
				if mem_to_cache.busy = '1' then
					state_next <= WRITE_BACK;
				else
					state_next <= READ_MEM_START;
				end if;
		end case;
	end process;
	
	
	mgmt_st_inst: entity work.mgmt_st
	generic map(
		SETS_LD  	=> SETS_LD,
		WAYS_LD  	=> WAYS_LD
	)
	port map (
		clk   		=> clk 																					,--std_logic
		res_n 		=> res_n																					,--std_logic

		index 		=> mgmt_st_index_s																	,--c_index_type,  cpu_to_cache_s.address(INDEX_SIZE-1 downto 0)
		wr    		=>	mgmt_st_wr_s																		,--std_logic
		rd    		=>	'1'																					,--std_logic

		valid_in    => mgmt_st_valid_in_s																,--std_logic
		dirty_in    => mgmt_st_dirty_in_s																,--std_logic
		tag_in      => mgmt_st_tag_in_s																	,--c_tag_type
		way_out     => open																					,--c_way_type
		valid_out   => open																					,--std_logic
		dirty_out   => mgmt_st_dirty_out_s																,--std_logic
		tag_out     => mgmt_st_tag_out_s																	,--c_tag_type
		hit_out     =>	mgmt_st_hit_out_s   																--std_logic
	);
	
	data_st_inst: entity work.data_st
	generic map (
		SETS_LD  	=> SETS_LD,
		WAYS_LD  	=> WAYS_LD
	)
	port map(
		clk        => clk 																					,--std_logic

		we         => data_st_we_s																			,--std_logic
		rd         => '1'																						,--std_logic
		way        => (others => '0')																		,--c_way_type
		index      => data_st_index_s																		,--c_index_type
		byteena    => (others => '1')																		,--mem_byteena_type

		data_in    => data_st_data_in_s																	,--mem_data_type
		data_out   => data_st_data_out_s																	--mem_data_type
	);
end architecture;
