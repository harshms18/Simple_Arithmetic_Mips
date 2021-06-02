.include "./cs47_proj_macro.asm"
.text
.globl au_logical
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_logical
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_logical:
	addi	$sp, $sp, -52
	sw	$a0, 0($sp)
	sw	$a1, 4($sp)
	sw	$a2, 8($sp)
	sw	$a3, 12($sp)
	sw	$fp, 16($sp)
	sw	$s0, 20($sp)	# Result storage stack frame
	sw	$s1, 24($sp)	
	sw	$ra, 28($sp)
	sw	$s2, 32($sp)
	sw	$s3, 36($sp)
	sw	$s4, 40($sp)
	sw	$s5, 44($sp)
	addi	$fp, $sp, 52
	li	$t0, 0		# Loop counter
	li	$s0, 0
	li	$v0, 0		# Initilaize result to 0
	li	$v1, 0		# Initialize result to 0
	beq 	$a2, 0x2D, sub_logical 		# 0x2D = ASCII '-'
	beq	$a2, 0x2B, add_logical		# 0x2B = ASCII '+'
	beq	$a2, 0x2A, mult_logical		# 0x2A = ASCII '*'
	beq	$a2, 0x2F, div_logical		# 0x2F = ASCII '/'
	j	restore_return_logical
sub_logical:
	nor	$a1, $a1, $zero
	li	$s1, 1
	j	add_logical_loop
add_logical:
	li	$s1, 0
	j	add_logical_loop
add_logical_loop:
	slti	$t4, $t0, 32
	beqz	$t4, end_logical_loop
	get_bit($a0, $t1, $t0)		# Assign to temporaries
	get_bit($a1, $t2, $t0)	
				
	xor	$t3, $t1, $t2		# Adder Implementation
	and	$t6, $t3, $s1
	xor	$t3, $s1, $t3	
	and	$t7, $t1, $t2
	or	$s1, $t6, $t7
	sllv	$t3, $t3, $t0
	or	$s0, $t3, $s0
	addi	$t0, $t0, 1
	j	add_logical_loop
	
end_logical_loop:
	or	$v0, $s0, $zero
	j	restore_return_logical

# s0 = product hi
# s1 = product lo - also multiplier
# s2 = multiplicand
# s3 = counter	
mult_logical:
	or	$s1, $a1, $zero
	li	$s0, 0
	li	$t0, 31
	get_bit($a0, $s4, $t0)
	get_bit($a1, $s5, $t0)
	or	$s2, $a0, $zero
	beqz	$s4, invert_check
	jal	invert_number
	or	$s2, $v0, $zero
	or	$a0, $s2, $zero
invert_check:
	beqz	$s5, invert_check_second_argument
	or	$a0, $a1, $zero
	jal	invert_number
	or	$s1, $v0, $zero
	or	$a0, $s2, $zero
invert_check_second_argument:
	li	$s0, 0
	li	$s3, 32
mult_logical_loop:
	beqz	$s3, sign_check
	get_bit($s1, $t1, $zero)
	beqz	$t1, bit_not_1
	move	$a1, $s0
	li	$a2, 0x2B
	jal	au_logical
	or	$s0, $v0, $zero
	
bit_not_1:
	srl	$s1, $s1, 1
	get_bit($s0, $t1, $zero)
	li	$t3, 31
	insert_bit($s1, $t1, $t3)
	srl	$s0, $s0, 1
	addi	$s3, $s3, -1
	j	mult_logical_loop
	
sign_check:
	xor	$t0, $s4, $s5
	beqz	$t0, end_mult
	move	$a0, $s1	
	jal	invert_number
	move	$s1, $v0
	nor	$s0, $s0, $zero
	
end_mult:
	move	$v0, $s1
	move	$v1, $s0
	j	restore_return_logical
	
div_logical:
	li	$s0, 0	# Quotient
	li	$s1, 0 	
	
	li	$t1, 31
	get_bit($a0, $t0, $t1)
	or	$s2, $zero, $a0
	beqz	$t0, dont_invert_a0_div
	jal	invert_number
	or	$s2, $zero, $v0
	
dont_invert_a0_div:	
	li	$t1, 31
	get_bit($a1, $t0, $t1)
	or	$s3, $a1, $zero
	beqz	$t0, dont_invert_a1_div
	move	$a0, $a1
	jal	invert_number
	or	$s3, $v0, $zero
dont_invert_a1_div:
	move	$a1, $s3
	li	$a2, 0x2D
	li	$s4, 0 		# Counter
	
div_logical_loop:			
	slti	$t0, $s4, 31 
	beqz	$t0, end_division_logical
	slt	$t0, $s2, $s3		
	bnez	$t0, end_division_logical
	move	$a0, $s2
	jal	au_logical
	move	$s2, $v0
	addi	$s4, $s4, 1
	j	div_logical_loop
	
end_division_logical:
	# check for negative values
	lw	$a0, 0($sp)	
	lw	$a1, 4($sp)	
	
	li	$t1, 31
	get_bit($a0, $s0, $t1)
	get_bit($a1, $t2, $t1)
	xor	$t3, $t2, $s0
	beqz	$t3, check_sign_quotient

	move	$a0, $s4
	jal	invert_number
	move	$s4, $v0
check_sign_quotient:
	# check remainder
	beqz	$s2, check_sign_remainder	
	beqz	$s0, check_sign_remainder
	
	move	$a0, $s2
	jal	invert_number
	move	$s2, $v0
check_sign_remainder:
	move	$v1, $s2	# Remainder
	move	$v0, $s4	# Quotient

# Restores stack frame	
restore_return_logical:
	lw	$a0, 0($sp)
	lw	$a1, 4($sp)
	lw	$a2, 8($sp)
	lw	$a3, 12($sp)
	lw	$fp, 16($sp)
	lw	$s0, 20($sp)
	lw	$s1, 24($sp)
	lw	$ra, 28($sp)
	lw	$s2, 32($sp)
	lw	$s3, 36($sp)
	lw	$s4, 40($sp)
	lw	$s5, 44($sp)
	addi	$sp, $sp, 52
	jr 	$ra

# Inverts a0 and stores it into v0
invert_number:
	addi	$sp, $sp, -24
	sw	$a0, 0($sp)
	sw	$a1, 4($sp)
	sw	$a2, 8($sp)
	sw	$fp, 12($sp)
	sw	$ra, 16($sp)
	addi	$fp, $sp, 24
	li	$a1, 1
	nor	$a0, $zero, $a0
	li	$a2, 0x2B
	jal	au_logical
	lw	$a0, 0($sp)
	lw	$a1, 4($sp)
	lw	$a2, 8($sp)
	lw	$fp, 12($sp)
	lw	$ra, 16($sp)
	addi	$sp, $sp, 24
	jr	$ra
