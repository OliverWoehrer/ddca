library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pkg.all;
use work.op_pkg.all;

entity ctrl is
	port (
		clk         : in std_logic;
		res_n       : in std_logic;
		stall       : in std_logic; -- connected to memory_busy_s

		stall_fetch : out std_logic;
		stall_dec   : out std_logic;
		stall_exec  : out std_logic;
		stall_mem   : out std_logic;
		stall_wb    : out std_logic;

		flush_fetch : out std_logic;
		flush_dec   : out std_logic;
		flush_exec  : out std_logic;
		flush_mem   : out std_logic;
		flush_wb    : out std_logic;

		-- from FWD
		wb_op_exec  : in  wb_op_type;
		exec_op_dec : in  exec_op_type;

		pcsrc_in : in std_logic;
		pcsrc_out : out std_logic
	);
end entity;

architecture rtl of ctrl is
	--Internal stall signals:
	signal stall_fetch_s : std_logic := '0';
	signal stall_dec_s : std_logic := '0';
	signal stall_exec_s : std_logic := '0';
	signal stall_mem_s : std_logic := '0';
	signal stall_wb_s : std_logic := '0';
	
	--Control signal for flush:
	signal flush_pipeline_s : std_logic := '0';
begin
	--Permanent Hardwires for stall signal:
	stall_fetch <= stall_fetch_s;
	stall_dec <= stall_dec_s;
	stall_exec <= stall_exec_s;
	stall_mem <= stall_mem_s;
	stall_wb <= stall_wb_s;
	
	
	--Sync stall logic:
	stall_logic: process(all)
	begin
		if res_n = '0' then
			stall_fetch_s <= '0';
			stall_dec_s <= '0';
			stall_exec_s <= '0';
			stall_mem_s <= '0';
			stall_wb_s <= '0';
		elsif (stall = '0') then
			if (exec_op_dec.rs1 = wb_op_exec.rd or exec_op_dec.rs2 = wb_op_exec.rd) and wb_op_exec.write = '1' and wb_op_exec.rd /= ZERO_REG then
				stall_fetch_s <= '1';
				stall_dec_s <= '1';
				stall_exec_s <= '0';
				stall_mem_s <= '0'; 
				stall_wb_s <= '0'; -- dont stall wb stage
			else
				stall_fetch_s <= '0';
				stall_dec_s <= '0';
				stall_exec_s <= '0';
				stall_mem_s <= '0';
				stall_wb_s <= '0';	
			end if;
		else
			-- already stalled
			stall_fetch_s <= '1';
			stall_dec_s <= '1';
			stall_exec_s <= '1';
			stall_mem_s <= '1';
			stall_wb_s <= '1';
		end if;
	end process;
	
	flush_logic : process(all)
	begin
		if res_n = '0' then
			flush_fetch <= '0';
			flush_dec <= '0';
			flush_exec <= '0';
			flush_mem <= '0';
			flush_wb <= '0';
		elsif stall = '0' then
			pcsrc_out <= pcsrc_in;
			if (exec_op_dec.rs1 = wb_op_exec.rd or exec_op_dec.rs2 = wb_op_exec.rd) and wb_op_exec.write = '1' and wb_op_exec.rd /= ZERO_REG then
				flush_fetch <= '0';
				flush_dec <= '0';
				flush_exec <= '1';
				flush_mem <= '0';
				flush_wb <= '0';
			elsif pcsrc_in = '1' then
				flush_fetch <= '1';
				flush_dec <= '1';
				flush_exec <= '1';
				flush_mem <= '1';
				flush_wb <= '1';
			else
				flush_fetch <= '0';
				flush_dec <= '0';
				flush_exec <= '0';
				flush_mem <= '0';
				flush_wb <= '0';
			end if;
		else -- already stalled
			flush_fetch <= '0';
			flush_dec <= '0';
			flush_exec <= '0';
			flush_mem <= '0';
			flush_wb <= '0';
		end if;
	end process;
end architecture;
