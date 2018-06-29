;********************************************************************************
;                           MINIJUEGO EL AHORCADO          
;********************************************************************************
;
;   + Juego de adivinanzas (funciona con dos jugadores).
;   + Presiona la tecla del simbolo candidato cuando sea tu turno por proponer.
;   + El juego termina cuando uno de los jugadores adivina la palabra oculta 
;     o el hombre ahorcado termina su aparicion.
;   + Presione ESC para salir.     
;
;********************************************************************************
;   Autor: Maria Graciela Martinez Espinosa | ISC 5B | Diciembre de 2016         
;********************************************************************************
;
;--- FUNCIONES MACRO DE SONIDO ---

TONO MACRO NUMERO        ;Esta macro recibe el tono
    MOV  BX,NUMERO       ;y manda a llamar a los procedimientos
    CALL BOCINA
ENDM


;--- FUNCIONES MACRO DEL JUEGO ---

;  Inicializamos variable en 0's
MGinitCeros macro var,nceros
    LOCAL ciclo
    mov bx,0h                               ; Indice inicial
    ciclo:
        mov var+bx,0h                       ; Movemos un 0 a la posicion
        add bx,1h                           ; Incrementamos en 1 el index
        cmp bx,nceros                       
        jl ciclo
    
endm

;  Formato de pantalla
MGclean macro filaIni, columnaIni, filaFin, columnaFin, color
    mov ch,filaIni
    mov cl,columnaIni
    mov dh,filaFin
    mov dl,columnaFin
    mov bh,color
    mov ah,06h                               ; Imprimir en pantalla
    int 10h
    
endm
;  Pintar texto
MGmsgPaint macro col, fil, color, texto, cant
    MGpushev
    mov al,00h
    mov bh,00h
    mov bl,color                             ; Color de texto E Color de fondo 01
    mov dl,col                               ; Columnas -> Posicion en x
    mov dh,fil                               ; Filas    -> Posicion en y
    mov cx,cant                              ; Cantidad de texto que quiero imprimir
    mov es,datauser                          ; Direccion de memoria donde esta la info a imprimir
    mov bp,offset texto
    mov ah,013h 
    int 10h
    MGpopev
endm 
;  Pintado del teclado
MGkeyboard macro boldLetter, color, cbtxt    ; boldLetter es un numero que representa 
    LOCAL ciclo,escCiclo,resaltar            ; la tecla a resaltar, si boldLetter= 27
    LOCAL normal,continue                    ; nada se resalta.
    mov cl,1                                 ; Columna inicial                                  
    mov bx,0H                                ; Indice inicial del vector abckey
    MGmsgPaint cl,21,color,space,2
    ciclo:
        mov al,abckey+bx
        mov indice,al    
        cmp bl,boldLetter
            je resaltar
        cmp bl,boldLetter
            jne normal
        resaltar:
            MGmsgPaint cl,21,cbtxt,indice,1  ; Pintamos letra resaltada
            jmp continue
        normal:                               
            MGmsgPaint cl,21,color,indice,1  ; Pintamos letra normal
        
        continue:
            add cl,1H                        ; Aumentamos la columna en 1
            MGmsgPaint cl,21,color,space,2                                

        add cl,2H                            ; Aumentamos la columna en 2
        add bx,1                             ; Incrementa el indice en 1
        cmp bx,26                             
        jge escCiclo 
            jmp ciclo
        escCiclo:
endm
;  Pintado del Hombre Ahorcado
MGmen macro regExtremidades                  ; regExtremidades es un registro con 0's y 1's
    LOCAL ciclo,ignore,noignore              ; donde los 1's  nos  indicaran cuantas  y que
    LOCAL ig1,ig2,ig3,ig4,ig5,ig6,ig7        ; extremidades del hombre pintar
    mov bx,0h
    ciclo:
        cmp regExtremidades+bx,0H
            jne noignore
                jmp ignore                   ; Esta extremidad no se dibuja
        
        noignore:
        cmp bx,0H
            jne ig1                          ; Comparamos cada extremidad para saber cual dibujar
                jmp psoga
            ig1:
        cmp bx,1H
            jne ig2
                jmp pface
            ig2:
        cmp bx,2H
            jne ig3
                jmp pbody
            ig3:
        cmp bx,3H
            jne ig4
                jmp phder
            ig4:
        cmp bx,4H
            jne ig5
                jmp phizq
            ig5:
        cmp bx,5H
            jne ig6
                jmp pfder
            ig6:
        cmp bx,6H
            jne ig7
                jmp pfizq
            ig7:
            
        psoga:                               ; Pintar soga
            MGmsgPaint 37,5,0F0H,soga1,5
            MGmsgPaint 37,6,0F0H,soga2,5
            MGmsgPaint 37,10,0F0H,soga3,5
            jmp ignore                       ; Ignoramos el resto de las extremidades
        pface:                               ; Pintar cabeza
            MGmsgPaint 37,7,0F0H,face1,5
            MGmsgPaint 37,8,0F0H,face2,5
            MGmsgPaint 37,9,0F0H,face3,5
            jmp ignore                       ; Ignoramos el resto de las extremidades
        pbody:                               ; Pintar cuerpo
            MGmsgPaint 37,11,0F0H,body1,5
            MGmsgPaint 37,12,0F0H,body2,5
            MGmsgPaint 37,13,0F0H,body3,5
            jmp ignore                       ; Ignoramos el resto de las extremidades
        phder:                               ; Pintar brazo derecho
            MGmsgPaint 41,11,0F0H,brder,1
            jmp ignore                       ; Ignoramos el resto de las extremidades
        phizq:                               ; Pintar brazo izquierdo
            MGmsgPaint 37,12,0F0H,brizq,2
            jmp ignore                       ; Ignoramos el resto de las extremidades
        pfder:                               ; Pintar pierna derecha
            MGmsgPaint 37,14,0F0H,pder1,5
            MGmsgPaint 37,15,0F0H,pder2,5
            jmp ignore                       ; Ignoramos el resto de las extremidades
        pfizq:                               ; Pintar pierna izquierda
            MGmsgPaint 37,14,0F0H,pizq1,2
            MGmsgPaint 37,15,0F0H,pizq2,2
            jmp ignore                       ; Ignoramos el resto de las extremidades
        
        
        ignore:
            add bx,1H
            cmp bx,7
            jge escCiclo 
                jmp ciclo
            escCiclo:
