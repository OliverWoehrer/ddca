onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/clk
add wave -noupdate /tb/res_n
add wave -noupdate -color Gold /tb/cache_inst/state
add wave -noupdate -color Gold /tb/cache_inst/state_next
add wave -noupdate /tb/cpu_to_cache
add wave -noupdate /tb/cache_to_cpu
add wave -noupdate /tb/cache_to_mem
add wave -noupdate /tb/mem_to_cache
add wave -noupdate -expand -group mgmt_st /tb/cache_inst/mgmt_st_inst/index
add wave -noupdate -expand -group mgmt_st /tb/cache_inst/mgmt_st_inst/wr
add wave -noupdate -expand -group mgmt_st /tb/cache_inst/mgmt_st_inst/rd
add wave -noupdate -expand -group mgmt_st /tb/cache_inst/mgmt_st_inst/valid_in
add wave -noupdate -expand -group mgmt_st /tb/cache_inst/mgmt_st_inst/dirty_in
add wave -noupdate -expand -group mgmt_st /tb/cache_inst/mgmt_st_inst/tag_in
add wave -noupdate -expand -group mgmt_st /tb/cache_inst/mgmt_st_inst/way_out
add wave -noupdate -expand -group mgmt_st /tb/cache_inst/mgmt_st_inst/valid_out
add wave -noupdate -expand -group mgmt_st /tb/cache_inst/mgmt_st_inst/dirty_out
add wave -noupdate -expand -group mgmt_st /tb/cache_inst/mgmt_st_inst/tag_out
add wave -noupdate -expand -group mgmt_st /tb/cache_inst/mgmt_st_inst/hit_out
add wave -noupdate -expand -group mgmt_st -expand -group mgmt_st_1w /tb/cache_inst/mgmt_st_inst/GEN_MGMT_ST(0)/mgmt_st_1w_inst/SETS_LD
add wave -noupdate -expand -group mgmt_st -expand -group mgmt_st_1w /tb/cache_inst/mgmt_st_inst/GEN_MGMT_ST(0)/mgmt_st_1w_inst/index
add wave -noupdate -expand -group mgmt_st -expand -group mgmt_st_1w /tb/cache_inst/mgmt_st_inst/GEN_MGMT_ST(0)/mgmt_st_1w_inst/we
add wave -noupdate -expand -group mgmt_st -expand -group mgmt_st_1w /tb/cache_inst/mgmt_st_inst/GEN_MGMT_ST(0)/mgmt_st_1w_inst/we_repl
add wave -noupdate -expand -group mgmt_st -expand -group mgmt_st_1w /tb/cache_inst/mgmt_st_inst/GEN_MGMT_ST(0)/mgmt_st_1w_inst/mgmt_info_in
add wave -noupdate -expand -group mgmt_st -expand -group mgmt_st_1w /tb/cache_inst/mgmt_st_inst/GEN_MGMT_ST(0)/mgmt_st_1w_inst/mgmt_info_out
add wave -noupdate -expand -group mgmt_st -expand -group mgmt_st_1w /tb/cache_inst/mgmt_st_inst/GEN_MGMT_ST(0)/mgmt_st_1w_inst/set_array
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {73106 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 176
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {199500 ps}
