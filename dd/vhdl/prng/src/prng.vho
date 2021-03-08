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

-- DATE "03/08/2021 12:55:43"

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
-- prdata	=>  Location: PIN_AF9,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- load_seed	=>  Location: PIN_AB11,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- seed[7]	=>  Location: PIN_AE7,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- clk	=>  Location: PIN_Y2,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- res_n	=>  Location: PIN_Y1,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- en	=>  Location: PIN_AF10,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- seed[6]	=>  Location: PIN_AF8,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- seed[0]	=>  Location: PIN_AE9,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- seed[1]	=>  Location: PIN_AF7,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- seed[2]	=>  Location: PIN_AH8,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- seed[3]	=>  Location: PIN_AE8,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- seed[5]	=>  Location: PIN_AC8,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- seed[4]	=>  Location: PIN_AA8,	 I/O Standard: 2.5 V,	 Current Strength: Default


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
SIGNAL \load_seed~input_o\ : std_logic;
SIGNAL \seed[6]~input_o\ : std_logic;
SIGNAL \lfsr[14]~feeder_combout\ : std_logic;
SIGNAL \seed[4]~input_o\ : std_logic;
SIGNAL \seed[3]~input_o\ : std_logic;
SIGNAL \seed[2]~input_o\ : std_logic;
SIGNAL \seed[1]~input_o\ : std_logic;
SIGNAL \seed[0]~input_o\ : std_logic;
SIGNAL \Equal0~0_combout\ : std_logic;
SIGNAL \seed[5]~input_o\ : std_logic;
SIGNAL \seed[7]~input_o\ : std_logic;
SIGNAL \Equal0~1_combout\ : std_logic;
SIGNAL \lfsr~5_combout\ : std_logic;
SIGNAL \lfsr[11]~feeder_combout\ : std_logic;
SIGNAL \ultra_short_polynomial~0_combout\ : std_logic;
SIGNAL \res_n~input_o\ : std_logic;
SIGNAL \res_n~inputclkctrl_outclk\ : std_logic;
SIGNAL \ultra_short_polynomial~q\ : std_logic;
SIGNAL \polynomial_selector[2]~0_combout\ : std_logic;
SIGNAL \Mux0~7_combout\ : std_logic;
SIGNAL \Mux0~6_combout\ : std_logic;
SIGNAL \Mux0~4_combout\ : std_logic;
SIGNAL \Mux0~5_combout\ : std_logic;
SIGNAL \Mux0~8_combout\ : std_logic;
SIGNAL \Mux0~2_combout\ : std_logic;
SIGNAL \Mux0~0_combout\ : std_logic;
SIGNAL \Mux0~1_combout\ : std_logic;
SIGNAL \Mux0~3_combout\ : std_logic;
SIGNAL \lfsr~17_combout\ : std_logic;
SIGNAL \lfsr~18_combout\ : std_logic;
SIGNAL \en~input_o\ : std_logic;
SIGNAL \lfsr~19_combout\ : std_logic;
SIGNAL \lfsr~20_combout\ : std_logic;
SIGNAL \lfsr~16_combout\ : std_logic;
SIGNAL \lfsr~3_combout\ : std_logic;
SIGNAL \lfsr~15_combout\ : std_logic;
SIGNAL \lfsr~14_combout\ : std_logic;
SIGNAL \lfsr~13_combout\ : std_logic;
SIGNAL \lfsr~12_combout\ : std_logic;
SIGNAL \lfsr~11_combout\ : std_logic;
SIGNAL \lfsr~10_combout\ : std_logic;
SIGNAL \lfsr~9_combout\ : std_logic;
SIGNAL \lfsr~8_combout\ : std_logic;
SIGNAL \lfsr~7_combout\ : std_logic;
SIGNAL \lfsr[10]~_wirecell_combout\ : std_logic;
SIGNAL \lfsr~6_combout\ : std_logic;
SIGNAL \lfsr~4_combout\ : std_logic;
SIGNAL \lfsr~2_combout\ : std_logic;
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

-- Location: IOOBUF_X20_Y0_N2
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

-- Location: IOIBUF_X27_Y0_N8
\load_seed~input\ : cycloneive_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_load_seed,
	o => \load_seed~input_o\);

-- Location: IOIBUF_X23_Y0_N15
\seed[6]~input\ : cycloneive_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_seed(6),
	o => \seed[6]~input_o\);

