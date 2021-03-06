/*
[decode.vhd] DECODE STAGE
The decode Unit is for converting the given instructions from  the fetch into operations which hav to be done.
alusrc1: rs1 or PC
alusrc2: rs2 or imm
alusrc3: not adding or imm adding
speical event OPC_JALR pc = imm + rs1 then alusrc1 = 0 alusrc2 = 1 alusrc3 = 1
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
entity decode is
	port (
		clk        : in  std_logic;
		res_n      : in  std_logic;
		stall      : in  std_logic;
		flush      : in  std_logic;

		-- from fetch
		pc_in      : in  pc_type;					--vec
		instr      : in  instr_type;				--vec

		-- from writeback
		reg_write  : in reg_write_type;									--	write, reg, data  für regfile

		-- towards next stages
		pc_out     : out pc_type := ZERO_PC;					-- vec 
		exec_op    : out exec_op_type := EXEC_NOP;					-- aluop, alusrc1[rs1 or PC], alusrc2[rs2 or imm], alusrc3, rs1, rs2, readdata1, readdata2, imm
		mem_op     : out mem_op_type := MEM_NOP;						-- branch, mem(memread, memwrite, memtype)
		wb_op      : out wb_op_type := WB_NOP;							-- rd, write, src

		-- exceptions
		exc_dec    : out std_logic := '0'
	);
end entity;

--------------------------------------------------------------------------------
--                               ARCHITECTURE                                 --
--------------------------------------------------------------------------------
architecture rtl of decode is
	--Constants for Operatio Codes (OPcode):
	constant OPC_LUI 		: std_logic_vector(6 downto 0) := "0110111";
	constant OPC_AUIPIC	: std_logic_vector(6 downto 0) := "0010111";
	constant OPC_JAL 		: std_logic_vector(6 downto 0) := "1101111";
	constant OPC_JALR 	: std_logic_vector(6 downto 0) := "1100111";
	constant OPC_BRANCH 	: std_logic_vector(6 downto 0) := "1100011";
	constant OPC_LOAD 	: std_logic_vector(6 downto 0) := "0000011";
	constant OPC_STORE 	: std_logic_vector(6 downto 0) := "0100011";
	constant OPC_OP_IMM 	: std_logic_vector(6 downto 0) := "0010011";
	constant OPC_OP 		: std_logic_vector(6 downto 0) := "0110011";
	constant OPC_NOP		: std_logic_vector(6 downto 0) := "0001111";

	--Internal Registered Signals:
	signal instr_s 		: instr_type := NOP_INST;
	signal pc_s				: pc_type := ZERO_PC;
	
	--Internal Temporary Signals:
	signal opcode			: std_logic_vector(6 downto 0) := (others => '0');
	signal funct7 			: std_logic_vector(6 downto 0) := (others => '0');
	signal funct3 			: std_logic_vector(2 downto 0) := (others => '0');
	
	function shamt_from_inst_format_I(inst : std_logic_vector) return std_logic_vector is
		variable imm : std_logic_vector(31 downto 0);
	begin
		imm(31 downto 5) := (others => '0');
		imm(4 downto 0) := inst(24 downto 20); --shamt
		return imm;
	end function;
	
	function imm_from_inst_format_I(inst : std_logic_vector) return std_logic_vector is
		variable imm : std_logic_vector(31 downto 0);
	begin
		imm(31 downto 12) := (others => inst(31));
		imm(11 downto 0) := inst(31 downto 20);
		return imm;
	end function;
	
	function imm_from_inst_format_S(inst : std_logic_vector) return std_logic_vector is
		variable imm : std_logic_vector(31 downto 0);
	begin
		imm(31 downto 11) := (others => inst(31));
		imm(10 downto 5) := inst(30 downto 25);
		imm(4 downto 0) := inst(11 downto 7);
		return imm;
	end function;
	
	function imm_from_inst_format_B(inst : std_logic_vector) return std_logic_vector is
		variable imm : std_logic_vector(31 downto 0);
	begin
		imm(31 downto 12) := (others => inst(31));
		imm(11) := inst(7);
		imm(10 downto 5) := inst(30 downto 25);
		imm(4 downto 1) := inst(11 downto 8);
		imm(0) := '0';
		return imm;
	end function;
	
	function imm_from_inst_format_U(inst : std_logic_vector) return std_logic_vector is
		variable imm : std_logic_vector(31 downto 0);
	begin
		imm(31 downto 12) := inst(31 downto 12);
		imm(11 downto 0) := (others => '0');
		return imm;
	end function;
	
	function imm_from_inst_format_J(inst : std_logic_vector) return std_logic_vector is
		variable imm : std_logic_vector(31 downto 0);
	begin
		imm(31 downto 20) := (others => inst(31));
		imm(19 downto 12) := inst(19 downto 12);
		imm(11) := inst(20);
		imm(10 downto 1) := inst(30 downto 21);
		imm(0) := '0';
		return imm;
	end function;
	
	function alu_op_for_BRANCH(funct3 : std_logic_vector) return alu_op_type is
	begin
		case funct3 is
		when "000" => return ALU_SUB;
		when "001" => return ALU_SUB;
		when "100" => return ALU_SLT;
		when "101" => return ALU_SLT;
		when "110" => return ALU_SLTU;
		when "111" => return ALU_SLTU;
		when others => 
		end case;
		return ALU_NOP;
	end function;
	
	function alu_op_for_OP_IMM(funct3 : std_logic_vector; sra_bool : std_logic) return alu_op_type is
	begin
		case funct3 is
		when "000" => return ALU_ADD;
		when "010" => return ALU_SLT;
		when "011" => return ALU_SLTU;
		when "100" => return ALU_XOR;
		when "110" => return ALU_OR;
		when "111" => return ALU_AND;
		when "001" => return ALU_SLL;
		when "101" =>
			if sra_bool = '0' then
				return ALU_SRL;
			else
				return ALU_SRA;
			end if;
		when others => 
		end case;
		return ALU_NOP;
	end function;
	
	function alu_op_for_OP(funct3 : std_logic_vector; funct7 : std_logic_vector) return alu_op_type is
	begin
		case funct3 & funct7 is
		when "000" & "0000000" => return ALU_ADD;
		when "000" & "0100000" => return ALU_SUB;
		when "001" & "0000000" => return ALU_SLL;
		when "010" & "0000000" => return ALU_SLT;
		when "011" & "0000000" => return ALU_SLTU;
		when "100" & "0000000" => return ALU_XOR;
		when "101" & "0000000" => return ALU_SRL;
		when "101" & "0100000" => return ALU_SRA;
		when "110" & "0000000" => return ALU_OR;
		when "111" & "0000000" => return ALU_AND;
		when others => 
		end case;
		return ALU_NOP;
	end function;

	function memtype_from_funct3(funct3 : std_logic_vector) return memtype_type is
	begin
		case funct3 is
		when "000" => return MEM_B;
		when "001" => return MEM_H;
		when "100" => return MEM_BU;
		when "101" => return MEM_HU;
		when others => 
		end case;
		return MEM_W;
	end function;
	
begin
	--Permanent Hardwires:
	instr_s <= instr;
	opcode	<= instr(6 downto 0);
	funct7 	<= instr(31 downto 25);
	funct3 	<= instr(14 downto 12);
	exec_op.rs1 <= instr(19 downto 15);
	exec_op.rs2 <= instr(24 downto 20);
	wb_op.rd <= instr(11 downto 7);
	pc_out <= pc_s;

	
	--Instance of Register File Entity:
	regfile_inst : entity work.regfile
	port map (
		clk			=> clk,              
		res_n       => res_n,
		stall  		=> stall,          
		rdaddr1		=> instr(19 downto 15),
		rdaddr2 		=> instr(24 downto 20),
		rddata1		=> exec_op.readdata1,
		rddata2 		=> exec_op.readdata2,
		wraddr		=> reg_write.reg,         
		wrdata     	=> reg_write.data,      
		regwrite    => reg_write.write     
	);
	

	--Register internal Signals:
	reg_sync : process 
	begin
		wait until rising_edge(clk);
		if res_n = '0' then
			pc_s <= ZERO_PC;
		elsif flush = '1' then
		elsif stall = '0' then
			pc_s <= pc_in;
		else
			-- keep old register values
		end if;
	end process;
	
	
	--Async Decode Logic:
	decode_logic : process (all)
	begin
		exc_dec <= '0';
		exec_op.aluop <= ALU_NOP;
		exec_op.alusrc1 <= '0';
		exec_op.alusrc2 <= '0';
		exec_op.alusrc3 <= '0';
		exec_op.imm <= ZERO_DATA;
		wb_op.write <= '0';
		wb_op.src <= WBS_ALU;
		mem_op <= MEM_NOP;
		case opcode is
			when OPC_LUI =>
				--format U
				exec_op.imm <= imm_from_inst_format_U(instr);
				exec_op.aluop <= ALU_NOP; -- required !! ALU return B
				exec_op.alusrc2 <= '1';
				wb_op.write <= '1';
				wb_op.src <= WBS_ALU;
				
			when OPC_AUIPIC =>
				--format U
				exec_op.imm <= imm_from_inst_format_U(instr);
				exec_op.aluop <= ALU_ADD;
				exec_op.alusrc1 <= '1';
				exec_op.alusrc2 <= '1';
				wb_op.write <= '1';
				wb_op.src <= WBS_ALU;
				
			when OPC_JAL =>
				--format J
				exec_op.imm <= imm_from_inst_format_J(instr);
				exec_op.aluop <= ALU_ADD;
				mem_op.branch <= BR_BR;
				exec_op.alusrc1 <= '1';
				exec_op.alusrc3 <= '1';
				wb_op.write <= '1';
				wb_op.src <= WBS_OPC;
				
			when OPC_JALR =>
				--format I
				exec_op.imm <= imm_from_inst_format_I(instr);
				exec_op.aluop <= ALU_ADD; --funct3 = "000"
				mem_op.branch <= BR_BR;
				exec_op.alusrc2 <= '1';
				exec_op.alusrc3 <= '1';
				wb_op.write <= '1';
				wb_op.src <= WBS_ALU;
				
			when OPC_BRANCH =>
				--format B
				exec_op.imm <= imm_from_inst_format_B(instr);
				exec_op.aluop <= alu_op_for_BRANCH(funct3);
				if funct3(0) = '0' then
					mem_op.branch <= BR_CND;
				else
					mem_op.branch <= BR_CNDI;
				end if;
				exec_op.alusrc3 <= '1';
				wb_op.write <= '0';
				wb_op.src <= WBS_ALU;
				
			when OPC_LOAD =>
				--format I
				exec_op.imm <= imm_from_inst_format_I(instr);
				exec_op.aluop <= ALU_ADD;
				exec_op.alusrc2 <= '1';
				mem_op.mem.memread <= '1';
				mem_op.mem.memtype <= memtype_from_funct3(funct3);
				wb_op.write <= '1';
				wb_op.src <= WBS_MEM;
			
			when OPC_STORE =>
				--format S
				exec_op.imm <= imm_from_inst_format_S(instr);
				exec_op.aluop <= ALU_ADD;
				exec_op.alusrc2 <= '1';
				mem_op.mem.memwrite <= '1';
				mem_op.mem.memtype <= memtype_from_funct3(funct3);
				wb_op.write <= '0';
				wb_op.src <= WBS_MEM;
				
			when OPC_OP_IMM =>
				--format I
				if funct3 = "001" or funct3 = "101" then
					exec_op.imm <= shamt_from_inst_format_I(instr);
				else
					exec_op.imm <= imm_from_inst_format_I(instr);
				end if;
				exec_op.aluop <= alu_op_for_OP_IMM(funct3,instr(30));
				exec_op.alusrc2 <= '1';
				wb_op.write <= '1';
				wb_op.src <= WBS_ALU;
				
			when OPC_OP =>
				--format R
				exec_op.imm <= (others => '0');
				exec_op.aluop <= alu_op_for_OP(funct3,funct7);
				wb_op.write <= '1';
				wb_op.src <= WBS_ALU;
				
			when OPC_NOP =>
				--format I
				exec_op.imm <= imm_from_inst_format_I(instr);
				wb_op.write <= '0';
				wb_op.src <= WBS_ALU;
				
			when others =>
				exc_dec <= '1';
				exec_op.aluop <= ALU_NOP;
				exec_op.alusrc1 <= '0';
				exec_op.alusrc2 <= '0';
				exec_op.alusrc3 <= '0';
				exec_op.imm <= (others => '0');
				wb_op.write <= '0';
				wb_op.src <= WBS_ALU;
				mem_op <= MEM_NOP;
			
		end case;
	end process;
	
	
	
	
end architecture;
