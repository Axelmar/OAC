	.data
	separador: .byte 0x1E
	msg1: .asciiz "Digite o nome do arquivo a ser codificado:"
	arquivo: .space 20
	buffer: .space 1024
	erro: .asciiz "Nao foi possivel abrir o arquivo"
	dicionario: .space 1024
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
Loop:	move $t8, $s4
	add $t8, $t8, $s0
	lb $t9, 0($t8)		#le um character do dicionario
	beqz $t9, acabou
	beq $t9, $s3, achousep		#se for o separador
	beq $t9, %char, continua
	j acabou

	
			
achousep:addi $t8, $t8, 1
	addi $t4, $t4, 1
	lb $t9, 0($t8)
	beq $t9, $t3, continua
	beq $t3, $s3, acabou
	j Loop
	
carregachar: move $t2, $s7
	add $t2, $t2, $s1
	lb $t3, 0($t2)		#le um character
	jr $ra	

acabou:
	sb $s3, dicionario($t4)		#coloca o separador
	jal strcpy
	sb $s3, dicionario($t4)		#coloca o separador
	li $v0, 1
	move $a0, $t4
	syscall
	li $v0, 11
	move $a0, %char
	syscall
	li $t5, 0
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
	
	############################################################################### LW78
	la $s0, dicionario
	la $s1, buffer
	la $s2, cadeia
	la $s3, separador
	move $t0, $v0			#t0 recebe o tamanho do buffer
	
	########## VENDO O Q TEM NO BUFFER
	li $v0, 4
	la $a0, buffer
	syscall

	
	#subi $t1, $t1, 1
	li $v0, 11
	
	#Percorre o buffer
encode:	move $t2, $s7
	add $t2, $t2, $s1
	lb $t3, 0($t2)		#le um character
	sb $t3, 0($s2)
	addi $s2, $s2, 1
	ESTA_DICIONARIO($t3)
continua: 
	
	
	#move $a0, $t3
	#syscall
	
	beq $t0, $s7, exit		#s3 eh o contador t0 eh o tamanho
	addi $s7, $s7, 1
	j encode

	
		
			
				
					
						
strcpy:	
	# empilhando
    	addi $sp, $sp, -8  # 0x23bdfff4 desloca 12 bytes para inserir 3 palavras na pilha
	#sw $s0, 0($sp)		# 0xafa40000 empilha $a0 destino
	sw $s2, 0($sp)		# 0xafa50004 empilha $a1 origem
	sw $a3, 4($sp)     	# 0xafb00008 empilha $s0 contador
	
loop:
	lb $s4, 0($s2)		# 0x80b10000 $s1 = primeiro caracter da string origem
	sb $s4, 0($s0)		# 0xa0910000 memoria[a0] = $s1  (copia o caracter para a string destino)

	addi $s2, $s2, 1	# 0x20a50001 incrementa endereco da string origem
	addi $s0, $s0, 1	# 0x20840001 incrementa endereco da string destino

	bne $s4, $zero, loop 	# 0x1620fffb repita ate string origem encontrar o '\0'
# final do loop
	
	#desempilhando
	lw $a3, 4($sp)     	# 0x8fb00008 recupera $s0 original da pilha
	lw $s2, 0($sp)		# 0x8fa50004 recupera $a1 original da pilha
	#lw $s0, 0($sp)		# 0x8fa40000 recupera $a0 original da pilha
    addi $sp, $sp, 8   # 0x23bd000c volta 12 bytes para retirar 3 palavras na pilha
		
	jr $ra				# 0x03e00008 retona para a main	
	
		
error: li $v0, 4
	la $a0, erro
	syscall		
	
exit:
	################# testar dicionario apagar dps
	li $v0, 4
	la $a0, dicionario
	syscall
	#################
	li $v0, 10
	syscall