-- Location: LCCOMB_X23_Y2_N16
\lfsr[14]~feeder\ : cycloneive_lcell_comb
-- Equation(s):
-- \lfsr[14]~feeder_combout\ = \seed[6]~input_o\

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1100110011001100",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	datab => \seed[6]~input_o\,
	combout => \lfsr[14]~feeder_combout\);

-- Location: IOIBUF_X18_Y0_N15
\seed[4]~input\ : cycloneive_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_seed(4),
	o => \seed[4]~input_o\);

-- Location: IOIBUF_X23_Y0_N22
\seed[3]~input\ : cycloneive_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_seed(3),
	o => \seed[3]~input_o\);

-- Location: IOIBUF_X20_Y0_N22
\seed[2]~input\ : cycloneive_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_seed(2),
	o => \seed[2]~input_o\);

-- Location: IOIBUF_X20_Y0_N8
\seed[1]~input\ : cycloneive_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_seed(1),
	o => \seed[1]~input_o\);

-- Location: IOIBUF_X27_Y0_N22
\seed[0]~input\ : cycloneive_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_seed(0),
	o => \seed[0]~input_o\);

-- Location: LCCOMB_X23_Y2_N28
\Equal0~0\ : cycloneive_lcell_comb
-- Equation(s):
-- \Equal0~0_combout\ = (\seed[3]~input_o\) # ((\seed[2]~input_o\) # ((\seed[1]~input_o\) # (\seed[0]~input_o\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1111111111111110",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \seed[3]~input_o\,
	datab => \seed[2]~input_o\,
	datac => \seed[1]~input_o\,
	datad => \seed[0]~input_o\,
	combout => \Equal0~0_combout\);

-- Location: IOIBUF_X18_Y0_N22
\seed[5]~input\ : cycloneive_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_seed(5),
	o => \seed[5]~input_o\);

-- Location: IOIBUF_X20_Y0_N15
\seed[7]~input\ : cycloneive_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_seed(7),
	o => \seed[7]~input_o\);

-- Location: LCCOMB_X23_Y2_N26
\Equal0~1\ : cycloneive_lcell_comb
-- Equation(s):
-- \Equal0~1_combout\ = (\seed[5]~input_o\) # ((\seed[7]~input_o\) # ((\seed[6]~input_o\) # (\seed[4]~input_o\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1111111111111110",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \seed[5]~input_o\,
	datab => \seed[7]~input_o\,
	datac => \seed[6]~input_o\,
	datad => \seed[4]~input_o\,
	combout => \Equal0~1_combout\);

-- Location: LCCOMB_X23_Y2_N0
\lfsr~5\ : cycloneive_lcell_comb
-- Equation(s):
-- \lfsr~5_combout\ = (!\Equal0~0_combout\ & (\load_seed~input_o\ & !\Equal0~1_combout\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0000000001010000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \Equal0~0_combout\,
	datac => \load_seed~input_o\,
	datad => \Equal0~1_combout\,
	combout => \lfsr~5_combout\);

-- Location: LCCOMB_X23_Y2_N10
\lfsr[11]~feeder\ : cycloneive_lcell_comb
-- Equation(s):
-- \lfsr[11]~feeder_combout\ = \seed[3]~input_o\

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1111111100000000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	datad => \seed[3]~input_o\,
	combout => \lfsr[11]~feeder_combout\);

