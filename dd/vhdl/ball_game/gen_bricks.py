#!/bin/env python3

import random

BLOCK_WIDTH = 16
DISPLAY_WIDTH = 400

cur_x = random.randrange(0,3)*BLOCK_WIDTH
while (True):
	width = random.randrange(1,10)*BLOCK_WIDTH
	if(cur_x + width >= DISPLAY_WIDTH):
		width = DISPLAY_WIDTH - cur_x
	
	print("Brick: x=" + str(cur_x) + ", width=" + str(width))
	
	cur_x += width + random.randrange(2,5)*BLOCK_WIDTH
	if(cur_x >= DISPLAY_WIDTH):
		break
