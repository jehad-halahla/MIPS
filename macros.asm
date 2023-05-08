#this file will include some functions to help with the data cleaning process

.macro terminate (%termination_value)
		li $a0, %termination_value
		li $v0, 17
		syscall
.end_macro	

#this function will print an integer

.macro print_int (%x)
	li $v0, 1
	add $a0, $zero, %x
	syscall
.end_macro

#this function will print a string

.macro print_str (%str)
	.data
myLabel: .asciiz %str
	.text
	li $v0, 4
	la $a0, myLabel
	syscall
.end_macro