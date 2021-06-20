library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library std; -- for Printing
use std.textio.all;

use work.mem_pkg.all;
use work.op_pkg.all;
use work.core_pkg.all;
use work.tb_util_pkg.all;

entity tb is
end entity;

architecture bench of tb is
	--Basic instance signals
	constant CLK_PERIOD : time := 10 ns;
	signal clk : std_logic;
	signal res_n : std_logic := '0';
	signal stop : boolean := false;

	--Test data file objects:
	file input_file : text;
	file output_ref_file : text;
	
	--Input signals:
	type input_t is record
		op : exec_op_type;
		pc_in : pc_type;
	end record;
	signal inp  : input_t := (
		op => EXEC_NOP,
		pc_in => ZERO_PC
	);
	
	--Output signals:
	type output_t is record
		pc_old_out : pc_type;
		pc_new_out : pc_type;
		aluresult : data_type;
		wrdata : data_type;
		zero : std_logic;
	end record;
	signal outp : output_t := (
		pc_old_out => ZERO_PC,
		pc_new_out => ZERO_PC,
		aluresult => ZERO_DATA,
		wrdata => ZERO_DATA,
		zero => '0'
	);

	--Procedures and Functions:
	impure function read_next_input(file f : text) return input_t is
		variable l : line;
		variable result : input_t;
		variable temp_slv: data_type;
	begin
		l := get_next_valid_line(f);
		result.op := EXEC_NOP;
		l := get_next_valid_line(f);
		result.pc_in := ZERO_PC;
		return result;
	end function;
	
	impure function read_next_output(file f : text) return output_t is
		variable l : line;
		variable result : output_t;
	begin
		l := get_next_valid_line(f);
		result.pc_old_out := ZERO_PC;
		l := get_next_valid_line(f);
		result.pc_new_out := ZERO_PC;
		l := get_next_valid_line(f);
		result.aluresult := ZERO_DATA;
		l := get_next_valid_line(f);
		result.wrdata := ZERO_DATA;
		l := get_next_valid_line(f);
		result.zero := '0';
		return result;
	end function;
	
	procedure check_output(refp : output_t) is
		variable passed : boolean;
	begin
		passed := (outp = refp);

		if not passed then
--			report "FAILED: "&"PC_IN="&to_string(inp.pc_in)& lf
--			& "**     expected: PC_OUT="&to_string(refp.pc_old_out)&" Instr="&to_string(refp.pc_new_out)&lf
--			& "**     actual:   PC_OUT="&to_string(outp.pc_old_out)&" Instr="&to_string(outp.pc_new_out)&lf
--			severity error;
		end if;
	end procedure;

begin
	--Instance of UUT:
	exec_inst : entity work.exec
	port map (
		clk           => clk,
		res_n         => res_n,
		stall         => '0',
		flush         => '0',

		-- from DEC
		op            => inp.op,
		pc_in         => inp.pc_in,

		-- to MEM
		pc_old_out    => outp.pc_old_out,
		pc_new_out    => outp.pc_new_out,
		aluresult     => outp.aluresult,
		wrdata        => outp.wrdata,
		zero          => outp.zero,

		memop_in      => MEM_NOP,
		memop_out     => open,
		wbop_in       => WB_NOP,
		wbop_out      => open,

		-- FWD
		exec_op       => open,
		reg_write_mem => REG_NOP,
		reg_write_wr  => REG_NOP
	);

	--Read and apply input data:
	stimulus : process
		variable fstatus: file_open_status;
	begin
		--First iteration
		res_n <= '0';
		timeout(5, CLK_PERIOD);
		res_n <= '1';
		file_open(fstatus, input_file, "testdata/input.txt", READ_MODE);
		timeout(1, CLK_PERIOD);

		while not endfile(input_file) loop
			inp <= read_next_input(input_file);
			wait until rising_edge(clk);
		end loop;
		file_close(input_file);
		
		--Second iteration
		res_n <= '0';
		timeout(5, CLK_PERIOD);
		res_n <= '1';
		file_open(fstatus, input_file, "testdata/input.txt", READ_MODE);
		timeout(1, CLK_PERIOD);
		
		while not endfile(input_file) loop
			inp <= read_next_input(input_file);
		wait until rising_edge(clk);
		end loop;
		
		--stop <= true;
		wait;
	end process;

	--Check and compare output of UUT:
	output_checker : process
		variable fstatus: file_open_status;
		variable refp : output_t;
	begin
		--First iteration
		file_open(fstatus, output_ref_file, "testdata/output.txt", READ_MODE);
		wait until res_n = '1';
		timeout(1, CLK_PERIOD);

		while not endfile(output_ref_file) loop
			refp := read_next_output(output_ref_file);
			wait until falling_edge(clk);
			check_output(refp);
			wait until rising_edge(clk);
		end loop;
		file_close(output_ref_file);
		
		--Second iteration
		file_open(fstatus, output_ref_file, "testdata/output.txt", READ_MODE);
		wait until res_n = '1';
		timeout(1, CLK_PERIOD);

		while not endfile(output_ref_file) loop
			refp := read_next_output(output_ref_file);
			wait until falling_edge(clk);
			check_output(refp);
			wait until rising_edge(clk);
		end loop;
		
		stop <= true;
		wait;
	end process;
	

	generate_clk : process
	begin
		clk_generate(clk, CLK_PERIOD, stop);
		wait;
	end process;

end architecture;
