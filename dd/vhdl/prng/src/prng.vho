-- Copyright (C) 2018  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details.

-- VENDOR "Altera"
-- PROGRAM "Quartus Prime"
-- VERSION "Version 18.1.0 Build 625 09/12/2018 SJ Standard Edition"

-- DATE "03/20/2021 11:26:01"

-- 
-- Device: Altera EP4CE115F29C7 Package FBGA780
-- 

-- 
-- This VHDL file should be used for ModelSim (VHDL) only
-- 

LIBRARY CYCLONEIVE;
LIBRARY IEEE;
USE CYCLONEIVE.CYCLONEIVE_COMPONENTS.ALL;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY 	hard_block IS
    PORT (
	devoe : IN std_logic;
	devclrn : IN std_logic;
	devpor : IN std_logic
	);
END hard_block;

-- Design Ports Information
-- ~ALTERA_ASDO_DATA1~	=>  Location: PIN_F4,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- ~ALTERA_FLASH_nCE_nCSO~	=>  Location: PIN_E2,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- ~ALTERA_DCLK~	=>  Location: PIN_P3,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- ~ALTERA_DATA0~	=>  Location: PIN_N7,	 I/O Standard: 2.5 V,	 Current Strength: Default


ARCHITECTURE structure OF hard_block IS
SIGNAL gnd : std_logic := '0';
SIGNAL vcc : std_logic := '1';
SIGNAL unknown : std_logic := 'X';
SIGNAL ww_devoe : std_logic;
SIGNAL ww_devclrn : std_logic;
SIGNAL ww_devpor : std_logic;
SIGNAL \~ALTERA_ASDO_DATA1~~padout\ : std_logic;
SIGNAL \~ALTERA_FLASH_nCE_nCSO~~padout\ : std_logic;
SIGNAL \~ALTERA_DATA0~~padout\ : std_logic;
SIGNAL \~ALTERA_ASDO_DATA1~~ibuf_o\ : std_logic;
SIGNAL \~ALTERA_FLASH_nCE_nCSO~~ibuf_o\ : std_logic;
SIGNAL \~ALTERA_DATA0~~ibuf_o\ : std_logic;

BEGIN

ww_devoe <= devoe;
ww_devclrn <= devclrn;
ww_devpor <= devpor;
END structure;


LIBRARY ALTERA;
LIBRARY CYCLONEIVE;
LIBRARY IEEE;
USE ALTERA.ALTERA_PRIMITIVES_COMPONENTS.ALL;
USE CYCLONEIVE.CYCLONEIVE_COMPONENTS.ALL;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY 	prng IS
    PORT (
	clk : IN std_logic;
	res_n : IN std_logic;
	load_seed : IN std_logic;
	seed : IN std_logic_vector(7 DOWNTO 0);
	en : IN std_logic;
	prdata : OUT std_logic
	);
END prng;

-- Design Ports Information
-- prdata	=>  Location: PIN_AB16,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- load_seed	=>  Location: PIN_AA16,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- seed[7]	=>  Location: PIN_AE17,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- clk	=>  Location: PIN_Y2,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- res_n	=>  Location: PIN_Y1,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- en	=>  Location: PIN_AB15,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- seed[6]	=>  Location: PIN_AG19,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- seed[5]	=>  Location: PIN_AG18,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- seed[0]	=>  Location: PIN_AA15,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- seed[1]	=>  Location: PIN_AH19,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- seed[2]	=>  Location: PIN_AE16,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- seed[3]	=>  Location: PIN_AH18,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- seed[4]	=>  Location: PIN_AF17,	 I/O Standard: 2.5 V,	 Current Strength: Default