-- Location: LCCOMB_X24_Y2_N22
\ultra_short_polynomial~0\ : cycloneive_lcell_comb
-- Equation(s):
-- \ultra_short_polynomial~0_combout\ = (\load_seed~input_o\ & ((\Equal0~1_combout\) # ((\Equal0~0_combout\)))) # (!\load_seed~input_o\ & (((\ultra_short_polynomial~q\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1110111011110000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \Equal0~1_combout\,
	datab => \Equal0~0_combout\,
	datac => \ultra_short_polynomial~q\,
	datad => \load_seed~input_o\,
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

-- Location: FF_X24_Y2_N23
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

-- Location: LCCOMB_X24_Y2_N18
\polynomial_selector[2]~0\ : cycloneive_lcell_comb
-- Equation(s):
-- \polynomial_selector[2]~0_combout\ = (\load_seed~input_o\ & ((\Equal0~0_combout\) # (\Equal0~1_combout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1111110000000000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	datab => \Equal0~0_combout\,
	datac => \Equal0~1_combout\,
	datad => \load_seed~input_o\,
	combout => \polynomial_selector[2]~0_combout\);

-- Location: FF_X24_Y2_N27
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

-- Location: FF_X24_Y2_N31
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

-- Location: LCCOMB_X24_Y2_N0
\Mux0~7\ : cycloneive_lcell_comb
-- Equation(s):
-- \Mux0~7_combout\ = (polynomial_selector(1) & !polynomial_selector(0))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0000000011001100",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	datab => polynomial_selector(1),
	datad => polynomial_selector(0),
	combout => \Mux0~7_combout\);

-- Location: LCCOMB_X24_Y2_N14
\Mux0~6\ : cycloneive_lcell_comb
-- Equation(s):
-- \Mux0~6_combout\ = (polynomial_selector(1) & (lfsr(13) $ (((lfsr(12)) # (polynomial_selector(0)))))) # (!polynomial_selector(1) & ((lfsr(13)) # ((polynomial_selector(0)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0101111101101010",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => lfsr(13),
	datab => lfsr(12),
	datac => polynomial_selector(1),
	datad => polynomial_selector(0),
	combout => \Mux0~6_combout\);

-- Location: LCCOMB_X24_Y2_N30
\Mux0~4\ : cycloneive_lcell_comb
-- Equation(s):
-- \Mux0~4_combout\ = lfsr(0) $ (((polynomial_selector(0) & (lfsr(4))) # (!polynomial_selector(0) & ((lfsr(3))))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0101001110101100",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => lfsr(4),
	datab => lfsr(3),
	datac => polynomial_selector(0),
	datad => lfsr(0),
	combout => \Mux0~4_combout\);

-- Location: LCCOMB_X24_Y2_N20
\Mux0~5\ : cycloneive_lcell_comb
-- Equation(s):
-- \Mux0~5_combout\ = lfsr(15) $ (((polynomial_selector(1) & ((lfsr(14)))) # (!polynomial_selector(1) & (\Mux0~4_combout\))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0011110001100110",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \Mux0~4_combout\,
	datab => lfsr(15),
	datac => lfsr(14),
	datad => polynomial_selector(1),
	combout => \Mux0~5_combout\);

-- Location: LCCOMB_X24_Y2_N2
\Mux0~8\ : cycloneive_lcell_comb
-- Equation(s):
-- \Mux0~8_combout\ = \Mux0~6_combout\ $ (\Mux0~5_combout\ $ (((!\Mux0~7_combout\ & !lfsr(2)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0011011011001001",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \Mux0~7_combout\,
	datab => \Mux0~6_combout\,
	datac => lfsr(2),
	datad => \Mux0~5_combout\,
	combout => \Mux0~8_combout\);

-- Location: FF_X24_Y2_N25
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

-- Location: LCCOMB_X24_Y2_N8
\Mux0~2\ : cycloneive_lcell_comb
-- Equation(s):
-- \Mux0~2_combout\ = (polynomial_selector(0) & ((polynomial_selector(1) & (lfsr(10))) # (!polynomial_selector(1) & ((lfsr(11)))))) # (!polynomial_selector(0) & (((polynomial_selector(1)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1011101111000000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => lfsr(10),
	datab => polynomial_selector(0),
	datac => lfsr(11),
	datad => polynomial_selector(1),
	combout => \Mux0~2_combout\);

-- Location: LCCOMB_X24_Y2_N26
\Mux0~0\ : cycloneive_lcell_comb
-- Equation(s):
-- \Mux0~0_combout\ = (polynomial_selector(1) & ((lfsr(2) $ (lfsr(0))))) # (!polynomial_selector(1) & (lfsr(14)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0011101011001010",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => lfsr(14),
	datab => lfsr(2),
	datac => polynomial_selector(1),
	datad => lfsr(0),
	combout => \Mux0~0_combout\);

-- Location: LCCOMB_X24_Y2_N4
\Mux0~1\ : cycloneive_lcell_comb
-- Equation(s):
-- \Mux0~1_combout\ = \Mux0~0_combout\ $ (lfsr(15) $ (lfsr(3)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1001011010010110",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \Mux0~0_combout\,
	datab => lfsr(15),
	datac => lfsr(3),
	combout => \Mux0~1_combout\);

-- Location: LCCOMB_X24_Y2_N10
\Mux0~3\ : cycloneive_lcell_comb
-- Equation(s):
-- \Mux0~3_combout\ = \Mux0~1_combout\ $ (((\Mux0~2_combout\) # ((!lfsr(12) & !polynomial_selector(0)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0011110000101101",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => lfsr(12),
	datab => \Mux0~2_combout\,
	datac => \Mux0~1_combout\,
	datad => polynomial_selector(0),
	combout => \Mux0~3_combout\);

-- Location: LCCOMB_X24_Y2_N24
\lfsr~17\ : cycloneive_lcell_comb
-- Equation(s):
-- \lfsr~17_combout\ = (polynomial_selector(2) & (\Mux0~8_combout\)) # (!polynomial_selector(2) & ((\Mux0~3_combout\)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1100111111000000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	datab => \Mux0~8_combout\,
	datac => polynomial_selector(2),
	datad => \Mux0~3_combout\,
	combout => \lfsr~17_combout\);

-- Location: LCCOMB_X24_Y2_N28
\lfsr~18\ : cycloneive_lcell_comb
-- Equation(s):
-- \lfsr~18_combout\ = (\ultra_short_polynomial~q\ & (\lfsr~17_combout\)) # (!\ultra_short_polynomial~q\ & ((lfsr(2) $ (lfsr(1)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1000110111011000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \ultra_short_polynomial~q\,
	datab => \lfsr~17_combout\,
	datac => lfsr(2),
	datad => lfsr(1),
	combout => \lfsr~18_combout\);

-- Location: IOIBUF_X29_Y0_N15
\en~input\ : cycloneive_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_en,
	o => \en~input_o\);

-- Location: LCCOMB_X24_Y2_N6
\lfsr~19\ : cycloneive_lcell_comb
-- Equation(s):
-- \lfsr~19_combout\ = (\en~input_o\ & (\lfsr~18_combout\)) # (!\en~input_o\ & ((lfsr(0))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1100111111000000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	datab => \lfsr~18_combout\,
	datac => \en~input_o\,
	datad => lfsr(0),
	combout => \lfsr~19_combout\);

-- Location: LCCOMB_X24_Y2_N12
\lfsr~20\ : cycloneive_lcell_comb
-- Equation(s):
-- \lfsr~20_combout\ = (\load_seed~input_o\ & (((\Equal0~0_combout\) # (\Equal0~1_combout\)))) # (!\load_seed~input_o\ & (\lfsr~19_combout\))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1111110010101010",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \lfsr~19_combout\,
	datab => \Equal0~0_combout\,
	datac => \Equal0~1_combout\,
	datad => \load_seed~input_o\,
	combout => \lfsr~20_combout\);

-- Location: FF_X24_Y2_N13
\lfsr[0]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \lfsr~20_combout\,
	clrn => \res_n~inputclkctrl_outclk\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => lfsr(0));

-- Location: LCCOMB_X25_Y2_N18
\lfsr~16\ : cycloneive_lcell_comb
-- Equation(s):
-- \lfsr~16_combout\ = (!\load_seed~input_o\ & !lfsr(0))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0000000000001111",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	datac => \load_seed~input_o\,
	datad => lfsr(0),
	combout => \lfsr~16_combout\);

-- Location: LCCOMB_X24_Y2_N16
\lfsr~3\ : cycloneive_lcell_comb
-- Equation(s):
-- \lfsr~3_combout\ = (\en~input_o\) # (\load_seed~input_o\)

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1111111111110000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	datac => \en~input_o\,
	datad => \load_seed~input_o\,
	combout => \lfsr~3_combout\);

-- Location: FF_X25_Y2_N19
\lfsr[1]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \lfsr~16_combout\,
	clrn => \res_n~inputclkctrl_outclk\,
	ena => \lfsr~3_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => lfsr(1));

-- Location: LCCOMB_X25_Y2_N8
\lfsr~15\ : cycloneive_lcell_comb
-- Equation(s):
-- \lfsr~15_combout\ = (!\load_seed~input_o\ & lfsr(1))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0000111100000000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	datac => \load_seed~input_o\,
	datad => lfsr(1),
	combout => \lfsr~15_combout\);

-- Location: FF_X25_Y2_N9
\lfsr[2]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \lfsr~15_combout\,
	clrn => \res_n~inputclkctrl_outclk\,
	ena => \lfsr~3_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => lfsr(2));

-- Location: LCCOMB_X23_Y2_N18
\lfsr~14\ : cycloneive_lcell_comb
-- Equation(s):
-- \lfsr~14_combout\ = (lfsr(2) & !\load_seed~input_o\)

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0000101000001010",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => lfsr(2),
	datac => \load_seed~input_o\,
	combout => \lfsr~14_combout\);

-- Location: FF_X23_Y2_N19
\lfsr[3]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \lfsr~14_combout\,
	clrn => \res_n~inputclkctrl_outclk\,
	ena => \lfsr~3_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => lfsr(3));

-- Location: LCCOMB_X23_Y2_N12
\lfsr~13\ : cycloneive_lcell_comb
-- Equation(s):
-- \lfsr~13_combout\ = (\load_seed~input_o\ & ((\Equal0~0_combout\) # ((\Equal0~1_combout\)))) # (!\load_seed~input_o\ & (((!lfsr(3)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1111001110100011",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \Equal0~0_combout\,
	datab => lfsr(3),
	datac => \load_seed~input_o\,
	datad => \Equal0~1_combout\,
	combout => \lfsr~13_combout\);

-- Location: FF_X23_Y2_N13
\lfsr[4]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \lfsr~13_combout\,
	clrn => \res_n~inputclkctrl_outclk\,
	ena => \lfsr~3_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => lfsr(4));

-- Location: LCCOMB_X23_Y2_N14
\lfsr~12\ : cycloneive_lcell_comb
-- Equation(s):
-- \lfsr~12_combout\ = (\load_seed~input_o\ & ((\Equal0~0_combout\) # ((\Equal0~1_combout\)))) # (!\load_seed~input_o\ & (((!lfsr(4)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1111001110100011",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \Equal0~0_combout\,
	datab => lfsr(4),
	datac => \load_seed~input_o\,
	datad => \Equal0~1_combout\,
	combout => \lfsr~12_combout\);

-- Location: FF_X23_Y2_N15
\lfsr[5]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \lfsr~12_combout\,
	clrn => \res_n~inputclkctrl_outclk\,
	ena => \lfsr~3_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => lfsr(5));

-- Location: LCCOMB_X23_Y2_N6
\lfsr~11\ : cycloneive_lcell_comb
-- Equation(s):
-- \lfsr~11_combout\ = (\load_seed~input_o\ & ((\Equal0~0_combout\) # ((\Equal0~1_combout\)))) # (!\load_seed~input_o\ & (((!lfsr(5)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1111001110100011",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \Equal0~0_combout\,
	datab => lfsr(5),
	datac => \load_seed~input_o\,
	datad => \Equal0~1_combout\,
	combout => \lfsr~11_combout\);

-- Location: FF_X23_Y2_N7
\lfsr[6]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \lfsr~11_combout\,
	clrn => \res_n~inputclkctrl_outclk\,
	ena => \lfsr~3_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => lfsr(6));

-- Location: LCCOMB_X23_Y2_N24
\lfsr~10\ : cycloneive_lcell_comb
-- Equation(s):
-- \lfsr~10_combout\ = (\load_seed~input_o\ & ((\Equal0~1_combout\) # ((\Equal0~0_combout\)))) # (!\load_seed~input_o\ & (((lfsr(6)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1111110110101000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \load_seed~input_o\,
	datab => \Equal0~1_combout\,
	datac => \Equal0~0_combout\,
	datad => lfsr(6),
	combout => \lfsr~10_combout\);

-- Location: FF_X23_Y2_N25
\lfsr[7]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \lfsr~10_combout\,
	clrn => \res_n~inputclkctrl_outclk\,
	ena => \lfsr~3_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => lfsr(7));

-- Location: LCCOMB_X23_Y2_N30
\lfsr~9\ : cycloneive_lcell_comb
-- Equation(s):
-- \lfsr~9_combout\ = (\load_seed~input_o\ & ((\seed[0]~input_o\))) # (!\load_seed~input_o\ & (!lfsr(7)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1111001100000011",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	datab => lfsr(7),
	datac => \load_seed~input_o\,
	datad => \seed[0]~input_o\,
	combout => \lfsr~9_combout\);

-- Location: FF_X23_Y2_N31
\lfsr[8]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \lfsr~9_combout\,
	clrn => \res_n~inputclkctrl_outclk\,
	ena => \lfsr~3_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => lfsr(8));

