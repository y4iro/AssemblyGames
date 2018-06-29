
PINTA MACRO COLUMNA, FILA, COLOR, TEXTO, TAM
	;IMPRIMIR EL TABLERO
	MOV AL,00H
	MOV BH,00H
	MOV BL,COLOR
	MOV CX,TAM
	MOV DL,COLUMNA
	MOV DH,FILA
	MOV ES,DATAUSER	
	MOV BP,OFFSET TEXTO
	MOV AH,13H
	INT 10H
ENDM

LIMPIA MACRO
	PUSH AX
	MOV AX,0600H
	MOV BH,0F0H
	MOV CX,0
	MOV DH,24
	MOV DL,79
	INT 10H
	POP AX
ENDM

convierte macro var,len
	push ax
	mov bx,len
	dec bx
	mov cx,10
	ciclo:
	div cl
	add ah,30h
	mov var+bx,ah
	xor ah,ah
	cmp bx,0h
	je finCiclo
	dec bx
	jmp ciclo
	finCiclo:
	pop ax
endm

archivo	macro carpeta,archivo,data2,tamdata,handler
	LOCAL errorF,err2,cfile,seguimos

	mov dx,offset carpeta
	mov ah,39h
	int 21h

	mov dx,offset archivo
	mov ah,3dh
	mov al,2h
	int 21h
	jc errorF
	jmp cfile

	errorF:
	mov ah,3ch
	mov cx,0
	mov dx,offset archivo
	int 21h
	jc err2

	cfile:
	mov handler,ax

	mov ah,42h
	mov bx,handler
	mov al,2
	mov cx,0
	mov dx,0
	int 21h

	mov ah,40h
	mov bx,handler
	mov dx,offset data2
	mov cx,tamdata
	int 21h

	mov ah,3eh
	mov bx,handler
	int 21h

	jmp seguimos

	err2:
	nop

	seguimos:

endm	

sacafecha macro date
	LOCAL anio
	mov ah,2ah          ;Recuperamos fecha del sys: al(dia de semana), cx(anio), dx(mes,dia)
	int 21h

	xchg bl, al         ; bl - dia de la semana 
	mov ax,000ah
	mov bh,dl           ; bh - mes 
	mov dl,0h 
	xchg dh,dl          ; dl - dia 
	xchg dl,al          ; al - dia, dh - 10h
	div dl              ; dia / 10 --> res:decenas, mod:unidades, en AX 

	add ah,30h          ; Acomodo de numero de dos digitos en ax, acomodando en ascii
	add al, 30h         ; Acomodo en ascii
	mov date+3, al      ; Se guarda en el primer y segundo numero el dia
	mov date+4, ah

	mov dx,000ah        ; Acomodando division para mes
	mov ah,00h
	mov al,bh        
	div dl              ; En ax se almacenara el mes de dos digitos
	
	add ah,30h
	add al, 30h         ; Acomodo en ascii
	mov date, al        ; Se guardan los siguientes dos numeros
	mov date+1, ah

	mov dx,000ah        ; Acomodando division para anio (1 digito)
	mov ax,cx           ; Valor del anio inicial en ax
	mov cx,4h           ; Contador
	lea si,date+9       ; Apuntador a direccion de caracteres (guarda como 2016 al final) 

	anio:
            
    	div dl           ; Division ax/10
    	add ah,30h       ; Acomodo en ascii       
    	mov [si], ah     ; Se guarda el digito del anio
    	dec si           ; Si apunta a un numero antes
    	mov ah,0h        ; Init de ah
    	dec cx           ; Contador--
    	jnz anio

endm

