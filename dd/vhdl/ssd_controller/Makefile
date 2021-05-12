# Makefile for LCD graphics controller
VCOM_ARGS=-2008 -work work -suppress 1236
VSIM_ARGS=-msgmode both

# The order is important!
VHDL_FILES = \
	../audio_cntrl/src/audio_cntrl_pkg.vhd\
	../nes_controller/src/nes_controller_pkg.vhd\
	../ball_game/src/ball_game_pkg.vhd\
	./src/ssd_controller_pkg.vhd\
	./src/ssd_controller.vhd\
	
	

# Files for post layout simulation
SDO_FILE=
VHO_FILE=

TB_FILES = \
	./tb/ssd_controller_tb.vhd

TIME_RESOLUTION = 1ps
TB = ssd_controller_tb

# For the pimulation time -all can also be selected. Questa then simulates until no more singal changes occour.
SIM_TIME = -all
WAVE_FILE_SRAM = scripts/ssd.do

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

sim: compile
	vsim -c -do "vsim $(TB) -t $(TIME_RESOLUTION) $(VSIM_ARGS);do scripts/ssd.do;run $(SIM_TIME);quit" 

sim_gui: compile
	vsim -do "vsim $(TB) -t $(TIME_RESOLUTION) $(VSIM_ARGS); do scripts/ssd.do; run $(SIM_TIME)" 

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
	rm -f *.ppm

.PHONY: clean
.PHONY: compile
.PHONY: sim_fifo
.PHONY: sim_fifo_cl



