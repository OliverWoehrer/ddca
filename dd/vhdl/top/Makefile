

VCOM_ARGS=-2008 -work work -suppress 1236
VSIM_ARGS=-msgmode both

# The order is important!
VHDL_FILES = \
	../synchronizer/src/sync.vhd\
	../synchronizer/src/sync_pkg.vhd\
	../prng/src/prng.vho\
	../prng/src/prng_pkg.vhd\
	../nes_controller/src/nes_controller_pkg.vhd\
	../math/src/math_pkg.vhd\
	../lcd_graphics_controller/src/gfx_if_pkg.vhd\
	../lcd_graphics_controller/src/lcd_graphics_controller.vho\
	../lcd_graphics_controller/src/lcd_graphics_controller_pkg.vhd\
	../lcd_graphics_controller/tb/sram.vhd\
	../display_switch/src/display_switch_pkg.vhd\
	../dbg_port/src/dbg_port_pkg.vhd\
	../dbg_port/src/dbg_port_top.vho\
	../audio_cntrl/src/audio_cntrl_pkg.vhd\
	../audio_cntrl/src/audio_cntrl_top.vho\
	../ball_game/src/ball_game_pkg.vhd\
	../audio_cntrl/src/audio_cntrl_2s.vhd\
	../display_switch/src/display_switch.vhd\
	../dbg_port/src/dbg_port.vhd\
	../ball_game/src/ball_game.vhd\
	../ball_game/src/ball_game_ex1.vhd\
	../ssd_controller/src/ssd_controller.vhd\
	../ssd_controller/src/ssd_controller_pkg.vhd\
	./src/pll.vhd\
	./src/top.vhd\
	


# Files for post layout simulation
SDO_FILE=./quartus/simulation/modelsim/top_vhd.sdo
VHO_FILE=./quartus/simulation/modelsim/top.vho

TB_FILES = \
	./tb/top_tb.vhd

TIME_RESOLUTION = 1ps
TB = top_tb

# For the pimulation time -all can also be selected. Questa then simulates until no more singal changes occour.
SIM_TIME = 5 us
WAVE_FILE_SRAM = scripts/wave.do
WAVE_FILE_HEX = scripts/wave_hex.do

compile: log

log: $(VHDL_FILES) $(TB_FILES)
	rm -f log
	vlib work | tee log
	for i in $(VHDL_FILES); do \
		vcom $(VCOM_ARGS) $$i | tee -a log;\
	done;
	for i in $(TB_FILES); do \
		vcom $(VCOM_ARGS) $$i | tee -a log;\
	done;
	@echo "--------------------------------------------------------------"
	@echo "--              Error and Warning Summary                   --"
	@echo "--------------------------------------------------------------"
	@cat log | grep 'Warning\|Error'
	@if [ $$(grep "Error:" -m 1 log) ]; then \
		echo "Compilation had errors!" \
		exit 1; \
	fi;

list_sources:
	@for i in $(VHDL_FILES) $(TB_FILES); do \
		echo $$i;\
	done;

sim_gui: compile
	vsim -do "vsim $(TB) -t $(TIME_RESOLUTION) $(VSIM_ARGS); do $(WAVE_FILE);run $(SIM_TIME)" 

sim_post:
	vlib work
	vcom $(VCOM_ARGS) $(VHO_FILE)
	vcom $(VCOM_ARGS) $(TB_FILES)
	vsim -do "vsim work.$(TB) -sdftyp uut=$(SDO_FILE); do $(WAVE_FILE_HEX); run $(SIM_TIME)"

clean:
	rm -f transcript
	rm -f vsim.wlf
	rm -f log
	rm -fr work

.PHONY: clean
.PHONY: compile
.PHONY: sim_fifo
.PHONY: sim_fifo_cl



