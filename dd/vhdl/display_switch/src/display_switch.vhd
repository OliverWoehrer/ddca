library ieee;
use ieee.std_logic_1164.all;

use work.gfx_if_pkg.all;

entity display_switch is
	port (
		control : in std_logic;
		
		--graphics interface A in
		in_a_gfx_instr       : in std_logic_vector(7 downto 0);
		in_a_gfx_instr_wr    : in std_logic;
		in_a_gfx_instr_full  : out std_logic;
		in_a_gfx_data        : in std_logic_vector(15 downto 0);
		in_a_gfx_data_wr     : in std_logic;
		in_a_gfx_data_full   : out std_logic;
		in_a_gfx_frame_sync  : out std_logic;
		
		--graphics interface B in
		in_b_gfx_instr       : in std_logic_vector(7 downto 0);
		in_b_gfx_instr_wr    : in std_logic;
		in_b_gfx_instr_full  : out std_logic;
		in_b_gfx_data        : in std_logic_vector(15 downto 0);
		in_b_gfx_data_wr     : in std_logic;
		in_b_gfx_data_full   : out std_logic;
		in_b_gfx_frame_sync  : out std_logic;
		
		--graphics interface A out
		out_a_gfx_instr       : out std_logic_vector(7 downto 0);
		out_a_gfx_instr_wr    : out std_logic;
		out_a_gfx_instr_full  : in std_logic;
		out_a_gfx_data        : out std_logic_vector(15 downto 0);
		out_a_gfx_data_wr     : out std_logic;
		out_a_gfx_data_full   : in std_logic;
		out_a_gfx_frame_sync  : in std_logic;
		
		--graphics interface B out
		out_b_gfx_instr       : out std_logic_vector(7 downto 0);
		out_b_gfx_instr_wr    : out std_logic;
		out_b_gfx_instr_full  : in std_logic;
		out_b_gfx_data        : out std_logic_vector(15 downto 0);
		out_b_gfx_data_wr     : out std_logic;
		out_b_gfx_data_full   : in std_logic;
		out_b_gfx_frame_sync  : in std_logic
	);
end entity;

architecture arch of display_switch is
begin
	process (all)
	begin
		if (control = '0') then
			out_a_gfx_instr       <= in_a_gfx_instr;
			out_a_gfx_instr_wr    <= in_a_gfx_instr_wr;
			in_a_gfx_instr_full   <= out_a_gfx_instr_full;
			out_a_gfx_data        <= in_a_gfx_data;
			out_a_gfx_data_wr     <= in_a_gfx_data_wr;
			in_a_gfx_data_full    <= out_a_gfx_data_full;
			in_a_gfx_frame_sync   <= out_a_gfx_frame_sync;
			
			out_b_gfx_instr       <= in_b_gfx_instr;
			out_b_gfx_instr_wr    <= in_b_gfx_instr_wr;
			in_b_gfx_instr_full   <= out_b_gfx_instr_full;
			out_b_gfx_data        <= in_b_gfx_data;
			out_b_gfx_data_wr     <= in_b_gfx_data_wr;
			in_b_gfx_data_full    <= out_b_gfx_data_full;
			in_b_gfx_frame_sync   <= out_b_gfx_frame_sync;
		else
			out_a_gfx_instr       <= in_b_gfx_instr;
			out_a_gfx_instr_wr    <= in_b_gfx_instr_wr;
			in_b_gfx_instr_full   <= out_a_gfx_instr_full;
			out_a_gfx_data        <= in_b_gfx_data;
			out_a_gfx_data_wr     <= in_b_gfx_data_wr;
			in_b_gfx_data_full    <= out_a_gfx_data_full;
			in_b_gfx_frame_sync   <= out_a_gfx_frame_sync;
			
			out_b_gfx_instr       <= in_a_gfx_instr;
			out_b_gfx_instr_wr    <= in_a_gfx_instr_wr;
			in_a_gfx_instr_full   <= out_b_gfx_instr_full;
			out_b_gfx_data        <= in_a_gfx_data;
			out_b_gfx_data_wr     <= in_a_gfx_data_wr;
			in_a_gfx_data_full    <= out_b_gfx_data_full;
			in_a_gfx_frame_sync   <= out_b_gfx_frame_sync;
		end if;
	end process;
end architecture;
