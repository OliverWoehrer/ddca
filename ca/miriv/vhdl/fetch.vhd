/*
[fetch.vhd] FETCH FROM INSTRUCTION MEMORY:
This unit either fetches instruction words from the instruction memory or inserts a
NOP instruction based on the input signal "flush".
Simultaneously the program counter is set or incremented based on the "pcsrc" signal.
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
entity fetch is
	port (
		clk        : in  std_logic;
		res_n      : in  std_logic;
		stall      : in  std_logic;
		flush      : in  std_logic;

		-- to control
		mem_busy   : out std_logic := '0';

		pcsrc      : in  std_logic;
		pc_in      : in  pc_type;
		pc_out     : out pc_type := ZERO_PC;
		instr      : out instr_type := NOP_INST;

		-- memory controller interface
		mem_out   : out mem_out_type := MEM_OUT_NOP;
		mem_in    : in  mem_in_type
	);
end entity;

--------------------------------------------------------------------------------
--                               ARCHITECTURE                                 --
--------------------------------------------------------------------------------
architecture rtl of fetch is
	--Program Counter:
	signal pc_s, pc_new : pc_type := ZERO_PC;
	
	--Instruction Logic:
	signal temp_instr : instr_type := NOP_INST;
	signal reset_flag : std_logic := '0';
	
begin
	--Permanent Hardwires:
	pc_out <= pc_s;
	mem_busy <= mem_in.busy; -- memory signals through-put; TODO: maybe needs to be synced and checked for stall
	
	mem_out.address <= std_logic_vector(pc_new(15 downto 2)); -- PC is address of next instruction
	mem_out.wr <= '0'; -- no memory writing in this stage
	mem_out.byteena <= "1111"; -- always read a hole word (32 Bit)
	mem_out.wrdata <= (others => '0'); -- constant zero
	
	--Register for Program Counter:
	reg_sync: process(clk)
	begin
		if rising_edge(clk) then
			if (res_n = '0') then
				pc_s <= ZERO_PC;
			elsif (stall = '0') then
				pc_s <= pc_new;
			elsif (flush = '1') then
				pc_s <= ZERO_PC;
			else
				-- keep old register values
			end if;
		end if;
	end process;
	
	
	--Async PC Logic:
	pc_logic: process(all)
	begin
		if res_n = '0' then
			pc_new <= ZERO_PC;
		elsif (reset_flag = '1') then
			pc_new <= ZERO_PC;
		else
			case pcsrc is
				when '1' => pc_new <= pc_in;
				when others => pc_new <= std_logic_vector(unsigned(pc_s) + to_unsigned(4,PC_WIDTH));
			end case;
		end if;
	end process;
	
	
	--Register for Instruction Logic:
	instr_logic_sync: process(clk)
	begin
		if rising_edge(clk) then
			if (res_n = '0') then -- reset PC to zero
				temp_instr <= NOP_INST;
				reset_flag <= '1';
			elsif (stall = '0') then -- only update when not stalled
				if (flush = '1') or (reset_flag = '1') then -- determine next instruction
					mem_out.rd <= '0';
					temp_instr <= NOP_INST;
				else
					mem_out.rd <= '1';
					temp_instr(31 downto 24) <= mem_in.rddata(7 downto 0);		--b0, most significant byte
					temp_instr(23 downto 16) <= mem_in.rddata(15 downto 8);		--b1
					temp_instr(15 downto 8)  <= mem_in.rddata(23 downto 16);	--b2
					temp_instr(7 downto 0)   <= mem_in.rddata(31 downto 24);	--b3, least significant byte
				end if;
				if (reset_flag = '1') then
						reset_flag <= '0'; -- reset reset_flag
				end if;
			end if;
		end if;
	end process;
	
	--Asynchronous Instruction Logic:
	instr_logic_async: process(all)
	begin
		if (res_n = '0') then -- reset PC to zero
			instr <= NOP_INST;
		elsif (stall = '0') then -- only update when not stalled
			if (flush = '1') or (reset_flag = '1') then -- determine next instruction
				instr <= NOP_INST;
			else
				instr(31 downto 24) <= mem_in.rddata(7 downto 0);		--b0, most significant byte
				instr(23 downto 16) <= mem_in.rddata(15 downto 8);		--b1
				instr(15 downto 8)  <= mem_in.rddata(23 downto 16);	--b2
				instr(7 downto 0)   <= mem_in.rddata(31 downto 24);	--b3, least significant byte
			end if;
		else
			instr <= temp_instr;
		end if;
	end process;
				

	
end architecture;
