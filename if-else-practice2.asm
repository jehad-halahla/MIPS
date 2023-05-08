#Q: Write a program that takes two integers as input and outputs the maximum of the two.
#we will define a macro that ends the program

#MACRO DEFINITIONS

.macro end
li $v0, 10
syscall
.end_macro

#DATA SEGMENT
.data
prompt: .asciiz "Enter the first number: "
prompt2: .asciiz "Enter the second number: "
result: .asciiz "The maximum is: "

#CODE SEGMENT
.text
.globl main
main:
#prompt the user for the first number
li $v0, 4
la $a0, prompt
syscall

#read the first number
li $v0, 5
syscall

#store the first number in $t0
move $t1, $v0

#read the second number
li $v0,4
la $a0, prompt2
syscall

#store the second number in $t1
li $v0, 5
syscall
move $t2, $v0

#compare the two numbers!
bge $t1,$t2,greater
#if t1 is less
li $v0,4
la $a0,result
syscall

li $v0,1
move $a0,$t2
syscall 

j finish

greater:
li $v0,4
la $a0, result
syscall

li $v0,1
move $a0,$t1
syscall

finish:
end