onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/clk
add wave -noupdate /tb/res_n
add wave -noupdate -color Gold /tb/cache_inst/state
add wave -noupdate -color Gold /tb/cache_inst/state_next
add wave -noupdate -childformat {{/tb/cpu_to_cache.address -radix hexadecimal} {/tb/cpu_to_cache.wrdata -radix hexadecimal}} -expand -subitemconfig {/tb/cpu_to_cache.address {-height 16 -radix hexadecimal} /tb/cpu_to_cache.wrdata {-height 16 -radix hexadecimal}} /tb/cpu_to_cache
add wave -noupdate -childformat {{/tb/cache_to_cpu.rddata -radix hexadecimal}} -expand -subitemconfig {/tb/cache_to_cpu.rddata {-height 16 -radix hexadecimal}} /tb/cache_to_cpu
add wave -noupdate -childformat {{/tb/cache_to_mem.address -radix hexadecimal} {/tb/cache_to_mem.wrdata -radix hexadecimal}} -expand -subitemconfig {/tb/cache_to_mem.address {-height 16 -radix hexadecimal} /tb/cache_to_mem.wrdata {-height 16 -radix hexadecimal}} /tb/cache_to_mem
add wave -noupdate -childformat {{/tb/mem_to_cache.rddata -radix hexadecimal}} -expand -subitemconfig {/tb/mem_to_cache.rddata {-height 16 -radix hexadecimal}} /tb/mem_to_cache
add wave -noupdate -expand -group mgmt_st /tb/cache_inst/mgmt_st_inst/index
add wave -noupdate -expand -group mgmt_st /tb/cache_inst/mgmt_st_inst/wr
add wave -noupdate -expand -group mgmt_st /tb/cache_inst/mgmt_st_inst/rd
add wave -noupdate -expand -group mgmt_st /tb/cache_inst/mgmt_st_inst/valid_in
add wave -noupdate -expand -group mgmt_st /tb/cache_inst/mgmt_st_inst/dirty_in
add wave -noupdate -expand -group mgmt_st /tb/cache_inst/mgmt_st_inst/tag_in
add wave -noupdate -expand -group mgmt_st /tb/cache_inst/mgmt_st_inst/valid_out
add wave -noupdate -expand -group mgmt_st /tb/cache_inst/mgmt_st_inst/dirty_out
add wave -noupdate -expand -group mgmt_st /tb/cache_inst/mgmt_st_inst/tag_out
add wave -noupdate -expand -group mgmt_st /tb/cache_inst/mgmt_st_inst/hit_out
add wave -noupdate -expand -group mgmt_st -expand -group mgmt_st_1w /tb/cache_inst/mgmt_st_inst/mgmt_st_1w_inst/index
add wave -noupdate -expand -group mgmt_st -expand -group mgmt_st_1w /tb/cache_inst/mgmt_st_inst/mgmt_st_1w_inst/we
add wave -noupdate -expand -group mgmt_st -expand -group mgmt_st_1w /tb/cache_inst/mgmt_st_inst/mgmt_st_1w_inst/set_array
add wave -noupdate -expand -group data_st /tb/cache_inst/data_st_inst/we
add wave -noupdate -expand -group data_st /tb/cache_inst/data_st_inst/rd
add wave -noupdate -expand -group data_st /tb/cache_inst/data_st_inst/way
add wave -noupdate -expand -group data_st /tb/cache_inst/data_st_inst/index
add wave -noupdate -expand -group data_st /tb/cache_inst/data_st_inst/byteena
add wave -noupdate -expand -group data_st -expand -group data_st_1w /tb/cache_inst/data_st_inst/data_inst/we
add wave -noupdate -expand -group data_st -expand -group data_st_1w /tb/cache_inst/data_st_inst/data_inst/rd
add wave -noupdate -expand -group data_st -expand -group data_st_1w /tb/cache_inst/data_st_inst/data_inst/index
add wave -noupdate -expand -group data_st -expand -group data_st_1w /tb/cache_inst/data_st_inst/data_inst/byteena
add wave -noupdate -expand -group data_st -expand -group data_st_1w -radix hexadecimal /tb/cache_inst/data_st_inst/data_inst/data_in
add wave -noupdate -expand -group data_st -expand -group data_st_1w -radix hexadecimal /tb/cache_inst/data_st_inst/data_inst/data_out
add wave -noupdate -expand -group data_st -expand -group data_st_1w -radix hexadecimal -childformat {{/tb/cache_inst/data_st_inst/data_inst/ram_inst/ram(0) -radix hexadecimal} {/tb/cache_inst/data_st_inst/data_inst/ram_inst/ram(1) -radix hexadecimal} {/tb/cache_inst/data_st_inst/data_inst/ram_inst/ram(2) -radix hexadecimal} {/tb/cache_inst/data_st_inst/data_inst/ram_inst/ram(3) -radix hexadecimal} {/tb/cache_inst/data_st_inst/data_inst/ram_inst/ram(4) -radix hexadecimal} {/tb/cache_inst/data_st_inst/data_inst/ram_inst/ram(5) -radix hexadecimal} {/tb/cache_inst/data_st_inst/data_inst/ram_inst/ram(6) -radix hexadecimal} {/tb/cache_inst/data_st_inst/data_inst/ram_inst/ram(7) -radix hexadecimal}} -expand -subitemconfig {/tb/cache_inst/data_st_inst/data_inst/ram_inst/ram(0) {-height 16 -radix hexadecimal} /tb/cache_inst/data_st_inst/data_inst/ram_inst/ram(1) {-height 16 -radix hexadecimal} /tb/cache_inst/data_st_inst/data_inst/ram_inst/ram(2) {-height 16 -radix hexadecimal} /tb/cache_inst/data_st_inst/data_inst/ram_inst/ram(3) {-height 16 -radix hexadecimal} /tb/cache_inst/data_st_inst/data_inst/ram_inst/ram(4) {-height 16 -radix hexadecimal} /tb/cache_inst/data_st_inst/data_inst/ram_inst/ram(5) {-height 16 -radix hexadecimal} /tb/cache_inst/data_st_inst/data_inst/ram_inst/ram(6) {-height 16 -radix hexadecimal} /tb/cache_inst/data_st_inst/data_inst/ram_inst/ram(7) {-height 16 -radix hexadecimal}} /tb/cache_inst/data_st_inst/data_inst/ram_inst/ram
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {63059 ps} 0}
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
WaveRestoreZoom {0 ps} {1239 ns}
