#log compiler messages
rm -f log
vlib work | tee log
vmap work work

vcom -work work -2008 ../../vhdl/mem_pkg.vhd | tee -a log
vcom -work work -2008 ../../vhdl/core_pkg.vhd | tee -a log
vcom -work work -2008 ../../vhdl/op_pkg.vhd | tee -a log
vcom -work work -2008 ../../vhdl/alu.vhd | tee -a log
vcom -work work -2008 ../../vhdl/exec.vhd | tee -a log

# compile testbench ad utility package
vcom -work work -2008 ../tb_util_pkg.vhd | tee -a log
vcom -work work -2008 tb/exec_tb.vhd | tee -a log
