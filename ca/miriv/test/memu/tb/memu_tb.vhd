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
		op			: memu_op_type;
		A  		: data_type;
		W			: data_type;
		D			: mem_in_type;
	end record;
	signal inp  : input_t := (
		MEMU_NOP,
		(others => '0'),
		(others => '0'),
		MEM_IN_NOP
	);
	
	
	--Output signals:
	type output_t is
	record
		R	: data_type;
		B 	: std_logic;
		XL : std_logic;
		XS	: std_logic;
		M  : mem_out_type;
	end record;
	type output_array_t is array (9 downto 0) of output_t;
	signal outp : output_t;

	--Procedures and Functions:
	impure function read_next_input(file f : text) return input_t is
		variable l : line;
		variable result : input_t;
	begin
		l := get_next_valid_line(f);
		result.op.memread := str_to_sl(l(1));
		l := get_next_valid_line(f);
		result.op.memwrite := str_to_sl(l(1));
		l := get_next_valid_line(f);
		result.op.memtype := str_to_mem_op(l.all);
		l := get_next_valid_line(f);
		result.A := bin_to_slv(l.all, DATA_WIDTH);
		l := get_next_valid_line(f);
		result.W := bin_to_slv(l.all, DATA_WIDTH);
		l := get_next_valid_line(f);
		result.D := to_mem_in_type(bin_to_slv(l.all, DATA_WIDTH + 1));
		
		return result;
	end function;
	
	impure function read_next_output(file f : text) return output_t is
		variable l : line;
		variable result : output_t;
	begin
		l := get_next_valid_line(f);
		result.R := bin_to_slv(l.all, DATA_WIDTH);

		l := get_next_valid_line(f);
		result.B := str_to_sl(l(1));
		l := get_next_valid_line(f);
		result.XS := str_to_sl(l(1));
		l := get_next_valid_line(f);
		result.XL := str_to_sl(l(1));
		
		l := get_next_valid_line(f);
		result.M := to_mem_out_type(bin_to_slv(l.all, DATA_WIDTH + ADDR_WIDTH + 1 + 1 + BYTEEN_WIDTH));
		return result;
	end function;
	
	procedure check_output(output_ref : output_t) is
		variable passed : boolean;
	begin
		passed := (outp = output_ref);

		if not passed then
			report "FAILED: "&"op="&to_string(inp.op.memread)&to_string(inp.op.memwrite)&to_string(inp.op.memtype)& lf
			& "**     expected: R=" & to_string(output_ref.R) & " B=" & to_string(output_ref.B) & " XL=" & to_string(output_ref.XL) & " XS=" & to_string(output_ref.XS) & " M Address=" & to_string(output_ref.M.address)
			& " M.wr=" & to_string(output_ref.M.wr)& " M.rd=" & to_string(output_ref.M.rd)& " M.byteena=" & to_string(output_ref.M.byteena)& " M.wrdata=" & to_string(output_ref.M.wrdata)& lf
			& "**     actual:   R=" & to_string(outp.R)       & " B=" & to_string(outp.B) 		& " XL=" & to_string(outp.XL) 		& " XS=" & to_string(outp.XS) 		& " M Address=" & to_string(outp.M.address) 
			& " M.wr=" & to_string(outp.M.wr)& 		  " M.rd=" & to_string(outp.M.rd)& 		  " M.byteena=" & to_string(outp.M.byteena)& 			" M.wrdata=" & to_string(outp.M.wrdata)& lf
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
		op => inp.op,
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
			0 => ('0','1',MEM_B),
			1 => ('0','1',MEM_BU),
			2 => ('0','1',MEM_H),
			3 => ('0','1',MEM_HU),
			4 => ('0','1',MEM_W),
			5 => ('1','0',MEM_B),
			6 => ('1','0',MEM_BU),
			7 => ('1','0',MEM_H),
			8 => ('1','0',MEM_HU),
			9 => ('1','0',MEM_W)
		);
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

		while not endfile(output_ref_file) loop
			output_ref := read_next_output(output_ref_file);
			report "TEST:"&" A=" &to_string(inp.A)&" W="&to_string(inp.W)&" D="&to_string(to_std_logic_vector(inp.D))& lf;
			wait until falling_edge(clk);
			check_output(output_ref);
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
