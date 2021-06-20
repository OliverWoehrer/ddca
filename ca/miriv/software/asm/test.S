		.text
		.align  2
		.globl  _start

_start:
addi x1, x0, 1
addi x2, x0, 2
or x3, x1, x2
addi x4, x0, 4
nop
nop
nop
add x1,x1,x2
add x1,x1,x3
add x1,x1,x4
nop
nop

	.end _start
	.size _start, .-_start

