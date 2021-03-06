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
	signal memory_busy_s					: std_logic := '0';
	
	--fetch
	signal stall_fetch_s					: std_logic := '0';
	signal flush_fetch_s					: std_logic := '0';
	signal mem_busy_from_fetch_s		: std_logic := '0';
	signal pc_from_fetch_s				: pc_type := ZERO_PC;
	signal instr_from_fetch_s			: instr_type := NOP_INST;
	
	--decode
	signal stall_dec_s					: std_logic := '0';
	signal flush_dec_s					: std_logic := '0';
	signal pc_from_decode_s				: pc_type := ZERO_PC;
	signal exec_op_from_decode_s		: exec_op_type := EXEC_NOP;
	signal mem_op_from_decode_s		: mem_op_type := MEM_NOP;
	signal wb_op_from_decode_s			: wb_op_type := WB_NOP;
	
	--execute
	signal stall_exec_s					: std_logic := '0';
	signal flush_exec_s					: std_logic := '0';
	signal pc_old_from_execute_s		: pc_type := ZERO_PC;
	signal pc_new_from_execute_s		: pc_type := ZERO_PC;
	signal aluresult_from_execute_s  : data_type := ZERO_DATA;
	signal wrdata_from_execute_s		: data_type := ZERO_DATA;
	signal zero_from_execute_s			: std_logic := '0';
	signal mem_op_from_execute_s		: mem_op_type := MEM_NOP;
	signal wb_op_from_execute_s		: wb_op_type := WB_NOP;
	
	--mem
	signal stall_mem_s					: std_logic := '0';
	signal flush_mem_s					: std_logic := '0';
	signal mem_busy_from_mem_s			: std_logic := '0';
	signal reg_write_from_mem_s		: reg_write_type := REG_NOP;
	
	signal pcsrc_from_mem_s				: std_logic := '0';
	signal pc_from_mem_s					: pc_type := ZERO_PC;
	
	signal wbop_from_mem_s 				: wb_op_type := WB_NOP;
	signal pc_old_from_mem_s    		: pc_type := ZERO_PC;
	signal aluresult_from_mem_s 		: data_type := ZERO_DATA;
	signal memresult_from_mem_s     	: data_type := ZERO_DATA;
	
	--wb
	signal stall_wb_s						: std_logic := '0';
	signal flush_wb_s						: std_logic := '0';
	signal reg_write_from_wb_s			: reg_write_type := REG_NOP;
	
	--ctrl
	signal pcsrc_from_crtl_s			: std_logic := '0';
	
begin
	memory_busy_s <= mem_busy_from_fetch_s or mem_busy_from_mem_s;

	fetch_inst : entity work.fetch
	port map (
		clk       => clk,
		res_n     => res_n,
		stall     => stall_fetch_s,
		flush     => flush_fetch_s,
		mem_busy  => mem_busy_from_fetch_s,
		
		-- from mem
		pcsrc     => pcsrc_from_crtl_s,
		pc_in     => pc_from_mem_s,
		
		-- to_decode
		pc_out    => pc_from_fetch_s,
		instr     => instr_from_fetch_s,

		-- memory controller interface
		mem_out   => mem_i_out,
		mem_in    => mem_i_in
	);
	
	decode_inst : entity work.decode
	port map(
		clk       	=> clk,
		res_n      	=> res_n,
		stall      	=> stall_dec_s,
		flush      	=> flush_dec_s,
	
		-- from fetch
		pc_in      	=> pc_from_fetch_s,					
		instr      	=> instr_from_fetch_s,			

		-- from writeback
		reg_write  => reg_write_from_wb_s,

		-- towards next stages
		pc_out     => pc_from_decode_s,			
		exec_op    => exec_op_from_decode_s,					
		mem_op     => mem_op_from_decode_s,					
		wb_op      => wb_op_from_decode_s,					

		-- exceptions
		exc_dec    => open
	);
	
	execute_inst : entity work.exec
	port map(
		clk           => clk,
		res_n         => res_n,
		stall         => stall_exec_s,
		flush         => flush_exec_s,

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
		reg_write_wr  => reg_write_from_wb_s
	);
	
	memory_inst : entity work.mem
	port map(
		clk           	=> clk,
		res_n        	=> res_n,
		stall         	=> stall_mem_s,
		flush         	=> flush_mem_s,

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
		pc_new_out    	=> pc_from_mem_s,
		pcsrc         	=> pcsrc_from_mem_s ,

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
	
	writeback_inst : entity work.wb
	port map(
		clk        		=> clk,
		res_n      		=> res_n,
		stall      		=> stall_wb_s,
		flush      		=> flush_wb_s,

		-- from MEM
		op         		=> wbop_from_mem_s,
		aluresult  		=> aluresult_from_mem_s,
		memresult  		=> memresult_from_mem_s,
		pc_old_in 		=> pc_old_from_mem_s,		
		
		-- to FWD and DEC
		reg_write  		=> reg_write_from_wb_s
	);
	

	
	control_inst : entity work.ctrl
	port map(
		clk         	=> clk,
		res_n       	=> res_n,
		stall       	=> memory_busy_s,

		stall_fetch 	=> stall_fetch_s,
		stall_dec   	=> stall_dec_s,
		stall_exec  	=> stall_exec_s,
		stall_mem   	=> stall_mem_s,
		stall_wb    	=> stall_wb_s,

		flush_fetch 	=> flush_fetch_s,
		flush_dec   	=> flush_dec_s,
		flush_exec  	=> flush_exec_s,
		flush_mem   	=> flush_mem_s,
		flush_wb    	=> flush_wb_s,

		-- from FWD
		wb_op_exec  	=> wb_op_from_execute_s,
		exec_op_dec 	=> exec_op_from_decode_s,

		pcsrc_in 		=> pcsrc_from_mem_s,
		pcsrc_out 		=> pcsrc_from_crtl_s
	);
	
	
end architecture;
