# Title: Filename: helloAssembly
# Author: Date: 8/5
# Description: a simple start file
# Input:
# Output:
################# Data segment #####################
.data 
prompt: .asciiz  "please, enter 3 integers\n"
################# Code segment #####################
.text
.globl main
main: # main program entry

li $v0,4
la $a0,prompt
syscall

li $v0,5
syscall

move $t1,$v0
li $v0,5
syscall

move $t2,$v0
li $v0,5
syscall

move $t3,$v0

addu $t1,$t1,$t2 # t1 = t1 + t2
addu $t1,$t1,$t3
move $a0,$t1
li $v0,1
syscall 

li $v0, 10 # Exit program
syscall
