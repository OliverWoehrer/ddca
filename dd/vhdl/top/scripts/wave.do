onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format logic /top_tb/sram_dq
add wave -noupdate -format logic /top_tb/sram_addr
add wave -noupdate -format logic /top_tb/sram_ub_n
add wave -noupdate -format logic /top_tb/sram_lb_n
add wave -noupdate -format logic /top_tb/sram_we_n
add wave -noupdate -format logic /top_tb/sram_ce_n
add wave -noupdate -format logic /top_tb/sram_oe_n
add wave -noupdate -format logic /top_tb/sclk
add wave -noupdate -format logic /top_tb/sda
add wave -noupdate -format logic /top_tb/scen
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 205
configure wave -valuecolwidth 293
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {15991500 ps}
