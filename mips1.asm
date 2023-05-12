.data
file_path:      .space 256           # Allocate memory for file path buffer
file_contents:  .space 4096          # Allocate memory for file contents

msg_prompt:     .asciiz "Enter file path: "
msg_output:     .asciiz "File contents:\n"

.text
.globl main

main:
    # Display prompt message
    li $v0, 4
    la $a0, msg_prompt
    syscall

    # Read file path from user input
    li $v0, 8
    la $a0, file_path
    li $a1, 256
    syscall

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

    # Display output message
    li $v0, 4
    la $a0, msg_output
    syscall

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
