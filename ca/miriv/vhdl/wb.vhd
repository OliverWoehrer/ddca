/*
[wb.vhd] WRITE BACK STAGE:
This unit writes back the result of the ALU operation (aluresult) or the data loaded
from the memory.
*/
----------------------------------------------------------------------------------
--                                LIBRARIES                                     --
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.op_pkg.all;

--------------------------------------------------------------------------------
--                                 ENTITY                                     --
--------------------------------------------------------------------------------
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

--------------------------------------------------------------------------------
--                               ARCHITECTURE                                 --
--------------------------------------------------------------------------------
architecture rtl of wb is
	--Internal Registered Signals:
	signal op_s				: wb_op_type := WB_NOP;
	signal aluresult_s	: data_type := ZERO_DATA;
	signal memresult_s	: data_type := ZERO_DATA;
	signal pc_old_s		: pc_type := ZERO_PC;
	
begin

	--Register internal Signals:
	reg_sync : process 
	begin
		wait until rising_edge(clk);
		if res_n = '0' then
			op_s <= WB_NOP;
			aluresult_s	<= ZERO_DATA;
			memresult_s	<= ZERO_DATA;
			pc_old_s		<= ZERO_PC;
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
	end process;
	
	
	--Async Write Back Logic:
	writeback_logic : process(all)
	begin
		reg_write.write <= op_s.write;
		reg_write.reg <= op_s.rd;
		case op_s.src is
		when WBS_MEM =>
			reg_write.data <= memresult_s;
		when WBS_OPC =>
			reg_write.data <= to_data_type(pc_old_s);
		when others => 							--WBS_ALU
			reg_write.data <= aluresult_s;
		end case;
	end process;
	
	
end architecture;