ARCHITECTURE structure OF prng IS
SIGNAL gnd : std_logic := '0';
SIGNAL vcc : std_logic := '1';
SIGNAL unknown : std_logic := 'X';
SIGNAL devoe : std_logic := '1';
SIGNAL devclrn : std_logic := '1';
SIGNAL devpor : std_logic := '1';
SIGNAL ww_devoe : std_logic;
SIGNAL ww_devclrn : std_logic;
SIGNAL ww_devpor : std_logic;
SIGNAL ww_clk : std_logic;
SIGNAL ww_res_n : std_logic;
SIGNAL ww_load_seed : std_logic;
SIGNAL ww_seed : std_logic_vector(7 DOWNTO 0);
SIGNAL ww_en : std_logic;
SIGNAL ww_prdata : std_logic;
SIGNAL \clk~inputclkctrl_INCLK_bus\ : std_logic_vector(3 DOWNTO 0);
SIGNAL \res_n~inputclkctrl_INCLK_bus\ : std_logic_vector(3 DOWNTO 0);
SIGNAL \prdata~output_o\ : std_logic;
SIGNAL \clk~input_o\ : std_logic;
SIGNAL \clk~inputclkctrl_outclk\ : std_logic;
SIGNAL \seed[6]~input_o\ : std_logic;
SIGNAL \lfsr[14]~feeder_combout\ : std_logic;
SIGNAL \seed[7]~input_o\ : std_logic;
SIGNAL \seed[4]~input_o\ : std_logic;
SIGNAL \seed[5]~input_o\ : std_logic;
SIGNAL \Equal0~1_combout\ : std_logic;
SIGNAL \seed[0]~input_o\ : std_logic;
SIGNAL \seed[3]~input_o\ : std_logic;
SIGNAL \seed[2]~input_o\ : std_logic;
SIGNAL \seed[1]~input_o\ : std_logic;
SIGNAL \Equal0~0_combout\ : std_logic;
SIGNAL \lfsr~3_combout\ : std_logic;
SIGNAL \Equal0~2_combout\ : std_logic;
SIGNAL \load_seed~input_o\ : std_logic;
SIGNAL \lfsr[11]~feeder_combout\ : std_logic;
SIGNAL \lfsr~15_combout\ : std_logic;
SIGNAL \ultra_short_polynomial~0_combout\ : std_logic;
SIGNAL \res_n~input_o\ : std_logic;
SIGNAL \res_n~inputclkctrl_outclk\ : std_logic;
SIGNAL \ultra_short_polynomial~q\ : std_logic;
SIGNAL \polynomial_selector[2]~0_combout\ : std_logic;
SIGNAL \Mux0~1_combout\ : std_logic;
SIGNAL \Mux0~2_combout\ : std_logic;
SIGNAL \Mux0~3_combout\ : std_logic;
SIGNAL \Mux0~0_combout\ : std_logic;
SIGNAL \Mux0~4_combout\ : std_logic;
SIGNAL \Mux0~5_combout\ : std_logic;
SIGNAL \Mux0~6_combout\ : std_logic;
SIGNAL \Mux0~7_combout\ : std_logic;
SIGNAL \Mux0~8_combout\ : std_logic;
SIGNAL \Mux0~9_combout\ : std_logic;
SIGNAL \lfsr[0]~0_combout\ : std_logic;
SIGNAL \en~input_o\ : std_logic;
SIGNAL \lfsr[15]~2_combout\ : std_logic;
SIGNAL \lfsr~14_combout\ : std_logic;
SIGNAL \lfsr~13_combout\ : std_logic;
SIGNAL \lfsr~12_combout\ : std_logic;
SIGNAL \lfsr~11_combout\ : std_logic;
SIGNAL \lfsr~10_combout\ : std_logic;
SIGNAL \lfsr~9_combout\ : std_logic;
SIGNAL \lfsr~8_combout\ : std_logic;
SIGNAL \lfsr~7_combout\ : std_logic;
SIGNAL \lfsr~6_combout\ : std_logic;
SIGNAL \lfsr~5_combout\ : std_logic;
SIGNAL \lfsr[10]~_wirecell_combout\ : std_logic;
SIGNAL \lfsr~4_combout\ : std_logic;
SIGNAL \lfsr[12]~_wirecell_combout\ : std_logic;
SIGNAL \lfsr~1_combout\ : std_logic;
SIGNAL polynomial_selector : std_logic_vector(2 DOWNTO 0);
SIGNAL lfsr : std_logic_vector(15 DOWNTO 0);
SIGNAL \ALT_INV_load_seed~input_o\ : std_logic;
SIGNAL ALT_INV_lfsr : std_logic_vector(15 DOWNTO 15);

COMPONENT hard_block
    PORT (
	devoe : IN std_logic;
	devclrn : IN std_logic;
	devpor : IN std_logic);
END COMPONENT;