endm
;  Pintado de la palabra con guiones y letras encontradas mas espaciado
MGwordPaint macro col, fil, color, vecTxt                  
    LOCAL ciclo                 
    mov cl,col                               ; Columna inicial                                  
    mov ch,fil
    mov bx,0H                                ; Indice donde comenzamos a mostrar el vecTxt
    ciclo:
        mov al,vecTxt+bx
        mov indice,al    
        MGmsgPaint cl,ch,color,indice,1      ; Pintamos letra o simbolo oculto
        add cl,1H                            ; Aumentamos la columna en 1
        MGmsgPaint cl,ch,color,space2,1      ; Pintamos un espacio
        add cl,1H                            ; Aumentamos la columna en 1
        add bx,1                             ; Incrementa el indice en 1
        cmp bl,10                             
        jl ciclo             
endm
;  Pintar el Ganador
MGwinner macro col, fil, txt1, txt2, alt, turn, p1, p2, color
    LOCAL txtj1,txtj2,empate,endwinnerpaint
    mov cl,col                                                                  
    mov ch,fil
    ; Si se encontro la palabra, el jugador en turno gana
    mov ah,turn
    cmp ah,1h
        jne cmpTurn2
            jmp txtj1
    cmpTurn2:
    cmp ah,2h
        jne cmpPoints
            jmp txtj2
    cmpPoints:
    ; Si no se encontro la palabra el jugador que haya acumulado mas puntos, gana
    mov ah,p1
    mov al,p2
    cmp ah,al
        jl txtj2
    cmp ah,al
        jg txtj1
    jmp empate
    txtj1:
        MGmsgPaint cl,ch,color,txt1,22
        jmp endwinnerpaint
    txtj2:
        MGmsgPaint cl,ch,color,txt2,22
        jmp endwinnerpaint
    empate:
        MGmsgPaint cl,ch,color,alt,22
    endwinnerpaint:
endm
;  Igualacion entre palabras mas vector con '_'
MGequWord macro destino, fuente
    LOCAL ciclo,continue                 
    mov bx,0H                                ; Indice inicial
    ciclo:
        mov al,[fuente+bx]
        mov destino+bx,al 
        cmp bx,0h                            ; 
            jl continue
        cmp al,20h                           ; 20H = espacios en blanco
            je continue 
        sub bx,1h
        mov wordMax+bx,'_'
        add bx,1h
        continue:
            add bx,1h                        ; Incrementa el indice en 1
        cmp bx,10                            ; 10 = N max de carcteres en una palabra
        jl ciclo
endm
;  Igualacion entre palabras
MGequWordnc macro destino, fuente
    LOCAL ciclo                 
    mov bx,0H                                ; Indice inicial
    ciclo:
        mov al,[fuente+bx]
        mov destino+bx,al 
        add bx,1h                        ; Incrementa el indice en 1
        cmp bx,10                            ; 10 = N max de carcteres en una palabra
        jl ciclo
endm
;  Obtener numero random, lo guardamos en una variable
MGgetRadom macro rango, var
    mov ah, 00h                              ; Obtenemos hora del sistema        
    int 1AH                                  ; cx:dx esperamos numero del reloj      
    mov ax,dx
    xor dx,dx
    mov cx,rango                             ; Generamos aleatorio de 0 a rango    
    div cx                                   ; cx/ax
    mov var,dl                               ; dx contiene el numero generado
endm 
;  Obtener fecha, formato 00/00/0000
MGgetDate macro date
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
    
    mov date+3,al       ; Se guarda en el primer y segundo numero el dia
    mov date+4,ah
    
    mov dx,000ah        ; Acomodando division para mes
    mov ah,00h
    mov al,bh        
    div dl              ; En ax se almacenara el mes de dos digitos
    
    add ah,30h
    add al, 30h         ; Acomodo en ascii
    mov date,al         ; Se guardan los siguientes dos numeros
    mov date+1,ah       
    
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
;  Comparamos tecla ingresada con la palabra y asignamos valores
MGcompareAndAsign macro e,wvec,wact,keycmp
    LOCAL ciclo,asignMay,asignMin,continue,ignore,goodtono,notono
    mov bx,0H                                ; Indice inicial
    mov e,0H                                 ; Limpiamos bandera de existencia
    ciclo:
        add bx,1h
        mov al,[wact+bx]
        sub bx,1h
        mov ah,keycmp
        add ah,41H
        cmp al,ah
            je asignMay                      ; Se asigna el valor de la letra mayuscula
        mov ah,keycmp
        add ah,61H    
        cmp al,ah
            je asignMin                      ; Se asigna el valor de la letra minuscula
            jmp continue                       
        
        asignMay:
            mov wvec+bx,al
            mov e,1H
            jmp continue
            
        asignMin:
            mov wvec+bx,al
            mov e,1H
            
        continue:
            add bx,1H
            cmp bx,10
        jl ciclo
    mov ah,e
    cmp e,1h
        je goodtono
        TONO 150
        jmp notono
    goodtono:
        TONO 700
    notono:
