VCOM_ARGS=-2008 -work work -suppress 1236
VSIM_ARGS=-msgmode both
TIME_RESOLUTION = 1ps
SIM_TIME = 5us
#########################################################################
# ALU Part
#########################################################################
# The order is important!
ALU_VHDL_FILES = \
	mem_pkg.vhd\
	core_pkg.vhd\
	op_pkg.vhd\
	alu.vhd\

ALU_TB_FILES = \
	./tb/alu_tb.vhd

ALU_TB = alu_tb
ALU_WAVE_FILE = scripts/alu_wave.do

compile_alu: log_alu 

log_alu: $(ALU_VHDL_FILES) $(ALU_TB_FILES)
	rm -f log
	vlib work | tee log
	for i in $(ALU_VHDL_FILES); do \
		vcom $(VCOM_ARGS) $$i | tee -a log;\
	done;
	for i in $(ALU_TB_FILES); do \
		vcom $(VCOM_ARGS) $$i | tee -a log;\
	done;
	@echo "--------------------------------------------------------------"
	@echo "--              Error and Warning Summary                   --"
	@echo "--------------------------------------------------------------"
	@cat log | grep 'Warning\|Error'
	@if [[ $$(grep "Error:" -m 1 log) ]]; then \
		echo "Compilation had errors!" \
		exit 1; \
	fi;

sim_gui_alu: compile_alu
	vsim -do "vsim $(TB) -t $(TIME_RESOLUTION) $(VSIM_ARGS); do $(ALU_WAVE_FILE);run $(SIM_TIME)"

#########################################################################
# MEMU Part
#########################################################################
MEMU_VHDL_FILES = \
	mem_pkg.vhd\
	core_pkg.vhd\
	op_pkg.vhd\
	memu.vhd\

MEMU_TB_FILES = \
	./tb/memu_tb.vhd

MEMU_TB = MEMU_tb
MEMU_WAVE_FILE = scripts/memu_wave.do

compile_memu: log_memu 

log_memu: $(MEMU_VHDL_FILES) $(MEMU_TB_FILES)
	rm -f log
	vlib work | tee log
	for i in $(MEMU_VHDL_FILES); do \
		vcom $(VCOM_ARGS) $$i | tee -a log;\
	done;
	for i in $(MEMU_TB_FILES); do \
		vcom $(VCOM_ARGS) $$i | tee -a log;\
	done;
	@echo "--------------------------------------------------------------"
	@echo "--              Error and Warning Summary                   --"
	@echo "--------------------------------------------------------------"
	@cat log | grep 'Warning\|Error'
	@if [[ $$(grep "Error:" -m 1 log) ]]; then \
		echo "Compilation had errors!" \
		exit 1; \
	fi;

sim_gui_memu: compile_memu
	vsim -do "vsim $(TB) -t $(TIME_RESOLUTION) $(VSIM_ARGS); do $(MEMU_WAVE_FILE);run $(SIM_TIME)"

#########################################################################
# REGFILE Part
#########################################################################
REGFILE_VHDL_FILES = \
	mem_pkg.vhd\
	core_pkg.vhd\
	regfile.vhd\

REGFILE_TB_FILES = \
	./tb/regfile_tb.vhd

REGFILE_TB = regfile_tb
REGFILE_WAVE_FILE = scripts/regfile_wave.do

compile_regfile: log_regfile 

log_regfile: $(REGFILE_VHDL_FILES) $(REGFILE_TB_FILES)
	rm -f log
	vlib work | tee log
	for i in $(REGFILE_VHDL_FILES); do \
		vcom $(VCOM_ARGS) $$i | tee -a log;\
	done;
	for i in $(REGFILE_TB_FILES); do \
		vcom $(VCOM_ARGS) $$i | tee -a log;\
	done;
	@echo "--------------------------------------------------------------"
	@echo "--              Error and Warning Summary                   --"
	@echo "--------------------------------------------------------------"
	@cat log | grep 'Warning\|Error'
	@if [[ $$(grep "Error:" -m 1 log) ]]; then \
		echo "Compilation had errors!" \
		exit 1; \
	fi;

sim_gui_regfile: compile_regfile
	vsim -do "vsim $(TB) -t $(TIME_RESOLUTION) $(VSIM_ARGS); do $(REGFILE_WAVE_FILE);run $(SIM_TIME)"

clean:
	rm -f transcript
	rm -f vsim.wlf
	rm -f log
	rm -fr work

.PHONY: clean
.PHONY: compile_alu
.PHONY: sim_gui_alu
.PHONY: compile_memu
.PHONY: sim_gui_memu
.PHONY: compile_regfile
.PHONY: sim_gui_regfile

