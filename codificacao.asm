	.data
	msg1: .asciiz "Digite o nome do arquivo a ser codificado:"
	arquivo: .space 20
	buffer: .space 1024
	erro: .asciiz "Nao foi possivel abrir o arquivo"
	data1: .asciiz "data1.txt"
	
	.text	
	.globl main

main:
	#Mensagem para receber nome do arquivo
	li	$v0, 4
	la	$a0, msg1
	syscall
	
	#Pega o nome do arquivo  #----------------- da erro na hora de abrir o arquivo
	li	$v0, 8
	la	$a0, arquivo
	li	$a1, 20
	syscall
	
	################################################################## ATE AKI ESTA TUDO CERTO

	#Abre o arquivo para compilação
	li   $v0, 13      # system call for open file
	la   $a0, data1     # output file name
	li   $a1, 0        # Open for writing (flags are 0: read, 1: write)
	li   $a2, 0        # mode is ignored
	syscall            # open a file (file descriptor returned in $v0)
	move $s6, $v0      # save the file descriptor
	bltz $s6, error
	
	#Le o arquivo
	li $v0, 14	# system call for read from file
	move $a0, $s6	# file descriptor
	la $a1, buffer	# endereço do input buffer
	li $a2, 1024	# numero de caracteres a serem lidos
	syscall
	
	
	
		
error: li $v0, 4
	la $a0, erro
	syscall		
	
exit: