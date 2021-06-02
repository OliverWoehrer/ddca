onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_cpu/dut/pipeline_inst/clk
add wave -noupdate /tb_cpu/dut/pipeline_inst/res_n
add wave -noupdate -divider -height 40 fetch
add wave -noupdate -group fetch /tb_cpu/dut/pipeline_inst/fetch_inst/stall
add wave -noupdate -group fetch /tb_cpu/dut/pipeline_inst/fetch_inst/flush
add wave -noupdate -group fetch -radix hexadecimal /tb_cpu/dut/pipeline_inst/fetch_inst/pc_in
add wave -noupdate -group fetch /tb_cpu/dut/pipeline_inst/fetch_inst/pcsrc
add wave -noupdate -group fetch -childformat {{/tb_cpu/dut/pipeline_inst/fetch_inst/mem_in.rddata -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/fetch_inst/mem_in.rddata {-height 16 -radix hexadecimal}} /tb_cpu/dut/pipeline_inst/fetch_inst/mem_in
add wave -noupdate -group fetch -radix hexadecimal /tb_cpu/dut/pipeline_inst/fetch_inst/instr
add wave -noupdate -group fetch /tb_cpu/dut/pipeline_inst/fetch_inst/mem_busy
add wave -noupdate -group fetch -radix hexadecimal /tb_cpu/dut/pipeline_inst/fetch_inst/pc_s
add wave -noupdate -group fetch -color Magenta -itemcolor Magenta -radix hexadecimal /tb_cpu/dut/pipeline_inst/fetch_inst/pc_new
add wave -noupdate -group fetch -radix hexadecimal /tb_cpu/dut/pipeline_inst/fetch_inst/pc_out
add wave -noupdate -group fetch -childformat {{/tb_cpu/dut/pipeline_inst/fetch_inst/mem_out.address -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/mem_out.wrdata -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/fetch_inst/mem_out.address {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/mem_out.wrdata {-height 16 -radix hexadecimal}} /tb_cpu/dut/pipeline_inst/fetch_inst/mem_out
add wave -noupdate -divider -height 40 decode
add wave -noupdate -group decode /tb_cpu/dut/pipeline_inst/decode_inst/stall
add wave -noupdate -group decode /tb_cpu/dut/pipeline_inst/decode_inst/flush
add wave -noupdate -group decode -radix hexadecimal /tb_cpu/dut/pipeline_inst/decode_inst/instr
add wave -noupdate -group decode -radix hexadecimal /tb_cpu/dut/pipeline_inst/decode_inst/pc_in
add wave -noupdate -group decode -childformat {{/tb_cpu/dut/pipeline_inst/decode_inst/reg_write.reg -radix unsigned} {/tb_cpu/dut/pipeline_inst/decode_inst/reg_write.data -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/decode_inst/reg_write.reg {-height 16 -radix unsigned} /tb_cpu/dut/pipeline_inst/decode_inst/reg_write.data {-height 16 -radix hexadecimal}} /tb_cpu/dut/pipeline_inst/decode_inst/reg_write
add wave -noupdate -group decode -childformat {{/tb_cpu/dut/pipeline_inst/decode_inst/exec_op.rs1 -radix unsigned} {/tb_cpu/dut/pipeline_inst/decode_inst/exec_op.rs2 -radix unsigned} {/tb_cpu/dut/pipeline_inst/decode_inst/exec_op.readdata1 -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/decode_inst/exec_op.readdata2 -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/decode_inst/exec_op.imm -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/decode_inst/exec_op.rs1 {-height 16 -radix unsigned} /tb_cpu/dut/pipeline_inst/decode_inst/exec_op.rs2 {-height 16 -radix unsigned} /tb_cpu/dut/pipeline_inst/decode_inst/exec_op.readdata1 {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/decode_inst/exec_op.readdata2 {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/decode_inst/exec_op.imm {-height 16 -radix hexadecimal}} /tb_cpu/dut/pipeline_inst/decode_inst/exec_op
add wave -noupdate -group decode /tb_cpu/dut/pipeline_inst/decode_inst/opcode
add wave -noupdate -group decode /tb_cpu/dut/pipeline_inst/decode_inst/mem_op
add wave -noupdate -group decode /tb_cpu/dut/pipeline_inst/decode_inst/wb_op
add wave -noupdate -group decode -radix hexadecimal /tb_cpu/dut/pipeline_inst/decode_inst/pc_out
add wave -noupdate -group decode -radix hexadecimal /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(1)
add wave -noupdate -group decode /tb_cpu/dut/pipeline_inst/decode_inst/exc_dec
add wave -noupdate -radix hexadecimal -childformat {{/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(31) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(30) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(29) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(28) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(27) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(26) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(25) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(24) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(23) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(22) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(21) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(20) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(19) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(18) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(17) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(16) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(15) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(14) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(13) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(12) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(11) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(10) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(9) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(8) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(7) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(6) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(5) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(4) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(3) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(2) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(1) -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(0) -radix hexadecimal}} -subitemconfig {/tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(31) {-radix hexadecimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(30) {-radix hexadecimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(29) {-radix hexadecimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(28) {-radix hexadecimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(27) {-radix hexadecimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(26) {-radix hexadecimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(25) {-radix hexadecimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(24) {-radix hexadecimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(23) {-radix hexadecimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(22) {-radix hexadecimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(21) {-radix hexadecimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(20) {-radix hexadecimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(19) {-radix hexadecimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(18) {-radix hexadecimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(17) {-radix hexadecimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(16) {-radix hexadecimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(15) {-radix hexadecimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(14) {-radix hexadecimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(13) {-radix hexadecimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(12) {-radix hexadecimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(11) {-radix hexadecimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(10) {-radix hexadecimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(9) {-radix hexadecimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(8) {-radix hexadecimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(7) {-radix hexadecimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(6) {-radix hexadecimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(5) {-radix hexadecimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(4) {-radix hexadecimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(3) {-radix hexadecimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(2) {-radix hexadecimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(1) {-radix hexadecimal} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1(0) {-radix hexadecimal}} /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/reg1
add wave -noupdate -divider -height 40 exec
add wave -noupdate -group exec /tb_cpu/dut/pipeline_inst/execute_inst/stall
add wave -noupdate -group exec /tb_cpu/dut/pipeline_inst/execute_inst/flush
add wave -noupdate -group exec -childformat {{/tb_cpu/dut/pipeline_inst/execute_inst/op.rs1 -radix unsigned} {/tb_cpu/dut/pipeline_inst/execute_inst/op.rs2 -radix unsigned} {/tb_cpu/dut/pipeline_inst/execute_inst/op.readdata1 -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/execute_inst/op.readdata2 -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/execute_inst/op.imm -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/execute_inst/op.rs1 {-height 16 -radix unsigned} /tb_cpu/dut/pipeline_inst/execute_inst/op.rs2 {-height 16 -radix unsigned} /tb_cpu/dut/pipeline_inst/execute_inst/op.readdata1 {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/execute_inst/op.readdata2 {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/execute_inst/op.imm {-height 16 -radix hexadecimal}} /tb_cpu/dut/pipeline_inst/execute_inst/op
add wave -noupdate -group exec -radix hexadecimal /tb_cpu/dut/pipeline_inst/execute_inst/pc_in
add wave -noupdate -group exec -childformat {{/tb_cpu/dut/pipeline_inst/execute_inst/reg_write_mem.reg -radix unsigned} {/tb_cpu/dut/pipeline_inst/execute_inst/reg_write_mem.data -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/execute_inst/reg_write_mem.reg {-height 16 -radix unsigned} /tb_cpu/dut/pipeline_inst/execute_inst/reg_write_mem.data {-height 16 -radix hexadecimal}} /tb_cpu/dut/pipeline_inst/execute_inst/reg_write_mem
add wave -noupdate -group exec /tb_cpu/dut/pipeline_inst/execute_inst/reg_write_wr
add wave -noupdate -group exec -radix hexadecimal /tb_cpu/dut/pipeline_inst/execute_inst/pc_s
add wave -noupdate -group exec -radix hexadecimal /tb_cpu/dut/pipeline_inst/execute_inst/pc_new_out
add wave -noupdate -group exec -radix hexadecimal /tb_cpu/dut/pipeline_inst/execute_inst/pc_old_out
add wave -noupdate -group exec -radix hexadecimal /tb_cpu/dut/pipeline_inst/execute_inst/aluresult
add wave -noupdate -group exec /tb_cpu/dut/pipeline_inst/execute_inst/zero
add wave -noupdate -group exec -radix hexadecimal /tb_cpu/dut/pipeline_inst/execute_inst/wrdata
add wave -noupdate -divider -height 40 mem
add wave -noupdate -group mem /tb_cpu/dut/pipeline_inst/memory_inst/stall
add wave -noupdate -group mem /tb_cpu/dut/pipeline_inst/memory_inst/flush
add wave -noupdate -group mem /tb_cpu/dut/pipeline_inst/memory_inst/mem_op
add wave -noupdate -group mem /tb_cpu/dut/pipeline_inst/memory_inst/zero
add wave -noupdate -group mem -radix hexadecimal /tb_cpu/dut/pipeline_inst/memory_inst/wrdata
add wave -noupdate -group mem /tb_cpu/dut/pipeline_inst/memory_inst/mem_busy
add wave -noupdate -group mem -radix hexadecimal /tb_cpu/dut/pipeline_inst/memory_inst/memresult
add wave -noupdate -group mem -radix hexadecimal /tb_cpu/dut/pipeline_inst/memory_inst/pc_new_in
add wave -noupdate -group mem -radix hexadecimal /tb_cpu/dut/pipeline_inst/memory_inst/pc_new_out
add wave -noupdate -group mem -radix hexadecimal /tb_cpu/dut/pipeline_inst/memory_inst/pc_old_in
add wave -noupdate -group mem -radix hexadecimal /tb_cpu/dut/pipeline_inst/memory_inst/pc_old_out
add wave -noupdate -group mem /tb_cpu/dut/pipeline_inst/memory_inst/pcsrc
add wave -noupdate -group mem /tb_cpu/dut/pipeline_inst/memory_inst/reg_write
add wave -noupdate -group mem -childformat {{/tb_cpu/dut/pipeline_inst/memory_inst/mem_in.rddata -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/memory_inst/mem_in.rddata {-height 16 -radix hexadecimal}} /tb_cpu/dut/pipeline_inst/memory_inst/mem_in
add wave -noupdate -group mem -childformat {{/tb_cpu/dut/pipeline_inst/memory_inst/mem_out.address -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/memory_inst/mem_out.wrdata -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/memory_inst/mem_out.address {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/memory_inst/mem_out.wrdata {-height 16 -radix hexadecimal}} /tb_cpu/dut/pipeline_inst/memory_inst/mem_out
add wave -noupdate -divider -height 40 wb
add wave -noupdate -group wb /tb_cpu/dut/pipeline_inst/writeback_inst/stall
add wave -noupdate -group wb /tb_cpu/dut/pipeline_inst/writeback_inst/flush
add wave -noupdate -group wb /tb_cpu/dut/pipeline_inst/writeback_inst/op
add wave -noupdate -group wb -radix hexadecimal /tb_cpu/dut/pipeline_inst/writeback_inst/aluresult
add wave -noupdate -group wb -radix hexadecimal /tb_cpu/dut/pipeline_inst/writeback_inst/memresult
add wave -noupdate -group wb -radix hexadecimal /tb_cpu/dut/pipeline_inst/writeback_inst/pc_old_in
add wave -noupdate -group wb -childformat {{/tb_cpu/dut/pipeline_inst/writeback_inst/reg_write.reg -radix unsigned} {/tb_cpu/dut/pipeline_inst/writeback_inst/reg_write.data -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/writeback_inst/reg_write.reg {-height 16 -radix unsigned} /tb_cpu/dut/pipeline_inst/writeback_inst/reg_write.data {-height 16 -radix hexadecimal}} /tb_cpu/dut/pipeline_inst/writeback_inst/reg_write
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {31823 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 226
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
configure wave -timelineunits us
update
WaveRestoreZoom {0 ps} {5312329 ps}