-- Location: LCCOMB_X23_Y2_N4
\lfsr~8\ : cycloneive_lcell_comb
-- Equation(s):
-- \lfsr~8_combout\ = (!\lfsr~5_combout\ & ((\load_seed~input_o\ & ((!\seed[1]~input_o\))) # (!\load_seed~input_o\ & (lfsr(8)))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0000001100100010",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => lfsr(8),
	datab => \lfsr~5_combout\,
	datac => \seed[1]~input_o\,
	datad => \load_seed~input_o\,
	combout => \lfsr~8_combout\);

-- Location: FF_X23_Y2_N5
\lfsr[9]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \lfsr~8_combout\,
	clrn => \res_n~inputclkctrl_outclk\,
	ena => \lfsr~3_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => lfsr(9));

-- Location: LCCOMB_X23_Y2_N2
\lfsr~7\ : cycloneive_lcell_comb
-- Equation(s):
-- \lfsr~7_combout\ = (\load_seed~input_o\ & (\seed[2]~input_o\)) # (!\load_seed~input_o\ & ((lfsr(9))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1101100011011000",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \load_seed~input_o\,
	datab => \seed[2]~input_o\,
	datac => lfsr(9),
	combout => \lfsr~7_combout\);

-- Location: FF_X23_Y2_N3
\lfsr[10]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \lfsr~7_combout\,
	clrn => \res_n~inputclkctrl_outclk\,
	ena => \lfsr~3_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => lfsr(10));

