.include "macros.asm"
.text 
.globl main

main:

print_str(" 1.is the dictionary.txt file exist or not Y/N \n")
#load Y/N from the curser 
li $v0,8
la $a0,buffer
li $a1,100
syscall

#save Y/N in the buffer 
 li $v0,4
 la $a0,buffer
 syscall 
 # Store buffer contents in $t0
move $t0, $a0

# Load first byte from buffer into $t1
lb $t1, ($t0)

# Compare $t1 with ASCII code for "Y"
li $t2, 89
beq $t1, $t2, equal
bne $t0,$t1,not_equal
equal:
print_str("masa")
j end
end:
    # Exit the program
    li $v0, 10
    syscall
    
#open file 
li $v0,13
la $a0,read1
li $a1, 0
syscall 
move $s0,$v0

#read the file 
li $v0,14
move  $a0,$s0
la $a1,fileWords
la $a2,1024
syscall

#print whats in the file 
li $v0,4
la $a0,fileWords
syscall 

#close file 
li $v0,16
move $a0,$s0
syscall 

.data

read1:.asciiz   "C:\\Users\\a-z\\Desktop\\read1.txt""
fileWords:.space 1024
buffer:.space 100
#equal:.asciiz 
not_equal:.asciiz 