.MODEL Small
.Stack 100H
.Data     
	DATAUSER DW 0	  
    	carpe db 'c:\ganadores',0
    	arch db 'c:\ganadores\gato.txt',0
    	handler dw ?
    	TACHE DB '\       / ',10,8,8,8,8,8,8,8,8,8,8,'  \   /   ',10,8,8,8,8,8,8,8,8,8,8,'    X     ',10,8,8,8,8,8,8,8,8,8,8,'  /   \   ',10,8,8,8,8,8,8,8,8,8,8,'/       \ ','$'
	CIRCULO DB ' / --- \  ',10,8,8,8,8,8,8,8,8,8,8,'|       | ',10,8,8,8,8,8,8,8,8,8,8,'|       | ',10,8,8,8,8,8,8,8,8,8,8,'|       | ',10,8,8,8,8,8,8,8,8,8,8,' \ ___ /   ','$'
	TABLERO1 DB '          |          |          ',10,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,'          |          |          ',10,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,'          |          |          ',10,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,'          |          |          ',10,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,'          |          |          ',10,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,'----------+----------+----------',10,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,'$'
	TABLERO2 DB '          |          |          ',10,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,'          |          |          ',10,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,'          |          |          ',10,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,'          |          |          ',10,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,'          |          |          ',10,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,'$'
	turno1 db ' Turno del jugador 1 '
	turno2 db ' Turno del jugador 2 '
	titulo db '  TIC TAC TOE PARA DOS JUGADORES '
	reiniciar db '  ESC = REINICIAR  '
	salir db '   ENTER = SALIR   '
	inst db ' SPACE=INSTRUCTIVO  '
	gano0 db '                     EMPATE                     '
	gano1 db '               GANO EL JUGADOR 1                '
	gano2 db '               GANO EL JUGADOR 2                '
	aviso db ' Presiona ESC para reiniciar o ENTER para salir '
	contador db 3
	px db 0h,0h,0h,0h
	py db 0h,0h,0h,0h
	x dw 0h
	y dw 0h
	fil db 0h
	col db 0h
	turno db 1h
	matriz db 0h,0h,0h,0h,0h,0h,0h,0h,0h
	gano db 0h
	archivo3 db 'Fecha: '
	fecha db 0h,0h,'/',0h,0h,'/',0h,0h,0h,0h
	gana db ' Gano jugador: '      ;34
	ganador db 0h,10,13  
	archivo2 db 'Fecha: '
	fecha2 db 0h,0h,'/',0h,0h,'/',0h,0h,0h,0h
	gana2 db ' EMPATE',10,13       ;25
	inst0 db '                     '
	inst1 db '      INSTRUCTIVO    '
	inst2 db '-Se cuentan con dos  '
	inst3 db ' tipos de fichas     '
	inst4 db ' (X o O)             '
	inst5 db '-Objetivo: lograr un '
	inst6 db ' 3 en linea ya sea   '
	inst7 db ' diagonal, horizontal'
	inst8 db ' o vertical          '
	inst9 db '-Turno a turno cada  '
	inst10 db ' jugador debera dar  '
	inst11 db ' click en la casilla	'
	inst12 db ' donde se desea      '
	inst13 db ' colocar el simbolo  '
	inst14 db ' representativo hasta'
	inst15 db ' que algun jugador	'
	inst16 db ' gane                '
	inst17 db 'ENTER PARA CONTINUAR '
