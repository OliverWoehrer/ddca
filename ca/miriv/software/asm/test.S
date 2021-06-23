		.text
		.align  2
		.globl  _start

_start:
addi x1, x0, 4
addi x5, x0, 0
addi x6, x0, 0
sw x1, 0(x0)
nop
nop
nop
lw x5, 0(x0)
addi x6, x5, 7

	.end _start
	.size _start, .-_start