BEGIN

ww_clk <= clk;
ww_res_n <= res_n;
ww_load_seed <= load_seed;
ww_seed <= seed;
ww_en <= en;
prdata <= ww_prdata;
ww_devoe <= devoe;
ww_devclrn <= devclrn;
ww_devpor <= devpor;

\clk~inputclkctrl_INCLK_bus\ <= (vcc & vcc & vcc & \clk~input_o\);

\res_n~inputclkctrl_INCLK_bus\ <= (vcc & vcc & vcc & \res_n~input_o\);
\ALT_INV_load_seed~input_o\ <= NOT \load_seed~input_o\;
ALT_INV_lfsr(15) <= NOT lfsr(15);
auto_generated_inst : hard_block
PORT MAP (
	devoe => ww_devoe,
	devclrn => ww_devclrn,
	devpor => ww_devpor);

-- Location: IOOBUF_X65_Y0_N2
\prdata~output\ : cycloneive_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false")
-- pragma translate_on
PORT MAP (
	i => ALT_INV_lfsr(15),
	devoe => ww_devoe,
	o => \prdata~output_o\);

-- Location: IOIBUF_X0_Y36_N15
\clk~input\ : cycloneive_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_clk,
	o => \clk~input_o\);

-- Location: CLKCTRL_G4
\clk~inputclkctrl\ : cycloneive_clkctrl
-- pragma translate_off
GENERIC MAP (
	clock_type => "global clock",
	ena_register_mode => "none")
-- pragma translate_on
PORT MAP (
	inclk => \clk~inputclkctrl_INCLK_bus\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	outclk => \clk~inputclkctrl_outclk\);

-- Location: IOIBUF_X72_Y0_N8
\seed[6]~input\ : cycloneive_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_seed(6),
	o => \seed[6]~input_o\);

-- Location: LCCOMB_X69_Y3_N24
\lfsr[14]~feeder\ : cycloneive_lcell_comb
-- Equation(s):
-- \lfsr[14]~feeder_combout\ = \seed[6]~input_o\

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1111111100000000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	datad => \seed[6]~input_o\,
	combout => \lfsr[14]~feeder_combout\);

-- Location: IOIBUF_X67_Y0_N8
\seed[7]~input\ : cycloneive_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_seed(7),
	o => \seed[7]~input_o\);

-- Location: IOIBUF_X67_Y0_N1
\seed[4]~input\ : cycloneive_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_seed(4),
	o => \seed[4]~input_o\);

-- Location: IOIBUF_X69_Y0_N8
\seed[5]~input\ : cycloneive_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_seed(5),
	o => \seed[5]~input_o\);

-- Location: LCCOMB_X68_Y3_N18
\Equal0~1\ : cycloneive_lcell_comb
-- Equation(s):
-- \Equal0~1_combout\ = (\seed[7]~input_o\) # ((\seed[4]~input_o\) # ((\seed[6]~input_o\) # (\seed[5]~input_o\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1111111111111110",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \seed[7]~input_o\,
	datab => \seed[4]~input_o\,
	datac => \seed[6]~input_o\,
	datad => \seed[5]~input_o\,
	combout => \Equal0~1_combout\);

-- Location: IOIBUF_X67_Y0_N22
\seed[0]~input\ : cycloneive_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_seed(0),
	o => \seed[0]~input_o\);

-- Location: IOIBUF_X69_Y0_N1
\seed[3]~input\ : cycloneive_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_seed(3),
	o => \seed[3]~input_o\);

-- Location: IOIBUF_X65_Y0_N22
\seed[2]~input\ : cycloneive_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_seed(2),
	o => \seed[2]~input_o\);

-- Location: IOIBUF_X72_Y0_N1
\seed[1]~input\ : cycloneive_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_seed(1),
	o => \seed[1]~input_o\);

-- Location: LCCOMB_X68_Y3_N16
\Equal0~0\ : cycloneive_lcell_comb
-- Equation(s):
-- \Equal0~0_combout\ = (\seed[0]~input_o\) # ((\seed[3]~input_o\) # ((\seed[2]~input_o\) # (\seed[1]~input_o\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1111111111111110",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \seed[0]~input_o\,
	datab => \seed[3]~input_o\,
	datac => \seed[2]~input_o\,
	datad => \seed[1]~input_o\,
	combout => \Equal0~0_combout\);

