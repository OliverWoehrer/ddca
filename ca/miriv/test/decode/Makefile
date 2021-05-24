.PHONY: all clean compile sim sim_gui

all: compile

clean:
	rm -fr work
	rm -f transcript
	rm -f *.wlf
	rm -f modelsim.ini
	rm -f log

compile:
	@vsim -c -do "do scripts/compile.do;quit -f"
	@echo "--------------------------------------------------------------"
	@echo "--              Error and Warning Summary                   --"
	@echo "--------------------------------------------------------------"
	@cat log | grep 'Warning\|Error'
	@if [ $$(grep "Error:" -m 1 log) ]; then \
		echo "Compilation had errors!" \
		exit 1; \
	fi;

sim: compile
	@vsim -c -t ps work.tb -quiet -do "run -all;quit -f" | grep -E "\*\*|Errors"

sim_gui: compile
	@vsim -t ps work.tb -quiet -do "do scripts/wave.do;run -all;wave zoom full"
