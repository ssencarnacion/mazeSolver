# CS 21 Lab 2 -- S2 AY 2021-2022
# Stephen Mary S. Encarnacion -- 08/25/2022
# 202002988.asm


###############################
.eqv start, $s5
.eqv end, $s6
.eqv board, $s7
.eqv bfsboard, $t5

.macro save_register
	addi $sp, $sp, -24
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw board, 16($sp)
	sw bfsboard, 20($sp)
.end_macro

	
.macro restore_register
	lw bfsboard, 20($sp)
	lw board, 16($sp)	
	lw $s3, 12($sp)
	lw $s2, 8($sp)
	lw $s1, 4($sp)
	lw $s0, 0($sp)
	addi $sp, $sp, 24	
.end_macro
			
.macro exit #ends the program
	li 	$v0, 10
	syscall
.end_macro

.macro newline #prints a newline
	li 	$a0, 0xA
	li 	$v0, 11
	syscall
.end_macro

.macro read_str # reads input 
	li $v0, 8
	la $a0, line
	li $a1, 20
	syscall
.end_macro	

.macro print_char(%n)
	addi 	$a0, %n, 0
	li	$v0, 11
	syscall
.end_macro

.macro print_int(%n)
	addi 	$a0, %n, 0
	li	$v0, 1
	syscall
	
.end_macro

################################	

.text
main:
	
	la board, input_board #set the address of our array
	move $t2, board #we save the address of the array so that we can traverse through it
	#run the input function 6 times, thus filling the array with 108 elements
	jal input
	jal input
	jal input
	jal input
	jal input
	jal input
	
	la bfsboard, bfs_board
	li $t0, 432 #the difference between bfs_board and input_board
	move $t1, start
	add $t0, $t0, $t1
	
	#we go to the starting point in the bfs board, and initialize it to 1
	addi $s1, $0, 1
	sw $s1, ($t0)
	
	#explore the bfs board
	li $a0, 0
	
	li $t0, 432 #the difference between bfs_board and input_board
	move $t1, end 
	add $t0, $t0, $t1 #store the ending point of bfs_board
		
	#while the ending is unexplored, loop
	explore_loop:
	lw $s1, ($t0) 
	bnez $s1, proceed_now
	addi $a0, $a0, 1
	jal pathing
	j explore_loop
	
	proceed_now:
	#find the coordinates of the end point, find i and j
	move $a3, $a0 #we move to $a3 the shortest distance
	
	subu $t0, end, board
	divu $t0, $t0, 4
	mflo $t0 
	
	divu $t6, $t0, 18 #i
	mflo $t6
	
	divu $t7, $t0, 18 #j
	mfhi $t7

	addi $t0, end, 432 #ending point in bfs board, go back to starting point
	lw $a0, ($t0) #store bfs_board[i][j]
	
	retrace:
	ble $a0, 1, ending
	
	#can only take one of the following moves, so we set up a safety measure
	#a move is taken once $a0 is decremented
	
	move $a1, $a0
	
	jal checkNE
	bne $a0, $a1, retrace 
	
	jal checkNW
	bne $a0, $a1, retrace 	
	
	jal checkSE
	bne $a0, $a1, retrace 
	
	jal checkSW
	bne $a0, $a1, retrace 	
		
	jal checkUp
	bne $a0, $a1, retrace 
	
	jal checkDown
	bne $a0, $a1, retrace 	
	
	jal checkLeft
	bne $a0, $a1, retrace 
	
	jal checkRight
	bne $a0, $a1, retrace 	
	
	ending:
 	#print the answers
 	
	jal print_board
	print_int($a3) #print the shortest distance
	exit

					
