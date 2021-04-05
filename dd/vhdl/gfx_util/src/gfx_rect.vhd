
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.math_pkg.all;
use work.gfx_util_pkg.all;


entity gfx_rect is
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
		
		--drawing paramers
		x : in std_logic_vector(log2c(WIDTH)-1 downto 0);
		y : in std_logic_vector(log2c(HEIGHT)-1 downto 0);
		w : in std_logic_vector(log2c(WIDTH)-1 downto 0);
		h : in std_logic_vector(log2c(HEIGHT)-1 downto 0);
		
		bw : in std_logic_vector(3 downto 0);
		bh : in std_logic_vector(3 downto 0);
		dx : in std_logic_vector(3 downto 0);
		dy : in std_logic_vector(3 downto 0);
		ls : in std_logic_vector(4 downto 0);
		
		fill : in std_logic;
		draw : in std_logic;
		
		--pixel coordinates output
		pixel_valid : out std_logic;
		pixel_x : out std_logic_vector(log2c(WIDTH)-1 downto 0);
		pixel_y : out std_logic_vector(log2c(HEIGHT)-1 downto 0);
		pixel_color : out std_logic
	);
end entity;

architecture arch of gfx_rect is
	signal running : std_logic;
	
	signal x_br : std_logic_vector(x'range);
	signal y_br : std_logic_vector(y'range);
	
	signal h_block_cnt : std_logic_vector(4 downto 0) := (others=>'0');
	signal v_block_cnt : std_logic_vector(4 downto 0) := (others=>'0');
	
	signal line_shift : std_logic_vector(5 downto 0);
begin

	x_br <= std_logic_vector(unsigned(x) + unsigned(w) - 1);
	y_br <= std_logic_vector(unsigned(y) + unsigned(h) - 1);

	busy <= running;

	sync : process(clk, res_n)
		variable h_block_cnt_temp : integer;
		variable line_shift_tmp : integer;
	begin
		if (res_n = '0') then
			pixel_x <= (others=>'0');
			pixel_y <= (others=>'0');
			running <= '0';
			h_block_cnt <= (others=>'0');
			v_block_cnt <= (others=>'0');
			line_shift <= (others=>'0');
		elsif (rising_edge(clk)) then
			pixel_valid <= '0';
			
			if (start = '1') then
				pixel_valid <= '1';
				pixel_x <= x;
				pixel_y <= y;
				running <= '1';
				h_block_cnt <= (others=>'0');
				v_block_cnt <= (others=>'0');
				line_shift <= (others=>'0');
			end if;
			
			if(running = '1' and stall = '0') then

				if(unsigned(h_block_cnt) = (unsigned(bw) + unsigned(dx) - 1) ) then
					h_block_cnt <= (others=>'0');
				else
					h_block_cnt <= std_logic_vector(unsigned(h_block_cnt) + 1);
				end if;

				if (unsigned(pixel_x) = unsigned(x_br)) then -- line complete
					h_block_cnt <= (others=>'0');
					line_shift_tmp := to_integer(unsigned(line_shift));
					
					if(unsigned(v_block_cnt) = (unsigned(bh) + unsigned(dy) - 1) ) then -- v block complete
						v_block_cnt <= (others=>'0');
						line_shift_tmp := line_shift_tmp - to_integer(unsigned(ls));
						if(line_shift_tmp < 0) then
							line_shift_tmp := line_shift_tmp + to_integer(unsigned(bw) + unsigned(dx));
						end if;
					else
						v_block_cnt <= std_logic_vector(unsigned(v_block_cnt) + 1);
					end if; 
					
					h_block_cnt_temp := line_shift_tmp;
					h_block_cnt <= std_logic_vector(to_unsigned(h_block_cnt_temp, h_block_cnt'length));
					line_shift <= std_logic_vector(to_unsigned(line_shift_tmp, line_shift'length));
				end if;
				
				pixel_valid <= '1';
				if (unsigned(pixel_x) = unsigned(x_br)) then
					pixel_x <= x;
					if(unsigned(pixel_y) = unsigned(y_br)) then
						running <= '0';
						pixel_valid <= '0';
					else
						pixel_y <= std_logic_vector(unsigned(pixel_y) + 1);
					end if;
				else
					pixel_x <= std_logic_vector(unsigned(pixel_x) + 1);
				end if;
				
			end if;
		end if;
	end process;
	
	gen_color : process(all)
		variable pixel_active_h : std_logic;
		variable line_active : std_logic;
		variable border_override : std_logic;
	begin
		pixel_color <= '0';
		border_override := '0';

		if (pixel_x = x or pixel_x = x_br or pixel_y = y or pixel_y = y_br) then
			border_override := '1';
		end if;

		if(unsigned(h_block_cnt) < unsigned(bw)) then
			pixel_active_h := '1';
		else
			pixel_active_h := '0';
		end if;
		
		if(unsigned(v_block_cnt) < unsigned(bh)) then
			line_active := '1';
		else
			line_active := '0';
		end if;
		
		pixel_color <= (border_override and draw) or (pixel_active_h and line_active);
	end process;

end architecture;