-- Location: LCCOMB_X21_Y2_N0
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

-- Location: FF_X23_Y2_N11
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
	ena => \lfsr~3_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => lfsr(11));

-- Location: LCCOMB_X23_Y2_N20
\lfsr~6\ : cycloneive_lcell_comb
-- Equation(s):
-- \lfsr~6_combout\ = (!\lfsr~5_combout\ & ((\load_seed~input_o\ & (!\seed[4]~input_o\)) # (!\load_seed~input_o\ & ((!lfsr(11))))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0001000000010011",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \seed[4]~input_o\,
	datab => \lfsr~5_combout\,
	datac => \load_seed~input_o\,
	datad => lfsr(11),
	combout => \lfsr~6_combout\);

-- Location: FF_X23_Y2_N21
\lfsr[12]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \lfsr~6_combout\,
	clrn => \res_n~inputclkctrl_outclk\,
	ena => \lfsr~3_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => lfsr(12));

-- Location: LCCOMB_X23_Y2_N8
\lfsr~4\ : cycloneive_lcell_comb
-- Equation(s):
-- \lfsr~4_combout\ = (\load_seed~input_o\ & (((!\seed[5]~input_o\ & \polynomial_selector[2]~0_combout\)))) # (!\load_seed~input_o\ & (((!\seed[5]~input_o\ & \polynomial_selector[2]~0_combout\)) # (!lfsr(12))))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "0001111100010001",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \load_seed~input_o\,
	datab => lfsr(12),
	datac => \seed[5]~input_o\,
	datad => \polynomial_selector[2]~0_combout\,
	combout => \lfsr~4_combout\);

