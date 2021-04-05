library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package object_collider_pkg is
	
	constant COORDINATE_WIDTH : integer := 12;
	constant GAME_OBJECT_ID_WIDTH : integer := 2;
	constant GAME_OBJECT_SPEED_WIDTH : integer := 4;
	
	constant DIR_LEFT : std_logic := '0';
	constant DIR_RIGHT : std_logic := '1';
	
	type game_object_t is
	record
		id : std_logic_vector(GAME_OBJECT_ID_WIDTH-1 downto 0);
		x : std_logic_vector(COORDINATE_WIDTH-1 downto 0);
		y : std_logic_vector(COORDINATE_WIDTH-1 downto 0);
		w : std_logic_vector(COORDINATE_WIDTH-1 downto 0);
		h : std_logic_vector(COORDINATE_WIDTH-1 downto 0);
	end record;
	
	constant GAME_OBJECT_NULL : game_object_t := (
		id => (others=>'0'),
		x  => (others=>'0'),
		y  => (others=>'0'),
		w  => (others=>'0'),
		h  => (others=>'0')
	);
	
	component object_collider is
		generic (
			DISPLAY_WIDTH : integer := 400;
			DISPLAY_HEIGHT : integer := 240
		);
		port (
			clk : in std_logic;
			res_n : in std_logic;
			start : in std_logic;
			done : out std_logic;
			apply_movement : in std_logic;
			apply_gravity : in std_logic;
			player_x : out std_logic_vector(COORDINATE_WIDTH-1 downto 0);
			player_y : out std_logic_vector(COORDINATE_WIDTH-1 downto 0);
			player : in game_object_t;
			player_speed : in std_logic_vector(GAME_OBJECT_SPEED_WIDTH-1 downto 0);
			player_dir : in std_logic;
			gravity : in std_logic_vector(GAME_OBJECT_SPEED_WIDTH-1 downto 0);
			object : in game_object_t;
			object_req : out std_logic;
			object_valid : in std_logic;
			object_is_blocking : in std_logic;
			object_eol : in std_logic;
			collision_detected : out std_logic
		);
	end component;
	
	function go_to_slv(go : game_object_t) return std_logic_vector;
	function slv_to_go(slv : std_logic_vector) return game_object_t;
	function create_game_object(x,y,w,h : integer; id : std_logic_vector ) return game_object_t;
end package;



package body object_collider_pkg is

	function go_to_slv(go : game_object_t) return std_logic_vector is
	begin
		return go.id & go.x & go.y & go.w & go.h;
	end function;
	
	function slv_to_go(slv : std_logic_vector) return game_object_t is
		variable go : game_object_t;
	begin
		go.id := slv(go.id'length+go.x'length+go.y'length+go.w'length+go.h'length-1 downto go.x'length+go.y'length+go.w'length+go.h'length);
		go.x := slv(go.x'length+go.y'length+go.w'length+go.h'length-1 downto go.y'length+go.w'length+go.h'length);
		go.y := slv(go.y'length+go.w'length+go.h'length-1 downto go.w'length+go.h'length);
		go.w := slv(go.w'length+go.h'length-1 downto go.h'length);
		go.h := slv(go.h'length-1 downto 0);
		return go;
	end function;


	function create_game_object(x,y,w,h : integer; id : std_logic_vector ) return game_object_t is
		variable go : game_object_t;
	begin
		go.x := std_logic_vector(to_signed(x, COORDINATE_WIDTH));
		go.y := std_logic_vector(to_signed(y, COORDINATE_WIDTH));
		go.w := std_logic_vector(to_signed(w, COORDINATE_WIDTH));
		go.h := std_logic_vector(to_signed(h, COORDINATE_WIDTH));
		go.id := id;
		return go;
	end function;

end package body;


