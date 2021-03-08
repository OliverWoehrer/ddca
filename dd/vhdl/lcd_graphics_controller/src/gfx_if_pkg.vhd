library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- The graphics interface uses 8 bit wide instructions and 3 instructions formats.
--  * Format A: [0000 XXXX]
--  * Format B: [01XX IIII]
--  * Format C: [1XXI IIII]
-- Here 'X' stands for opcode bits and 'I' for immidiate bits.
--
-- [A] NOP         [0000 0000]
-- [A] CLEAR       [0000 0001]
-- [A] FRAME_SYNC  [0000 0010]
-- [A] SET_PIXEL   [0000 1000]
-- [A] DRAW_LINE   [0000 1001]
-- [A] DRAW_CIRCLE [0000 1010]
-- [B] SET_CFG     [0100 000D]
-- [B] SET_COLOR   [0101 000C]
-- [B] SET_PATTERN [0110 0PPP]
--    * P: pattern selector (3 bits)
-- [C] DRAW_RECT   [100A BPPP]
--    * A: enable alpha (1 bit)
--    * B: draw border (1 bit)
--    * P: pattern selector (3 bits)
--        000: solid_secondary
--        001-110: user_pattern1-6
--        111: solid_primary

package gfx_if_pkg is
	constant GFX_INSTR_WIDTH : integer := 8;
	constant GFX_DATA_WIDTH : integer := 16;

	--Format A opcodes
	constant OPCODE_NOP : std_logic_vector(3 downto 0) := x"0";
	constant OPCODE_CLEAR : std_logic_vector(3 downto 0) := x"1";
	constant OPCODE_FRAME_SYNC : std_logic_vector(3 downto 0) := x"2";
	constant OPCODE_SET_PIXEL : std_logic_vector(3 downto 0) := x"8";
	constant OPCODE_DRAW_LINE : std_logic_vector(3 downto 0) := x"9";
	constant OPCODE_DRAW_CIRCLE : std_logic_vector(3 downto 0) := x"a";
	--Format B opcodes
	constant OPCODE_SET_CFG : std_logic_vector(1 downto 0) := "00";
	constant OPCODE_SET_COLOR : std_logic_vector(1 downto 0) := "01";
	constant OPCODE_SET_PATTERN : std_logic_vector(1 downto 0) := "10";
	--Format C opcodes
	constant OPCODE_DRAW_RECT : std_logic_vector(1 downto 0) := "00";

	constant GFX_INSTR_NOP         : std_logic_vector(7 downto 0) := x"0" & OPCODE_NOP;
	constant GFX_INSTR_CLEAR       : std_logic_vector(7 downto 0) := x"0" & OPCODE_CLEAR;
	constant GFX_INSTR_FRAME_SYNC  : std_logic_vector(7 downto 0) := x"0" & OPCODE_FRAME_SYNC;
	constant GFX_INSTR_SET_PIXEL   : std_logic_vector(7 downto 0) := x"0" & OPCODE_SET_PIXEL;
	constant GFX_INSTR_DRAW_LINE   : std_logic_vector(7 downto 0) := x"0" & OPCODE_DRAW_LINE;
	constant GFX_INSTR_DRAW_CIRCLE : std_logic_vector(7 downto 0) := x"0" & OPCODE_DRAW_CIRCLE;
	
	function GFX_INSTR_SET_CFG(enable_double_buffering : boolean) return std_logic_vector;
	function GFX_INSTR_SET_COLOR(color_selector : boolean) return std_logic_vector;
	function GFX_INSTR_SET_PATTERN(pattern_id : integer) return std_logic_vector;
	function GFX_INSTR_DRAW_RECT(enable_alpha : boolean; draw_border : boolean; pattern_id : integer) return std_logic_vector;

	function is_instr_format_A(instr : std_logic_vector) return boolean;
	function is_instr_format_B(instr : std_logic_vector) return boolean;
	function is_instr_format_C(instr : std_logic_vector) return boolean;

	type gfx_instr_array_t is array(integer range <>) of std_logic_vector(GFX_INSTR_WIDTH-1 downto 0);
	type gfx_data_array_t is array(integer range <>) of std_logic_vector(GFX_DATA_WIDTH-1 downto 0);
	
end package;

package body gfx_if_pkg  is

	function GFX_INSTR_SET_CFG(enable_double_buffering : boolean) return std_logic_vector is
		variable instr : std_logic_vector(7 downto 0);
	begin
		instr := "01000000";
		if (enable_double_buffering) then
			instr(0) := '1';
		end if;
		return instr;
	end function;
	
	function GFX_INSTR_SET_COLOR(color_selector : boolean) return std_logic_vector is
		variable instr : std_logic_vector(7 downto 0);
	begin
		instr := "01010000";
		if (color_selector) then
			instr(0) := '1';
		end if;
		return instr;
	end function;
	
	function GFX_INSTR_SET_PATTERN(pattern_id : integer) return std_logic_vector  is
		variable instr : std_logic_vector(7 downto 0);
	begin
		instr := "01100000";
		assert (pattern_id >= 1 or pattern_id <= 6) report "pattern_id must be between 1 and 6" severity failure;
		instr(2 downto 0) := std_logic_vector(to_unsigned(pattern_id, 3));
		return instr;
	end function;
	
	function GFX_INSTR_DRAW_RECT(enable_alpha : boolean; draw_border : boolean; pattern_id : integer) return std_logic_vector is
		variable instr : std_logic_vector(7 downto 0);
	begin
		instr := "1" & OPCODE_DRAW_RECT & "00000";
		assert (pattern_id >= 0 or pattern_id <= 7) report "pattern_id must be between 0 and 7" severity failure;
		instr(2 downto 0) := std_logic_vector(to_unsigned(pattern_id, 3));
		if(draw_border) then
			instr(3) := '1';
		end if;
		if (enable_alpha) then
			instr(4) := '1';
		end if;
		return instr;
	end function;

	function is_instr_format_A(instr : std_logic_vector) return boolean is
	begin
		if instr(7 downto 4) = x"0" then
			return true;
		end if;
		return false;
	end function;
	
	function is_instr_format_B(instr : std_logic_vector) return boolean is
	begin
		if instr(7 downto 6) = "01" then
			return true;
		end if;
		return false;
	end function;
	
	function is_instr_format_C(instr : std_logic_vector) return boolean is
	begin
		if instr(7) = '1' then
			return true;
		end if;
		return false;
	end function;

end package body;

