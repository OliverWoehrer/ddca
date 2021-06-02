		.text
		.align  2
		.globl  _start

_start:
		addi x5, x0, 4
		addi x20, x20, 1
		nop
		nop
		sll x20, x20, x5
		nop
		nop		
		addi x20, x20, 2
		nop
		nop
		sll x20, x20, x5
		nop
		nop
		addi x20, x20, 3
		nop
		nop
		sll x20, x20, x5
		nop
		nop
		addi x20, x20, 5
		nop
		nop
		sll x20, x20, x5
		nop
		nop
		addi x20, x20, 6
		nop
		nop
		sll x20, x20, x5
		nop
		nop
		addi x20, x20, 7
		nop
		nop
		sll x20, x20, x5
		nop
		nop
		addi x20, x20, 8
		nop
		nop
		sll x20, x20, x5
		nop
		nop
		addi x20, x20, 9
		nop
		nop
		nop
		nop
		sw x20, 0(x0)
		lb x21, 0(x0)
		lh x22, 0(x0)	
		lw x23, 0(x0)
		lbu x24, 0(x0)
		lhu x25, 0(x0)

		.end _start
		.size _start, .-_start