checkSE:
	save_register
	move $s0, $t6 #store i
	move $s1, $t7 #store j
	subi $s3, $a0, 1 # k-1
	
	bge $s0, 5, checkSE_end
	bge $s1, 17, checkSE_end
	addi $s0, $s0, 1
	addi $s1, $s1, 1
	
	#$s2 contains the index
	mul $s2, $s0, 18
	add $s2, $s2, $s1
	mul $s2, $s2, 4 	
	
	#adding base addresses
	add board, board, $s2
	add bfsboard, bfsboard, $s2
	
	lw $s2, (bfsboard)
	bne $s2, $s3 checkSE_end
	#board[i][j] = 1, from 0 (ASCII)
	lw $s2, (board)
	addi $s2, $s2, 1
	sw $s2, (board)
	subi $a0, $a0, 1	
	addi $t6, $t6, 1
	addi $t7, $t7, 1
	
	checkSE_end:
	restore_register	
	jr $ra			
				
checkSW:
	save_register
	move $s0, $t6 #store i
	move $s1, $t7 #store j
	subi $s3, $a0, 1 # k-1
	
	bge $s0, 5, checkSW_end
	blez $s1, checkSW_end
	
	addi $s0, $s0, 1
	addi $s1, $s1, -1
	
	#$s2 contains the index
	mul $s2, $s0, 18
	add $s2, $s2, $s1
	mul $s2, $s2, 4 	
	
	#adding base addresses
	add board, board, $s2
	add bfsboard, bfsboard, $s2
	
	lw $s2, (bfsboard)
	bne $s2, $s3 checkSW_end
	#board[i][j] = 1
	lw $s2, (board)
	addi $s2, $s2, 1
	sw $s2, (board)	
	subi $a0, $a0, 1	
	addi $t6, $t6, 1
	addi $t7, $t7, -1
	
	checkSW_end:
	restore_register	
	jr $ra						
						
checkNE:
	save_register
	move $s0, $t6 #store i
	move $s1, $t7 #store j
	subi $s3, $a0, 1 # k-1
	
	blez $s0, checkNE_end
	bge $s1, 17, checkNE_end
	
	addi $s0, $s0, -1
	addi $s1, $s1, 1
	
	#$s2 contains the index
	mul $s2, $s0, 18
	add $s2, $s2, $s1
	mul $s2, $s2, 4 	
	
	#adding base addresses
	add board, board, $s2
	add bfsboard, bfsboard, $s2
	
	lw $s2, (bfsboard)
	bne $s2, $s3 checkNE_end
	#board[i][j] = 1, from 0 (ASCII)
	lw $s2, (board)
	addi $s2, $s2, 1
	sw $s2, (board)
	subi $a0, $a0, 1	
	addi $t6, $t6, -1
	addi $t7, $t7, 1

	checkNE_end:
	restore_register	
	jr $ra	
									
checkNW:
	save_register
	move $s0, $t6 #store i
	move $s1, $t7 #store j
	subi $s3, $a0, 1 # k-1
	
	blez $s0, checkNW_end
	blez $s1, checkNW_end
	
	addi $s0, $s0, -1
	addi $s1, $s1, -1
	
	#$s2 contains the index
	mul $s2, $s0, 18
	add $s2, $s2, $s1
	mul $s2, $s2, 4 	
	
	#adding base addresses
	add board, board, $s2
	add bfsboard, bfsboard, $s2
	
	lw $s2, (bfsboard)
	bne $s2, $s3 checkNW_end
	#board[i][j] = 1, from 0 (ASCII)
	lw $s2, (board)
	addi $s2, $s2, 1
	sw $s2, (board)
	subi $a0, $a0, 1	
	addi $t6, $t6, -1
	addi $t7, $t7, -1
	
	checkNW_end:
	restore_register
	jr $ra
										
