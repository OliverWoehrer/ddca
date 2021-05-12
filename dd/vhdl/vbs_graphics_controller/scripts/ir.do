onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /vbs_graphics_controller_tb/clk_s
add wave -noupdate /vbs_graphics_controller_tb/gfx_instr_s
add wave -noupdate /vbs_graphics_controller_tb/uut/ir.state
add wave -noupdate /vbs_graphics_controller_tb/uut/instr_fifo_s
add wave -noupdate -radix decimal /vbs_graphics_controller_tb/uut/vram_wr_addr
add wave -noupdate /vbs_graphics_controller_tb/uut/vram_wr_data
add wave -noupdate /vbs_graphics_controller_tb/uut/ir.db
add wave -noupdate /vbs_graphics_controller_tb/uut/ir.ba
add wave -noupdate -radix decimal /vbs_graphics_controller_tb/uut/vram_base_addr_s
add wave -noupdate -radix decimal /vbs_graphics_controller_tb/uut/vram_rd_addr_s
add wave -noupdate /vbs_graphics_controller_tb/uut/vram_rd_data_s
add wave -noupdate /vbs_graphics_controller_tb/uut/frame_start_s
add wave -noupdate /vbs_graphics_controller_tb/uut/frame_pix_rd_s
add wave -noupdate /vbs_graphics_controller_tb/uut/frame_pix_data_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3900280000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 186
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
WaveRestoreZoom {62253417540 ps} {62253967498 ps}
