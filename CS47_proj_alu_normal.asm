.include "./cs47_proj_macro.asm"
.text
.globl au_normal
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_normal
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_normal:
	beq 	$a2, 0x2D, sub_normal 		# 0x2D = ASCII '-'
	beq	$a2, 0x2B, add_normal 		# 0x2B = ASCII '+'
	beq	$a2, 0x2F, div_normal 		# 0x2F = ASCII '/'
	beq	$a2, 0x2A, mult_normal  	# 0x2A = ASCII '*'
add_normal:
	add	$v0, $a0, $a1			# $v0 = $a0 + $a1
	j	return_normal
sub_normal:
	sub	$v0, $a0, $a1			# $v0 = $a0 - $a1
	j	return_normal
mult_normal:
	mult	$a0, $a1			# $a0 * $a1
	mfhi	$v1				# $v1 = HI value of $a0 * $a1
	mflo	$v0				# $v0 = LO value of $a0 * $a1
	j	return_normal
div_normal:
	div	$a0, $a1			# $a0 / $a1
	mflo	$v0				# $v0 = Quotient
	mfhi	$v1				# $v1 = Remainder
	j	return_normal
return_normal:
	jr	$ra
