library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library std; -- for Printing
use std.textio.all;

use work.mem_pkg.all;
use work.core_pkg.all;
use work.op_pkg.all;
use work.tb_util_pkg.all;

entity tb is
end entity;

architecture bench of tb is
	--Basic instance signals
	constant CLK_PERIOD : time := 10 ns;
	signal clk : std_logic;
	signal res_n : std_logic := '0';
	signal stall : std_logic := '0';
	signal flush : std_logic := '0';
	signal stop : boolean := false;

	--Test data file objects:
	file input_file : text;
	file output_ref_file : text;
	
	--Input signals:
	type input_t is
	record
		pc_in		: pc_type;
		instr  	: instr_type;
		reg_write: reg_write_type;
	end record;
	signal inp  : input_t := (
		(others => '0'),
		(others => '0'),
		('0',(others => '0'),(others => '0'))
	);
	
	
	--Output signals:
	type output_t is
	record
		pc_out	: pc_type;
		exec_op 	: exec_op_type;
		mem_op 	: mem_op_type;
		wb_op		: wb_op_type;
		exc_dec  : std_logic;
	end record;
	type output_array_t is array (9 downto 0) of output_t;
	signal outp : output_t ;

	--Procedures and Functions:
	impure function read_next_input(file f : text) return input_t is
		variable l : line;
		variable result : input_t;
	begin
		l := get_next_valid_line(f);
		result.pc_in := bin_to_slv(l.all, PC_WIDTH);
		
		l := get_next_valid_line(f);
		result.instr := bin_to_slv(l.all, DATA_WIDTH);
		
		l := get_next_valid_line(f);
		result.reg_write.write := str_to_sl(l(1));

		l := get_next_valid_line(f);
		result.reg_write.reg := bin_to_slv(l.all, REG_BITS);
		
		l := get_next_valid_line(f);
		result.reg_write.data := bin_to_slv(l.all, DATA_WIDTH);
		
		return result;
	end function;
	
	impure function read_next_output(file f : text) return output_t is
		variable l : line;
		variable result : output_t;
	begin
		return result;
	end function;
	
	procedure check_output(output_ref : output_t) is
		variable passed : boolean;
	begin
		passed := (outp = output_ref);
	end procedure;

begin
	--Instance of UUT:
	decode_inst : entity work.decode
	port map (
		clk => clk,
		res_n => res_n,
		stall => stall,
		flush => flush,
		
		pc_in => inp.pc_in,
		instr => inp.instr,
		
		reg_write => inp.reg_write,
		
		pc_out => outp.pc_out,
		exec_op => outp.exec_op,
		mem_op => outp.mem_op,
		wb_op => outp.wb_op,
		
		exc_dec => outp.exc_dec
		
	);

	--Read and apply input data:
	stimulus : process
		variable fstatus: file_open_status;
	begin
		res_n <= '0';
		wait for 5*CLK_PERIOD;
		res_n <= '1';
		
		file_open(fstatus, input_file, "testdata/input.txt", READ_MODE);
		timeout(1, CLK_PERIOD);

		while not endfile(input_file) loop
			inp <= read_next_input(input_file);
			timeout(1, CLK_PERIOD);
		end loop;
		wait;
	end process;

	--Check and compare output of UUT:
	output_checker : process
		variable fstatus: file_open_status;
		variable output_ref : output_t;
	begin
		file_open(fstatus, output_ref_file, "testdata/output.txt", READ_MODE);

		wait until res_n = '1';
		timeout(1, CLK_PERIOD);
		
		stop <= true;
		wait;
	end process;
	

	generate_clk : process
	begin
		clk_generate(clk, CLK_PERIOD, stop);
		wait;
	end process;

end architecture;
