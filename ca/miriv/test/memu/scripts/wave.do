onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/clk
add wave -noupdate /tb/res_n
add wave -noupdate /tb/stop
add wave -noupdate /tb/inp
add wave -noupdate -expand /tb/op
add wave -noupdate -expand -subitemconfig {/tb/outp.M -expand} /tb/outp
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {89414 ps} 0}
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
configure wave -timelineunits ns
update
WaveRestoreZoom {85536 ps} {114464 ps}
