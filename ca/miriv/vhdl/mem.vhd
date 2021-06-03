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
		reg_write     : out reg_write_type := REG_NOP;

		-- to FETCH
		pc_new_out    : out pc_type := ZERO_PC;
		pcsrc         : out std_logic := '0';

		-- to WB
		wbop_out      : out wb_op_type := WB_NOP;
		pc_old_out    : out pc_type := ZERO_PC;
		aluresult_out : out data_type := ZERO_DATA;
		memresult     : out data_type := ZERO_DATA;

		-- memory controller interface
		mem_out       : out mem_out_type;
		mem_in        : in  mem_in_type;

		-- exceptions
		exc_load      : out std_logic := '0';
		exc_store     : out std_logic := '0'
	);
end entity;

architecture rtl of mem is

	signal mem_op_s     : mem_op_type := MEM_NOP; 			--branch, mem(memread, memwrite, memtype)
	signal wbop_s       : wb_op_type := WB_NOP;			--rd, write, src
	signal pc_new_s     : pc_type := ZERO_PC;
	signal pc_old_s     : pc_type := ZERO_PC;
	signal aluresult_s  : data_type := ZERO_DATA;
	signal wrdata_s     : data_type := ZERO_DATA;
	signal zero_s       : std_logic := '0';

begin
	reg_write		<= REG_NOP;
	wbop_out			<= wbop_s;
	pc_old_out		<= pc_old_s;
	aluresult_out	<= aluresult_s;
	
	reg : process 
	begin
		wait until rising_edge(clk);
		if res_n = '0' then
			mem_op_s 	<= MEM_NOP;
			wbop_s		<= WB_NOP;
			pc_new_s 	<= ZERO_PC;
			pc_old_s		<= ZERO_PC;
			aluresult_s <= ZERO_DATA
			wrdata_s		<= ZERO_DATA;
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
				pcsrc <= '1';
				pc_new_out <= pc_new_s(15 downto 1) & '0';
			when BR_CND =>
				if zero_s = '1' then
					pcsrc <= '1';
					pc_new_out <= pc_new_s;
				else
					pcsrc <= '0';
					pc_new_out <= pc_old_s;
				end if;
			when BR_CNDI => 
				if zero_s = '0' then
					pcsrc <= '1';
					pc_new_out <= pc_new_s;
				else
					pcsrc <= '0';
					pc_new_out <= pc_old_s;
				end if;
			when others => 					--BR_NOP
				pcsrc <= '0';
				pc_new_out <= pc_old_s;
		end case;
	end process branch;
	


	memu_inst : entity work.memu(rtl)
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
