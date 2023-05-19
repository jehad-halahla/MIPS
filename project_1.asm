#INCLUDE SECTION 
.include "macros.asm"

#CODE SECTION
.text 
.globl main

main:
program:

take_option:

jal print_menu

#load option from the terminal 
    li $v0,8
    la $a0,option
    li $a1,100
    syscall

    # Store buffer contents in $t0
    move $t0, $a0
   
    # Load first byte from buffer into $t1
    lb $t1, ($t0)
    #check if input is yes
    la $a1,yes

    jal compare_strings_with_case
    #also check if user entered only y/Y using xor operation
    beqz   $v0,answer_is_yes


    #check if input is no
    la $a1,no
    jal compare_strings_with_case
    beqz   $v0,answer_is_no

    #check if input is compress
    la $a1,compress
    jal compare_strings_with_case
    beqz   $v0,answer_is_compress

    #check if input is decompress
    la $a1,decompress
    jal compare_strings_with_case
    beqz   $v0,answer_is_decompress
    
    la $a1,quit
    jal compare_strings_with_case
    beqz $v0,answer_is_quit

	print_str("input doesn't match...please enter y/n/c/d/q..\n")

j take_option

answer_is_no:
    print_str("answer is no,creating new Dictionary named dictionary.txt...\n")
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
    #after file opened, we will check if it exists or not
    #if it doesn't exist then print error message and take file path again
    beq $v0, -1, error_message_2
    #if it exists then load file contents into buffer
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
	j no_problem
error_message_2:
    print_str("file doesn't exist...please enter file path again.\n")
    j answer_is_yes
 no_problem:
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
    print_str("please enter the file path to compress.\n")
 j end_error_message
error_message:
    print_str("file doesn't exist...please enter file path again.\n")
end_error_message:
 #we will first count the number of words in the file
  #jal count_words_in_file_contents
    #print the number of words in the file
     #Read file path from user input
    li $v0, 8
    la $a0, compression_path
    li $a1, 256
    syscall
   	la $a0,compression_path
	jal DeleteNewLine
    # Open file for reading
    li $v0, 13
    la $a0, compression_path
    li $a1, 0
    syscall
    move $s1, $v0 #file descriptor for file to read from
    #if file doesn't exist then print error message and take file path again
    beq $v0, -1, error_message        
    #we will load the file contents into buffer and print it
    li $v0, 14
    move $a0, $s1
    la $a1, c_file_contents
    li $a2, 4096
    syscall
    print_str("file contents:\n")
    li $v0, 4
    la $a0, c_file_contents
    syscall
    # Close the file
    li $v0, 16
    move $a0, $s1
    syscall
    #now we will count the number of words in the file
    #jal count_words
    #print the number of words in the file
   # print_str("there are ")
   # li $v0, 1
   # move $a0, $s1
   # syscall
   # print_str(" words in the file.\n")
    #now we will store the words in the array
    la $a0,c_file_contents
    jal store_words_in_array
    #now we will print the array
    jal print_array
     j take_option
answer_is_decompress:
    print_str("please enter the file path to decompress.\n")
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
    print_str("\n")
    print_str("\n")
    print_str(" 1.does the dictionary.txt file exist or not.\n")
    print_str(" 2.if yes,then enter the file path.\n")
    print_str(" 3.if no,then create a new dictionary.txt file.\n")
    print_str(" 4.choose compression or decompression:\n")
    print_str(" 5.quit the program (quit/q) case insensitve\n")
    jr $ra

count_words:
#each special character is a word
#keep taking characters from a to z and A to Z
#if a special character is found then increment the counter
move $t0,$a0
li $s1,0
li $s2,0 #if there is a space then s2 > 1
count_chars:
lb $t1,($t0)
beq $t1,' ',space_found
returns_from_space_found:
beqz $t1,done_counting_words
sge $t2,$t1,'a'
sle $t3,$t1,'z'
and $t2,$t2,$t3 #the char is alphabetical
sge $t3,$t1,'A'
sle $t4,$t1,'Z'
and $t3,$t3,$t4 #the char is alphabetical
or $t2,$t2,$t3 #the char is alphabetical
beqz $t2,not_alphabetical
addi $t0,$t0,1
j count_chars
not_alphabetical:
addi $s1,$s1,1
addi $t0,$t0,1
j count_chars
space_found:
seq $s2,$t1,' ' #if space is found then s2 ==  1
j returns_from_space_found
done_counting_words:
#if space is found then increment the counter
addu $s1,$s1,$s2
jr $ra

