library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ram_pkg.all;

-- This core continuously reads a frame buffer from video RAM (accessed via 
-- vram_rd, vram_addr and vram_data) and outputs the data using a FIFO-like 
-- interface on pix_rd and pix_data.
-- The size of the frame buffer is defined by the generics WIDTH and HEIGHT.
-- The start address of the frame buffer can be controlled using the
-- vram_base_addr input signal. 
-- The frame_start signal is used to synchronize the switch of the frame buffer
-- to the start of a frame. It is asserted for exactly one clock cycle, two 
-- clock cycles before the frame_reader actually starts to fetch a new frame 
-- from the address pointed to by vram_base_addr. The base address may only be 
-- changed at the beginning of a frame.

entity frame_reader is
	generic (
		WIDTH : integer;
		HEIGHT : integer;
		VRAM_ADDR_WIDTH : integer;
		VRAM_DATA_WIDTH : integer
	);
	port (
		clk : in std_logic;
		res_n : in std_logic;
		
		-- frame synchronization signal
		frame_start : out std_logic;
		vram_base_addr : in std_logic_vector(VRAM_ADDR_WIDTH-1 downto 0);
		
		-- interface to the video RAM
		vram_rd : out std_logic;
		vram_addr : out std_logic_vector(VRAM_ADDR_WIDTH-1 downto 0);
		vram_data : in std_logic_vector(VRAM_DATA_WIDTH-1 downto 0);
		
		--asserting pix_rd yields the next pixel data on the next clock edge 
		pix_rd : in std_logic;
		pix_data : out std_logic_vector(VRAM_DATA_WIDTH-1 downto 0)
	);
end entity;


architecture arch of frame_reader is
	constant OUTPUT_FIFO_DEPTH : integer := 8;
	
	signal wr : std_logic;
	signal wr_data : std_logic_vector(VRAM_DATA_WIDTH-1 downto 0);
	signal half_full : std_logic;
	
	signal pix_x : integer range 0 to WIDTH-1 := 0;
	signal pix_y : integer range 0 to HEIGHT-1 := 0;
	
	signal read_burst_cnt : integer range 0 to OUTPUT_FIFO_DEPTH/2 := 0;
	
	signal wr_cnt : integer;
	signal rd_cnt : integer;
	
	signal frame_start_wait_cycle : std_logic; -- used to delay the data fetching at the start of a new frame
	signal init : std_logic; -- indicates that the circuit comes out of reset
begin

	sync : process(clk, res_n)
	begin
		if (res_n = '0') then
			pix_x <= 0;
			pix_y <= 0;
			vram_rd <= '0';
			vram_addr <= (others => '0');
			read_burst_cnt <= 0;
			frame_start <= '0';
			init <= '1';
			frame_start_wait_cycle <= '0';
		elsif (rising_edge(clk)) then
			vram_rd <= '0';
			frame_start <= '0';
			frame_start_wait_cycle <= frame_start;
			
			if (init = '1') then
				frame_start <= '1';
				init <= '0';
			end if;
			
			if(half_full = '0') then
				read_burst_cnt <= OUTPUT_FIFO_DEPTH/2;
			end if;
			
			if (read_burst_cnt /= 0 and init = '0' and not (frame_start = '1' or frame_start_wait_cycle = '1') ) then
				read_burst_cnt <= read_burst_cnt - 1;
				vram_addr <= std_logic_vector(unsigned(vram_base_addr) + to_unsigned(pix_x + WIDTH*pix_y, VRAM_ADDR_WIDTH));
				vram_rd <= '1';
				
				if (pix_x = WIDTH-1) then
					pix_x <= 0;
					if(pix_y = HEIGHT-1) then
						pix_y <= 0;
						frame_start <= '1';
					else
						pix_y <= pix_y + 1;
					end if;
				else
					pix_x <= pix_x + 1;
				end if;
			end if;
			
			wr <= vram_rd;
		end if;
	end process;

	fifo_1c1r1w_inst : fifo_1c1r1w
	generic map (
		DEPTH          => OUTPUT_FIFO_DEPTH,
		DATA_WIDTH     => VRAM_DATA_WIDTH
	)
	port map (
		clk        => clk,
		res_n      => res_n,
		rd_data    => pix_data,
		rd         => pix_rd,
		wr_data    => vram_data,
		wr         => wr,
		empty      => open,
		full       => open,
		half_full  => half_full
	);


	dbg : process(clk, res_n)
	begin
		if (res_n = '0') then
			wr_cnt <= 0;
			rd_cnt <= 0;
		elsif (rising_edge(clk)) then
			if(wr = '1') then
				wr_cnt <= wr_cnt + 1;
			end if;
			
			if (pix_rd = '1') then
				rd_cnt <= rd_cnt + 1;
			end if;
		end if;
	end process;


end architecture;
