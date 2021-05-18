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
	signal stop : boolean := false;

	--Test data file objects:
	file input_file : text;
	file output_ref_file : text;
	
	--Input signals:
	type input_t is
	record
		A  		: data_type;
		W			: data_type;
		D			: mem_in_type;
	end record;
	signal inp  : input_t := (
		(others => '0'),
		(others => '0'),
		MEM_IN_NOP
	);
	
	signal op	: memu_op_type;
	
	--Output signals:
	type output_t is
	record
		R	: data_type;
		B 	: std_logic;
		XL : std_logic;
		XS	: std_logic;
		M  : mem_out_type;
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
		result.W := bin_to_slv(l.all, DATA_WIDTH);
		l := get_next_valid_line(f);
		result.D := to_mem_in_type(bin_to_slv(l.all, DATA_WIDTH));
		
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
			result(i).B := str_to_sl(l(1));
			l := get_next_valid_line(f);
			result(i).XS := str_to_sl(l(1));
			l := get_next_valid_line(f);
			result(i).XL := str_to_sl(l(1));
			
			l := get_next_valid_line(f);
			result(i).M := to_mem_out_type(bin_to_slv(l.all, DATA_WIDTH));
		end loop;
		
		return result;
	end function;
	
	procedure check_output(output_ref : output_t) is
		variable passed : boolean;
	begin
		passed := (outp = output_ref);

		if not passed then
			report "FAILED: "&"op="&to_string(op)& lf
			& "**     expected: R=" & to_string(output_ref.R) & " B=" & to_string(output_ref.B) & " XL=" & to_string(output_ref.XL) & " XS=" & to_string(output_ref.XS) & " M=" & to_string(output_ref.M)& lf
			& "**     actual:   R=" & to_string(outp.R)       & " B=" & to_string(outp.B) 		& " XL=" & to_string(outp.XL) 		& " XS=" & to_string(outp.XS) 		& " M=" & to_string(outp.M) & lf
			severity error;
		else
			/*report " PASSED: "&"op="&to_string(op)& lf
			severity note;*/
		end if;
	end procedure;

begin
	--Instance of UUT:
	memu_inst : entity work.memu
	port map (
		op => op,
		A  => inp.A,
		W	=> inp.W,
		R  => outp.R,
		
		B	=> outp.B,
		XL => outp.XL,
		XS	=> outp.XS,
		
		D => inp.D,
		M => outp.M
	);

	--Read and apply input data:
	stimulus : process
		variable fstatus: file_open_status;
		type MEM_ops_t is array (9 downto 0) of memu_op_type;
		constant MEM_OPS : MEM_ops_t := (
			0 => ('1','0',MEM_B),
			1 => ('1','0',MEM_BU),
			2 => ('1','0',MEM_H),
			3 => ('1','0',MEM_HU),
			4 => ('1','0',MEM_W),
			5 => ('0','1',MEM_B),
			6 => ('0','1',MEM_BU),
			7 => ('0','1',MEM_H),
			8 => ('0','1',MEM_HU),
			9 => ('0','1',MEM_W)
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
				op <= MEM_OPS(i);
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
			report "TEST:"&" A=" &to_string(inp.A)&" W="&to_string(inp.W)&" D="&to_string(to_std_logic_vector(inp.D))& lf;
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