endm
; Validamos si se ha equivocdo e ingresara a pintarse una extremidad mas del hombre ahorcado
MGvalExist macro e,regExtremidades
    LOCAL ciclo,continue,sig,next
    cmp e,1h                                 ; La letra si existe
        je continue                          ; Ignoramos el proceso y continuamos

    mov bx,0h                                ; Indice inicial
    ciclo:
        mov ah,[regExtremidades+bx]
        cmp ah,1h
            je next
        mov regExtremidades+bx,1h
            jmp continue
        
        next:
        add bx,1h
        cmp bx,7
            jl ciclo
    
    continue:
        mov bx,6h
        mov ah,[regExtremidades+bx]
        cmp ah,1h
            jne sig
            mov bx,7h
            mov regExtremidades+bx,1h
            mov gwinval,0h
    sig: 
endm
;  Validamos si el juego a finalizado con la palabra encontrada
MGisWin macro regLetterFind,regExtremidades
    LOCAL ciclo,jmciclo,sig,sig2
    mov bx,7h
    mov ah,regExtremidades+bx
    cmp ah,1h
        jne jmciclo
            jmp sig                          ; Ya ha perdido la partida
    jmciclo:                            
    mov bx,0h                                ; Indice inicial
    ciclo:
        mov ah,[regLetterFind+bx]
        cmp ah,'_'
            jne sig2
                jmp sig                      ; Aun no hay ganador
        sig2:                           
        add bx,1h
        cmp bx,10
        jl ciclo
    ; Asignamos estado de fin del juego
    mov bx,7h
    mov regExtremidades+bx,1h
    mov ah,turnos
    mov gwinval,ah
    sig:
endm
;  Salvar archivos
MGfileUpdate macro carpeta,archivo, data, tamdata, handler
    LOCAL errorF,err2,cfile
    ; create c:\emu8086\ahorcado
    mov dx, offset carpeta
    mov ah, 39h
    int 21h
    ; open c:\emu8086\ahorcado
    mov dx, offset archivo
    mov ah, 3dh
    mov al,2h
    int 21h
    jc errorF 
    jmp cfile
    
    errorF:
    ; create and open file: c:\emu8086\ahorcado\puntaje.txt
    mov ah, 3ch
    mov cx, 0
    mov dx, offset archivo
    int 21h
    jc err2
    cfile:  
    
    mov handler, ax
    ; seek:
    mov ah, 42h
    mov bx, handler
    mov al, 2
    mov cx, 0
    mov dx, 0
    int 21h
    ; write to file:
    mov ah, 40h
    mov bx, handler
    mov dx, offset data
    mov cl, tamdata
    int 21h
    ; close c:\emu8086\ahorcado\puntaje.txt
    mov ah, 3eh
    mov bx, handler
    int 21h
    err2:
    nop
 endm
;  Sustituto de pusha
MGpushev macro
    push ax
    push bx
    push cx
    push dx
endm
;  Sustituto de popa
MGpopev macro
    pop dx
    pop cx
    pop bx
    pop ax
endm
;  Limpiar registros
cleanReg macro
    xor ax,ax
    xor bx,bx
    xor cx,cx
    xor dx,dx
endm
;  Salvar puntajes en archivo
MGsavepoints macro carpeta,archivo,v1,v2,data,tamdata,handler
    mov ah,0h
    mov al,v1
    MGconvertAx convacuj1,5                    ; Convertimos a decimal el puntaje acumulado del jugador1 
    mov al,v2
    MGconvertAx convacuj2,5                    ; Convertimos a decimal el puntaje acumulado del jugador2
    MGgetDate dateSys                          ; Obtenemos la fecha del sistema 
    MGfileUpdate carpeta,archivo,data,tamdata,handler
endm
;  Convertidor hexa - ascii decimal (puntuaciones, hay que guardar en AX el valor hexa antes de llamar la macro)
MGconvertAx macro var, len                     ;Conversor hexa a decimal, var es la variable para guardar el ascii decimal
    LOCAL cycle,endCycle
    MGpushev
    mov bx,len                             ;Empieza desde el digito marcado
    dec bx
    mov cx,10
    cycle:                                 ;Divide sobre 10 para obtener el modulo
        div cl
        add ah,30h                         ;Lo convierte en numero ascii
        mov var+bx,ah                      ;Lo mueve a la posicion de memoria deseada
        xor ah,ah
        cmp bx,0h                          ;Hasta que se terminen los digitos
        je endCycle
        dec bx
        jmp cycle 
    endCycle: 
    MGpopev
