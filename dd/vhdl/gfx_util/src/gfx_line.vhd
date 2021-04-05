
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.math_pkg.all;
use work.gfx_util_pkg.all;

entity gfx_line is
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
		x0 : in std_logic_vector(log2c(WIDTH)-1 downto 0);
		y0 : in std_logic_vector(log2c(HEIGHT)-1 downto 0);
		x1 : in std_logic_vector(log2c(WIDTH)-1 downto 0);
		y1 : in std_logic_vector(log2c(HEIGHT)-1 downto 0);
		
		--pixel coordinates output
		pixel_valid : out std_logic;
		pixel_x : out std_logic_vector(log2c(WIDTH)-1 downto 0);
		pixel_y : out std_logic_vector(log2c(HEIGHT)-1 downto 0)
	);
end entity;

architecture arch of gfx_line is
	signal dx : integer range -2**(log2c(WIDTH)+1) to 2**(log2c(WIDTH)+1)-1 := 0;
	signal dy : integer range -2**(log2c(HEIGHT)+1) to 2**(log2c(HEIGHT)+1)-1 := 0;
	signal err : integer range -2**(log2c(max(WIDTH,HEIGHT))+1) to 2**(log2c(max(WIDTH,HEIGHT))+1)-1 := 0;
	
	signal sx : std_logic;
	signal sy : std_logic;
	
	signal running : std_logic;
	
	constant ADD_ONE : std_logic := '1';
	constant SUB_ONE : std_logic := '0';
begin
	busy <= running;
	
	sync : process(clk, res_n)
		variable err_temp_var : integer;
	begin
		if (res_n = '0') then
			pixel_x <= (others=>'0');
			pixel_y <= (others=>'0');
			sx <= '0';
			sy <= '0';
			pixel_valid <= '0';
			running <= '0';
			dx <= 0;
			dy <= 0;
			err <= 0;
		elsif (rising_edge(clk)) then
			
			pixel_valid <= '0';
			
			if (start = '1') then
				pixel_x <= x0;
				pixel_y <= y0;
				pixel_valid <= '1';

				dx <= abs(to_integer(signed('0' & x1) - signed('0' & x0)));
				dy <= -abs(to_integer(signed('0' & y1) - signed('0' & y0)));
				
				if unsigned(x0) < unsigned(x1) then
					sx <= ADD_ONE;
				else
					sx <= SUB_ONE;
				end if;

				if unsigned(y0) < unsigned(y1) then
					sy <= ADD_ONE;
				else
					sy <= SUB_ONE;
				end if;

				err <= abs(to_integer(signed('0' & x1) - signed('0' & x0)))-
					abs(to_integer(signed('0' & y1) - signed('0' & y0)));
					
				running <= '1';
			end if;
			
			if(running = '1' and stall = '0') then
				pixel_valid <= '1';
				err_temp_var := err;
				
				-- The following two if-statements can be true 
				-- at the same time!!!! That means that only 
				-- the last signal assignment is executed if 
				-- only signals for the error are used!!!!!
				if ((err*2) >= dy) then 
					err_temp_var := err + dy;
					if(sx = SUB_ONE) then
						pixel_x <= std_logic_vector(unsigned(pixel_x) - 1);
					else
						pixel_x <= std_logic_vector(unsigned(pixel_x) + 1);
					end if;
				end if; 
			
				if ((err*2) <= dx) then 
					err_temp_var := err_temp_var + dx;
					if(sy = SUB_ONE) then
						pixel_y <= std_logic_vector(unsigned(pixel_y) - 1);
					else
						pixel_y <= std_logic_vector(unsigned(pixel_y) + 1);
					end if;
				end if;
			
				err <= err_temp_var;
				
				if (
					unsigned(pixel_x) = unsigned(x1) and
					unsigned(pixel_y) = unsigned(y1)
				) then
					running <= '0';
					pixel_valid <= '0';
				end if;
			end if;
		end if;
	end process;

end architecture;
