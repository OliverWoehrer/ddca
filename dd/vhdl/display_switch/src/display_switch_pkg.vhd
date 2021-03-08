library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package display_switch_pkg is

	component display_switch is
		port (
			control : in std_logic;
			in_a_gfx_instr : in std_logic_vector(7 downto 0);
			in_a_gfx_instr_wr : in std_logic;
			in_a_gfx_instr_full : out std_logic;
			in_a_gfx_data : in std_logic_vector(15 downto 0);
			in_a_gfx_data_wr : in std_logic;
			in_a_gfx_data_full : out std_logic;
			in_a_gfx_frame_sync : out std_logic;
			in_b_gfx_instr : in std_logic_vector(7 downto 0);
			in_b_gfx_instr_wr : in std_logic;
			in_b_gfx_instr_full : out std_logic;
			in_b_gfx_data : in std_logic_vector(15 downto 0);
			in_b_gfx_data_wr : in std_logic;
			in_b_gfx_data_full : out std_logic;
			in_b_gfx_frame_sync : out std_logic;
			out_a_gfx_instr : out std_logic_vector(7 downto 0);
			out_a_gfx_instr_wr : out std_logic;
			out_a_gfx_instr_full : in std_logic;
			out_a_gfx_data : out std_logic_vector(15 downto 0);
			out_a_gfx_data_wr : out std_logic;
			out_a_gfx_data_full : in std_logic;
			out_a_gfx_frame_sync : in std_logic;
			out_b_gfx_instr : out std_logic_vector(7 downto 0);
			out_b_gfx_instr_wr : out std_logic;
			out_b_gfx_instr_full : in std_logic;
			out_b_gfx_data : out std_logic_vector(15 downto 0);
			out_b_gfx_data_wr : out std_logic;
			out_b_gfx_data_full : in std_logic;
			out_b_gfx_frame_sync : in std_logic
		);
	end component;
end package;