.CODE
.Startup
	inicio:
	mov ax,@DATA
	mov ds,ax
	mov DATAUSER, AX

	MOV AX,0003H
	INT 10H

	mov ax,1003h
	mov bx,0
	int 10h

	mov matriz,0h
	mov matriz+1,0h
	mov matriz+2,0h
	mov matriz+3,0h
	mov matriz+4,0h
	mov matriz+5,0h
	mov matriz+6,0h
	mov matriz+7,0h
	mov matriz+8,0h

	mov turno,1h

	LIMPIA

	;TABLERO EN POSICION 20,5
	PINTA 20,1,11110100B,TITULO,33
	PINTA 56,11,01110000B,reiniciar,19
	PINTA 56,13,01110000B,salir,19
	PINTA 56,15,01110000B,inst,19

	sacafecha fecha
	pinta 60,1,11110000b,fecha,10
	sacafecha fecha2

	PINTA 20,5,11110000B,TABLERO1,357
	PINTA 20,11,11110000B,TABLERO1,357
	PINTA 20,17,11110000B,TABLERO2,300

	;habilitamos el mouse
	mov ax,1
	int 33h

	;sacamos las coordenadas del mouse
	mov ax,1003h
	mov bx,0
	int 10h

	coordenadas:

	call verifica

	cmp turno,2
	jz  t2
	PINTA 25,3,11100000B,turno1,21
	jmp sigue

	t2:
	PINTA 25,3,11100000B,turno2,21

	sigue:
	mov ah,0Bh
	int 21h
	cmp al,00h
	jne presiono

	mov ax,3
	int 33h

	mov ax,cx
 	mov x,cx
	mov y,dx


	;convierte px,4
	;PINTA 0,0,11110000B,px,4

	mov ax,3
	int 33h

	cmp bx,1
	jz click2
	
	jmp coordenadas
	click2:jmp click
	finito2:jmp finito
	vuelve2:jmp vuelve
	presiono:
	mov ah,02h
	mov dl,08h
	int 21h   
	
	mov dl,00h
	int 21h
	
	mov ax,0000h
	int 16h
	
	cmp al,0Dh
	je finito2   
	cmp al,1Bh
	je vuelve2
	cmp al,20h
	je instructivos
	jmp coordenadas

	instructivos:
	;LIMPIA
	;PINTA 20,1,11110100B,TITULO,33
	PINTA 54,1,11110000B,inst0,21 
	PINTA 54,2,11110001B,inst1,21
	PINTA 54,4,11110000B,inst2,21
	PINTA 54,5,11110000B,inst3,21
	PINTA 54,6,11110000B,inst4,21
	PINTA 54,8,11110000B,inst5,21
	PINTA 54,9,11110000B,inst6,21
	PINTA 54,10,11110000B,inst7,21
	PINTA 54,11,11110000B,inst8,21
	PINTA 54,13,11110000B,inst9,21
	PINTA 54,14,11110000B,inst10,21
	PINTA 54,15,11110000B,inst11,21
	PINTA 54,16,11110000B,inst12,21
	PINTA 54,17,11110000B,inst13,21
	PINTA 54,18,11110000B,inst14,21
	PINTA 54,19,11110000B,inst15,19
	PINTA 54,20,11110000B,inst16,6
        PINTA 55,22,11110001B,inst17,21

    cicl2:
	mov ah,0Bh
	int 21h
	cmp al,00h
	jne presiono3
	jmp cicl2

	presiono3:
	mov ah,02h
	mov dl,08h
	int 21h   
	
	mov dl,00h
	int 21h
	
	mov ax,0000h
	int 16h
	
	cmp al,0Dh
	je regreso  
	jmp cicl2

	regreso:
	PINTA 54,1,11110000B,inst0,21 
	PINTA 54,2,11110000B,inst0,21
	PINTA 54,4,11110000B,inst0,21
	PINTA 54,5,11110000B,inst0,21
	PINTA 54,6,11110000B,inst0,21
	PINTA 54,8,11110000B,inst0,21
	PINTA 54,9,11110000B,inst0,21
	PINTA 54,10,11110000B,inst0,21
	PINTA 54,11,11110000B,inst0,21
	PINTA 54,13,11110000B,inst0,21
	PINTA 54,14,11110000B,inst0,21
	PINTA 54,15,11110000B,inst0,21
	PINTA 54,16,11110000B,inst0,21
	PINTA 54,17,11110000B,inst0,21
	PINTA 54,18,11110000B,inst0,21
	PINTA 54,19,11110000B,inst0,19
	PINTA 54,20,11110000B,inst0,6
        PINTA 55,22,11110000B,inst0,21

	PINTA 56,11,01110000B,reiniciar,19
	PINTA 56,13,01110000B,salir,19
	PINTA 56,15,01110000B,inst,19
	pinta 60,1,11110000b,fecha,10
	jmp yano2

	finito:
	jmp fin

	vuelve:
	jmp reinicia

	click:
	uno1:
	cmp x,161
	JB yano2
	JAE uno2

	uno2:
	cmp x,239
	JBE uno3
	jmp dos1

	uno3:
	mov fil,1
	jmp cuno1 

	dos1:
	cmp x,248
	JB yano2
	JAE dos2

	yano2:
	jmp coordenadas

	dos2:
	cmp x,327
	JBE dos3
	jmp tres1

	dos3:
	mov fil,2
	jmp cuno1

	tres1:
	cmp x,336
	JBE yano
	JAE tres2

	tres2:
	cmp x,414
	JBE tres3
	jmp yano

	tres3:
	mov fil,3
	jmp cuno1

	cuno1:
	cmp y,40
	JB yano
	JAE cuno2

	cuno2:
	cmp y,79
	JBE cuno3
	JA cdos1

	cuno3:
	mov col,1
	jmp imprime1
	;ya recupero coordenadas

	cdos1:
	cmp y,88
	JB yano
	JAE cdos2

	cdos2:
	cmp y,127
	JBE cdos3
	jmp ctres1

	cdos3:
	mov col,2
	jmp imprime2
	;ya recupero coordenadas

	ctres1:
	cmp y,136
	JB yano
	JAE ctres2

	ctres2:
	cmp y,175
	JBE ctres3
	jmp yano

	ctres3:
	mov col,3
	jmp imprime3
	;ya recupero coordenadas

	yano:
	jmp coordenadas

	imprime1:
	cmp fil,1
	jz uno
	cmp fil,2
	jz dos
	cmp fil,3
	jz tress
	jmp yano

	uno:
	cmp matriz,0
	jnz yano
	cmp turno,2
	jz c1
	PINTA 20,5,11110001B,TACHE,94
	mov turno,2
	mov matriz,1
	jmp yano

	c1:
	PINTA 20,5,11111100B,CIRCULO,94
	mov turno,1
	mov matriz,2
	jmp yano

	tress:
	jmp tres

	dos:
	cmp matriz+1,0
	jnz yano
	cmp turno,2
	jz c2
	PINTA 31,5,11110001B,TACHE,94
	mov turno,2
	mov matriz+1,1
	jmp yano

	c2:
	PINTA 31,5,11111100B,CIRCULO,94
	mov turno,1
	mov matriz+1,2
	jmp yano

	tres:
	cmp matriz+2,0
	jnz yano3
	cmp turno,2
	jz c3
	PINTA 42,5,11110001B,TACHE,94
	mov turno,2
	mov matriz+2,1
	jmp yano

	c3:
	PINTA 42,5,11111100B,CIRCULO,94
	mov turno,1
	mov matriz+2,2
	jmp yano

	imprime2:
	cmp fil,1
	jz unod
	cmp fil,2
	jz dosd
	cmp fil,3
	jz tresd2
	jmp yano

	yano3:
	jmp coordenadas

	unod:
	cmp matriz+3,0
	jnz yano3
	cmp turno,2
	jz undo
	PINTA 20,11,11110001B,TACHE,94
	mov turno,2
	mov matriz+3,1
	jmp yano

	undo:
	PINTA 20,11,11111100B,CIRCULO,94
	mov turno,1
	mov matriz+3,2
	jmp yano

	tresd2:
	jmp tresd

	dosd:
	cmp matriz+4,0
	jnz yano3
	cmp turno,2
	jz dods
	PINTA 31,11,11110001B,TACHE,94
	mov turno,2
	mov matriz+4,1
	jmp yano

	dods:
	PINTA 31,11,11111100B,CIRCULO,94
	mov turno,1
	mov matriz+4,2
	jmp yano

	tresd:
	cmp matriz+5,0
	jnz yano5
	cmp turno,2
	jz treds
	PINTA 42,11,11110001B,TACHE,94
	mov turno,2
	mov matriz+5,1
	jmp yano

	yano5:
	jmp coordenadas

	treds:
	PINTA 42,11,11111100B,CIRCULO,94
	mov turno,1
	mov matriz+5,2
	jmp yano

	imprime3:
	cmp fil,1
	jz unot
	cmp fil,2
	jz dost
	cmp fil,3
	jz trest3
	jmp yano

	unot:
	cmp matriz+6,0
	jnz yano5
	cmp turno,2
	jz unto
	PINTA 20,17,11110001B,TACHE,94
	mov turno,2
	mov matriz+6,1
	jmp yano

	trest3:
	jmp trest2

	unto:
	PINTA 20,17,11111100B,CIRCULO,94
	mov turno,1
	mov matriz+6,2
	jmp yano

	dost:
	cmp matriz+7,0
	jnz yano4
	cmp turno,2
	jz dots
	PINTA 31,17,11110001B,TACHE,94
	mov turno,2
	mov matriz+7,1
	jmp yano

	trest2:
	jmp trest

	yano4:
	jmp coordenadas

	dots:
	PINTA 31,17,11111100B,CIRCULO,94
	mov turno,1
	mov matriz+7,2
	jmp yano

	trest:
	cmp matriz+8,0
	jnz yano4
	cmp turno,2
	jz trets
	PINTA 42,17,11110001B,TACHE,94
	mov turno,2
	mov matriz+8,1
	jmp yano

	trets:
	PINTA 42,17,11111100B,CIRCULO,94
	mov turno,1
	mov matriz+8,2
	jmp yano
	 

	reinicia:
	jmp inicio

	fin:

	mov ah,4ch
	int 21h
