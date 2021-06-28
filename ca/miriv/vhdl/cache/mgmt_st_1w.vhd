library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mem_pkg.all;
use work.cache_pkg.all;

entity mgmt_st_1w is
	generic (
		SETS_LD  : natural := SETS_LD
	);
	port (
		clk     : in std_logic;
		res_n   : in std_logic;

		index   : in c_index_type;
		we      : in std_logic;
		we_repl	: in std_logic;

		mgmt_info_in  : in c_mgmt_info;
		mgmt_info_out : out c_mgmt_info := C_MGMT_NOP
	);
end entity;

architecture impl of mgmt_st_1w is
	type info_array is array (SETS-1 downto 0) of c_mgmt_info;
	signal set_array : info_array := (others => C_MGMT_NOP);
begin
	mgmt_info_out <= set_array(to_integer(unsigned(index)));

	sync: process(all)
	begin
		if res_n = '0' then
			set_array <= (others => C_MGMT_NOP);
		elsif rising_edge(clk) then
			if we = '1' or we_repl = '1' then
				set_array(to_integer(unsigned(index))) <= mgmt_info_in;
			end if;
		end if;
	end process;
end architecture;