endm

;--- COMIENZA PROCESO PRINCIPAL ---
.model small
.stack 100h

.data
    ; Declaracion de variables
    datauser dw 0
    titulo db "El Ahorcado",'$'
    indj01 db "Turno del jugador 1"
    indj02 db "Turno del jugador 2"
    errorT db "Ocurrio un error   "
    bodyFg db 0h,0h,0h,0h,0h,0h,0h,0h        ; SOGA | CABEZA | TORSO | BRAZO DER | BRAZO IZQ | PIE DER | PIE IZQ | END GAME
    letter db 27h                            ; Letra que resaltara del tablero
             ; A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q  R  S  T  U  V  W  X  Y  Z
    abcdef db 0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h
    abcdev db 0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h
    abckey db "ABCDEFGHIJKLMNOPQRSTUVWXYZ"   ; Abecedario para el teclado
    indice db 0h
    space  db " |"                           ; Pipe separador
    space2 db " "
    turnos db 0h                             ; Juega el individuo x
    exist  db 0h                             ; Bandera de existencia 0-No existe 1-Existe 2-Ignoramos
    acuj1  db 0h                             ; Puntaje acumulado por el jugador 1
    acuj2  db 0h                             ; Puntaje acumulado por el jugador 2
    
    gwinval db 0h                            ; var que define si 1:Se gano la partida 2:Se perdio, gana quien tenga mayor puntaje
    winner1 db "Gana el jugador 1     "
    winner2 db "Gana el jugador 2     "
    empatar db "Ha habido un Empate   "
    
    ; Categorias                            
    categoria db 0h                          ; Variable categoria (0,1,2)
    categx db "Categoria: "
    categ0 db " Animales "
    categ1 db " Deportes "
    categ2 db "Tecnologia"
    
    ; Palabra#categoria#numero
    palabra db 0h,0h,0h,0h,0h,0h,0h,0h,0h,0h,0h ; Variable aux para guardar tam y palabra actual
    nword  db 0h
    word00 db 6,"Jaguar     "                ; Categoria 0 Palabra 0
    word01 db 5,"Tapir      "                ; Categoria 0 Palabra 1
    word02 db 7,"Velella    "                ; Categoria 0 Palabra 2
    word03 db 4,"Tuza       "                ; Categoria 0 Palabra 3
    word04 db 7,"Pantera    "                ; Categoria 0 Palabra 4
    word10 db 8,"natacion   "                ; Categoria 1 Palabra 0
    word11 db 9,"Waterpolo  "                ; Categoria 1 Palabra 1
    word12 db 9,"Taekwondo  "                ; Categoria 1 Palabra 2
    word13 db 5,"Rugby      "                ; Categoria 1 Palabra 3
    word14 db 5,"Voley      "                ; Categoria 1 Palabra 4
    word20 db 4,"VAIO       "                ; Categoria 2 Palabra 0
    word21 db 8,"Centrino   "                ; Categoria 2 Palabra 1
    word22 db 9,"Hipertext  "                ; Categoria 2 Palabra 2
    word23 db 9,"Ordenador  "                ; Categoria 2 Palabra 3
    word24 db 5,"Raton      "                ; Categoria 2 Palabra 4
    
    wordMax db 0h,0h,0h,0h,0h,0h,0h,0h,0h,0h ; Vector con carcteres encontrados
    
    ; Estructura base del ahorcado 80x25 = 2000
    default0 db "                                                                                "  ; Fila 1
    default1 db "                                                                                "  ; Fila 2
    default2 db "                                                                                "  ; Fila 3
    default3 db "                                                                                "  ; Fila 4
    default4 db "                                                                                "  ; Fila 5
    default5 db "                         ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ                                        "  ; Fila 6
    default6 db "                         º                                                      "  ; Fila 7
    default7 db "                         º                                                      "  ; Fila 8
    default8 db "                         º                                                      "  ; Fila 9
    default9 db "                         º                                                      "  ; Fila 10
    defaultA db "                         º                                                      "  ; Fila 11
    defaultB db "                         º                                                      "  ; Fila 12
    defaultC db "                         º                                                      "  ; Fila 13
    defaultD db "                         º                                                      "  ; Fila 14
    defaultE db "                         º                                                      "  ; Fila 15
    defaultF db "                         º                                                      "  ; Fila 16
    defaultG db "                        ÜÜÜ                                                     "  ; Fila 17
    defaultH db "                                                                                "  ; Fila 18
    defaultI db "                                                                                "  ; Fila 19
    defaultJ db "                                                                                "  ; Fila 20
    defaultK db "                                                                                "  ; Fila 21
    defaultL db "                                                                                "  ; Fila 22
    defaultM db "                                                                                "  ; Fila 23
    defaultN db "                                                                                "  ; Fila 24
    defaultO db "                                                                                "  ; Fila 25
    
    soga1 db "  º  "
    soga2 db "  º  "
    face1 db "ÜÜÜÜÜ"
    face2 db " ú ú "
    face3 db " -n- "
    soga3 db "-ÜÜÜ-"
    body1 db "  |  "
    body2 db "  |  "
    body3 db "  |  "
    brder db "/"
    brizq db "--"
    pizq1 db " /"
    pizq2 db "/ "
    pder1 db "   \ "
    pder2 db "    \"
    
    newPart1 db "Presiona ESC para salir"
    newPart2 db "Presiona ENTER para abrir una nueva partida"
    
    ; Instructivo: Pantalla inicial
    instructivo  db "                                                                                "  ; Fila 1
    instructivo1 db "                                                                                "  ; Fila 1
    instructivo2 db "                             MINIJUEGO EL AHORCADO                              "  ; Fila 1
    instructivo3 db "                                                                                "  ; Fila 1
    instructivo4 db "        Descubre la palabra oculta adivinando las letras que la componen.       "  ; Fila 1
    instructivo5 db "                                                                                "  ; Fila 1
    instructivo6 db "        Tienes que seleccionar la letra que creas que contiene la palabra       "  ; Fila 1
    instructivo7 db "        proyectada en tu pantalla y que el  ordenador  te muestra  oculta       "  ; Fila 1
    instructivo8 db "        entre guiones bajos ( _ ).                                              "  ; Fila 1
    instructivo9 db "                                                                                "  ; Fila 1
    instructivoA db "        Para  seleccionar la letra solo basta con presionar en tu teclado       "  ; Fila 1
    instructivoB db "        la letra candidata.                                                     "  ; Fila 1
    instructivoC db "                                                                                "  ; Fila 1
    instructivoD db "        Invita a un amigo a jugar y que comience el juego!                      "  ; Fila 1
    instructivoE db "                                                                                "  ; Fila 1
    instructivoF db "                                                                                "  ; Fila 1
    instructivoG db "        Para terminar la partida presiona ESC.                                  "  ; Fila 1
    instructivoH db "                                                                                "  ; Fila 1
    instructivoI db "        Si  deseas iniciar una nueva  partida una vez terminada la actual       "  ; Fila 1
    instructivoJ db "        presiona ENTER.                                                         "  ; Fila 1
    instructivoK db "                                                                                "  ; Fila 1
    instructivoL db "                                                                                "  ; Fila 1
    instructivoM db "  >>>>>>>>>>>>>>>>>> Presiona cualquier tecla para comenzar <<<<<<<<<<<<<<<<<<< "  ; Fila 1
    instructivoN db "                                                                                "  ; Fila 1
    instructivoO db "                                                                                "  ; Fila 1
    
    
    ; Variables para salvar archivo
    gcarpeta db "c:\ganadores", 0
    garchivo db "c:\ganadores\ahorcado.txt", 0
    ghandler dw ?
    gtamdata db 43
    ; Texto para salvar archivo
    puntajeTxt  db "Jugador1: "
    convacuj1   db 0h,0h,0h,0h,0h
    puntajeTxt1 db " Jugador2: "
    convacuj2   db 0h,0h,0h,0h,0h
    spacetxt    db " "
    dateSys     db 0h,0h,"/",0h,0h,"/",0h,0h,0h,0h
    entertxt    db 0ah
    