-- Location: LCCOMB_X69_Y3_N26
\lfsr~3\ : cycloneive_lcell_comb
-- Equation(s):
-- \lfsr~3_combout\ = (!\seed[5]~input_o\ & ((\Equal0~1_combout\) # (\Equal0~0_combout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0000000011101110",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \Equal0~1_combout\,
	datab => \Equal0~0_combout\,
	datad => \seed[5]~input_o\,
	combout => \lfsr~3_combout\);

-- Location: LCCOMB_X68_Y3_N30
\Equal0~2\ : cycloneive_lcell_comb
-- Equation(s):
-- \Equal0~2_combout\ = (\Equal0~1_combout\) # (\Equal0~0_combout\)

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1111111111001100",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	datab => \Equal0~1_combout\,
	datad => \Equal0~0_combout\,
	combout => \Equal0~2_combout\);

-- Location: IOIBUF_X65_Y0_N8
\load_seed~input\ : cycloneive_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_load_seed,
	o => \load_seed~input_o\);

-- Location: LCCOMB_X69_Y3_N28
\lfsr[11]~feeder\ : cycloneive_lcell_comb
-- Equation(s):
-- \lfsr[11]~feeder_combout\ = \seed[3]~input_o\

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1010101010101010",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \seed[3]~input_o\,
	combout => \lfsr[11]~feeder_combout\);

-- Location: LCCOMB_X67_Y3_N26
\lfsr~15\ : cycloneive_lcell_comb
-- Equation(s):
-- \lfsr~15_combout\ = lfsr(1) $ (lfsr(2))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0011001111001100",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	datab => lfsr(1),
	datad => lfsr(2),
	combout => \lfsr~15_combout\);

-- Location: LCCOMB_X67_Y3_N28
\ultra_short_polynomial~0\ : cycloneive_lcell_comb
-- Equation(s):
-- \ultra_short_polynomial~0_combout\ = (\load_seed~input_o\ & ((\Equal0~1_combout\) # ((\Equal0~0_combout\)))) # (!\load_seed~input_o\ & (((\ultra_short_polynomial~q\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1111101011011000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \load_seed~input_o\,
	datab => \Equal0~1_combout\,
	datac => \ultra_short_polynomial~q\,
	datad => \Equal0~0_combout\,
	combout => \ultra_short_polynomial~0_combout\);

-- Location: IOIBUF_X0_Y36_N22
\res_n~input\ : cycloneive_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_res_n,
	o => \res_n~input_o\);

-- Location: CLKCTRL_G3
\res_n~inputclkctrl\ : cycloneive_clkctrl
-- pragma translate_off
GENERIC MAP (
	clock_type => "global clock",
	ena_register_mode => "none")
-- pragma translate_on
PORT MAP (
	inclk => \res_n~inputclkctrl_INCLK_bus\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	outclk => \res_n~inputclkctrl_outclk\);

-- Location: FF_X67_Y3_N29
ultra_short_polynomial : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \ultra_short_polynomial~0_combout\,
	clrn => \res_n~inputclkctrl_outclk\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => \ultra_short_polynomial~q\);

-- Location: LCCOMB_X68_Y3_N28
\polynomial_selector[2]~0\ : cycloneive_lcell_comb
-- Equation(s):
-- \polynomial_selector[2]~0_combout\ = (\load_seed~input_o\ & ((\Equal0~1_combout\) # (\Equal0~0_combout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1111000011000000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	datab => \Equal0~1_combout\,
	datac => \load_seed~input_o\,
	datad => \Equal0~0_combout\,
	combout => \polynomial_selector[2]~0_combout\);

-- Location: FF_X68_Y3_N31
\polynomial_selector[0]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	asdata => \seed[6]~input_o\,
	clrn => \res_n~inputclkctrl_outclk\,
	sload => VCC,
	ena => \polynomial_selector[2]~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => polynomial_selector(0));

-- Location: FF_X68_Y3_N9
\polynomial_selector[1]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	asdata => \seed[3]~input_o\,
	clrn => \res_n~inputclkctrl_outclk\,
	sload => VCC,
	ena => \polynomial_selector[2]~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => polynomial_selector(1));

