onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top_tb/clk
add wave -noupdate -expand /top_tb/hex6
add wave -noupdate -expand /top_tb/hex7
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {950000 ps} 0} {{Cursor 2} {960488 ps} 0} {{Cursor 3} {963017 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {947536 ps} {963944 ps}
