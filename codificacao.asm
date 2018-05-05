	.data
	msg1: .asciiz "Digite o nome do arquivo a ser codificado:"
	arquivo: .space 20
	buffer: .space 1024
	erro: .asciiz "Nao foi possivel abrir o arquivo"
	dicionario: .space 1024
	
	
	
	data1: .asciiz "data1.txt"
	
	.text	
	.globl main


.macro ABRIR_ARQUIVO(%nome_arquivo, %rw, %mode)
	#%rw 0 ler, 1 escrever

	li   $v0, 13      # system call for open file
	la   $a0, %nome_arquivo     # output file name
	li   $a1, %rw        # Open for writing (flags are 0: read, 1: write)
	li   $a2, %mode        # mode is ignored
	syscall            # open a file (file descriptor returned in $v0)
	move $s6, $v0      # save the file descriptor
	bltz $s6, error
.end_macro


main:
	#Mensagem para receber nome do arquivo
#	li	$v0, 4
#	la	$a0, msg1
#	syscall
	
	#Pega o nome do arquivo  #----------------- da erro na hora de abrir o arquivo
#	li	$v0, 8
#	la	$a0, arquivo
#	li	$a1, 20
#	syscall
	

	#Abre o arquivo para compilação
	ABRIR_ARQUIVO(data1, 0, 0)
	
	#Le o arquivo
	li $v0, 14	# system call for read from file
	move $a0, $s6	# file descriptor
	la $a1, buffer	# endereço do input buffer
	li $a2, 3	# numero de caracteres a serem lidos
	syscall
	
	############################################################################### LW78
	la $s0, dicionario
	la $s1, buffer
	
	li $v0, 4
	la $a0, buffer
	syscall
	
	move $t0, $s0
	move $t1, $s1
	
	
	#Pega o tamanho do buffer --- acho q ele sai do vetor
	li $t3, 0
tamanho: lb      $t2, buffer($t3)
	add     $t3, $t3, 1
	bne     $t2, $zero, tamanho
	
	
	#Percorre o buffer
Loop:	sll $t4, $s3, 2
	add $t4, $t4, $s1
	lb $t5, 0($t4)	
	beq $t3, $s3, exit
	addi $s3, $s3, 1
	j Loop
	
	
	
	
	j exit
	
	
		
error: li $v0, 4
	la $a0, erro
	syscall		
	
exit:
	li $v0, 10
	syscall