-- Location: LCCOMB_X68_Y3_N10
\Mux0~1\ : cycloneive_lcell_comb
-- Equation(s):
-- \Mux0~1_combout\ = lfsr(14) $ (((!polynomial_selector(0) & lfsr(12))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1010111101010000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => polynomial_selector(0),
	datac => lfsr(12),
	datad => lfsr(14),
	combout => \Mux0~1_combout\);

-- Location: LCCOMB_X68_Y3_N20
\Mux0~2\ : cycloneive_lcell_comb
-- Equation(s):
-- \Mux0~2_combout\ = lfsr(13) $ (((\Mux0~1_combout\ & polynomial_selector(1))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0111011110001000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \Mux0~1_combout\,
	datab => polynomial_selector(1),
	datad => lfsr(13),
	combout => \Mux0~2_combout\);

-- Location: LCCOMB_X68_Y3_N8
\Mux0~3\ : cycloneive_lcell_comb
-- Equation(s):
-- \Mux0~3_combout\ = (polynomial_selector(0) & (lfsr(2) $ (((\Mux0~2_combout\) # (!polynomial_selector(1)))))) # (!polynomial_selector(0) & (\Mux0~2_combout\ $ (((lfsr(2) & !polynomial_selector(1))))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0111001110000110",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => polynomial_selector(0),
	datab => lfsr(2),
	datac => polynomial_selector(1),
	datad => \Mux0~2_combout\,
	combout => \Mux0~3_combout\);

-- Location: LCCOMB_X67_Y3_N2
\Mux0~0\ : cycloneive_lcell_comb
-- Equation(s):
-- \Mux0~0_combout\ = lfsr(0) $ (((polynomial_selector(0) & (lfsr(4))) # (!polynomial_selector(0) & ((lfsr(3))))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0110011000111100",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => lfsr(4),
	datab => lfsr(0),
	datac => lfsr(3),
	datad => polynomial_selector(0),
	combout => \Mux0~0_combout\);

-- Location: LCCOMB_X67_Y3_N12
\Mux0~4\ : cycloneive_lcell_comb
-- Equation(s):
-- \Mux0~4_combout\ = \Mux0~3_combout\ $ (lfsr(15) $ (((!polynomial_selector(1) & !\Mux0~0_combout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0110011001101001",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \Mux0~3_combout\,
	datab => lfsr(15),
	datac => polynomial_selector(1),
	datad => \Mux0~0_combout\,
	combout => \Mux0~4_combout\);

-- Location: FF_X68_Y3_N27
\polynomial_selector[2]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	asdata => \seed[0]~input_o\,
	clrn => \res_n~inputclkctrl_outclk\,
	sload => VCC,
	ena => \polynomial_selector[2]~0_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => polynomial_selector(2));

-- Location: LCCOMB_X67_Y3_N30
\Mux0~5\ : cycloneive_lcell_comb
-- Equation(s):
-- \Mux0~5_combout\ = (polynomial_selector(1) & (lfsr(2) $ (((lfsr(0)))))) # (!polynomial_selector(1) & (((lfsr(14)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0111010010111000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => lfsr(2),
	datab => polynomial_selector(1),
	datac => lfsr(14),
	datad => lfsr(0),
	combout => \Mux0~5_combout\);

-- Location: LCCOMB_X67_Y3_N8
\Mux0~6\ : cycloneive_lcell_comb
-- Equation(s):
-- \Mux0~6_combout\ = lfsr(3) $ (\Mux0~5_combout\ $ (lfsr(15)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1100001100111100",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	datab => lfsr(3),
	datac => \Mux0~5_combout\,
	datad => lfsr(15),
	combout => \Mux0~6_combout\);

-- Location: LCCOMB_X68_Y3_N22
\Mux0~7\ : cycloneive_lcell_comb
-- Equation(s):
-- \Mux0~7_combout\ = (polynomial_selector(0) & ((polynomial_selector(1) & (lfsr(10))) # (!polynomial_selector(1) & ((lfsr(11)))))) # (!polynomial_selector(0) & (((polynomial_selector(1)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1101101011010000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => polynomial_selector(0),
	datab => lfsr(10),
	datac => polynomial_selector(1),
	datad => lfsr(11),
	combout => \Mux0~7_combout\);

-- Location: LCCOMB_X68_Y3_N0
\Mux0~8\ : cycloneive_lcell_comb
-- Equation(s):
-- \Mux0~8_combout\ = \Mux0~6_combout\ $ (((\Mux0~7_combout\) # ((!lfsr(12) & !polynomial_selector(0)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0101101001011001",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \Mux0~6_combout\,
	datab => lfsr(12),
	datac => \Mux0~7_combout\,
	datad => polynomial_selector(0),
	combout => \Mux0~8_combout\);

-- Location: LCCOMB_X68_Y3_N26
\Mux0~9\ : cycloneive_lcell_comb
-- Equation(s):
-- \Mux0~9_combout\ = (polynomial_selector(2) & (\Mux0~4_combout\)) # (!polynomial_selector(2) & ((\Mux0~8_combout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1010111110100000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \Mux0~4_combout\,
	datac => polynomial_selector(2),
	datad => \Mux0~8_combout\,
	combout => \Mux0~9_combout\);

-- Location: LCCOMB_X67_Y3_N16
\lfsr[0]~0\ : cycloneive_lcell_comb
-- Equation(s):
-- \lfsr[0]~0_combout\ = (\ultra_short_polynomial~q\ & ((\Mux0~9_combout\))) # (!\ultra_short_polynomial~q\ & (\lfsr~15_combout\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1110111000100010",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \lfsr~15_combout\,
	datab => \ultra_short_polynomial~q\,
	datad => \Mux0~9_combout\,
	combout => \lfsr[0]~0_combout\);

-- Location: IOIBUF_X67_Y0_N15
\en~input\ : cycloneive_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_en,
	o => \en~input_o\);

-- Location: LCCOMB_X67_Y3_N4
\lfsr[15]~2\ : cycloneive_lcell_comb
-- Equation(s):
-- \lfsr[15]~2_combout\ = (\load_seed~input_o\) # (\en~input_o\)

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1111111111110000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	datac => \load_seed~input_o\,
	datad => \en~input_o\,
	combout => \lfsr[15]~2_combout\);

-- Location: FF_X67_Y3_N17
\lfsr[0]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \lfsr[0]~0_combout\,
	asdata => \Equal0~2_combout\,
	clrn => \res_n~inputclkctrl_outclk\,
	sload => \load_seed~input_o\,
	ena => \lfsr[15]~2_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => lfsr(0));

-- Location: LCCOMB_X67_Y3_N0
\lfsr~14\ : cycloneive_lcell_comb
-- Equation(s):
-- \lfsr~14_combout\ = (!\load_seed~input_o\ & !lfsr(0))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0000000000001111",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	datac => \load_seed~input_o\,
	datad => lfsr(0),
	combout => \lfsr~14_combout\);

-- Location: FF_X67_Y3_N1
\lfsr[1]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \lfsr~14_combout\,
	clrn => \res_n~inputclkctrl_outclk\,
	ena => \lfsr[15]~2_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => lfsr(1));

-- Location: LCCOMB_X67_Y3_N6
\lfsr~13\ : cycloneive_lcell_comb
-- Equation(s):
-- \lfsr~13_combout\ = (!\load_seed~input_o\ & lfsr(1))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0000111100000000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	datac => \load_seed~input_o\,
	datad => lfsr(1),
	combout => \lfsr~13_combout\);

-- Location: FF_X67_Y3_N7
\lfsr[2]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \lfsr~13_combout\,
	clrn => \res_n~inputclkctrl_outclk\,
	ena => \lfsr[15]~2_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => lfsr(2));

-- Location: LCCOMB_X67_Y3_N20
\lfsr~12\ : cycloneive_lcell_comb
-- Equation(s):
-- \lfsr~12_combout\ = (!\load_seed~input_o\ & lfsr(2))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0000111100000000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	datac => \load_seed~input_o\,
	datad => lfsr(2),
	combout => \lfsr~12_combout\);

-- Location: FF_X67_Y3_N21
\lfsr[3]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \lfsr~12_combout\,
	clrn => \res_n~inputclkctrl_outclk\,
	ena => \lfsr[15]~2_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => lfsr(3));

-- Location: LCCOMB_X67_Y3_N10
\lfsr~11\ : cycloneive_lcell_comb
-- Equation(s):
-- \lfsr~11_combout\ = (\load_seed~input_o\ & (((\Equal0~1_combout\) # (\Equal0~0_combout\)))) # (!\load_seed~input_o\ & (!lfsr(3)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1011101110110001",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \load_seed~input_o\,
	datab => lfsr(3),
	datac => \Equal0~1_combout\,
	datad => \Equal0~0_combout\,
	combout => \lfsr~11_combout\);

-- Location: FF_X67_Y3_N11
\lfsr[4]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \lfsr~11_combout\,
	clrn => \res_n~inputclkctrl_outclk\,
	ena => \lfsr[15]~2_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => lfsr(4));

-- Location: LCCOMB_X67_Y3_N24
\lfsr~10\ : cycloneive_lcell_comb
-- Equation(s):
-- \lfsr~10_combout\ = (\load_seed~input_o\ & (((\Equal0~1_combout\) # (\Equal0~0_combout\)))) # (!\load_seed~input_o\ & (!lfsr(4)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1111010111000101",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => lfsr(4),
	datab => \Equal0~1_combout\,
	datac => \load_seed~input_o\,
	datad => \Equal0~0_combout\,
	combout => \lfsr~10_combout\);

-- Location: FF_X67_Y3_N25
\lfsr[5]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \lfsr~10_combout\,
	clrn => \res_n~inputclkctrl_outclk\,
	ena => \lfsr[15]~2_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => lfsr(5));

-- Location: LCCOMB_X67_Y3_N14
\lfsr~9\ : cycloneive_lcell_comb
-- Equation(s):
-- \lfsr~9_combout\ = (\load_seed~input_o\ & (((\Equal0~1_combout\) # (\Equal0~0_combout\)))) # (!\load_seed~input_o\ & (!lfsr(5)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1011101110110001",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \load_seed~input_o\,
	datab => lfsr(5),
	datac => \Equal0~1_combout\,
	datad => \Equal0~0_combout\,
	combout => \lfsr~9_combout\);

-- Location: FF_X67_Y3_N15
\lfsr[6]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \lfsr~9_combout\,
	clrn => \res_n~inputclkctrl_outclk\,
	ena => \lfsr[15]~2_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => lfsr(6));

-- Location: LCCOMB_X68_Y3_N14
\lfsr~8\ : cycloneive_lcell_comb
-- Equation(s):
-- \lfsr~8_combout\ = (\load_seed~input_o\ & (((\Equal0~1_combout\) # (\Equal0~0_combout\)))) # (!\load_seed~input_o\ & (lfsr(6)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1111101011001010",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => lfsr(6),
	datab => \Equal0~1_combout\,
	datac => \load_seed~input_o\,
	datad => \Equal0~0_combout\,
	combout => \lfsr~8_combout\);

-- Location: FF_X68_Y3_N15
\lfsr[7]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \lfsr~8_combout\,
	clrn => \res_n~inputclkctrl_outclk\,
	ena => \lfsr[15]~2_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => lfsr(7));

-- Location: LCCOMB_X68_Y3_N4
\lfsr~7\ : cycloneive_lcell_comb
-- Equation(s):
-- \lfsr~7_combout\ = (\load_seed~input_o\ & (\seed[0]~input_o\)) # (!\load_seed~input_o\ & ((!lfsr(7))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1010001110100011",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \seed[0]~input_o\,
	datab => lfsr(7),
	datac => \load_seed~input_o\,
	combout => \lfsr~7_combout\);

-- Location: FF_X68_Y3_N5
\lfsr[8]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \lfsr~7_combout\,
	clrn => \res_n~inputclkctrl_outclk\,
	ena => \lfsr[15]~2_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => lfsr(8));

-- Location: LCCOMB_X68_Y3_N2
\lfsr~6\ : cycloneive_lcell_comb
-- Equation(s):
-- \lfsr~6_combout\ = (\load_seed~input_o\ & (\Equal0~2_combout\ & ((!\seed[1]~input_o\)))) # (!\load_seed~input_o\ & (((lfsr(8)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0000110010101100",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \Equal0~2_combout\,
	datab => lfsr(8),
	datac => \load_seed~input_o\,
	datad => \seed[1]~input_o\,
	combout => \lfsr~6_combout\);

-- Location: FF_X68_Y3_N3
\lfsr[9]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \lfsr~6_combout\,
	clrn => \res_n~inputclkctrl_outclk\,
	ena => \lfsr[15]~2_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => lfsr(9));

