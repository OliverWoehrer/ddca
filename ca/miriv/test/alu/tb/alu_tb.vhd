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
	type input_t is
	record
		A			: data_type;
		B  		: data_type;
	end record;
	signal inp  : input_t := (
		(others => '0'),
		(others => '0')
	);
	signal op	: alu_op_type;
	
	--Output signals:
	type output_t is
	record
		R	: data_type;
		Z 	: std_logic;
	end record;
	type output_array_t is array (10 downto 0) of output_t;
	signal outp : output_t;

	--Procedures and Functions:
	impure function read_next_input(file f : text) return input_t is
		variable l : line;
		variable result : input_t;
	begin
		l := get_next_valid_line(f);
		result.A := bin_to_slv(l.all, DATA_WIDTH);
		l := get_next_valid_line(f);
		result.B := bin_to_slv(l.all, DATA_WIDTH);
		
		return result;
	end function;
	
	impure function read_next_output(file f : text) return output_array_t is
		variable l : line;
		variable result : output_array_t;
	begin
		for i in 0 to 10 loop
			l := get_next_valid_line(f);
			result(i).R := bin_to_slv(l.all, DATA_WIDTH);

			l := get_next_valid_line(f);
			result(i).Z := str_to_sl(l(1));
		end loop;
		
		return result;
	end function;
	
	procedure check_output(output_ref : output_t) is
		variable passed : boolean;
	begin
		passed := (outp = output_ref);

		if not passed then
			report "FAILED: "&"op="&to_string(op)& lf
			& "**     expected: R=" & to_string(output_ref.R) & " Z=" & to_string(output_ref.Z) & lf
			& "**     actual:   R=" & to_string(outp.R)       & " Z=" & to_string(outp.Z) & lf
			severity error;
		else
			/*report " PASSED: "&"op="&to_string(op)& lf
			severity note;*/
		end if;
	end procedure;

begin
	--Instance of UUT:
	alu_inst : entity work.alu
	port map (
		op => op,
		A  => inp.A,
		B	=> inp.B,
		R  => outp.R,
		Z	=> outp.Z
	);

	--Read and apply input data:
	stimulus : process
		variable fstatus: file_open_status;
		type ALU_ops_t is array (10 downto 0) of alu_op_type;
		constant ALU_OPS : ALU_ops_t := (
			0 => ALU_NOP,
			1 => ALU_SLT,
			2 => ALU_SLTU,
			3 => ALU_SLL,
			4 => ALU_SRL,
			5 => ALU_SRA,
			6 => ALU_ADD,
			7 => ALU_SUB,
			8 => ALU_AND,
			9 => ALU_OR,
			10 => ALU_XOR
		);
	begin
		res_n <= '0';
		wait for 5*CLK_PERIOD;
		res_n <= '1';
		
		file_open(fstatus, input_file, "testdata/input.txt", READ_MODE);
		
		timeout(1, CLK_PERIOD);

		while not endfile(input_file) loop
			inp <= read_next_input(input_file);
			for i in 0 to 10 loop
				op <= ALU_OPS(i);
				timeout(1, CLK_PERIOD);
			end loop;
		end loop;
		wait;
	end process;

	--Check and compare output of UUT:
	output_checker : process
		variable fstatus: file_open_status;
		variable output_ref : output_array_t;
	begin
		file_open(fstatus, output_ref_file, "testdata/output.txt", READ_MODE);

		wait until res_n = '1';
		timeout(1, CLK_PERIOD);

		while not endfile(output_ref_file) loop
			output_ref := read_next_output(output_ref_file);
			report "TEST:"&" A=" &to_string(inp.A)&" B="&to_string(inp.B)& lf;
			for i in 0 to 10 loop
				wait until falling_edge(clk);
				check_output(output_ref(i));
				wait until rising_edge(clk);
			end loop;	
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
