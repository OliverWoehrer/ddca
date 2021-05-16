onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/clk
add wave -noupdate /tb/res_n
add wave -noupdate /tb/stop
add wave -noupdate -divider Input
add wave -noupdate /tb/op
add wave -noupdate -radix hexadecimal /tb/inp.A
add wave -noupdate -radix hexadecimal /tb/inp.B
add wave -noupdate -divider Output
add wave -noupdate -radix hexadecimal -childformat {{/tb/outp.R(31) -radix hexadecimal} {/tb/outp.R(30) -radix hexadecimal} {/tb/outp.R(29) -radix hexadecimal} {/tb/outp.R(28) -radix hexadecimal} {/tb/outp.R(27) -radix hexadecimal} {/tb/outp.R(26) -radix hexadecimal} {/tb/outp.R(25) -radix hexadecimal} {/tb/outp.R(24) -radix hexadecimal} {/tb/outp.R(23) -radix hexadecimal} {/tb/outp.R(22) -radix hexadecimal} {/tb/outp.R(21) -radix hexadecimal} {/tb/outp.R(20) -radix hexadecimal} {/tb/outp.R(19) -radix hexadecimal} {/tb/outp.R(18) -radix hexadecimal} {/tb/outp.R(17) -radix hexadecimal} {/tb/outp.R(16) -radix hexadecimal} {/tb/outp.R(15) -radix hexadecimal} {/tb/outp.R(14) -radix hexadecimal} {/tb/outp.R(13) -radix hexadecimal} {/tb/outp.R(12) -radix hexadecimal} {/tb/outp.R(11) -radix hexadecimal} {/tb/outp.R(10) -radix hexadecimal} {/tb/outp.R(9) -radix hexadecimal} {/tb/outp.R(8) -radix hexadecimal} {/tb/outp.R(7) -radix hexadecimal} {/tb/outp.R(6) -radix hexadecimal} {/tb/outp.R(5) -radix hexadecimal} {/tb/outp.R(4) -radix hexadecimal} {/tb/outp.R(3) -radix hexadecimal} {/tb/outp.R(2) -radix hexadecimal} {/tb/outp.R(1) -radix hexadecimal} {/tb/outp.R(0) -radix hexadecimal}} -subitemconfig {/tb/outp.R(31) {-radix hexadecimal} /tb/outp.R(30) {-radix hexadecimal} /tb/outp.R(29) {-radix hexadecimal} /tb/outp.R(28) {-radix hexadecimal} /tb/outp.R(27) {-radix hexadecimal} /tb/outp.R(26) {-radix hexadecimal} /tb/outp.R(25) {-radix hexadecimal} /tb/outp.R(24) {-radix hexadecimal} /tb/outp.R(23) {-radix hexadecimal} /tb/outp.R(22) {-radix hexadecimal} /tb/outp.R(21) {-radix hexadecimal} /tb/outp.R(20) {-radix hexadecimal} /tb/outp.R(19) {-radix hexadecimal} /tb/outp.R(18) {-radix hexadecimal} /tb/outp.R(17) {-radix hexadecimal} /tb/outp.R(16) {-radix hexadecimal} /tb/outp.R(15) {-radix hexadecimal} /tb/outp.R(14) {-radix hexadecimal} /tb/outp.R(13) {-radix hexadecimal} /tb/outp.R(12) {-radix hexadecimal} /tb/outp.R(11) {-radix hexadecimal} /tb/outp.R(10) {-radix hexadecimal} /tb/outp.R(9) {-radix hexadecimal} /tb/outp.R(8) {-radix hexadecimal} /tb/outp.R(7) {-radix hexadecimal} /tb/outp.R(6) {-radix hexadecimal} /tb/outp.R(5) {-radix hexadecimal} /tb/outp.R(4) {-radix hexadecimal} /tb/outp.R(3) {-radix hexadecimal} /tb/outp.R(2) {-radix hexadecimal} /tb/outp.R(1) {-radix hexadecimal} /tb/outp.R(0) {-radix hexadecimal}} /tb/outp.R
add wave -noupdate /tb/outp.Z
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {160234 ps} 0}
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
WaveRestoreZoom {29250 ps} {176250 ps}
