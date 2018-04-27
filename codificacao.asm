	.data
	msg1: .asciiz "Digite o nome do arquivo a ser codificado:"	
	
	.text	
	.globl main

main:
	#print msg1
	li	$v0, 4
	la	$a0, msg1
	syscall
	
	#get n from user and save
	li	$v0, 5
	syscall
	move	$t0, $v0
	beqz 	$t0, exit