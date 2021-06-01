/*
[exec.vhd] EXECUTE INSTRUCTION:
This unit instantiates the ALU and applies its input signals according to the
three ALU control signals ALUsrc1, ALUsrc2 and ALUsrc3.
*/
----------------------------------------------------------------------------------
--                                LIBRARIES                                     --
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.op_pkg.all;
use work.mem_pkg.all;

--------------------------------------------------------------------------------
--                                 ENTITY                                     --
--------------------------------------------------------------------------------
entity exec is
	port (
		clk           : in  std_logic;
		res_n         : in  std_logic;
		stall         : in  std_logic;
		flush         : in  std_logic;

		-- from DEC
		op            : in  exec_op_type; -- aluop, alusrc1, alusrc2, alusrc3, rs1, rs2, readdata1, readdata2, imm
		pc_in         : in  pc_type;

		-- to MEM
		pc_old_out    : out pc_type := ZERO_PC;		-- vec, imem address
		pc_new_out    : out pc_type := ZERO_PC;		-- vec, imem address
		aluresult     : out data_type := ZERO_DATA;	-- vec, memory data (32 Bit)
		wrdata        : out data_type := ZERO_DATA;	-- vec, memory data (32 Bit)
		zero          : out std_logic := '0';

		memop_in      : in  mem_op_type;
		memop_out     : out mem_op_type := MEM_NOP;
		wbop_in       : in  wb_op_type;
		wbop_out      : out wb_op_type := WB_NOP;

		-- FWD
		exec_op       : out exec_op_type := EXEC_NOP;
		reg_write_mem : in  reg_write_type;
		reg_write_wr  : in  reg_write_type
	);
end entity;

--------------------------------------------------------------------------------
--                               ARCHITECTURE                                 --
--------------------------------------------------------------------------------
architecture rtl of exec is
	--Internal Register Signals:
	signal op_s : exec_op_type := EXEC_NOP;
	signal pc_s : pc_type := ZERO_PC;
	signal memop_s : mem_op_type := MEM_NOP;
	signal wbop_s : wb_op_type := WB_NOP;

	--ALU input signals:
	signal aluop_s : alu_op_type := ALU_NOP;
	signal alu_A_s : data_type := ZERO_DATA;
	signal alu_B_s : data_type := ZERO_DATA;
	
begin

	--Permanent Hardwires:
	pc_old_out <= pc_s;
	exec_op <= EXEC_NOP; -- can be ignored for now
	memop_out <= memop_s;
	wbop_out <= wbop_s;
	wrdata <= op_s.readdata2; -- forward signal to Memory Stage:
	
	--Instantiate ALU entity
	alu_inst : entity work.alu(rtl)
		port map(
			op	=> op_s.aluop,
			A	=>	alu_A_s,
			B	=> alu_B_s,
			R	=> aluresult,
			Z	=> zero
		);
	
	
	--Register for Inputs:
	reg_sync: process(clk)
	begin
		if rising_edge(clk) then
			if (res_n = '0') then
				op_s <= EXEC_NOP;
				pc_s <= ZERO_PC;
				memop_s <= MEM_NOP;
				wbop_s <= WB_NOP;				
			elsif (stall = '0') then
				op_s <= op;
				pc_s <= pc_in;
				memop_s <= memop_in;
				wbop_s <= wbop_in;
			elsif (flush = '1') then
				op_s <= EXEC_NOP;
				pc_s <= ZERO_PC;
				memop_s <= MEM_NOP;
				wbop_s <= WB_NOP;
			else
				-- keep old register values
			end if;
		end if;
	end process;
	
	
	--Async Exec Logic:
	exec_logic: process(all)
		variable selector : std_logic_vector(2 downto 0) := "000";
	begin
		selector := op_s.alusrc1 & op_s.alusrc2 & op_s.alusrc3;
		case (selector) is
			when "101" => -- special case: JAL
				alu_A_s <= to_data_type(pc_s);
				alu_B_s <= std_logic_vector(to_unsigned(4,DATA_WIDTH));
				pc_new_out <= to_pc_type(std_logic_vector(signed(pc_s) + signed(op_s.imm)));
			when "011" => -- special case: JALR
				alu_A_s <= to_data_type(pc_s);
				alu_B_s <= std_logic_vector(to_unsigned(4,DATA_WIDTH));
				pc_new_out <= to_pc_type(std_logic_vector(unsigned(op_s.imm) + unsigned(op_s.readdata1)));
			when others =>
				--ALU input signals:
				case op.alusrc1 is -- select input A
					when '1' => alu_A_s <= to_data_type(pc_s); --TODO: changed to pc_old_out, needs to be tested
					when others => alu_A_s <= op_s.readdata1;
				end case;
				case op.alusrc2 is -- select input B
					when '1' => alu_B_s <= op_s.imm;
					when others => alu_B_s <= op_s.readdata2;
				end case;
				
				--Addition for PC:
				case op.alusrc3 is
					when '1' => pc_new_out <= to_pc_type(std_logic_vector(signed(pc_s) + shift_left(signed(op_s.imm),1)));
					when others => pc_new_out <= pc_s;
				end case;
		end case;
	end process;
	
	
	/*
	--Synchonous Through Put:
	sync_through_put: process(clk)
	begin
		if rising_edge(clk) then
			if (res_n = '0') then
				pc_s <= ZERO_PC;
				memop_out <= MEM_NOP;
				wbop_out <= WB_NOP;
				exec_op <= EXEC_NOP; -- irrelevant for now!
			elsif (stall = '0') then -- only update registers when not stalled
				pc_s <= pc_in;
				memop_out <= memop_in;
				wbop_out <= wbop_in;
				exec_op <= op; -- irrelevant for now!
			end if;
		end if;
	end process;
	

	--Synchronous Exec Logic:
	sync_exec_logic: process(clk)
		variable selector : std_logic_vector(2 downto 0) := "000";
	begin
		if rising_edge(clk) then
			if (res_n = '0') then
				pc_new_out <= ZERO_PC;
				wrdata <= ZERO_DATA;
			elsif (stall = '0') then -- only update registers when not stalled
				selector := op.alusrc1 & op.alusrc2 & op.alusrc3;
				case (selector) is
					when "101" => -- special case: JAL
						alu_A_s <= to_data_type(pc_s);
						alu_B_s <= std_logic_vector(to_unsigned(4,DATA_WIDTH));
						pc_new_out <= to_pc_type(std_logic_vector(signed(pc_in) + signed(op.imm)));
					when "011" => -- special case: JALR
						alu_A_s <= to_data_type(pc_s);
						alu_B_s <= std_logic_vector(to_unsigned(4,DATA_WIDTH));
						pc_new_out <= to_pc_type(std_logic_vector(unsigned(op.imm) + unsigned(op.readdata1)));
					when others =>
						--ALU input signals:
						case op.alusrc1 is -- select input A
							when '1' => alu_A_s <= to_data_type(pc_s); --TODO: changed to pc_old_out, needs to be tested
							when others => alu_A_s <= op.readdata1;
						end case;
						case op.alusrc2 is -- select input B
							when '1' => alu_B_s <= op.imm;
							when others => alu_B_s <= op.readdata2;
						end case;
						
						--Addition for PC:
						case op.alusrc3 is
							when '1' => pc_new_out <= to_pc_type(std_logic_vector(signed(pc_in) + shift_left(signed(op.imm),1)));
							when others => pc_new_out <= pc_in;
						end case;
				end case;
				
				--Forward Signals to Memory Stage:
				wrdata <= op.readdata2;
				aluop_s <= op.aluop;
				
			end if;
		end if;
	end process;
	*/


end architecture;
