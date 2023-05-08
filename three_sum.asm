.data
prompt: .asciiz "please enter 3 numbers\n"
#just trying to pull edited

.text 
 .globl main
 main:
 	li $v0,4
 	la $a0,prompt
 	syscall 
 	
	li $v0,5
	syscall 
	move $t0,$v0
	
	li $v0,5
	syscall 
	move $t1,$v0
	
	li $v0,5
	syscall 
	move $t2,$v0
	
	addu $t0,$t0,$t1
	addu $t0,$t0,$t2
	
	
	li $v0,1
	move $a0,$t0
	syscall 
	
	li $v0,10
	syscall 
