library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use ieee.std_logic_textio.all;


entity sram is
	generic (
		OUTPUT_DIR   : string  := "./"
	);
	port (
		-- SRAM interface
		dq     : inout std_logic_vector(15 downto 0);
		addr   : in	std_logic_vector(19 downto 0);
		lb_n   : in	std_logic;
		ub_n   : in	std_logic;
		ce_n   : in	std_logic;
		oe_n   : in	std_logic;
		we_n   : in	std_logic;
		
		-- on rising_edge: dump frame to file
		write_file : in std_logic;
		base_address : natural := 0;
		width        : natural := 400;
		height       : natural := 240
	);
end entity;


architecture arch of sram is
	--SRAM storage
	type SRAM is array(1048575 downto 0) of std_logic_vector(15 downto 0);
	signal storage : SRAM := (others => x"0000");
	
	--buffer (for bus driver)
	signal data : std_logic_vector(15 downto 0) := (others => '0');
begin

	--tri-state for bus driver 
	dq <= data when (we_n = '1' and ce_n = '0' and oe_n = '0' and not(lb_n = '1' and ub_n = '1')) else (others => 'Z');
	
	--I/O processes
	read_data : process(all)
	begin
		if (we_n = '1' and ce_n = '0' and oe_n = '0') then
			data <= storage(to_integer(unsigned(addr)));
		end if;
	end process;

	write_data : process(all)
	begin
		if (we_n = '0' and ce_n ='0' and oe_n = '1' and lb_n = '0' and ub_n = '0') then
			storage(to_integer(unsigned(addr))) <= dq;
		end if;
	end process;
	
	
	--file dump of SRAM storage
	file_dump : process(write_file)
		file outfile : text;
		variable l: line;
		variable status: FILE_OPEN_STATUS;
		variable fileCounter : natural := 0;
		
		variable colorValue : std_logic_vector(15 downto 0);
		variable redValue : unsigned(15 downto 0);
		variable greenValue : unsigned(15 downto 0);
		variable blueValue : unsigned(15 downto 0);
	begin
		if rising_edge(write_file) then
			file_open(status,outfile, OUTPUT_DIR&"sram_dump_"&NATURAL'image(fileCounter)&".ppm", write_mode);
			write(l, string'("P3"));
			writeline(outfile,l);
			write(l, string'("400 240"));
			writeline(outfile,l);
			write(l, string'("31"));
			writeline(outfile,l);
			for y in 0 to (height-1) loop
				for x in 0 to (width-1) loop
					--get color values of byte
					colorValue := storage(base_address + y*width + x);
					
					redValue := shift_right(unsigned(colorValue and "0111110000000000"), 10);
					greenValue := shift_right(unsigned(colorValue and "0000001111100000"), 5);
					blueValue := unsigned(colorValue and "0000000000011111");
					
					--report "X := "&natural'image(x)&" Y := "&natural'image(y)&" Addr := "&integer'image(to_integer(unsigned(addr)));
					--report "R:= "&integer'image(to_integer(redValue))&" G:= "&integer'image(to_integer(greenValue))&" B:= "&integer'image(to_integer(blueValue));
					
					--write colors to dump file
					write(l, string'(integer'image(to_integer(redValue))&" ") );
					write(l, string'(integer'image(to_integer(greenValue))&" ") );
					write(l, string'(integer'image(to_integer(blueValue))&" ") );
				end loop;
				writeline(outfile,l);
			end loop;
			file_close(outfile);
			fileCounter := fileCounter + 1;
		end if;
	end process;
	
end architecture;
