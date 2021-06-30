		.text
		.align  2
		.globl  _start

_start:
addi x2, x0, 72		#init addr x12
addi x3, x0, 136	#init addr x22
addi x6, x0, 88		#init addr x16
addi x7, x0, 152	#init addr x26
addi x10, x0, 10	# value x0A
addi x11, x0, 11	# value x0B
addi x12, x0, 12	# value x0C
addi x20, x0, 170	# value xAA
addi x21, x0, 187	# value xBB
addi x22, x0, 204	# value xCC
sw x10, 0(x2)	# init memory with value 0x0A
sw x11, 0(x6)	# init memory with value 0x0B
sw x12, 0(x3)	# init memory with value 0x0C
nop
nop
nop
nop
nop #the actual work starts here:
lw x13, 0(x2)	#read miss 0x12
lw x15, 0(x6)	#read miss 0x16
lw x13, 0(x2)	#read hit 0x12
lw x14, 0(x3)	#read miss 0x22
nop
nop
nop
sw x21, 0(x6)	#write hit 0x16
lw x15, 0(x6)	#read hit 0x16
sw x22, 0(x7)	#write miss 0x26
lw x16, 0(x7)	#read miss 0x26
sw x22, 0(x7)	#write hit 0x26
lw x15, 0(x6)	#read miss 0x16
nop
nop
nop

.end _start
.size _start, .-_start
