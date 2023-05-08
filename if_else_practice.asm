#this problem will check if input number is positive or negative or zero
.data
prompt: .asciiz "Enter a number: "
pos: .asciiz "Positive"
neg: .asciiz "Negative"
z: .asciiz "Zero"

#CODE SEGMENT
.text
.globl main
main:
#prompt user to enter a number
li $v0,4
la $a0,prompt
syscall

#read the number
li $v0,5
syscall

#check if number is positive or negative or zero
bge $v0,$zero,positiveOrZero
#here number is negative
li $v0,4
la $a0,neg
syscall
j end
positiveOrZero:
beq $v0,$zero,zero
#here number is positive
li $v0,4
la $a0,pos
syscall
j end
zero:
#here number is zero
li $v0,4
la $a0,z
syscall
end:
#CODE SEGMENT END
li $v0,10
syscall
