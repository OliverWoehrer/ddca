/*
[fwd.vhd] FORWARD FROM MEM AND WB:
This unit instantiates the Memory Unit and applies its input signals according to the
memory operation codes. It also brnached and sets the program counter accordingly
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
entity fwd is
	port (
		-- from Mem
		reg_write_mem : in reg_write_type;

		-- from WB
		reg_write_wb  : in reg_write_type;

		-- from/to EXEC
		reg    : in  reg_adr_type;
		val    : out data_type := ZERO_DATA;
		do_fwd : out std_logic := '0'
	);
end entity;

--------------------------------------------------------------------------------
--                               ARCHITECTURE                                 --
--------------------------------------------------------------------------------
architecture rtl of fwd is
begin
	fwd_logic: process(all)
	begin
		--Check forward condition from MEM stage:
		if (reg_write_mem.write = '1') and (reg_write_mem.reg /= ZERO_REG) and (reg = reg_write_mem.reg) then
			val <= reg_write_mem.data;
			do_fwd <= '1';
		
		--Check forward condition from WB stage:
		-- Attention: fwd condition from MEM stage has to be false to resolve
		-- double hazards correctly! Therefore the order of if-statement and
		-- the elsif-statment is important.
		elsif (reg_write_wb.write = '1') and (reg_write_wb.reg /= ZERO_REG) and (reg = reg_write_wb.reg) then
			val <= reg_write_wb.data;
			do_fwd <= '1';
			
		--Default case (do not forward):
		else
			val <= ZERO_DATA;
			do_fwd <= '0';
		end if;
	end process;
	

end architecture;