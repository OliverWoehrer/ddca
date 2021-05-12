onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format logic -radix unsigned /lcd_graphics_controller_tb/sram_dq_s
add wave -noupdate -format logic -radix hexadecimal /lcd_graphics_controller_tb/sram_addr_s
add wave -noupdate -format logic /lcd_graphics_controller_tb/sram_ub_n_s
add wave -noupdate -format logic /lcd_graphics_controller_tb/sram_lb_n_s
add wave -noupdate -format logic /lcd_graphics_controller_tb/sram_we_n_s
add wave -noupdate -format logic /lcd_graphics_controller_tb/sram_ce_n_s
add wave -noupdate -format logic /lcd_graphics_controller_tb/sram_oe_n_s
add wave -noupdate -format logic /lcd_graphics_controller_tb/clk_s
add wave -noupdate -format logic /lcd_graphics_controller_tb/sda_s
add wave -noupdate -format logic /lcd_graphics_controller_tb/scen_s

add wave -noupdate -format logic /lcd_graphics_controller_tb/write_file_s

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
