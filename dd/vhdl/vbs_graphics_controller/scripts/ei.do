onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /vbs_graphics_controller_tb/clk_s
add wave -noupdate /vbs_graphics_controller_tb/gfx_instr_s
add wave -noupdate /vbs_graphics_controller_tb/uut/frame_start_s
add wave -noupdate /vbs_graphics_controller_tb/uut/frame_pix_rd_s
add wave -noupdate /vbs_graphics_controller_tb/uut/frame_pix_data_s
add wave -noupdate /vbs_graphics_controller_tb/uut/ei.state
add wave -noupdate /vbs_graphics_controller_tb/uut/ei.clk_cnt
add wave -noupdate /vbs_graphics_controller_tb/uut/ei.pix_cnt
add wave -noupdate /vbs_graphics_controller_tb/uut/ei.frame
add wave -noupdate /vbs_graphics_controller_tb/vga_clk
add wave -noupdate /vbs_graphics_controller_tb/vga_g_s
add wave -noupdate /vbs_graphics_controller_tb/vga_sync_n_s
add wave -noupdate /vbs_graphics_controller_tb/vga_blank_n_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {17869860000 ps} 0} {{Cursor 2} {352100000 ps} 0}
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
WaveRestoreZoom {17497987104 ps} {19103012896 ps}
