#this code will generate a random int and then we will make the user try to guess it untill he get the right guess
#DATA SECTION

.data 
guess: .asciiz "your guess is wrong, try again\n"
correct_guess: .asciiz "your guess is correct\n"


#CODE SECTION
.text
.globl main
main:
#we will generate a random int and store it in $t0
li $v0,42
syscall
move $t0,$v0
#now we will make the number between 0 and 10
andi $t0,$t0,0x0000000A
#now we will make the user guess the number
#we will store the guess in $t1

#we will make a loop that will make the user guess the number untill he get it right
loop:
#we will ask the user to enter a number
li $v0,5
syscall
move $t1,$v0
#now we will compare the guess with the random number
beq $t1,$t0,correct
#now we will print a message that the guess is wrong
li $v0,4
la $a0,guess
syscall
j loop
#now we will print a message that the guess is correct
correct:
li $v0,4
la $a0,correct_guess
syscall
#now we will exit the program
li $v0,10
syscall
