library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mem_pkg.all;
use work.core_pkg.all;
use work.op_pkg.all;

entity memu is
	port (
		-- to mem
		op   : in  memu_op_type;
		A    : in  data_type;								--length 32
		W    : in  data_type;								--length 32
		R    : out data_type := (others => '0');		--length 32,

		B    : out std_logic := '0';
		XL   : out std_logic := '0';
		XS   : out std_logic := '0';

		-- to memory controller
		D    : in  mem_in_type;
		M    : out mem_out_type := MEM_OUT_NOP
	);
end entity;

architecture rtl of memu is
begin
	M.address <= A(15 downto 2);
	B <= D.busy;
	memu_write: process(all)
	begin
		if op.memread = '0' and op.memwrite = '1' then
			XS <= '1';
			M.wr <= '1';
			case op.memtype is
			when MEM_B | MEM_BU =>
				if A(1 downto 0) = "00" then
					M.byteena <= "1000";
					M.wrdata(31 downto 24) <= W(7 downto 0);			--b0
					M.wrdata(23 downto 16) <= (others => '-');		--X
					M.wrdata(15 downto 8)  <= (others => '-');		--X
					M.wrdata(7 downto 0)   <= (others => '-');		--X
				elsif A(1 downto 0) = "01" then
					M.byteena <= "0100";
					M.wrdata(31 downto 24) <= (others => '-');		--X
					M.wrdata(23 downto 16) <= W(7 downto 0);			--b0
					M.wrdata(15 downto 8)  <= (others => '-');		--X
					M.wrdata(7 downto 0)   <= (others => '-');		--X
				elsif A(1 downto 0) = "10" then
					M.byteena <= "0010";
					M.wrdata(31 downto 24) <= (others => '-');		--X
					M.wrdata(23 downto 16) <= (others => '-');		--X
					M.wrdata(15 downto 8)  <= W(7 downto 0);			--b0
					M.wrdata(7 downto 0)   <= (others => '-');		--X
				elsif A(1 downto 0) = "11" then
					M.byteena <= "0001";
					M.wrdata(31 downto 24) <= (others => '-');		--X
					M.wrdata(23 downto 16) <= (others => '-');		--X
					M.wrdata(15 downto 8)  <= (others => '-');		--X
					M.wrdata(7 downto 0)   <= W(7 downto 0);			--b0
				else
					M.wrdata <= (others => '0');
					M.byteena <= "1111";
				end if;
				
			when MEM_H | MEM_HU =>
				if (A(1 downto 0) = "00") or (A(1 downto 0) = "01") then
					M.byteena <= "1100";
					M.wrdata(31 downto 24) <= W(7 downto 0);			--b0
					M.wrdata(23 downto 16) <= W(15 downto 8);			--b1
					M.wrdata(15 downto 8)  <= (others => '-');		--X
					M.wrdata(7 downto 0)   <= (others => '-');		--X
				elsif (A(1 downto 0) = "10") or (A(1 downto 0) = "11") then
					M.byteena <= "0011";
					M.wrdata(31 downto 24) <= (others => '-');		--X
					M.wrdata(23 downto 16) <= (others => '-');		--X
					M.wrdata(15 downto 8)  <= W(7 downto 0);			--b0
					M.wrdata(7 downto 0)   <= W(15 downto 8);			--b1
				else
					M.wrdata <= (others => '0');
					M.byteena <= "1111";
				end if;
				
			when MEM_W =>
				M.byteena <= "1111";
				M.wrdata(31 downto 24) <= W(7 downto 0);				--b0
				M.wrdata(23 downto 16) <= W(15 downto 8);				--b1
				M.wrdata(15 downto 8)  <= W(23 downto 16);			--b2
				M.wrdata(7 downto 0)   <= W(31 downto 24);			--b3
				
			when others =>
				report "others";
				M.wrdata <= (others => '0');
			end case;
		else 
			XS <= '0';
			M.wr <= '0';
			M.byteena <= "1111";
			M.wrdata <= (others => '0');
		end if;
	end process;
	
	memu_read: process(all)
	begin
		if op.memread = '1' and op.memwrite = '0' then
			XL <= '1';
			M.rd <= '1';
			case op.memtype is
			when MEM_B =>
				if A(1 downto 0) = "00" then
					R(31 downto 24) <= (others => D.rddata(31));		--S
					R(23 downto 16) <= (others => D.rddata(31));		--S
					R(15 downto 8)  <= (others => D.rddata(31));		--S
					R(7 downto 0)   <= D.rddata(31 downto 24);		--b3
				elsif A(1 downto 0) = "01" then
					R(31 downto 24) <= (others => D.rddata(23));		--S
					R(23 downto 16) <= (others => D.rddata(23));		--S
					R(15 downto 8)  <= (others => D.rddata(23));		--S
					R(7 downto 0)   <= D.rddata(23 downto 16);		--b2
				elsif A(1 downto 0) = "10" then
					R(31 downto 24) <= (others => D.rddata(15));		--S
					R(23 downto 16) <= (others => D.rddata(15));		--S
					R(15 downto 8)  <= (others => D.rddata(15));		--S
					R(7 downto 0)   <= D.rddata(15 downto 8);			--b1
				elsif A(1 downto 0) = "11" then
					R(31 downto 24) <= (others => D.rddata(7));		--S
					R(23 downto 16) <= (others => D.rddata(7));		--S
					R(15 downto 8)  <= (others => D.rddata(7));		--S
					R(7 downto 0)   <= D.rddata(7 downto 0);			--b0
				else
					R <= (others =>'0');
				end if;
				
			when MEM_BU =>
				if A(1 downto 0) = "00" then
					R(31 downto 24) <= (others => '0');					--0
					R(23 downto 16) <= (others => '0');					--0
					R(15 downto 8)  <= (others => '0');					--0
					R(7 downto 0)   <= D.rddata(31 downto 24);		--b3
				elsif A(1 downto 0) = "01" then
					R(31 downto 24) <= (others => '0');					--0
					R(23 downto 16) <= (others => '0');					--0
					R(15 downto 8)  <= (others => '0');					--0
					R(7 downto 0)   <= D.rddata(23 downto 16);		--b2
				elsif A(1 downto 0) = "10" then
					R(31 downto 24) <= (others => '0');					--0
					R(23 downto 16) <= (others => '0');					--0
					R(15 downto 8)  <= (others => '0');					--0
					R(7 downto 0)   <= D.rddata(15 downto 8);			--b1
				elsif A(1 downto 0) = "11" then
					R(31 downto 24) <= (others => '0');					--0
					R(23 downto 16) <= (others => '0');					--0
					R(15 downto 8)  <= (others => '0');					--0
					R(7 downto 0)   <= D.rddata(7 downto 0);			--b0
				else
					R <= (others =>'0');
				end if;
			
			when MEM_H =>
				if (A(1 downto 0) = "00") or (A(1 downto 0) = "01") then
					R(31 downto 24) <= (others => D.rddata(23));		--S
					R(23 downto 16) <= (others => D.rddata(23));		--S
					R(15 downto 8)  <= D.rddata(23 downto 16);		--b2
					R(7 downto 0)   <= D.rddata(31 downto 24);		--b3
				elsif (A(1 downto 0) = "10") or (A(1 downto 0) = "11") then
					R(31 downto 24) <= (others => D.rddata(7));		--S
					R(23 downto 16) <= (others => D.rddata(7));		--S
					R(15 downto 8)  <= D.rddata(7 downto 0);			--b0
					R(7 downto 0)   <= D.rddata(15 downto 8);			--b1
				else
					R <= (others =>'0');
				end if;
			
			when MEM_HU =>
				if (A(1 downto 0) = "00") or (A(1 downto 0) = "01") then
					R(31 downto 24) <= (others => '0');					--0
					R(23 downto 16) <= (others => '0');					--0
					R(15 downto 8)  <= D.rddata(23 downto 16);		--b2
					R(7 downto 0)   <= D.rddata(31 downto 24);		--b3
				elsif (A(1 downto 0) = "10") or (A(1 downto 0) = "11") then
					R(31 downto 24) <= (others => '0');					--0
					R(23 downto 16) <= (others => '0');					--0
					R(15 downto 8)  <= D.rddata(7 downto 0);			--b0
					R(7 downto 0)   <= D.rddata(15 downto 8);			--b1
				else
					R <= (others =>'0');
				end if;
			
			when MEM_W =>
				R(31 downto 24) <= D.rddata(7 downto 0);				--b0
				R(23 downto 16) <= D.rddata(15 downto 8);				--b1
				R(15 downto 8)  <= D.rddata(23 downto 16);			--b2
				R(7 downto 0)   <= D.rddata(31 downto 24);			--b3
				
			when others =>
				R <= (others =>'0');
			end case;
		else
			XL <= '0';
			M.rd <= '0';
			R <= (others =>'0');
		end if;
	end process;
	
end architecture;
