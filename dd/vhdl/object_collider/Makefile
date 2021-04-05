

VCOM_ARGS=-2008 -work work -suppress 1236 -novopt
VSIM_ARGS=-msgmode both -novopt

GHDL_ARGS=--std=08 --work=work 
GHDL_ANALYSE=ghdl -a $(GHDL_ARGS)
GHDL_ELABORATE=ghdl -e $(GHDL_ARGS)


VHDL_FILES = \
	./src/object_collider_pkg.vhd\
	./src/object_collider.vhd

TB_FILES = \
	./tb/object_collider_tb.vhd

TB = object_collider_tb
SIM_TIME = -all
TIME_RESOLUTION = 1ps

all: compile

################################################################################
#                                   MODELSIM                                   #
################################################################################
compile: $(VHDL_FILES) $(TB_FILES)
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

sim_gui: compile
	vsim -do "vsim $(TB) -t $(TIME_RESOLUTION) $(VSIM_ARGS); do scripts/wave.do; run $(SIM_TIME)"

sim: compile
	vsim -c -do "vsim $(TB) -t $(TIME_RESOLUTION) $(VSIM_ARGS); run $(SIM_TIME);quit"


################################################################################
#                                     GHDL                                     #
################################################################################
GHDL_OBJECTS=$(VHDL_FILES:.vhd=.o) $(TB_FILES:.vhd=.o)

%.o: %.vhd
	$(GHDL_ANALYSE) $< 

gcompile: $(GHDL_OBJECTS)

gsim: gcompile
	$(GHDL_ELABORATE) $(TB)
	./$(TB)

gsim_gui: gcompile
	ghdl -e --std=08 $(TB)
	./$(TB) --vcd=traces.vcd
	gtkwave traces.vcd &


clean:
	rm -f transcript
	rm -f vsim.wlf
	rm -f log
	rm -fr work
	rm -f *.o
	rm -f *.cf


