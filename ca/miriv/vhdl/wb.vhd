library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.op_pkg.all;

entity wb is
	port (
		clk        : in  std_logic;
		res_n      : in  std_logic;
		stall      : in  std_logic;
		flush      : in  std_logic;

		-- from MEM
		op         : in  wb_op_type;
		aluresult  : in  data_type;
		memresult  : in  data_type;
		pc_old_in  : in  pc_type;

		-- to FWD and DEC
		reg_write  : out reg_write_type := REG_NOP
	);
end entity;

architecture rtl of wb is
	signal op_s				: wb_op_type := WB_NOP;
	signal aluresult_s	: data_type := (others => '0');
	signal memresult_s	: data_type := (others => '0');
	signal pc_old_s		: pc_type := (others => '0');
begin
	mux : process(all)
	begin
		reg_write.write <= op_s.write;
		reg_write.reg <= op_s.rd;
		case op_s.src is
		when WBS_MEM =>
			reg_write.data <= memresult;
		when WBS_OPC =>
			reg_write.data <= to_data_type(pc_old_s);
		when others => 							--WBS_ALU
			reg_write.data <= aluresult_s;
		end case;
	end process;

	reg : process 
	begin
		wait until rising_edge(clk);
		if res_n = '0' then
			op_s <= WB_NOP;
		elsif flush = '1' then
			op_s <= WB_NOP;
		elsif stall = '0' then
			op_s <= op;
			aluresult_s <= aluresult;
			memresult_s <= memresult;
			pc_old_s <= pc_old_in;
		else
			-- keep old register values
		end if;
	end process reg;
	
	
end architecture;
