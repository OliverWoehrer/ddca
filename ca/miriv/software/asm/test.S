		.text
		.align  2
		.globl  _start

_start:
        addi x5, x0, 0
        addi x6, x0, 3
        addi x7, x0, 0
	nop
	nop	
	sw x6, 28(x0)
	nop
	nop
loop:
	addi x5, x5, 1
	beq x5, x6, end
	lw x23, 28(x0)
    	nop
	nop
	nop
	jal x0, loop
	nop
	nop
	nop
end:
	addi x7, x0, 1
        nop
        nop

	.end _start
	.size _start, .-_start