-- Location: FF_X23_Y2_N9
\lfsr[13]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \lfsr~4_combout\,
	clrn => \res_n~inputclkctrl_outclk\,
	ena => \lfsr~3_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => lfsr(13));

-- Location: FF_X23_Y2_N17
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
	ena => \lfsr~3_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => lfsr(14));

-- Location: LCCOMB_X23_Y2_N22
\lfsr~2\ : cycloneive_lcell_comb
-- Equation(s):
-- \lfsr~2_combout\ = (\load_seed~input_o\ & ((\seed[7]~input_o\))) # (!\load_seed~input_o\ & (!lfsr(14)))

-- pragma translate_off
GENERIC MAP (
	lut_mask => "1011000110110001",
	sum_lutc_input => "datac")
-- pragma translate_on
PORT MAP (
	dataa => \load_seed~input_o\,
	datab => lfsr(14),
	datac => \seed[7]~input_o\,
	combout => \lfsr~2_combout\);

-- Location: FF_X23_Y2_N23
\lfsr[15]\ : dffeas
-- pragma translate_off
GENERIC MAP (
	is_wysiwyg => "true",
	power_up => "low")
-- pragma translate_on
PORT MAP (
	clk => \clk~inputclkctrl_outclk\,
	d => \lfsr~2_combout\,
	clrn => \res_n~inputclkctrl_outclk\,
	ena => \lfsr~3_combout\,
	devclrn => ww_devclrn,
	devpor => ww_devpor,
	q => lfsr(15));

ww_prdata <= \prdata~output_o\;
END structure;


