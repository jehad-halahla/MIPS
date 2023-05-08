#Q:Write a program that takes an integer input from the user and determines whether it is even or odd. If the number is even, print "Even" to the console, otherwise print "Odd".
.include "macros.asm"

#DATA SEGMENT
.date

#DATA ENDS

#CODE SEGMENT
.text

.globl main

main:

#Prompt user for input
print_str("please enter the first number: ")
li $v0, 5
syscall
move $t0, $v0
#test if its even or odd
andi $t1, $t0, 1
beq $t1, $zero, even
print_str("Odd")
j end
even:
print_str("Even")
end:
terminate(0)