.Exit

verifica proc near
	etapa1:
	cmp matriz,1
	jz casix
	cmp matriz,2
	jz casio
	jmp etapa2

	casix:
	cmp matriz+1,1
	jnz etapa2
	cmp matriz+2,1
	jnz etapa2
	mov gano,1
	jmp seacabo

	casio:
	cmp matriz+1,2
	jnz etapa2
	cmp matriz+2,2
	jnz etapa2
	mov gano,2
	jmp seacabo

	etapa2:
	cmp matriz,1
	jz casi2x
	cmp matriz,2
	jz casi2o
	jmp etapa3

	casi2x:
	cmp matriz+4,1
	jnz etapa3
	cmp matriz+8,1
	jnz etapa3
	mov gano,1
	jmp seacabo

	casi2o:
	cmp matriz+4,2
	jnz etapa3
	cmp matriz+8,2
	jnz etapa3
	mov gano,2
	jmp seacabo

	etapa3:
	cmp matriz,1
	jz casi3x
	cmp matriz,2
	jz casi3o
	jmp etapa4

	casi3x:
	cmp matriz+3,1
	jnz etapa4
	cmp matriz+6,1
	jnz etapa4
	mov gano,1
	jmp seacabo

	casi3o:
	cmp matriz+3,2
	jnz etapa4
	cmp matriz+6,2
	jnz etapa4
	mov gano,2
	jmp seacabo

	etapa4:
	cmp matriz+1,1
	jz casi4x
	cmp matriz+1,2
	jz casi4o
	jmp etapa5

	casi4x:
	cmp matriz+4,1
	jnz etapa5
	cmp matriz+7,1
	jnz etapa5
	mov gano,1
	jmp seacabo

	casi4o:
	cmp matriz+4,2
	jnz etapa5
	cmp matriz+7,2
	jnz etapa5
	mov gano,2
	jmp seacabo

	etapa5:
	cmp matriz+2,1
	jz casi5x
	cmp matriz+2,2
	jz casi5o
	jmp etapa6

	casi5x:
	cmp matriz+4,1
	jnz etapa6
	cmp matriz+6,1
	jnz etapa6
	mov gano,1
	jmp seacabo

	casi5o:
	cmp matriz+4,2
	jnz etapa6
	cmp matriz+6,2
	jnz etapa6
	mov gano,2
	jmp seacabo

	reinicia1: jmp reinicia
	final: jmp fin

	etapa6:
	cmp matriz+2,1
	jz casi6x
	cmp matriz+2,2
	jz casi6o
	jmp etapa7

	casi6x:
	cmp matriz+5,1
	jnz etapa7
	cmp matriz+8,1
	jnz etapa7
	mov gano,1
	jmp seacabo

	casi6o:
	cmp matriz+5,2
	jnz etapa7
	cmp matriz+8,2
	jnz etapa7
	mov gano,2
	jmp seacabo

	etapa7:
	cmp matriz+3,1
	jz casi7x
	cmp matriz+3,2
	jz casi7o
	jmp etapa8

	casi7x:
	cmp matriz+4,1
	jnz etapa8
	cmp matriz+5,1
	jnz etapa8
	mov gano,1
	jmp seacabo

	casi7o:
	cmp matriz+4,2
	jnz etapa8
	cmp matriz+5,2
	jnz etapa8
	mov gano,2
	jmp seacabo

	etapa8:
	cmp matriz+6,1
	jz casi8x
	cmp matriz+6,2
	jz casi8o
	jmp etapa9

	casi8x:
	cmp matriz+7,1
	jnz etapa9
	cmp matriz+8,1
	jnz etapa9
	mov gano,1
	jmp seacabo

	casi8o:
	cmp matriz+7,2
	jnz etapa9
	cmp matriz+8,2
	jnz etapa9
	mov gano,2
	jmp seacabo

	fin2:
	jmp final
	reinicia2:
	jmp reinicia1

	etapa9:
	cmp matriz,0
	jz finverifica2
	cmp matriz+1,0
	jz finverifica2
	cmp matriz+2,0
	jz finverifica2
	cmp matriz+3,0
	jz finverifica2
	cmp matriz+4,0
	jz finverifica2
	cmp matriz+5,0
	jz finverifica2
	cmp matriz+6,0
	jz finverifica2
	cmp matriz+7,0
	jz finverifica2
	cmp matriz+8,0
	jz finverifica2
	mov gano,0
	jmp seacabo

	finverifica2:
	jmp finverifica

	gana5: jmp gana1
	gana4: jmp gana3

	seacabo:
	
	mov dl,gano
	add dl,30h
	mov ganador,dl

	cmp gano,0
	jz empate
	cmp gano,1
	jz gana5
	cmp gano,2
	jz gana4

	empate: 
	archivo carpe,arch,archivo2,26,handler
	;lpinta 0,0,11110000b,archivo2,26
	PINTA 15,23,11110000B,gano0,48
	PINTA 15,24,11110000b,aviso,48
	jmp sigue2
	
	gana1:
	archivo carpe,arch,archivo3,35,handler
	;pinta 0,0,11110000b,archivo3,35	  
	PINTA 15,23,11110000B,gano1,48
	PINTA 15,24,11110000b,aviso,48
	jmp sigue2

	fin3: jmp fin2
	reinicia3: jmp reinicia2

	gana3:
	archivo carpe,arch,archivo3,35,handler
	;pinta 0,0,11110000b,archivo3,35
	PINTA 15,23,11110000B,gano2,48
	PINTA 15,24,11110000b,aviso,48
	jmp sigue2

	ciclo1:
	sigue2:
	mov ah,0Bh
	int 21h
	cmp al,00h
	jne presiono2
	jmp ciclo1

	presiono2:
	mov ah,02h
	mov dl,08h
	int 21h

	reinicia4:jmp reinicia3
	fin4: jmp fin3   
	
	mov dl,00h
	int 21h
	
	mov ax,0000h
	int 16h
	
	cmp al,0Dh
	je fin4  
	cmp al,1Bh
	je reinicia4
	jmp ciclo1


	finverifica:
	ret
verifica endp

END
