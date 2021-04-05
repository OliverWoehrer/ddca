onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /object_collider_tb/CLK_PERIOD
add wave -noupdate /object_collider_tb/DISPLAY_WIDTH
add wave -noupdate /object_collider_tb/DISPLAY_HEIGHT
add wave -noupdate /object_collider_tb/GAME_OBJECTS
add wave -noupdate /object_collider_tb/stop_clock
add wave -noupdate /object_collider_tb/clk
add wave -noupdate /object_collider_tb/res_n
add wave -noupdate -divider {Control signals}
add wave -noupdate /object_collider_tb/start
add wave -noupdate /object_collider_tb/done
add wave -noupdate -divider {Movement parameters}
add wave -noupdate -childformat {{/object_collider_tb/player.x -radix decimal} {/object_collider_tb/player.y -radix decimal} {/object_collider_tb/player.w -radix decimal} {/object_collider_tb/player.h -radix decimal}} -subitemconfig {/object_collider_tb/player.x {-height 16 -radix decimal} /object_collider_tb/player.y {-height 16 -radix decimal} /object_collider_tb/player.w {-height 16 -radix decimal} /object_collider_tb/player.h {-height 16 -radix decimal}} /object_collider_tb/player
add wave -noupdate -radix unsigned /object_collider_tb/player_speed
add wave -noupdate /object_collider_tb/player_dir
add wave -noupdate -radix unsigned /object_collider_tb/gravity
add wave -noupdate /object_collider_tb/apply_movement
add wave -noupdate /object_collider_tb/apply_gravity
add wave -noupdate -divider {Game objects list}
add wave -noupdate -childformat {{/object_collider_tb/object.x -radix decimal} {/object_collider_tb/object.y -radix decimal} {/object_collider_tb/object.w -radix decimal} {/object_collider_tb/object.h -radix decimal}} -subitemconfig {/object_collider_tb/object.x {-height 16 -radix decimal} /object_collider_tb/object.y {-height 16 -radix decimal} /object_collider_tb/object.w {-height 16 -radix decimal} /object_collider_tb/object.h {-height 16 -radix decimal}} /object_collider_tb/object
add wave -noupdate /object_collider_tb/object_req
add wave -noupdate /object_collider_tb/object_valid
add wave -noupdate /object_collider_tb/object_is_blocking
add wave -noupdate /object_collider_tb/object_eol
add wave -noupdate -divider {Collision information}
add wave -noupdate /object_collider_tb/collision_detected
add wave -noupdate -divider {Final player position}
add wave -noupdate -radix decimal /object_collider_tb/player_x
add wave -noupdate -radix decimal /object_collider_tb/player_y
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {26049286 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 189
configure wave -valuecolwidth 167
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
WaveRestoreZoom {0 ps} {59671500 ps}
