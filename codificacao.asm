	.data
	separador: .byte 0x1D
	msg1: .asciiz "Digite o nome do arquivo a ser codificado:"
	arquivo: .space 20
	buffer: .space 1024
	erro: .asciiz "Nao foi possivel abrir o arquivo"
	dicionario: .space 1024
	cadeia: .space 10
	ext_saida: .asciiz "lzw"
	arq_saida: .space 25
	enter: 		.asciiz "\n"
	barra_zero: 	.asciiz "\0"
	char_saida:	.space 1
	index:		.space 1
	.text	
	.globl main


.macro ABRIR_ARQUIVO(%nome_arquivo, %rw, %mode)
	#%rw 0 ler, 1 escrever

	li   $v0, 13      
	la   $a0, %nome_arquivo    
	li   $a1, %rw        
	li   $a2, %mode        
	syscall            
	move $s6, $v0      
	bltz $s6, error
.end_macro

.macro ESCREVER_ARQUIVO(%char)
	li $v0, 15
	move $a0, $s6
	la $a1, %char
	li $a2, 1
	syscall
.end_macro

.macro ESTA_DICIONARIO(%char)
Loop:	move $t8, $s4
	add $t8, $t8, $s0
	lb $t9, 0($t8)		
	beqz $t9, acabou
	beq $t9, $s3, achousep		
	beq $t9, %char, continua
	addi $s4, $s4, 1
	j acabou

	
			
achousep:addi $s4, $s4, 1
	addi $s2, $s2, 1
	addi $t8, $t8, 1
	lb $t9, 0($t8)
	beq $t9, $t3, continua
	beq $t3, $s3, acabou
	j Loop
	
acabou:
	sb $s3, 0($t7)		#coloca o separador
	addi $t7, $t7, 1
	jal concatena
	sb $s3, 0($t7)		#coloca o separador
	
	sb $t4, index
	ESCREVER_ARQUIVO(index)
	sb %char, char_saida
	ESCREVER_ARQUIVO(char_saida)
	li $t5, 0
.end_macro


.macro ADICIONAR_EXTENSAO(%origem, %destino)
	# empilhando
    	addi $sp, $sp, -8  
	sw %origem, 0($sp)		
	sw %destino, 4($sp)     	
	
loop:
	lb $s5, 0(%origem)		
	sb $s5, 0(%destino)		

	addi %origem, %origem, 1	
	addi %destino, %destino, 1	

	bne $s5, '.', loop 	
# final do loop
	
	la %origem, ext_saida
ext:	lb $s5, 0(%origem)
	sb $s5, 0(%destino)
	
	addi %origem, %origem, 1
	addi %destino, %destino, 1
	
	bne $s5, $zero, ext
	
	#desempilhando
	lw %origem, 4($sp)     	
	lw %destino, 0($sp)		
    	addi $sp, $sp, 8   
			
.end_macro

main:
	#Mensagem para receber nome do arquivo
	li	$v0, 4
	la	$a0, msg1
	syscall
	
	#Pega o nome do arquivo 
	li	$v0, 8
	la	$a0, arquivo
	li	$a1, 20
	syscall
	
	la $t0, arquivo
 	lb $t2, enter	 
 	lb $t3, barra_zero
enquanto_dif_enter:
       	lb   $t1, 0($t0)
	beq  $t1, $t2, Limpando
       	addi $t0, $t0, 1
       	j enquanto_dif_enter
       	       		
Limpando:
	la $t1, arquivo
	sub $s6, $t0, $t1  
	sb $t3, 0($t0)
	

	#Abre o arquivo para compilação
	ABRIR_ARQUIVO(arquivo, 0, 0)
	
	#Le o arquivo
	li $v0, 14	
	move $a0, $s6	
	la $a1, buffer	
	li $a2, 20	
	syscall
	
	li $v0, 16
	syscall
	
	## Abre arquivo de saida para escrita
	la $t6, arquivo
	la $t7, arq_saida
	ADICIONAR_EXTENSAO($t6, $t7)

	ABRIR_ARQUIVO(arq_saida, 1, 0)	
	li $t6, 0
	li $t7, 0
	############################################################################### LW78
	la $s0, dicionario
	la $s1, buffer
	la $s2, cadeia
	la $s3, separador
	move $t0, $v0			
	move $t7, $s0

	#Percorre o buffer
encode:	move $t2, $s7
	add $t2, $t2, $s1
	lb $t3, 0($t2)		
	sb $t3, 0($s2)
	ESTA_DICIONARIO($t3)
	
continua: 
	beq $t0, $s7, exit		
	addi $s7, $s7, 1
	j encode					
						
concatena:	
	# empilhando
    	addi $sp, $sp, -4  
	sw $s2, 0($sp)		
	
loop:
	lb $s5, 0($s2)		
	sb $s5, 0($t7)		
	addi $s2, $s2, 1	
	addi $t7, $t7, 1	
	bne $s5, $zero, loop 	
# final do loop
	
	#desempilhando
	lw $s2, 0($sp)		
    	addi $sp, $sp, 4   
	jr $ra	
		
error: 
	li $v0, 4
	la $a0, erro
	syscall		
	
exit:
	li $v0, 10
	syscall
