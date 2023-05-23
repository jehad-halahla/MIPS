#	this code was written by: jehad halahla, masa itmazi
#	last edit May 22 23:45
#	ID: 1201467, 1200814
#
#	PROJECT IS ALMOST COMPLETE !
#
#############################################################
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
     print_str("Enter the file name and path:")
     
    # Read the file name and path from the terminal
    li $v0, 8
    la $a0, new_file_path
    li $a1, 256
    syscall
    la $a0,new_file_path
    jal DeleteNewLine
    

    # Open the file for writing
    li $v0, 13             # Load the system call number for opening a file
    la $a0, new_file_path       # Load the address of the filename buffer
    li $a1, 1              # Load the file access mode (1 for write-only)
    li $a2, 0              # Load the file permission (not used in this case)
    syscall                # Execute the system call

    # Check if the file was successfully opened
    bltz $v0, file_error   # Branch if $v0 < 0, indicating an error
    blez $v0, take_option
j take_option
    # File was successfully opened
    # $v0 contains the file descriptor

    # Close the file
    li $v0, 16             # Load the system call number for closing a file
    move $a0, $v0          # Move the file descriptor to $a0
    syscall                # Execute the system call
 

file_error:
    # An error occurred while opening the file
    #display an error message
    print_str("error while creating new file please enter file name and path again ") 
     j answer_is_no

answer_is_quit:
    print_str("thank you for using our program...\n")
j end_program

answer_is_yes:
	print_str("please enter dictionary path:\n")
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
    la $a1, dictionary_buffer
    li $a2, 4096
    syscall
    print_str("dictionary contents:\n")
    li $v0, 4
    la $a0, dictionary_buffer
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
    # Close the file
    li $v0, 16
    move $a0, $s1
    syscall
    
    la $a0,c_file_contents
    jal store_words_in_array
    print_str("\n")
    print_str("\n")

    #we will only add the words that are not in the dictionary

    la $a1,dictionary_buffer #dictionary buffer address
    la $a0,array_from_buffer
    lb $s3,0($a0)
    beqz $s3,done_with_words
    li $s0,0 #array index
add_to_dictionary:
    lb $s3,0($a0)
    beqz $s3,done_with_words
    jal check_if_word_is_in_dictionary
    addiu $s0,$s0,1
    move $t0,$v0 #if t0 == 1 then the word is in the dictionary
    beqz $t0,word_not_found
    j word_found
word_not_found:
    #we will add the word to the end of the dictionary
    #we will first find the end of the dictionary
    #we will use a procedure to find the end of the dictionary and store the address in $v0
    jal append_word_to_dictionary
    #now we will print the dictionary buffer 
    #increment the array address to the next word
    la $t1, array_from_buffer  # array address
    sll $s1, $s0, 6            # calculate the word index
    addu $t1,$t1,$s1
    move $a0,$t1
    j add_to_dictionary

word_found:
    #we will add the code of the word to the codes array
    #line number is in $v1
    #we will store the code as a 2 byte number in the codes array
    move $s4,$s0
    subiu $s4,$s0,1
    sb $v1,codes_array($s4)
    la $t1, array_from_buffer  # array address
    sll $s1, $s0, 6            # calculate the word index
    addu $t1,$t1,$s1
    move $a0,$t1
    j add_to_dictionary
done_with_words:
    print_str("\n all done \n")
    #we will write the dictionary to the file
    # Open file for writing
    li $v0, 13
    la $a0, dictionary_path
    li $a1, 1
    li $a2, 0
    syscall

    move $s0, $v0        # Save file descriptor in $s0
    # Write buffer contents to file
    #we will make a loop to find length of the dictionary buffer
    la $a0,dictionary_buffer
    li $s2,0 #length of dictionary buffer

loop_find_length:
    lb $t1,($a0)
    beqz $t1,done_find_length
    addiu $a0,$a0,1
    addiu $s2,$s2,1
    j loop_find_length
done_find_length: 

    li $v0, 15
    move $a0, $s0
    la $a1, dictionary_buffer
    move $a2, $s2
    syscall
    #close the file
    li $v0, 16
    move $a0, $s2
    syscall

    #now we will compress the file by first generating a code for each word in the array
    la $a0,codes_array        
    #we will use a procedure to convert to hex
    la $a1,hex_codes
    la $a2,codes_array
    li $s1,0 #index
loop_converter:
    lb $t1,($a2)
    beqz $t1,done_converting
    move $a0,$t1
    jal convertToHex
    addiu $a2,$a2,1
    addiu $s1,$s1,1
    #we will also advance the hex_codes address
    la $a1,hex_codes
    sll $t2,$s1,3
    addu $a1,$a1,$t2
    j loop_converter
