onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format logic /prng_tb/clk_s
add wave -noupdate -format logic /prng_tb/res_n_s
add wave -noupdate -format logic /prng_tb/load_seed_s
add wave -noupdate -format logic -radix unsigned /prng_tb/seed_s
add wave -noupdate -format logic /prng_tb/en_s
add wave -noupdate -format logic /prng_tb/prdata_s
add wave -noupdate -format logic /prng_tb/shift_s
add wave -noupdate -format logic -radix hexadecimal /prng_tb/seq
wave zoom range {8000 ps} {350000 ps}
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
