library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.mem_pkg.all;
use work.op_pkg.all;

entity mem is
	port (
		clk           : in  std_logic;
		res_n         : in  std_logic;
		stall         : in  std_logic;
		flush         : in  std_logic;

		-- to Ctrl
		mem_busy      : out std_logic;

		-- from EXEC
		mem_op        : in  mem_op_type;
		wbop_in       : in  wb_op_type;
		pc_new_in     : in  pc_type;
		pc_old_in     : in  pc_type;
		aluresult_in  : in  data_type;
		wrdata        : in  data_type;
		zero          : in  std_logic;

		-- to EXEC (forwarding)
		reg_write     : out reg_write_type;

		-- to FETCH
		pc_new_out    : out pc_type;
		pcsrc         : out std_logic;

		-- to WB
		wbop_out      : out wb_op_type;
		pc_old_out    : out pc_type;
		aluresult_out : out data_type;
		memresult     : out data_type;

		-- memory controller interface
		mem_out       : out mem_out_type;
		mem_in        : in  mem_in_type;

		-- exceptions
		exc_load      : out std_logic;
		exc_store     : out std_logic
	);
end entity;

architecture rtl of mem is

	signal mem_op_s     : mem_op_type; 			--branch, mem(memread, memwrite, memtype)
	signal wbop_s       : wb_op_type;			--rd, write, src
	signal pc_new_s     : pc_type;
	signal pc_old_s     : pc_type;
	signal aluresult_s  : data_type;
	signal wrdata_s     : data_type;
	signal zero_s       : std_logic;

begin

	reg : process 
	begin
		wait until rising_edge(clk);
		if res_n = '0' then
			mem_op_s 	<= MEM_NOP;
			wbop_s		<= WB_NOP;
			pc_new_s 	<= (others => '0');
			pc_old_s		<= (others => '0');
			aluresult_s <= (others => '0');
			wrdata_s		<= (others => '0');
			zero_s		<= '0';
		elsif flush = '1' then
			mem_op_s 	<= MEM_NOP;
			wbop_s		<= WB_NOP;
		elsif stall = '0' then
			mem_op_s 	<= mem_op;
			wbop_s		<= wbop_in;
			pc_new_s		<= pc_new_in;
			pc_old_s		<= pc_old_in;
			aluresult_s	<= aluresult_in;
			wrdata_s		<= wrdata;
			zero_s		<= zero;
		else
			mem_op_s.mem.memread <= '0';
			mem_op_s.mem.memwrite <= '0';
		end if;
	end process reg;
	
	branch : process(all)
	begin
		case mem_op_s.branch is
			when BR_BR =>
				pc_new_out <= aluresult_in(15 downto 1) & '0';
			when BR_CND => 
				pc_new_out <= pc_new_s when zero_s = '1' else pc_old_s;
			when BR_CNDI => 
				pc_new_out <= pc_new_s when zero_s = '0' else pc_old_s;
			when others => 					--BR_NOP
				pc_new_out <= pc_old_s;
			end case;
	end process branch;
	

	memu_inst : entity work.memu
	port map(
		op => mem_op_s.mem,
		A => aluresult_s,
		W => wrdata_s,
		R => memresult,

		B => mem_busy,
		XL => exc_load,
		XS => exc_store,

		D => mem_in,
		M => mem_out
	);
end architecture;
