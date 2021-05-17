#log compiler messages
rm -f log
vlib work | tee log
vmap work work

vcom -work work -2008 ../../vhdl/mem_pkg.vhd  | tee -a log
vcom -work work -2008 ../../vhdl/core_pkg.vhd  | tee -a log
vcom -work work -2008 ../../vhdl/op_pkg.vhd  | tee -a log
vcom -work work -2008 ../../vhdl/regfile.vhd  | tee -a log

# compile testbench ad utility package
vcom -work work -2008 ../tb_util_pkg.vhd | tee -a log
vcom -work work -2008 tb/regfile_tb.vhd | tee -a log
