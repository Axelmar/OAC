	.data
	msg1: .asciiz "Digite o nome do arquivo a ser codificado:"
	arquivo: .space 20
	buffer: .space 1024
	erro: .asciiz "Nao foi possivel abrir o arquivo"
	fdic: .asciiz "dicionario.txt"
	dicionario: .space 20
	cadeia: .space 10
	
	
	
	data1: .asciiz "teste.txt"
	
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

.macro ESTA_DICIONARIO(%char)
Loop:	LE_ARQUIVO(dicionario, 10)
move $t8, $s4
	add $t8, $t8, $s0
	lb $t9, 0($t8)		#le um character
	beq $t9, %char, existe	
	beq $t4, $s4, acabou
	addi $s4, $s4, 1
	j Loop
	
existe:	sb %char, cadeia($t5)		#se existe guarda o char na cadeia
	addi $t5, $t5, 1
	move $s7, $s4			#salva o index de referencia
	j continua
acabou:

.end_macro

.macro ESCREVER_ARQUIVO(%string, %tam)
	#Escrever no arquivo
	li $v0, 15
	move $a0, $s6
	la $a1, %string
	move $a2, %tam
	syscall
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
	li $a2, 20	# numero de caracteres a serem lidos
	syscall
	
	move $t1, $v0	#tamanho do buffer
	
	li $v0, 16
	syscall
	ABRIR_ARQUIVO(fdic, 0, 0)
	
	############################################################################### LW78
	la $s1, buffer
	
	
	########## VENDO O Q TEM NO BUFFER
	li $v0, 4
	la $a0, buffer
	syscall
	
	li $v0, 11
	
	#Percorre o buffer
encode:	move $t2, $s3
	add $t2, $t2, $s1
	lb $t3, 0($t2)		#le um character
	li $s4, 0
	ESTA_DICIONARIO($t3)
continua: 
	
	
	#move $a0, $t3
	#syscall
	
	beq $t1, $s3, exit		#s3 eh o contador t1 eh o tamanho
	addi $s3, $s3, 1
	j encode
	
	
		
error: li $v0, 4
	la $a0, erro
	syscall		
	
exit:
	li $v0, 10
	syscall