checkUp:
	save_register
	
	
	move $s0, $t6 #store i
	move $s1, $t7 #store j
	subi $s3, $a0, 1 # k-1
	
	
	blez $s0, checkUp_end
	addi $s0, $s0, -1
	
	#$s2 contains the index
	mul $s2, $s0, 18
	add $s2, $s2, $s1
	mul $s2, $s2, 4 	
	
	#adding base addresses
	add board, board, $s2
	add bfsboard, bfsboard, $s2
	
	
	lw $s2, (bfsboard)
	bne $s2, $s3 checkUp_end
	
	
	#board[i][j] = 1, from 0 (ASCII)
	lw $s2, (board)
	addi $s2, $s2, 1
	sw $s2, (board)
	

	
	subi $a0, $a0, 1	
	addi $t6, $t6, -1
	
	
	checkUp_end:
	restore_register	
	jr $ra	
											
checkDown:
	save_register
	
	
	move $s0, $t6 #store i
	move $s1, $t7 #store j
	subi $s3, $a0, 1 # k-1
	
	
	bge $s0, 5, checkDown_end
	addi $s0, $s0, 1
	
	#$s2 contains the index
	mul $s2, $s0, 18
	add $s2, $s2, $s1
	mul $s2, $s2, 4 	
	
	#adding base addresses
	add board, board, $s2
	add bfsboard, bfsboard, $s2
	
	
	lw $s2, (bfsboard)
	bne $s2, $s3 checkDown_end
	
	
	#board[i][j] = 1, from 0 (ASCII)
	lw $s2, (board)
	addi $s2, $s2, 1
	sw $s2, (board)
	
	subi $a0, $a0, 1	
	addi $t6, $t6, 1
	
	checkDown_end:
	restore_register	
	jr $ra	

checkLeft:
	save_register
	
	
	move $s0, $t6 #store i
	move $s1, $t7 #store j
	subi $s3, $a0, 1 # k-1
	
	
	blez $s1,checkLeft_end
	addi $s1, $s1, -1
	
	#$s2 contains the index
	mul $s2, $s0, 18
	add $s2, $s2, $s1
	mul $s2, $s2, 4 	
	
	#adding base addresses
	add board, board, $s2
	add bfsboard, bfsboard, $s2
	
	
	lw $s2, (bfsboard)
	bne $s2, $s3 checkLeft_end
	
	
	#board[i][j] = 1, from 0 (ASCII)
	lw $s2, (board)
	addi $s2, $s2, 1
	sw $s2, (board)
	
	subi $a0, $a0, 1	
	addi $t7, $t7, -1
	
	checkLeft_end:
	restore_register	
	jr $ra	
		
checkRight:
	save_register
	
	
	move $s0, $t6 #store i
	move $s1, $t7 #store j
	subi $s3, $a0, 1 # k-1
	
	
	bge $s1, 17, checkRight_end
	addi $s1, $s1, 1
	
	#$s2 contains the index
	mul $s2, $s0, 18
	add $s2, $s2, $s1
	mul $s2, $s2, 4 	
	
	#adding base addresses
	add board, board, $s2
	add bfsboard, bfsboard, $s2
	
	
	lw $s2, (bfsboard)
	bne $s2, $s3 checkRight_end
	
	
	#board[i][j] = 1, from 0 (ASCII)
	lw $s2, (board)
	addi $s2, $s2, 1
	sw $s2, (board)
	
	subi $a0, $a0, 1	
	addi $t7, $t7, 1
	
	checkRight_end:
	restore_register	
	jr $ra	
				
pathing:
	addi $sp, $sp, -24
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $ra, 20($sp)		
							
	#looping
	#for i in range(6) i = $s0
		#for j in range(18) j = $s1
		
	li $s0, 0 
	
	for1:
	li $s1, 0
	
	for2:
	beq $s1, 18, check_outer
	
	#to locate index, index = base address + (i * 16 + j) * 4
	mul $s2, $s0, 18
	add $s2, $s2, $s1
	mul $s2, $s2, 4
	
	#bfs_board[i][j] == k check
	add $s2, $s2, bfsboard
	lw $s3, ($s2)
	bne $s3, $a0, pathing_increment
	
	jal moveNE
	jal moveNW
	jal moveSE
	jal moveSW
	jal moveUp
	jal moveDown
	jal moveLeft
	jal moveRight
	
	pathing_increment:
	addi $s1, $s1, 1
	j for2		
	
	check_outer:
	addi $s0, $s0, 1
	beq $s0, 6, pathing_end
	j for1
	
	pathing_end:
	lw $ra, 20($sp)	
	lw $s4, 16($sp)
	lw $s3, 12($sp)
	lw $s2, 8($sp)
	lw $s1, 4($sp)
	lw $s0, 0($sp)
	addi $sp, $sp, 12	
	jr $ra
	
