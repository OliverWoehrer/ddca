/*
[alu.vhd] ARITHMETIC LOGICAL UNIT:
This unit is the ALU of the RISC-V processor. It handles the most basic ALU instructions
and is implemented as a MUX, selected via the op-signal. It operates asynchronously.
*/
----------------------------------------------------------------------------------
--                                LIBRARIES                                     --
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mem_pkg.all;
use work.core_pkg.all;
use work.op_pkg.all;


--------------------------------------------------------------------------------
--                                 ENTITY                                     --
--------------------------------------------------------------------------------
entity alu is
	port (
		op   : in  alu_op_type;
		A, B : in  data_type;
		R    : out data_type := (others => '0');
		Z    : out std_logic := '0'
	);
end alu;

--------------------------------------------------------------------------------
--                               ARCHITECTURE                                 --
--------------------------------------------------------------------------------
architecture rtl of alu is
begin
	--Arithmetic Logic:
	alu_logic: process(op,A,B)
	begin -- ATTENTION: zero flag is only valid on SUB and SLT(U)
		case op is
			when ALU_NOP =>
				R <= B;
				Z <= '-';
			when ALU_SLT =>
				if (signed(A) < signed(B)) then
					R <= std_logic_vector(to_unsigned(1,DATA_WIDTH));
					Z <= '0';
				else
					R <= std_logic_vector(to_unsigned(0,DATA_WIDTH));
					Z <= '1';
				end if;
			when ALU_SLTU =>
				if (unsigned(A) < unsigned(B)) then
					R <= std_logic_vector(to_signed(1,DATA_WIDTH));
					Z <= '0';
				else
					R <= std_logic_vector(to_signed(0,DATA_WIDTH));
					Z <= '1';
				end if;
			when ALU_SLL =>
				R <= std_logic_vector(shift_left(unsigned(A),to_integer(unsigned(B(4 downto 0)))));
				Z <= '-';
			when ALU_SRL =>
				R <= std_logic_vector(shift_right(unsigned(A),to_integer(unsigned(B(4 downto 0)))));
				Z <= '-';
			when ALU_SRA =>
				R <= std_logic_vector(shift_right(signed(A),to_integer(unsigned(B(4 downto 0)))));
				Z <= '-';
			when ALU_ADD =>
				R <= std_logic_vector(signed(A) + signed(B));
				Z <= '-';
			when ALU_SUB =>
				R <= std_logic_vector(signed(A) - signed(B));
				if (A = B) then
					Z <= '1';
				else
					Z <= '0';
				end if;
			when ALU_AND =>
				R <= A and B;
				Z <= '-';
			when ALU_OR =>
				R <= A or B;
				Z <= '-';
			when ALU_XOR =>
				R <= A xor B;
				Z <= '-';
			when others =>
				R <= B;
				Z <= '-';
		end case;
	end process;

end architecture;
