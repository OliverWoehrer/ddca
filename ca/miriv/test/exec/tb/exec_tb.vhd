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
		pcsrc : std_logic;
		pc_in : pc_type;
		mem_in : mem_in_type;
	end record;
	signal inp  : input_t := (
		pcsrc => '0',
		pc_in => ZERO_PC,
		mem_in => MEM_IN_NOP
	);
	
	--Output signals:
	type output_t is record
		pc_out : pc_type;
		instr	: instr_type;
	end record;
	signal outp : output_t := (
		pc_out => (others => '0'),
		instr => (others => '0')
	);

	--Procedures and Functions:
	impure function read_next_input(file f : text) return input_t is
		variable l : line;
		variable result : input_t;
		variable temp_slv: data_type;
	begin
		l := get_next_valid_line(f);
		result.pcsrc := str_to_sl(l(1));
		l := get_next_valid_line(f);
		result.pc_in := hex_to_slv(l.all, PC_WIDTH);
		l := get_next_valid_line(f);
		result.mem_in.busy := '0';
		temp_slv := hex_to_slv(l.all, DATA_WIDTH);
		result.mem_in.rddata(31 downto 24) := temp_slv(7 downto 0);		--b0, most significant byte
		result.mem_in.rddata(23 downto 16) := temp_slv(15 downto 8);		--b1
		result.mem_in.rddata(15 downto 8)  := temp_slv(23 downto 16);	--b2
		result.mem_in.rddata(7 downto 0)   := temp_slv(31 downto 24);	--b3, least significant byte
		return result;
	end function;
	
	impure function read_next_output(file f : text) return output_t is
		variable l : line;
		variable result : output_t;
	begin
		l := get_next_valid_line(f);
		result.pc_out := hex_to_slv(l.all, PC_WIDTH);
		l := get_next_valid_line(f);
		result.instr := hex_to_slv(l.all, DATA_WIDTH);
		return result;
	end function;
	
	procedure check_output(refp : output_t) is
		variable passed : boolean;
	begin
		passed := (outp = refp);

		if not passed then
			report "FAILED: "&"PC_IN="&to_string(inp.pc_in)& lf
			& "**     expected: PC_OUT="&to_string(refp.pc_out)&" Instr="&to_string(refp.instr)&lf
			& "**     actual:   PC_OUT="&to_string(outp.pc_out)&" Instr="&to_string(outp.instr)&lf
			severity error;
		end if;
	end procedure;

begin
	--Instance of UUT:
	fetch_inst : entity work.fetch
	port map (
		clk		=> clk,
		res_n		=> res_n,
		stall		=> '0',
		flush		=> '0',
		mem_busy	=> open,
		pcsrc		=> inp.pcsrc,
		pc_in		=> inp.pc_in,
		pc_out	=> outp.pc_out,
		instr    => outp.instr,
		mem_out  => open,
		mem_in	=> inp.mem_in
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