moveNE:
	save_register
	move $s3, $a0
	
	blez $s0, endNE
	bge $s1, 17, endNE
	
	addi $s0, $s0, -1
	addi $s1, $s1, 1

	
	mul $s2, $s0, 18
	add $s2, $s2, $s1
	mul $s2, $s2, 4 	
	
	add board, board, $s2 #board[i][j]
	add bfsboard, bfsboard, $s2 #bfs_board[i][j]
	
	lw $s2, (bfsboard)
	bnez  $s2, endNE
	
	lw $s2, (board)
	bne $s2, 48, endNE
	
	add $s3, $s3, 1
	sw $s3, (bfsboard)
	
	endNE:
	restore_register
	jr $ra
	

moveNW:
	save_register
	
	move $s3, $a0
	
	blez $s0, endNW
	blez $s1, endNW
	
	addi $s0, $s0, -1
	addi $s1, $s1, -1
		
	#$s2 contains the index
	mul $s2, $s0, 18
	add $s2, $s2, $s1
	mul $s2, $s2, 4 	
	
	add board, board, $s2
	add bfsboard, bfsboard, $s2
	
	lw $s2, (bfsboard)
	bnez  $s2, endNW
	
	lw $s2, (board)
	bne $s2, 48, endNW
	
	add $s3, $s3, 1
	sw $s3, (bfsboard)
	
	endNW:
	restore_register
	jr $ra
	

moveSE:
	save_register
	
	move $s3, $a0
	
	bge $s0, 5, endSE
	bge $s1, 17, endSE
	
	addi $s0, $s0, 1
	addi $s1, $s1, 1
		
	#$s2 contains the index
	mul $s2, $s0, 18
	add $s2, $s2, $s1
	mul $s2, $s2, 4 	
	
	add board, board, $s2
	add bfsboard, bfsboard, $s2
	
	lw $s2, (bfsboard)
	bnez  $s2, endSE
	
	lw $s2, (board)
	bne $s2, 48, endSE
	
	add $s3, $s3, 1
	sw $s3, (bfsboard)
	
	endSE:
	restore_register
	jr $ra	
		
moveSW:
	save_register
	move $s3, $a0
	
	bge $s0, 5, endSW
	blez $s1, endSW
	
	addi $s0, $s0, 1
	addi $s1, $s1, -1
		
	#$s2 contains the index
	mul $s2, $s0, 18
	add $s2, $s2, $s1
	mul $s2, $s2, 4 	
	
	add board, board, $s2
	add bfsboard, bfsboard, $s2
	
	lw $s2, (bfsboard)
	bnez  $s2, endSW
	
	lw $s2, (board)
	bne $s2, 48, endSW
	
	add $s3, $s3, 1
	sw $s3, (bfsboard)
	
	endSW:
	restore_register
	jr $ra			
							
moveUp:
	save_register
	move $s3, $a0
	
	blez $s0, endUp
	addi $s0, $s0, -1
	
	#$s2 contains the index
	mul $s2, $s0, 18
	add $s2, $s2, $s1
	mul $s2, $s2, 4 	
	
	add board, board, $s2
	add bfsboard, bfsboard, $s2
	
	lw $s2, (bfsboard)
	bnez  $s2, endUp
	
	lw $s2, (board)
	bne $s2, 48, endUp
	
	add $s3, $s3, 1
	sw $s3, (bfsboard)
	
	endUp:
	restore_register
	jr $ra
							
