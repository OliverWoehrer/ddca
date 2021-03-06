/*
REGISTER FILE [regfile.vhd]:
This unit is implementing the 32 working registers (each 32 Bit wide) of RISC-V.
It provides two reading ports in parallel and one writing port. To accomplish this
behaviour two seperate dual-port RAMs (reg1 and reg2) are used while the writing port
signals are hardwired togehter. This ensures the consistency of data.
While reading takes place asynchronously the write logic is synchronous to the clock.
*/
----------------------------------------------------------------------------------
--                                LIBRARIES                                     --
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mem_pkg.all;
use work.core_pkg.all;

--------------------------------------------------------------------------------
--                                 ENTITY                                     --
--------------------------------------------------------------------------------
entity regfile is
	port (
		clk              : in  std_logic;
		res_n            : in  std_logic;
		stall            : in  std_logic;
		rdaddr1, rdaddr2 : in  reg_adr_type;
		rddata1, rddata2 : out data_type := ZERO_DATA;
		wraddr           : in  reg_adr_type;
		wrdata           : in  data_type;
		regwrite         : in  std_logic
	);
end entity;

--------------------------------------------------------------------------------
--                               ARCHITECTURE                                 --
--------------------------------------------------------------------------------
architecture rtl of regfile is
	--Dual Port RAM delcarations:
	type registers_t is array (REG_COUNT-1 downto 0) of std_logic_vector(DATA_WIDTH-1 downto 0);

	--Register File Storage:
	constant REGFILE_RESET: registers_t := (others => (others => '0'));
	signal reg1, reg2: registers_t := REGFILE_RESET;	
	signal data1_s, data2_s : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
	
begin
	--Register Read Data:
	reg_sync : process(clk)
	begin
		if rising_edge(clk) then
			if (res_n = '0') then
				data1_s <= ZERO_DATA;
				data2_s <= ZERO_DATA;
			elsif (stall = '0') then
				data1_s <= reg1(to_integer(unsigned(rdaddr1)));
				data2_s <= reg2(to_integer(unsigned(rdaddr2)));
			else
				-- keep old registered values
			end if;
		end if;
	end process;
	
	
	--Async Read Logic:
	read_logic: process(all)
	begin
		if (stall = '0') then
			--Handle Read Interface 1:
			if (rdaddr1 = std_logic_vector(to_unsigned(0,REG_BITS))) then
				rddata1 <= (others => '0');
			elsif (rdaddr1 = wraddr) then
				rddata1 <= wrdata;
			else
				rddata1 <= reg1(to_integer(unsigned(rdaddr1)));
			end if;

			--Handle Read Interface 2:
			if (rdaddr2 = std_logic_vector(to_unsigned(0,REG_BITS))) then
				rddata2 <= (others => '0');
			elsif (rdaddr2 = wraddr) and (regwrite = '1') then
				rddata2 <= wrdata;
			else
				rddata2 <= reg2(to_integer(unsigned(rdaddr2)));
			end if;
		else
			rddata1 <= data1_s;
			rddata2 <= data2_s;
		end if;
	end process;

	
	--Sync Write Logic:
	write_logic: process(clk)
	begin
		if rising_edge(clk) then
			if (res_n = '0') then
				reg1 <= REGFILE_RESET;
				reg2 <= REGFILE_RESET;
			else
				if (stall = '0') and (wraddr /= std_logic_vector(to_unsigned(0,REG_BITS))) and (regwrite = '1') then -- only update register values when not stalled!
					reg1(to_integer(unsigned(wraddr))) <= wrdata;
					reg2(to_integer(unsigned(wraddr))) <= wrdata;
				end if;
			end if;
		end if;
	end process;
	
	
	
end architecture;
