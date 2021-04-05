
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.math_pkg.all;
use work.gfx_util_pkg.all;


entity gfx_circle is
	generic (
		WIDTH : integer;
		HEIGHT : integer
	);
	port (
		clk : in std_logic;
		res_n : in std_logic;
		
		--control signals
		start : in std_logic;
		stall : in std_logic;
		busy : out std_logic;
		
		--drawing parameters
		x_center : in std_logic_vector(log2c(WIDTH)-1 downto 0);
		y_center : in std_logic_vector(log2c(HEIGHT)-1 downto 0);
		radius   : in std_logic_vector(log2c(WIDTH)-1 downto 0);
		
		--pixel coordinates output
		pixel_valid : out std_logic;
		pixel_x : out std_logic_vector(log2c(WIDTH)-1 downto 0);
		pixel_y : out std_logic_vector(log2c(HEIGHT)-1 downto 0)
	);
end entity;

architecture arch of gfx_circle is
	signal section_counter : std_logic_vector(2 downto 0);
	signal balance : integer range -2**(log2c(WIDTH)+2) to 2**(log2c(WIDTH)+2)-1 := 0;
	signal xoff : integer range 0 to 2**(log2c(WIDTH)+1)-1 := 0;
	signal yoff : integer range 0 to 2**(log2c(WIDTH)+1)-1 := 0;
	signal running : std_logic;
begin

	sync : process(clk, res_n)
		variable var_balance : integer;
		variable var_setpixel_y : integer;
		variable var_setpixel_x : integer;
	begin
		if (res_n = '0') then
			pixel_x <= (others=>'0');
			pixel_y <= (others=>'0');
			pixel_valid <= '0';
			busy <= '0';
			running <= '0';
			section_counter <= (others=>'0');
		elsif (rising_edge(clk)) then
			pixel_valid <= '0';
			busy <= running;
			
			if (start = '1') then
				busy <= '1';
				running <= '1';
				section_counter <= (others=>'0');
				balance <= -to_integer(signed('0' & radius));
				xoff <= 0;
				yoff <= to_integer(unsigned(radius));
			end if;
			
			if(running = '1' and stall = '0') then
				if (unsigned(section_counter) = 0) then
					var_setpixel_y := to_integer(unsigned(y_center)) + yoff;
					var_setpixel_x := to_integer(unsigned(x_center)) + xoff;
					
				elsif (unsigned(section_counter) = 1) then
					var_setpixel_y := to_integer(unsigned(y_center)) + yoff;
					var_setpixel_x := to_integer(unsigned(x_center)) - xoff;
										
				elsif (unsigned(section_counter) = 2) then
					var_setpixel_y := to_integer(unsigned(y_center)) - yoff;
					var_setpixel_x := to_integer(unsigned(x_center)) + xoff;
					
				elsif (unsigned(section_counter) = 3) then
					var_setpixel_y := to_integer(unsigned(y_center)) - yoff;
					var_setpixel_x := to_integer(unsigned(x_center)) - xoff;
					
				elsif (unsigned(section_counter) = 4) then
					var_setpixel_y := to_integer(unsigned(y_center)) + xoff;
					var_setpixel_x := to_integer(unsigned(x_center)) + yoff;
					
				elsif (unsigned(section_counter) = 5) then
					var_setpixel_y := to_integer(unsigned(y_center)) + xoff;
					var_setpixel_x := to_integer(unsigned(x_center)) - yoff;
					
				elsif (unsigned(section_counter) = 6) then
					var_setpixel_y := to_integer(unsigned(y_center)) - xoff;
					var_setpixel_x := to_integer(unsigned(x_center)) + yoff;
					
				elsif (unsigned(section_counter) = 7) then
					var_setpixel_y := to_integer(unsigned(y_center)) - xoff;
					var_setpixel_x := to_integer(unsigned(x_center)) - yoff;
				end if;
				
				
				if (unsigned(section_counter) = 7) then
					section_counter <= (others=>'0');
			
					var_balance := balance;
					var_balance := var_balance + (2*xoff);
				
					if var_balance >= 0 then
						yoff <= yoff - 1;
						var_balance := var_balance - (2*(yoff-1));
					end if;
				
					xoff <= xoff + 1;
					balance <= var_balance;
				else
					section_counter <= std_logic_vector(unsigned(section_counter) + 1);
				end if;
			
				if (
					var_setpixel_x >= 0 and var_setpixel_x < WIDTH and 
					var_setpixel_y >= 0 and var_setpixel_y < HEIGHT
				) then
					pixel_y <= std_logic_vector(to_unsigned(var_setpixel_y, pixel_y'length));
					pixel_x <= std_logic_vector(to_unsigned(var_setpixel_x, pixel_x'length));
					pixel_valid <= '1';
				end if;

				
				if (xoff > yoff) then
					running <= '0';
				end if;
				
			end if;
		end if;
	end process;

end architecture;
