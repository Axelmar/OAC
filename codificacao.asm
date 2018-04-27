	.data
	msg1: .asciiz "Digite o nome do arquivo a ser codificado:"
	data1: .asciiz "data1.txt"
	
	.text	
	.globl main

main:
	#print msg1
	li	$v0, 4
	la	$a0, msg1
	syscall
	
	#get n from user and save
	#li	$v0, 8
	#la	$a0, ($v0)
	
	#li	$a1, 20
	#syscall
	#move	$t0, $v0
	#beqz 	$t0, exit
	
	#li $v0, 4
	#move $a0, $t0

	li   $v0, 13      # system call for open file
	la   $a0, data1     # output file name
	li   $a1, 1        # Open for writing (flags are 0: read, 1: write)
	li   $a2, 100        # mode is ignored
	syscall            # open a file (file descriptor returned in $v0)
	move $s6, $v0      # save the file descriptor
	
  ###############################################################
  # Write to file just opened
  li   $v0, 14       # system call for write to file
  move $a0, $s6      # file descriptor 
  la   $a1, data1	     # address of buffer from which to write
  li   $a2, 100       # hardcoded buffer length
  syscall            # write to file
	 move $s1, $v0
	
	 li $v0, 4
	 move $a0, $s1
	 syscall
	
	
exit: