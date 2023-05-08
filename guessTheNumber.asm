#DATA SECTION

.data 
guess: .asciiz "your guess is wrong, try again\n"
correct_guess: .asciiz "your guess is correct\n"


#CODE SECTION
.text
.globl main
main:
#we will generate a random int and store it in $t0
li $v0, 40     # service number 40 initializes the RNG
li $a0, 31    #sets generation seed
syscall

li $v0, 41         # system call 42 is not valid in MARS; we will skip this instruction
syscall
move $t0,$v0
#now we will make the number between 0 and 16
andi $t0,$t0,0x0000000f
#now we will make the user guess the number
#we will store the guess in $t1

#load the address of the "your guess is wrong" message outside the loop
la $a0, guess

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
