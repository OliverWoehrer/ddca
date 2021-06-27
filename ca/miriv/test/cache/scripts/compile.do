#log compiler messages
rm -f log
vlib work | tee log
vmap work work

vcom -work work -2008 ../../vhdl/mem_pkg.vhd | tee -a log
vcom -work work -2008 ../../vhdl/core_pkg.vhd | tee -a log
vcom -work work -2008 ../../vhdl/op_pkg.vhd | tee -a log
vcom -work work -2008 ../../vhdl/cache/cache_pkg.vhd | tee -a log
vcom -work work -2008 ../../vhdl/cache/ram/single_clock_rw_ram_pkg.vhd | tee -a log
vcom -work work -2008 ../../vhdl/cache/ram/single_clock_rw_ram.vhd | tee -a log
vcom -work work -2008 ../../vhdl/cache/data_st_1w.vhd | tee -a log
vcom -work work -2008 ../../vhdl/cache/data_st.vhd | tee -a log
vcom -work work -2008 ../../vhdl/cache/mgmt_st_1w.vhd | tee -a log
vcom -work work -2008 ../../vhdl/cache/mgmt_st.vhd | tee -a log
vcom -work work -2008 ../../vhdl/cache/cache.vhd | tee -a log

# compile testbench ad utility package
vcom -work work -2008 ../tb_util_pkg.vhd | tee -a log
vcom -work work -2008 tb/cache_tb.vhd | tee -a log
