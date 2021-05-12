onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /nes_controller_tb/clk_s
add wave -noupdate /nes_controller_tb/res_n_s
add wave -noupdate /nes_controller_tb/nes_latch_s
add wave -noupdate /nes_controller_tb/nes_clk_s
add wave -noupdate /nes_controller_tb/nes_data_s
add wave -noupdate /nes_controller_tb/button_state_s
add wave -noupdate /nes_controller_tb/uut/button_state_next
add wave -noupdate /nes_controller_tb/uut/fsm/clk_cnt
add wave -noupdate /nes_controller_tb/uut/fsm/bit_cnt
add wave -noupdate /nes_controller_tb/uut/shiftreg
add wave -noupdate /nes_controller_tb/uut/state
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