.code
start proc far
    ; Inicia modo protegido
    mov ax,@data
    mov ds,ax
    mov datauser,ax
    
    ; Iniciamos mostrando el instructivo del juego
    mov ax,003h                              ; Inicia modo de video de 00x25 a 16 colores
    int 10h
    mov ax,1003H
    mov bx,0                                 ; Desabilitamos el parpdeo
    int 10H
    MGmsgPaint 0,0,0F9H,instructivo,2000
    MGwaitKeyInit:
        mov ah,0BH                           ; Input Status
        int 21H
        cmp al,00H                           ; Esperar evento de tecla, sin mostrar
            je MGnoInit
            jmp MGinit 
            MGnoInit:
        jmp MGwaitKeyInit
    
    ; El juego comienza al presionar cualquier tecla
    
    MGinit:
        MGclean 0,0,24,79,00FH               ; Limpiamos toda la pantalla para darle formato en blanco FH
        mov acuj1,0h                         ; Inicializamos puntaje del jugador 1
        mov acuj2,0h                         ; Inicializamos puntaje del jugador 2
        mov turnos,1H                        ; Inicializamos turno del jugador 1
        mov exist,0H                         ; Inicializamos existencia de la letra ingresada
        mov categoria,0H                     ; Inicializamos el numero de la ctegoria actual
        mov nword,0h                         ; Inicializamos el numero de la palabra actual
        mov gwinval,0h
        MGinitCeros bodyFg,8                 ; Inicializamos el vector de extremidades pintadas
        MGinitCeros abcdef,26                ; Inicializamos el vector de letras resaltadas
        MGinitCeros abcdev,26                ; Inicializamos el vector de letras evaluadas
        MGinitCeros palabra,11
        MGinitCeros wordMax,10
        
    ; Generamos dos aleatorios para escoger al azar una categoria y palabra de la adivinanza
    MGgetRadom 3,categoria                   ; numero 0 - 2
    MGgetRadom 5,nword                       ; numero 0 - 4
    
    ; Obtenemos y guardamos la palabra escogida
    MGgetPalabra:
        ; Filtramos categorias
        mov al,categoria
        cmp al,0h
            jne nocategoria0
                jmp MGcategoria0
            nocategoria0:
        cmp al,1h
            jne nocategoria1
                jmp MGcategoria1
            nocategoria1:
        cmp al,2h
            jne nocategoria2
                jmp MGcategoria2
            nocategoria2:
        cmp al,0h
            jge noerrorWord13
                jmp MGerrorWord
            noerrorWord13:
        cmp al,2h 
            jle noerrorWord12
                jmp MGerrorWord
            noerrorWord12:
        MGcategoria0:
            ; Validamos numero de palabra
            mov al,nword
            cmp al,0h
                jne nopalabra00
                    jmp MGpalabra00
                nopalabra00:
            cmp al,1h
                jne nopalabra01
                    jmp MGpalabra01
                nopalabra01:
            cmp al,2h
                jne nopalabra02
                    jmp MGpalabra02
                nopalabra02:
            cmp al,3h
                jne nopalabra03
                    jmp MGpalabra03
                nopalabra03:
            cmp al,4h
                jne nopalabra04
                    jmp MGpalabra04
                nopalabra04:
            cmp al,0h
                jge noerrorWord11
                    jmp MGerrorWord
                noerrorWord11:
            cmp al,2h
                jle noerrorWord10
                    jmp MGerrorWord 
                noerrorWord10:
            MGpalabra00:
                MGequWord palabra,word00
                jmp main
            MGpalabra01:
                MGequWord palabra,word01
                jmp main
            MGpalabra02:
                MGequWord palabra,word02
                jmp main
            MGpalabra03:
                MGequWord palabra,word03
                jmp main
            MGpalabra04:
                MGequWord palabra,word04
                jmp main
        MGcategoria1:
            ; Validamos numero de palabra
            mov al,nword
            cmp al,0h
                jne nopalabra10
                    jmp MGpalabra10
                nopalabra10:
            cmp al,1h
                jne nopalabra11
                    jmp MGpalabra11
                nopalabra11:
            cmp al,2h
                jne nopalabra12
                    jmp MGpalabra12 
                nopalabra12:
            cmp al,3h
                jne nopalabra13
                    jmp MGpalabra13
                nopalabra13:
            cmp al,4h
                jne nopalabra14
                    jmp MGpalabra14
                nopalabra14:
            cmp al,0h
                jge noerrorWord8
                    jmp MGerrorWord
                noerrorWord8:
            cmp al,2h
                jle noerrorWord9
                    jmp MGerrorWord
                noerrorWord9:
            MGpalabra10:
                MGequWord palabra,word10
                jmp main
            MGpalabra11:
                MGequWord palabra,word11
                jmp main
            MGpalabra12:
                MGequWord palabra,word12
                jmp main
            MGpalabra13:
                MGequWord palabra,word13
                jmp main
            MGpalabra14:
                MGequWord palabra,word14
            jmp main
        MGcategoria2:
            ; Validamos numero de palabra
            mov al,nword
            cmp al,0h
                jne noerrorWord1
                    jmp MGpalabra20
                noerrorWord1:
            cmp al,1h
                jne noerrorWord2
                    jmp MGpalabra21
                noerrorWord2:
            cmp al,2h
                jne noerrorWord3
                    jmp MGpalabra22
                noerrorWord3:
            cmp al,3h
                jne noerrorWord4
                    jmp MGpalabra23
                noerrorWord4:
            cmp al,4h
                jne noerrorWord5
                    jmp MGpalabra24
                noerrorWord5:
            cmp al,0h
                jge noerrorWord6
                    jmp MGerrorWord
                noerrorWord6:
            cmp al,2h
                jge noerrorWord7
                    jmp MGerrorWord
                noerrorWord7:
            MGpalabra20:
                MGequWord palabra,word20
                jmp main
            MGpalabra21:
                MGequWord palabra,word21
                jmp main
            MGpalabra22:
                MGequWord palabra,word22
                jmp main
            MGpalabra23:
                MGequWord palabra,word23
                jmp main
            MGpalabra24:
                MGequWord palabra,word24
            jmp main
        MGerrorWord:
            jmp MGsalir
    
    ; Ciclo Principal del Juego    
    main:
        MGmsgPaint 0,0,0F0H,default0,2000    ; Pintamos la estructura base
        MGmsgPaint 34,2,0F5H,titulo,11       ; Pintamos el titulo con Fondo: F blanco, Texto: 5 magenta
        MGwordPaint 30,19,0F0H,wordMax       ; Pintamos palabra
        MGmen bodyFg                         ; Pintamos las extremidades del hombre ahorcado
        MGkeyboard letter,00FH,003H          ; Pintamos teclado, Fondo Negro 0 Texto Blanco F, Texto resaltado Cyan 3H
        
        ; Pintamos la categoria
        MGmsgPaint 55,9,0F0H,categx,11
        mov al,categoria
        cmp al,0h
            je MGpcat0
        cmp al,1h
            je MGpcat1
        cmp al,2h
            je MGpcat2
        jmp MGvalp
            
        MGpcat0:
            MGmsgPaint 67,9,0F0H,categ0,10   ; Categoria: Animales
            jmp MGvalp
        MGpcat1:
            MGmsgPaint 67,9,0F0H,categ1,10   ; Categoria: Deporte
            jmp MGvalp
        MGpcat2:
            MGmsgPaint 67,9,0F0H,categ2,10   ; Categoria: Tecnologia
            jmp MGvalp
        
        MGvalp:  
        ; Validamos partida
        MGisWin wordMax,bodyFg
        mov bx,7h
        mov al,[bodyFg+bx]
        cmp al,0H
            jnz notxtTurno
                jmp MGtxtTurno               ; El juego aun no termina               
        
        notxtTurno:
            ; Mostramos al ganador   MGwinner macro col, fil, txt1, txt2, alt, turn, p1, p2, color
            MGwinner 55,10,winner1,winner2,empatar,gwinval,acuj1,acuj2,0F4H
            MGmsgPaint 28,22,0F5H,newPart1,23    ; El juego termino ESC para salir
            MGmsgPaint 18,23,0F5H,newPart2,43    ; Preguntamos si se quiere otra partida
            ; Igualamos la palabra para mostrar el resultado
            MGequWordnc wordMax,palabra
            MGmsgPaint  55,9,0F5H,wordMax,10
            ; Esperamos la entrada de ESC o ENTER que seran validados en cmpKey
        
        MGwaitKey:
            
            mov ah,0BH                       ; Input Status
            int 21H
            cmp al,00H                       ; Esperar evento de tecla, sin mostrar
                je nocmpKeys
                jmp MGcmpKeys 
                nocmpKeys:
            jmp MGwaitKey
        
            
        MGcontinue:
            
            ; Comparamos la tecla oprimida con la palabra de adivinanza
            MGcompareAndAsign exist,wordMax,palabra,letter
            ; Segun la bandera de existencia validamos la aparicion del hombre ahorcado
            MGvalExist exist,bodyFg
            
            ; Si la letra existe en la palabra y la letra no ha sido evaluada,
            ; Incrementa el puntaje acumulado del jugador
            mov ah,exist
            cmp ah,1h
                je MGincr                    ; Existe la letra, validamos su evaluacion
                    jmp MGnoinc              ; No existe la letra en la palabra, cambia turno
            MGincr:
            mov bh,0h
            mov bl,letter
            cmp bl,27h
                jl inc1
                    jmp main
                inc1:
            mov ah,[abcdev+bx]
            cmp ah,1h
                jne MGinct                   ; No ha sido evaluada, incrementa puntaje
                    jmp main                 ; La letra ya fue evaluada, no incrementa puntaje ni cambia turno
            
            MGinct:
            mov ah,turnos
            cmp ah,1h
                je MGincpunj1
            cmp ah,2h
                je MGincpunj2
            
            jmp MGnoinc                      ; Cambiamos turno por error del sistema
            
                MGincpunj1:
                    mov abcdev+bx,1H         ; Activamos la bandera de letras evaluadas
                    mov ah,acuj1
                    add ah,1h
                    mov acuj1,ah
                    jmp main
                MGincpunj2:
                    mov abcdev+bx,1H         ; Activamos la bandera de letras evaluadas
                    mov ah,acuj2
                    add ah,1h
                    mov acuj2,ah
                    jmp main
                
            MGnoinc:
            jmp MGchangeTurn
            
    jmp main
    ; Fin Ciclo Principal del Juego
    
    MGcmpKeys:                               ; Comparacion de teclas
        mov ah, 00h                          ;Lectura de teclado
        int 16H                              ;AL = tecla 
        cmp al,00H                           ; Comparamos contra todas las teclas especiales
            jne notwaitKeyEsp               
                jmp MGwaitKey
        notwaitKeyEsp:
        
        mov letter,27H                       ; Limpiamos la variable letter
        
        MGcmpEsc:
        cmp al,1BH                           ; Comparamos con la tecla ESC de salida
            je nocmpEnter
                jmp MGcmpEnter               ; Si no es igual salta a comparar con enter
        nocmpEnter:
        mov bx,7h                            ; Si es igual verificamos que el juego se haya cerrado
        mov ah,[bodyFg+bx]
            cmp ah,1H
                je nosalir
                    jmp MGsalir              ; La partida no se ha cerrado, termina el juego  
                nosalir:
            ; La partida se cerro, salvamos puntajes
            MGsavepoints gcarpeta,garchivo,acuj1,acuj2,puntajeTxt,gtamdata,ghandler                     
            jmp MGsalir                      ; Termina el juego
        MGcmpEnter:    
            ; Comparamos con la tecla ENTER de nueva partida ssi la partida anterior se cerro
            mov bx,7h
            mov ah,[bodyFg+bx]
                cmp ah,1H 
                    je nonext
                    jmp MGnext               ; La partida no se ha cerrado, el juego continua
                nonext:
                cmp al,0DH
                je notwaitKey2                      
                    jmp MGwaitKey            ; La partida se cerro pero no ingreso un enter
                notwaitKey2:                 
                ; Salvamos puntaje en archivos y reinicia el juego
                MGsavepoints gcarpeta,garchivo,acuj1,acuj2,puntajeTxt,gtamdata,ghandler                 
                jmp MGinit
       
        ; Verificamos que la partida no se haya cerrado para permitir el ingreso de letras
        mov bx,7h
        mov ah,[bodyFg+bx]
            cmp ah,1H         
            jne notwaitKey                               
            jmp MGwaitKey                    ; La partida esta cerrada, se espera ESC o ENTER
            notwaitKey:
        MGnext:
            mov bx,0H
            MGcleanABC:
                mov abcdef+bx,0H 
                add bx,1
                cmp bx,26
            jl MGcleanABC
        
        ; Comparamos con mayusculas A - Z
        cmp al,'A'
            jl MGisNotLetter
        cmp al,'Z'
            jg MGcmpMin
        
        sub al,41H                           ; Obtenemos la letra del alfabeto a resaltar 0 = A, 1 = B, ...
            mov letter,al
            xor bx,bx
            mov bl,letter                    ; Activamos la bandera del alfabeto para diferenciar letras normales y resaltadas
            mov abcdef+bx,1H
            jmp MGcontinue
        
        MGcmpMin:                            ; Comparamos con miusculas a - z
        cmp al,'a'
            jl MGisNotLetter
        cmp al,'z'
            jg MGisNotLetter
        
        sub al,61H                           ; Obtenemos la letra del alfabeto a resaltar 0 = a, 1 = b, ...
            mov letter,al
            xor bx,bx
            mov bl,letter                    ; Activamos la bandera del alfabeto para diferenciar letras normales y resaltadas
            mov abcdef+bx,1H
            jmp MGcontinue
        
        MGisNotLetter:
            mov letter,27H                   ; Ninguna letra se resalta
            mov dh,al                        ; Guardamos valor de la tecla en dh
            
            mov al,turnos
            sub al,1H                    
            mov turnos,al                    ; El turno disminuye 1
            mov al,dh                        ; Recuperamos valor de la tecla
            
            jmp MGwaitKey    
    
    ; Itercalamos los turnos
    MGchangeTurn:
        ; El turno solo cambia cuando el jugador se equivoca (le letra no esta en la palabra)
        mov ah,exist
        cmp ah,1h
            jne nomain
                jmp main
            
        nomain:        
        mov ah,turnos
        cmp ah,2H
            je MGturno1
        cmp ah,1H
            je MGturno2
        
        MGturno1:
            mov turnos,1H                    ; Turno del jugador 1
            jmp main
        MGturno2:
            mov turnos,2H                    ; Turno del jugador 2
            jmp main
        
        mov turnos,1H                        ; Se inicializa el turno en 1 en caso de errores
        jmp main
        
    
    
    ; Pintamos indicaciones de turno
    MGtxtTurno:
        mov ah,turnos
        cmp ah,1H
            jne MGj2   
        MGmsgPaint 55,10,0F0H,indj01,19      ; Turno 1 con Fondo: F blanco, Texto: 0 negro
        jmp MGwaitKey
        
        MGj2:
            cmp ah,2h
            jne MGdefaultTurnJ
            MGmsgPaint 55,10,0F0H,indj02,19  ; Turno 2 con Fondo: F blanco, Texto: 0 negro
            jmp MGwaitKey
            
        MGdefaultTurnJ:
            mov turnos,1H
            MGmsgPaint 55,10,0F0H,indj01,19  ; Turno 1 con Fondo: F blanco, Texto: 0 negro
            jmp MGwaitKey
        
    MGsalir:
        mov ax,4c00h                         ; Regresar control al s.o.
        int 21h