moveDown:
	save_register
	move $s3, $a0
	
	bge $s0, 5, endDown
	addi $s0, $s0, 1
	
	#$s2 contains the index
	mul $s2, $s0, 18
	add $s2, $s2, $s1
	mul $s2, $s2, 4 	
	
	add board, board, $s2
	add bfsboard, bfsboard, $s2
	
	lw $s2, (bfsboard)
	bnez  $s2, endDown
	
	lw $s2, (board)
	bne $s2, 48, endDown
	
	add $s3, $s3, 1
	sw $s3, (bfsboard)
	
	endDown:
	restore_register
	jr $ra	
	
moveLeft:
	save_register
	move $s3, $a0
	
	blez $s1, endLeft
	addi $s1, $s1, -1
	
	#$s2 contains the index
	mul $s2, $s0, 18
	add $s2, $s2, $s1
	mul $s2, $s2, 4 	
	
	add board, board, $s2
	add bfsboard, bfsboard, $s2
	
	lw $s2, (bfsboard)
	bnez  $s2, endLeft
	
	lw $s2, (board)
	bne $s2, 48, endLeft
	
	add $s3, $s3, 1
	sw $s3, (bfsboard)
	
	endLeft:
	restore_register
	jr $ra	
		
moveRight:
	save_register
	move $s3, $a0
	
	bge $s1, 17, endRight
	addi $s1, $s1, 1
	
	#$s2 contains the index
	mul $s2, $s0, 18
	add $s2, $s2, $s1
	mul $s2, $s2, 4 	
	
	add board, board, $s2
	add bfsboard, bfsboard, $s2
	
	lw $s2, (bfsboard)
	bnez  $s2, endRight
	
	lw $s2, (board)
	bne $s2, 48, endRight
	
	add $s3, $s3, 1
	sw $s3, (bfsboard)
	
	endRight:
	restore_register
	jr $ra		
																		
input:
	addi $sp, $sp, -12
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	
	li $s2, 48
	read_str
	loop_store:
	beq $s0, 18, end_input 
	lb $s1, line($s0)
	
	beq $s1, 83, found_start
	beq $s1, 70, found_end
	
	return:
	sw $s1, ($t2)
	addi $t2, $t2, 4
	addi $s0, $s0, 1
	j loop_store
	
	end_input:
	lw $s2, 8($sp)
	lw $s1, 4($sp)
	lw $s0, 0($sp)
	addi $sp, $sp, 12
	jr $ra
	
	found_start: #we store the starting point, and change 'S' to '0'
	la start, ($t2)
	move $s1, $s2 
	j return
	
	found_end: #we store the starting point, and change 'F' to '0'
	la end, ($t2)
	move $s1, $s2
	j return
	
print_board: #prints the solved board
	addi $sp, $sp, -12
	sw $s0, 0($sp)
	sw $s1, 4($sp)	
	sw $s2, 8($sp)
	move $t2, board 
	#nested loop
	#basically a for i in list, for j in i, just like printing a list of lists
	line_loop:
	
	newline
	
	li $s1, 0
	beq $s0, 6, end_print
	
	print_loop:
	beq $s1, 18, loopback
	lw $s2, ($t2)
	
	beq $t2, start, restore_start #we restore the 'S'
	beq $t2, end, restore_end	#we restore the 'F' 
	
	return_print:
	print_char($s2) 
	addi $s1, $s1, 1
	addi $t2, $t2, 4
	j print_loop
	
	loopback:
	addi $s0, $s0,1
	j line_loop
	
	end_print:
	lw $s2, 8($sp)
	lw $s1, 4($sp)
	lw $s0, 0($sp)
	addi $sp, $sp, 12
	jr $ra
	
	restore_start:
	li $s2, 83
	j return_print
	
	restore_end:
	li $s2, 70
	j return_print

.data
	line: .space 20
	input_board: .word 0:108 #initialize the bfs board, which will be key in solving the problem
	bfs_board: .word 0:108 #initialize the bfs board, which will be key in solving the problem
