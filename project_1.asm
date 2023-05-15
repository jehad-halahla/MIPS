#INCLUDE SECTION 
.include "macros.asm"

#CODE SECTION
.text 
.globl main
main:
print_str(" 1.does the dictionary.txt file exist or not Y/N.\n")

#load Y/N from the terminal 
take_option:
li $v0,8
la $a0,option
li $a1,100
syscall

# Store buffer contents in $t0
move $t0, $a0
# Load first byte from buffer into $t1
lb $t1, ($t0)
# Compare $t1 with ASCII code for "Y"

xori  $t2,$t1,'Y'
xori $t3,$t1,'y'
and $t3,$t3,$t2
beqz  $t3,answer_is_yes

xori  $t2,$t1,'N'
xori $t3,$t1,'n'
and $t3,$t3,$t2
beqz $t3,answer_is_no



print_str("input doesn't match...please enter y/n..\n")

j take_option

answer_is_no:

print_str("answer is no,creating new Dictionary...\n")
j end_option

answer_is_yes:
	print_str("please enter file path:\n")
	 #Read file path from user input
    li $v0, 8
    la $a0, file_path
    li $a1, 256
    syscall
   	la $a0,file_path
	jal DeleteNewLine
    # Print the file path
    li $v0, 4
    la $a0, file_path
    syscall
    
    # Open file for reading
    li $v0, 13
    la $a0, file_path
    li $a1, 0
    syscall
    move $s0, $v0        # Save file descriptor in $s0
    
    end_option:

    # Display output message
    print_str("File contents:\n")
    # Read file contents
    li $v0, 14
    move $a0, $s0
    la $a1, file_contents
    li $a2, 4096
    syscall
    
    # Display file contents
    li $v0, 4
    la $a0, file_contents
    syscall

    # Close the file
    li $v0, 16
    move $a0, $s0
    syscall

    # Exit program
    li $v0, 10
    syscall
    
    
DeleteNewLine:
	lb $t0,($a0)
	beq $t0,'\n',here
	addi $a0,$a0,1
	j DeleteNewLine
	
here:
	sb $zero,($a0)
	jr $ra


j end
end:
    # Exit the program
    li $v0, 10
    syscall
    
#DATA SECTION
.data

dictionary_path:	.asciiz   "C:\\Users\\a-z\\Desktop\\MIPSProgramming\\dictionary.txt"
fileWords:	.space 1024
option:	.space 100              #Allocate memory for file path buffer
buffer2:	.space 256             # Allocate memory for file path buffer
file_path:      .space 256           # Allocate memory for file path buffer
file_contents:  .space 4096          # Allocate memory for file contents