-- Location: LCCOMB_X68_Y3_N24
\lfsr~5\ : cycloneive_lcell_comb
-- Equation(s):
-- \lfsr~5_combout\ = (\load_seed~input_o\ & (\seed[2]~input_o\)) # (!\load_seed~input_o\ & ((lfsr(9))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1010111110100000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \seed[2]~input_o\,
	datac => \load_seed~input_o\,
	datad => lfsr(9),
	combout => \lfsr~5_combout\);

-- Location: FF_X68_Y3_N25
\lfsr[10]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \lfsr~5_combout\,
	clrn => \res_n~inputclkctrl_outclk\,
	ena => \lfsr[15]~2_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => lfsr(10));

-- Location: LCCOMB_X69_Y3_N30
\lfsr[10]~_wirecell\ : cycloneive_lcell_comb
-- Equation(s):
-- \lfsr[10]~_wirecell_combout\ = !lfsr(10)

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0000000011111111",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	datad => lfsr(10),
	combout => \lfsr[10]~_wirecell_combout\);

-- Location: FF_X69_Y3_N29
\lfsr[11]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \lfsr[11]~feeder_combout\,
	asdata => \lfsr[10]~_wirecell_combout\,
	clrn => \res_n~inputclkctrl_outclk\,
	sload => \ALT_INV_load_seed~input_o\,
	ena => \lfsr[15]~2_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => lfsr(11));

