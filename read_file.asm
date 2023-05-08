#this code reads a file in the same directory


#DATA SECTION
.data
.align 2
fileNameW: .asciiz "/home/jehad_halahla/Desktop/mips_32_programming/write.txt"  
fileName: .asciiz "/home/jehad_halahla/Desktop/mips_32_programming/read.txt" #it is prefered to use absolute paths
line: .space 1024

#CODE SECTION
.text 
.globl main
main:

li $v0,13
la $a0,fileNameW
li $a1, 9           # file flags for append mode
syscall
move $t2,$v0 #save the file descriptor in a temp register

#we will open the read.txt file for reading first
li $v0,13
la $a0,fileName
li $a1,0
syscall
move $t1,$v0 #save the file descriptor in a temp register

#reading from file to the buffer line

li $v0,14
move $a0,$t1
la $a1,line
li $a2,1024
syscall

#now wo will print the buffer "line" that now contains contents of file up to 1024 characters
li $v0,4
la $a0,line
li $a1,1024
syscall

#now we will print to the file the buffer line contents
li $v0,15
move $a0,$t2
la $a1,line
li $a2,20
syscall

#we will close the file so the contents update
li $v0,16
move $a0,$t2
syscall 

li $v0,16
move $a0,$t1
syscall 

#END OF CODE SECTION
li $v0,10
syscall 