#we will write a proc that compares input choice with the options
#and returns the corresponding value

compare_strings_with_case:
    #input string in a0 and string to compare with in a1
    #output 1 if equal and 0 if not equal
    move $t0,$a0
    move $t1,$a1
    li $t2,0

#returns 0 if equal and 1 if not equal
loop_compare:
    lb $t3,($t0)
    lb $t4,($t1)
    beqz $t3,done_compare
    beq $t3,'\n',done_compare
    beqz $t4,done_compare
    seq $t5,$t3,$t4
    addi $t4,$t4,32 # to count for capital letters
    seq $t6,$t3,$t4
    or $t5,$t5,$t6
    beqz $t5,not_equal
    addi $t0,$t0,1
    addi $t1,$t1,1
    j loop_compare
not_equal:
    li $t2,1
done_compare:
    move $v0,$t2
jr $ra

#procedure to store words in the array
#procedure to store words in the array
#procedure to store words in the array
store_words_in_array:
    la $t0, array_from_buffer  # array address
    li $t6, 0                  # word count
    li $t8, 0                  #index
    la $t1, c_file_contents    # buffer address

store_loop:
    lb $t2, ($t1)              # load character from buffer
    beqz $t2, done_storing_words_1  # if null character, exit loop
    beq $t2, '\n', done_storing_words_1  # if newline character, exit loop
    sge $t3, $t2, 'a'          # check if the character is alphabetical
    sle $t4, $t2, 'z'
    and $t3, $t3, $t4
    sge $t4, $t2, 'A'
    sle $t5, $t2, 'Z'
    and $t4, $t4, $t5
    or $t3, $t3, $t4           # the character is alphabetical if not zero

    beqz $t3, not_alphabetical_1  # if the character is not alphabetical, skip storing
    sb $t2, ($t0)              # store the character in the array
    addi $t0, $t0, 1           # move to the next byte within the current array cell
    addi $t1, $t1, 1           # move to the next character
    j store_loop               # jump to the beginning of the loop
not_alphabetical_1:
    addi $t8, $t8, 1           # increment index
    #calculate the next word index and store the special character
    li $t9,'\n'
    sb $t9,($t0)
    la $t0, array_from_buffer  # array address
    sll $t7, $t8, 6            # calculate the word index
    addu $t0, $t0, $t7         # move to the next array cell
    sb $t2, ($t0)              # store the special character in the array
    li $t2,'\n'
    sb $t2,1($t0)
    addi $t1, $t1, 1
    addi $t8, $t8, 1  
    la $t0, array_from_buffer  # array address
    sll $t7, $t8, 6            # calculate the word index
    addu $t0, $t0, $t7         # move to the next array cell
               # move to the next character
    j store_loop               # jump to the beginning of the loop
done_storing_words_1:
    jr $ra                     # return from the procedure



#procedure to print the array
print_array:
    la $t0, array_from_buffer  # array address
    li $t1, 0                  # initialize counter
print_loop:
    lb $t2, ($t0)              # load byte from array
    beq $t2,'\n',new_word
    beqz $t2, done_printing   # if null character, exit loop

    li $v0, 11                # syscall code for printing a character
    move $a0, $t2             # load the byte to print into $a0
    syscall

    addi $t0, $t0, 1          # move to the next byte in the array
  

    j print_loop              # jump to the beginning of the loop

new_word:
    addi $t1, $t1, 1          # increment counter
    sll $t3, $t1, 6           # calculate the word index
    la $t0,array_from_buffer
    addu $t0, $t0, $t3        # move to the next array cell
    j print_loop              # jump to the beginning of the loop

done_printing:
 li $v0, 11                # syscall code for printing a character
    li $a0, '\n'            # load the byte to print into $a0
    syscall
    jr $ra












#DATA SECTION
.data

dictionary_path:	.asciiz   "dictionary.txt"
yes:    .asciiz   "YES"
no:     .asciiz   "NO"
compress:      .asciiz   "COMPRESS"
decompress:      .asciiz   "DECOMPRESS"
quit:      .asciiz   "QUIT"
option:	.space 100              #Allocate memory for file path buffer
file_path:      .space 256           # Allocate memory for file path buffer
file_contents:  .space 2048          # Allocate memory for file contents
compression_path: .space 256        #path to the file that we want to compress
c_file_contents: .space 2048        #path to the compressed file
dictionary_array: .space 6400
array_from_buffer: .space 3200 # can store up to 50 words at a t

