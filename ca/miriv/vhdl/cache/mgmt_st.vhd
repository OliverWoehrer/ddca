library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.mem_pkg.all;
use work.cache_pkg.all;

entity mgmt_st is
	generic (
		SETS_LD  : natural := SETS_LD;
		WAYS_LD  : natural := WAYS_LD
	);
	port (
		clk   : in std_logic;
		res_n : in std_logic;

		index : in c_index_type;
		wr    : in std_logic;
		rd    : in std_logic;

		valid_in    : in std_logic;
		dirty_in    : in std_logic;
		tag_in      : in c_tag_type;
		way_out     : out c_way_type := (others => '0');
		valid_out   : out std_logic := '0';
		dirty_out   : out std_logic := '0';
		tag_out     : out c_tag_type := (others => '0');
		hit_out     : out std_logic := '0'
	);
end entity;

architecture impl of mgmt_st is
	signal temp :std_logic := '0';
begin
	mgmt_st_1w_inst : entity work.mgmt_st_1w
	generic map(
		SETS_LD =>SETS_LD
	)
	port map(
		clk     =>clk,
		res_n   =>res_n,

		index   => index,
		we      => wr,
		we_repl => '0',	

		mgmt_info_in.valid => valid_in,
		mgmt_info_in.dirty => dirty_in,
		mgmt_info_in.replace => '0',
		mgmt_info_in.tag => tag_in,
		mgmt_info_out.valid => valid_out,
		mgmt_info_out.dirty => dirty_out,
		mgmt_info_out.replace => temp,
		mgmt_info_out.tag => tag_out
	);
	
	hit_out <= '1' when tag_in = tag_out else '0';
end architecture;