start endp

;  Procesos salida de sonido
BocinaOn  PROC                  ;Activa la bocina
    IN AL, 61h
    OR AL, 11B
    OUT 61h, AL
    RET
BocinaOn  ENDP

BocinaOff  PROC                 ;Desactiva la bocina
    IN AL, 61h
    AND AL, 11111100b
    OUT 61h, AL
    RET
BocinaOff  ENDP

Ajustar  PROC                   ;Ajusta la bocina con la frecuencia dada
    PUSH BP
    MOV BP,SP
    MOV DX,18      
    MOV AX,13353   
    MOV BX,[BP + 4]
    DIV BX
    MOV BX,AX  
    MOV AL,0B6h
    OUT 43h,AL
    ;ENVIAR AL PUERTO LA FRECUENCIA EN DOS BYTES POR SEPARADO.
    MOV AX, BX
    OUT 42h, AL ;ENVIA PRIMER BYTE. (PUERTO PARALELO = 378H)
    MOV AL, AH
    OUT 42h, AL ;ENVIA SEGUNDO BYTE. (PUERTO SERIAL = 3F8H)
    POP BP
    RET
Ajustar ENDP

Suena proc                      ;Activa la bocina y coloca el nombre de
    CALL bocinaON               ;la tecla.
    MOV AX,40H
    MOV ES,AX
    MOV DX,ES:[006EH]
    MOV AX,ES:[006CH]
    ADD AX,7
    ADC DX,0                    ;Se le suma 7 unidades a ese valor
CLIC:
    CMP DX,ES:[006EH]           ;Y se compara hasta que sean iguales
    JB FINI                     ;Pasando por un ciclo, cuando llegen
    JA CLIC                     ;a ser iguales se sale del ciclo y
    CMP AX,ES:[006CH]
    JA CLIC
FINI:
    CALL    BocinaOff           ;Se desconecta la bocina y regresa.
    RET
Suena endp

Bocina proc                     ;Este procedimiento guarda AX y BX en
    PUSH    BX                  ;la pila para no perder su valor, con
    MOV     AX,BX              ;esto llama a ajusta y a suena
    PUSH    AX
    CALL    Ajustar             ;Pone la frecuencia en el puerto.
    POP     AX
    POP     BX
    CALL    SUENA               ;Activa el speaker y lo desactiva.
    ret
Bocina endp

Retardo proc
    ;Instruccion para parar la ejecucion del programa por 1 segundo AH = 86H
    MOV CX,0FH
    MOV DX,4240H
    MOV AH,86H
    INT 15H
    ret
    
Retardo endp

end