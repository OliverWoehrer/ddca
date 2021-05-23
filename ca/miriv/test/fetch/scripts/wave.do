onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/clk
add wave -noupdate /tb/res_n
add wave -noupdate /tb/stop
add wave -noupdate -divider Global
add wave -noupdate -radix hexadecimal /tb/fetch_inst/pc
add wave -noupdate /tb/fetch_inst/fetch_logic_sync/reset_flag
add wave -noupdate -divider Input
add wave -noupdate -radix hexadecimal /tb/fetch_inst/pc_in
add wave -noupdate -radix hexadecimal /tb/fetch_inst/mem_in.rddata
add wave -noupdate -divider Output
add wave -noupdate -radix hexadecimal /tb/fetch_inst/pc_out
add wave -noupdate -radix hexadecimal /tb/fetch_inst/instr
add wave -noupdate -radix hexadecimal -childformat {{/tb/fetch_inst/mem_out.address(13) -radix hexadecimal} {/tb/fetch_inst/mem_out.address(12) -radix hexadecimal} {/tb/fetch_inst/mem_out.address(11) -radix hexadecimal} {/tb/fetch_inst/mem_out.address(10) -radix hexadecimal} {/tb/fetch_inst/mem_out.address(9) -radix hexadecimal} {/tb/fetch_inst/mem_out.address(8) -radix hexadecimal} {/tb/fetch_inst/mem_out.address(7) -radix hexadecimal} {/tb/fetch_inst/mem_out.address(6) -radix hexadecimal} {/tb/fetch_inst/mem_out.address(5) -radix hexadecimal} {/tb/fetch_inst/mem_out.address(4) -radix hexadecimal} {/tb/fetch_inst/mem_out.address(3) -radix hexadecimal} {/tb/fetch_inst/mem_out.address(2) -radix hexadecimal} {/tb/fetch_inst/mem_out.address(1) -radix hexadecimal} {/tb/fetch_inst/mem_out.address(0) -radix hexadecimal}} -subitemconfig {/tb/fetch_inst/mem_out.address(13) {-radix hexadecimal} /tb/fetch_inst/mem_out.address(12) {-radix hexadecimal} /tb/fetch_inst/mem_out.address(11) {-radix hexadecimal} /tb/fetch_inst/mem_out.address(10) {-radix hexadecimal} /tb/fetch_inst/mem_out.address(9) {-radix hexadecimal} /tb/fetch_inst/mem_out.address(8) {-radix hexadecimal} /tb/fetch_inst/mem_out.address(7) {-radix hexadecimal} /tb/fetch_inst/mem_out.address(6) {-radix hexadecimal} /tb/fetch_inst/mem_out.address(5) {-radix hexadecimal} /tb/fetch_inst/mem_out.address(4) {-radix hexadecimal} /tb/fetch_inst/mem_out.address(3) {-radix hexadecimal} /tb/fetch_inst/mem_out.address(2) {-radix hexadecimal} /tb/fetch_inst/mem_out.address(1) {-radix hexadecimal} /tb/fetch_inst/mem_out.address(0) {-radix hexadecimal}} /tb/fetch_inst/mem_out.address
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {58622 ps} 0}
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
WaveRestoreZoom {22331 ps} {106331 ps}
