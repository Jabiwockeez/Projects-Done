# CS 21 Lab 2 -- S2 AY 2021-2022
# Jack Vincent Nicolas -- 04/19/2022
# 4x4.asm -- 4x4 Sudoku Solver
.eqv	row $s0
.eqv	col $s1
.eqv	num $s2

.text
main:
	li $t1 0x10010000
	li $t0 4
m_loop:	
	beq $s0 $t0 end_input
	
	li $v0 5 # Get nth row
	syscall
	move $t2 $v0
	
	li $t3 1000 # Get 1st
	div $t2 $t3
	mflo $t2 # X 0 0 0
	mfhi $t3 # 0 0 0
	
	sw $t2 0($t1)
	move $t2 $t3
	
	li $t3 100 # Get 2nd
	div $t2 $t3
	mflo $t2 # X 0 0
	mfhi $t3 # 0 0
	
	sw $t2 4($t1)
	move $t2 $t3
	
	li $t3 10 # Get 3rd
	div $t2 $t3
	mflo $t2 # X 0
	mfhi $t3 # 0
	
	sw $t2 8($t1)
	move $t2 $t3
	
	li $t3 1 # Get 4th
	div $t2 $t3
	mflo $t2 # X
	
	sw $t2 12($t1)
	
	addi $s0 $s0 1
	addi $t1 $t1 32
	j m_loop
	
end_input:
	li $s6 0x10010000	#.data storage
	li $s7 4	# Size of Grid
	
	jal solve
	
	j exit
	
solve:
	subu $sp $sp 32
	sw $ra 28($sp)
	sw row 24($sp)
	sw col 20($sp)
	sw num 16($sp)
	
	li row 0
	li col 0
	li num 0
	
## na start	
num_unassigned:
	li $t0 0 # i = 0
	li $s5 0 # num_unassign = 0
	
loop_nu: # out loop
	beq $t0 $s7 solve_cont # if i == size: num_unassign = 0
	li $t1 0 # j = 0
	
loop_nu2: # in loop
	beq $t1 $s7 endloop_nu2 # if j == size: end j loop
	
	li $s6 0x10010000
	mul $t2 $t0 32 # Get row bytes (i)
	mul $t3 $t1 4 # Get col bytes (j)
	add $t4 $t2 $t3 # Get [i][j]
	add $t4 $t4 $s6 # Get [i][j]
	lw $t3 ($t4) # grid[i][j]
	bne $t3 0 ikot # if grid[i][j] != 0: j loop
	
	# if grid[i][j] == 0
	move row $t0 # row = i
	move col $t1 # col = j
	li $s5 1 # num_unassign = 1
	j solve_cont
	
ikot:	
	addi $t1 $t1 1 # j++
	j loop_nu2
endloop_nu2: # in loop
	addi $t0 $t0 1 # i++
	j loop_nu
	
solve_cont:
	beqz $s5 exit # If num_unassign == 0: return 1
	li num 1 # num = 1 (for solve loop)
# solve start	
loop_s:
	bgt num $s7 ret_0 # num > size -> endloop
	
# is_safe start
is_safe:
	li $s4 1 # int safe = 1;
	li $t0 0 # i = 0	
r_loop:
	beq $t0 $s7 r_loop_end # if i == size: end
	
	li $s6 0x10010000
	mul $t1 row 32 # Get the row byte
	mul $t2 $t0 4 # Get the col byte (i)
	add $t3 $t1 $t2 # Get [row][i]
	add $t3 $t3 $s6 # Get [row][i]
	lw $t3 ($t3) # grid[row][i]
	beq $t3 num not_safe # if grid[row][i] == num: safe = 0
	
	addi $t0 $t0 1 # i++
	j r_loop	
	
r_loop_end:
	li $t0 0 # i = 0	
c_loop:
	beq $t0 $s7 c_loop_end # if i == size: end
	
	li $s6 0x10010000
	mul $t1 $t0 32 # Get the row byte (i)
	mul $t2 col 4 # Get the col byte
	add $t3 $t1 $t2 # Get [i][col]
	add $t3 $t3 $s6 # Get [i][col]
	lw $t3 ($t3) # grid[i][col]
	beq $t3 num not_safe # if grid[i][col] == num; safe = 0
	
	addi $t0 $t0 1 # i++
	j c_loop
	
c_loop_end:

	div $t2 row 2 # row_start = row/2
	mul $t2 $t2 2 # row_start = (row/2) * 2 
	
	move $t0 $t2 # i = row_start
	addi $t2 $t2 2 # row_start + 2
	
rs_loop: # out loop
	beq $t0 $t2 yes_safe# if r_s == r_s + 2: safe = 1
	
	div $t3 col 2 # col_start = col/2
	mul $t3 $t3 2 # col_start = (col/2) * 2 
	
	move $t1 $t3 # j = col_start
	addi $t3 $t3 2 # col_start + 2	
cs_loop:
	beq $t1 $t3 cs_loop_end # if c_s == c_s + 2: end j loop
	li $s6 0x10010000
	mul $t4 $t0 32 # Get row bytes [i]
	mul $t5 $t1 4 # Get col byte [j]
	add $t6 $t4 $t5 # Get [i][j]
	add $t6 $t6 $s6 # Get [i][j]
	lw $t7 ($t6) # grid[i][j]
	beq $t7 num not_safe# if grid[i][j] == num: safe = 0

	addi $t1 $t1 1
	j cs_loop
	
cs_loop_end:	
	addi $t0 $t0 1
	j rs_loop	
# end is_safe	
yes_safe:
	li $s4 1
	
	li $s6 0x10010000
	mul $t2 row 32	# Get row bytes
	mul $t3 col 4	# Get col bytes
	add $t4 $t2 $t3 # Get [row][col]
	add $t4 $t4 $s6 # Get [tow][col]
	sw num ($t4) # grid[row][col] = i
	
	jal solve
	
	lw $ra 28($sp)
	lw row 24($sp)
	lw col 20($sp)
	lw num 16($sp)
	addu $sp $sp 32
	
	beq $s3 1 ret_1 # if (solve == 1): return 1
	
	li $s6 0x10010000
	mul $t2 row 32	# Get row bytes
	mul $t3 col 4	# Get col bytes
	add $t4 $t2 $t3 # Get [row][col]
	add $t4 $t4 $s6 # Get [row][col]
	sw $0 ($t4) # grid[row][col] = 0
not_safe:
	li $s4 0 # safe = 0
	j add1	
	
add1:	
	addi num num 1
	j loop_s
	
ret_0:
	li $s6 0
	jr $ra
ret_1:
	li $s6 1
	jr $ra
exit:	
	li $v0 10
	syscall