done_converting:

    #we have the index so we can now write the codes array to the file

    move $t0,$s1 #index

    #calculate the size using index and sll
    sll $t1,$t0,3
    li $v0, 13
    la $a0, compressed_file_path
    li $a1, 1
    syscall
    move $s0, $v0        # Save file descriptor in $s0
    #we will write the codes array to the file
    li $v0, 15
    move $a0, $s0
    la $a1, hex_codes
    move $a2, $t1
    syscall
    #close the file
    li $v0, 16
    move $a0, $s0
    syscall  

    #we will calculate the compression ratio
    #size of compressed file is the number of codes * 2
    sll $t2,$t0,1 #size of compressed file
    #we will loop in the c_file_contents array and count the number of characters to find uncompressed file size
    la $a0,c_file_contents
    li $t3,0
count_letters:
    lb $t1,($a0)
    beqz $t1,done_counting_letters
    addiu $a0,$a0,1
    addiu $t3,$t3,1
    j count_letters
done_counting_letters:
    #we will use floating point division to calculate the compression ratio
    sll $t3,$t3,1
    mtc1 $t2,$f0
    mtc1 $t3,$f2
    cvt.s.w $f0,$f0
    cvt.s.w $f2,$f2
    div.s $f4,$f2,$f0
   
    #we will print the compression ratio
    print_str("compression ratio is:\n")
    li $v0, 2
    mov.s $f12,$f2
    syscall
    print_str("%\n")


     j take_option

answer_is_decompress:
    print_str("output at decompressed.txt....\n")
   
    #we will itterate over codes and get the corresponding word from the dictionary
    la $a0,codes_array
    la $a1,dictionary_buffer
    la $a2,decompression_buffer

move $t0,$a0 #codes buffer address

loop_decompress:
    lb $t1,($t0)
    beqz $t1,done_decompressing
    #now $t1 has the line that we need
    #we will itterate over the dictionary and find the word
    move $t4,$a1 #we will save the dictionary buffer address in $t4
    li $s2,1 #index
loop_dictionary:
    lb $t2,($t4)
    beqz $t2,loop_decompressing
    beq $t1,$s2,got_word
loop_untill_line:
    lb $t2,($t4)
    beq $t2,'\n',increment_index
    addiu $t4,$t4,1
    j loop_untill_line
increment_index:
    addiu $s2,$s2,1
    addiu $t4,$t4,1
    j loop_dictionary
got_word:
    #loop store word in decompression buffer
    move $t5,$t4
loop_store_word:
    lb $t6,($t5)
    beq $t6,'\n',loop_decompressing
    sb $t6,($a2)
    addiu $t5,$t5,1
    addiu $a2,$a2,1
    j loop_store_word
loop_decompressing:
    addiu $t0,$t0,1
    j loop_decompress
done_decompressing:
     #we will open the file for writing
    li $v0, 13
    la $a0, decompressed_file
    li $a1, 1
    syscall
    move $s0, $v0        # Save file descriptor in $s0
    # Write buffer contents to file
    la $a0,c_file_contents
    li $t3,0
count_letters_1:
    lb $t1,($a0)
    beqz $t1,done_counting_letters_1
    addiu $a0,$a0,1
    addiu $t3,$t3,1
    j count_letters_1
done_counting_letters_1:
    #length is in $t3

    li $v0, 15
    move $a0, $s0
    la $a1, decompression_buffer
    move $a2, $t3
    syscall
    #close the file
    li $v0, 16
    move $a0, $s0
    syscall
    
    j take_option

    

end_program:
    # Exit program
    terminate(0)
    


DeleteNewLine:
	lb $t0,($a0)
	beq $t0,'\n',here
	addi $a0,$a0,1
	j DeleteNewLine

#PROCEDURES SECTION

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
print_menu_end:

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
count_words_end:


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
compare_strings_with_case_end:

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
    addiu $t0, $t0, 1           # move to the next byte within the current array cell
    addiu $t1, $t1, 1           # move to the next character
    j store_loop               # jump to the beginning of the loop
not_alphabetical_1:
    addiu $t8, $t8, 1           # increment index
    #calculate the next word index and store the special character
    li $t9,'\n'
    sb $t9,($t0)
    la $t0, array_from_buffer  # array address
    sll $t7, $t8, 6            # calculate the word index
    addu $t0, $t0, $t7         # move to the next array cell
    sb $t2, ($t0)              # store the special character in the array
    li $t2,'\n'
    sb $t2,1($t0)
    addiu $t1, $t1, 1
    addiu $t8, $t8, 1  
    la $t0, array_from_buffer  # array address
    sll $t7, $t8, 6            # calculate the word index
    addu $t0, $t0, $t7         # move to the next array cell
               # move to the next character
    j store_loop               # jump to the beginning of the loop
done_storing_words_1:
    #end the last word with a \n
    li $t2,'\n'
    sb $t2,($t0)
    sb $zero,1($t0)
    jr $ra                     # return from the procedure
store_words_in_array_end:


check_if_word_is_in_dictionary:
    # Input string in $a0 and string to compare with in $a1
    move $t0, $a0  # Array address
    move $t1, $a1  # Dictionary buffer address
    li $t9,1 #line that word is found in is its code

