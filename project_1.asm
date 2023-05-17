#INCLUDE SECTION 
.include "macros.asm"

#CODE SECTION
.text 
.globl main

main:
program:

take_option:

jal print_menu

#load Y/N from the terminal 
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

xori  $t2,$t1,'C'
xori $t3,$t1,'c'
and $t3,$t3,$t2
beqz $t3,answer_is_compress

xori  $t2,$t1,'Q'
xori $t3,$t1,'q'
and $t3,$t3,$t2
beqz $t3,answer_is_quit



	print_str("input doesn't match...please enter y/n/c/d/q..\n")

j take_option

answer_is_no:
print_str("answer is no,creating new Dictionary...\n")
# Open file for reading
    li $v0, 13
    la $a0, dictionary_path
    li $a1, 0
    syscall
    move $s0, $v0        # Save file descriptor in $s0
j default_dictionary
answer_is_quit:
print_str("thank you for using our program...\n")
j end_program

answer_is_yes:
	print_str("please enter file path:\n")
	 #Read file path from user input
    li $v0, 8
    la $a0, file_path
    li $a1, 256
    syscall
   	la $a0,file_path
	jal DeleteNewLine
    # Open file for reading
    li $v0, 13
    la $a0, file_path
    li $a1, 0
    syscall
    move $s0, $v0        # Save file descriptor in $s0
    j take_option
default_dictionary:
    #load file contents into buffer
    li $v0, 14
    move $a0, $s0
    la $a1, file_contents
    li $a2, 4096
    syscall
    print_str("file contents:\n")
    li $v0, 4
    la $a0, file_contents
    syscall

    # Close the file
    li $v0, 16
    move $a0, $s0   
    syscall
    j take_option

answer_is_compress:
 print_str("answer is compression....\n")
 #we will first count the number of words in the file
  jal count_words_in_file_contents
    #print the number of words in the file
    li $v0,1
    addiu $s1,$s1,1
    move $a0,$s1
    syscall
    print_str(" words in the file\n")
    j take_option

    
end_option:


    # Display output message

    print_str("File contents:\n")
    # Read file contents
    li $v0, 14
    move $a0, $s0
    la $a1, file_contents
    li $a2, 4096
    syscall

    # Close the file
    li $v0, 16
    move $a0, $s0
    syscall
end_program:
    # Exit program
    terminate(0)
    
    
DeleteNewLine:
	lb $t0,($a0)
	beq $t0,'\n',here
	addi $a0,$a0,1
	j DeleteNewLine
	
here:
	sb $zero,($a0)
	jr $ra

print_menu:
    print_str("Welcome to our compression program...\n")
    print_str("please follow the instructions below:\n")
    print_str(" 1.does the dictionary.txt file exist or not Y/N.\n")
    print_str(" 2.if yes,then enter the file path.\n")
    print_str(" 3.if no,then create a new dictionary.txt file.\n")
    print_str(" 4.choose compression(c/C) or decompression(D/d):\n")
    print_str(" 5.quit the program (q/Q)\n")
    jr $ra

count_words_in_file_contents:
    #we will assume that the file contents are stored in file_contents
    #we will count the number of words in the file and store it in $s1
    #we will also assume that each char that is not alphabetic is a word
    la $t0,file_contents
loop_count:
    lb $t1,($t0)
    beqz $t1,done_counting
    beq $t1,' ',is_space
    beq $t1,'\n',is_space
    beq $t1,'\t',is_space
    beq $t1,'\r',is_space
    beq $t1,'.',is_space
    beq $t1,',',is_space
    beq $t1,';',is_space
    beq $t1,':',is_space
    beq $t1,'!',is_space
    beq $t1,'?',is_space
    beq $t1,'-',is_space
    beq $t1,'_',is_space
    addi $t0,$t0,1
	j loop_count
is_space:
    addi $s1,$s1,1
    addi $t0,$t0,1
    j loop_count
done_counting:
    jr $ra
#DATA SECTION
.data

dictionary_path:	.asciiz   "dictionary.txt"
option:	.space 100              #Allocate memory for file path buffer
file_path:      .space 256           # Allocate memory for file path buffer
file_contents:  .space 4096          # Allocate memory for file contents
array:	.space 1024