-- Location: LCCOMB_X68_Y3_N12
\lfsr~4\ : cycloneive_lcell_comb
-- Equation(s):
-- \lfsr~4_combout\ = (\load_seed~input_o\ & (\Equal0~2_combout\ & (!\seed[4]~input_o\))) # (!\load_seed~input_o\ & (((!lfsr(11)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0010000000101111",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \Equal0~2_combout\,
	datab => \seed[4]~input_o\,
	datac => \load_seed~input_o\,
	datad => lfsr(11),
	combout => \lfsr~4_combout\);

-- Location: FF_X68_Y3_N13
\lfsr[12]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \lfsr~4_combout\,
	clrn => \res_n~inputclkctrl_outclk\,
	ena => \lfsr[15]~2_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => lfsr(12));

-- Location: LCCOMB_X69_Y3_N8
\lfsr[12]~_wirecell\ : cycloneive_lcell_comb
-- Equation(s):
-- \lfsr[12]~_wirecell_combout\ = !lfsr(12)

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0000000011111111",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	datad => lfsr(12),
	combout => \lfsr[12]~_wirecell_combout\);

-- Location: FF_X69_Y3_N27
\lfsr[13]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \lfsr~3_combout\,
	asdata => \lfsr[12]~_wirecell_combout\,
	clrn => \res_n~inputclkctrl_outclk\,
	sload => \ALT_INV_load_seed~input_o\,
	ena => \lfsr[15]~2_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => lfsr(13));

-- Location: FF_X69_Y3_N25
\lfsr[14]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \lfsr[14]~feeder_combout\,
	asdata => lfsr(13),
	clrn => \res_n~inputclkctrl_outclk\,
	sload => \ALT_INV_load_seed~input_o\,
	ena => \lfsr[15]~2_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => lfsr(14));

-- Location: LCCOMB_X67_Y3_N18
\lfsr~1\ : cycloneive_lcell_comb
-- Equation(s):
-- \lfsr~1_combout\ = (\load_seed~input_o\ & ((\seed[7]~input_o\))) # (!\load_seed~input_o\ & (!lfsr(14)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1100010111000101",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => lfsr(14),
	datab => \seed[7]~input_o\,
	datac => \load_seed~input_o\,
	combout => \lfsr~1_combout\);

-- Location: FF_X67_Y3_N19
\lfsr[15]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \lfsr~1_combout\,
	clrn => \res_n~inputclkctrl_outclk\,
	ena => \lfsr[15]~2_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => lfsr(15));

ww_prdata <= \prdata~output_o\;
END structure;


