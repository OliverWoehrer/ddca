onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ssd_controller_tb/clk_s
add wave -noupdate /ssd_controller_tb/res_n_s
add wave -noupdate -radix unsigned /ssd_controller_tb/player_points_s
add wave -noupdate -radix unsigned /ssd_controller_tb/uut/points_display/player_points_old
add wave -noupdate -radix unsigned /ssd_controller_tb/uut/points_display/player_points_temp
add wave -noupdate /ssd_controller_tb/uut/state
add wave -noupdate -radix unsigned /ssd_controller_tb/uut/points_display/thousands
add wave -noupdate -radix unsigned /ssd_controller_tb/uut/points_display/hundreds
add wave -noupdate -radix unsigned /ssd_controller_tb/uut/points_display/tens
add wave -noupdate -radix unsigned /ssd_controller_tb/uut/points_display/digits
add wave -noupdate /ssd_controller_tb/uut/points_display/clk_cnt
add wave -noupdate /ssd_controller_tb/uut/points_display/bli_cnt
add wave -noupdate /ssd_controller_tb/hex0_s
add wave -noupdate /ssd_controller_tb/hex1_s
add wave -noupdate /ssd_controller_tb/hex2_s
add wave -noupdate /ssd_controller_tb/hex3_s

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1368 ns}