restart_search:
    #print the line we are searching in
    li $t6, 1

start_search:
    lb $t3, ($t1)  # Load the current dictionary char
    lb $t4, ($t0)  # Load the current array char
    # If the dictionary word is done, we go to the next dictionary word
    beq $t3, '\n', next_dictionary_word
    beq $t4, '\n',next_dictionary_word

    # If null character, exit loop
    beqz $t4, done_search

    seq $t5, $t3, $t4
    and $t6, $t5, $t6  # Update the flag indicating if the word is in the dictionary
    addiu $t0, $t0, 1
    addiu $t1, $t1, 1
    j start_search

next_dictionary_word:
    # If the current dict char is '\n', increment the dictionary address
    # If the current dict char is not '\n', loop until you find '\n'
    # If $t6 == 1, then the word is in the dictionary
    #if t4 is not \n then words are not equal
    seq $t5, $t4, '\n'
    seq $t8,$t3,'\n'
    and $t6, $t5, $t6
    and $t8,$t6,$t8
    bnez $t8, word_is_in_dictionary

loop_until_newline:
    lb $t3, ($t1)
    beqz $t3, done_search  # Exit loop if null character is encountered
    beq $t3, '\n', increment_dictionary_address
    addiu $t1, $t1, 1
    j loop_until_newline

increment_dictionary_address:
    move $t0, $a0
    addiu $t9,$t9,1
    addiu $t1, $t1, 1
    j restart_search
    #we reset the array address to the beginning of the array

word_is_in_dictionary:
    # If $t6 == 1, then the word is in the dictionary
    # If $t6 == 0, then the word is not in the dictionary
    move $v0, $t6  # Set the return value to $t6 indicating if the word is in the dictionary
    move $v1, $t9
    jr $ra

done_search:
    # If $t6 == 1, then the word is in the dictionary
    # If $t6 == 0, then the word is not in the dictionary
    move $v0, $t6  # Set the return value to $t6 indicating if the word is in the dictionary
     move $v1, $t9
    jr $ra
check_if_word_is_in_dictionary_end:


#procedure to find end of dictionary
find_end_of_dictionary:
#init a counter to 0
    li $s5,0
    move $t0,$a1 #dictionary buffer address
loop_find_end:
    lb $t1,($t0)
    beqz $t1,done_find_end
    addiu $t0,$t0,1
    addiu $s5,$s5,1
    j loop_find_end
done_find_end:
    move $v0,$t0
    move $v1,$s5
    b dict_end_found

#procedure to add word to dictionary
append_word_to_dictionary:
#word is stored in $a0
#dictionary buffer address is stored in $a1
#we will first find the end of the dictionary
    b find_end_of_dictionary
dict_end_found:
    move $t0,$v0 #end of dictionary address
    move $t1,$a0 #word address
append_loop:
    lb $t2,($t1)
    beqz $t2,done_append
    sb $t2,($t0)
    addiu $t0,$t0,1
    addiu $t1,$t1,1
    j append_loop
done_append:
    sb $t2,($t0)
    sb $zero,1($t0)
    move $s2,$t0 #dictionary buffer address
    move $t1,$a0
    #number of charachters is stored in $t1
    #address difference is stored in $t3
    jr $ra
append_word_to_dictionary_end:

convertToHex:
	#first we format
	li $t0,'0'
	li $t1,'x'
	sb $t0,($a1)
	sb $t1,1($a1)
	
	andi $t0,$a0,15
	lb $t2,numbers($t0)
	sb $t2,6($a1)
	srl $a0,$a0,4
	
	andi $t0,$a0,15
	lb $t2,numbers($t0)
	sb $t2,5($a1)
	srl $a0,$a0,4
	
	andi $t0,$a0,15
	lb $t2,numbers($t0)
	sb $t2,4($a1)
	srl $a0,$a0,4
	
	andi $t0,$a0,15
	lb $t2,numbers($t0)
	sb $t2,3($a1)
	srl $a0,$a0,4
	
	andi $t0,$a0,15
	lb $t2,numbers($t0)
	sb $t2,2($a1)
	
	li $t0,'\n'
	sb $t0,7($a1)

	jr $ra
convertToHex_end:	
    

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
compression_path: .space 256        #path to the file that we want to compress
c_file_contents: .space 3200        #path to the compressed file
dictionary_buffer: .space 6400
array_from_buffer: .space 6400 # can store up to 50 words 
#each code is 2 bytes and we need 50 words to give codes for so size of codes array is 100 bytes
codes_array: .space 1024
compressed_file_path: .asciiz "compressed.txt"
hex_codes: .space 1024 #max unique words are just 50
numbers: .asciiz "0123456789ABCDEF"
new_file_path:      .space 256           # Allocate memory for the created file path buffer
decompression_buffer: .space 3200
decompressed_file: .asciiz "decompressed.txt"