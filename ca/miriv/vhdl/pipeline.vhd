library ieee;
use ieee.std_logic_1164.all;

use work.core_pkg.all;
use work.mem_pkg.all;
use work.op_pkg.all;

entity pipeline is
	port (
		clk    : in  std_logic;
		res_n  : in  std_logic;

		-- instruction interface
		mem_i_out    : out mem_out_type;
		mem_i_in     : in  mem_in_type;

		-- data interface
		mem_d_out    : out mem_out_type;
		mem_d_in     : in  mem_in_type
	);
end entity;

architecture impl of pipeline is
	signal stall_s 						: std_logic := '0';
	
	--fetch
	signal mem_busy_from_fetch_s		: std_logic;
	signal pc_from_fetch_s 				: pc_type;
	signal instr_from_fetch_s			: instr_type;
	
	--decode
	signal pc_from_decode_s				: pc_type;
	signal exec_op_from_decode_s		: exec_op_type;
	signal mem_op_from_decode_s		: mem_op_type;
	signal wb_op_from_decode_s			: wb_op_type;
	
	--execute 
	signal pc_old_from_execute_s		: pc_type;
	signal pc_new_from_execute_s		: pc_type;
	signal aluresult_from_execute_s  : data_type;
	signal wrdata_from_execute_s		: data_type;
	signal zero_from_execute_s			: std_logic;
	signal mem_op_from_execute_s		: mem_op_type;
	signal wb_op_from_execute_s		: wb_op_type;
	
	--mem
	signal mem_busy_from_mem_s			: std_logic;
	signal reg_write_from_mem_s		: reg_write_type;
	
	signal pcsrc_from_mem_s				: std_logic;
	signal pc_in_form_mem_s				: pc_type;
	
	signal wbop_from_mem_s 				: wb_op_type;
	signal pc_old_from_mem_s    		: pc_type;
	signal aluresult_from_mem_s 		: data_type;
	signal memresult_from_mem_s     	: data_type;
	
	--wb
	signal reg_write_from_wb_s			: reg_write_type;
	
	
begin
	stall_s <= mem_busy_from_fetch_s or mem_busy_from_mem_s;

	fetch_stage_inst : entity work.fetch
	port map (
		clk       => clk,
		res_n     => res_n,
		stall     => stall_s,
		flush     => '0',
		mem_busy  => mem_busy_s,
		
		-- from mem
		pcsrc     => pcsrc_from_mem_s,
		pc_in     => pc_in_form_mem_s,
		
		-- to_decode
		pc_out    => pc_from_fetch_s,
		instr     => instr_from_fetch_s,

		-- memory controller interface
		mem_out   => mem_i_out,
		mem_in    => mem_i_in
	);
	
	decode_stage_inst : entity work.decode
	port map(
		clk       	=> clk,
		res_n      	=> res_n,
		stall      	=> stall_s,
		flush      	=> '0',
	
		-- from fetch
		pc_in      	=> pc_from_fetch_s,					
		instr      	=> instr_from_fetch_s,			

		-- from writeback
		reg_write  => reg_write_from_wb_s,

		-- towards next stages
		pc_out     => pc_from_decode_s,			
		exec_op    => exec_op_from_decode_s,					
		mem_op     => mem_op_from_decode_s,					
		wb_op      => wb_op_from_decode_s					

		-- exceptions
		exc_dec    => open
	);
	
	execute_stage_inst : entity work.exec
	port map(
		clk           => clk,
		res_n         => res_n,
		stall         => stall_s,
		flush         => '0',

		-- from DEC
		op            => exec_op_from_decode_s,
		pc_in         => pc_from_decode_s,

		-- to MEM
		pc_new_out    => pc_new_from_execute_s,
		pc_old_out    => pc_old_from_execute_s,
		aluresult     => aluresult_from_execute_s,
		wrdata        => wrdata_from_execute_s,
		zero          => zero_from_execute_s,

		memop_in      => mem_op_from_decode_s,
		memop_out     => mem_op_from_execute_s,
		wbop_in       => wb_op_from_decode_s,
		wbop_out      => wb_op_from_execute_s,

		-- FWD
		exec_op       => open,
		reg_write_mem => reg_write_from_mem_s,
		reg_write_wr  => (others => '0');
	);
	
	memory_stage_inst : entity work.mem
	port map(
		clk           	=> clk,
		res_n        	=> res_n,
		stall         	=> stall_s,
		flush         	=> '0',

		-- to Ctrl
		mem_busy      	=> mem_busy_from_mem_s,

		-- from EXEC
		mem_op        	=> mem_op_from_execute_s,
		wbop_in      	=> wb_op_from_execute_s,
		pc_new_in    	=> pc_new_from_execute_s,
		pc_old_in     	=> pc_old_from_execute_s,
		aluresult_in  	=> aluresult_from_execute_s,
		wrdata        	=> wrdata_from_execute_s,
		zero          	=> zero_from_execute_s,

		-- to EXEC (forwarding)
		reg_write     	=> reg_write_from_mem_s,

		-- to FETCH
		pc_new_out    	=> pc_in_form_mem_s,
		pcsrc         	=> pcsrc_from_mem_s,

		-- to WB
		wbop_out      	=> wbop_from_mem_s,
		pc_old_out    	=> pc_old_from_mem_s,
		aluresult_out 	=> aluresult_from_mem_s,
		memresult     	=> memresult_from_mem_s,

		-- memory controller interface
		mem_out       	=> mem_d_out,
		mem_in        	=> mem_d_in,

		-- exceptions
		exc_load      	=> open,
		exc_store     	=> open
	);
	
	write_back_inst : entity work.wb
	port map(
		clk        		=> clk,
		res_n      		=> res_n,
		stall      		=> stall_s,
		flush      		=> '0',

		-- from MEM
		op         		=> wbop_from_mem_s,
		aluresult  		=> aluresult_from_mem_s,
		memresult  		=> memresult_from_mem_s,
		pc_old_in 		=> pc_old_from_mem_s,		
		
		-- to FWD and DEC
		reg_write  		=> reg_write_from_wb_s
	);
	
end architecture;
