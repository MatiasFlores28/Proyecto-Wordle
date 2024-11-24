.data
	mensaje_ingrese: .asciz "Ingrese una palabra de x letras:\n"
        mensaje_mas_letras: .asciz "La palabra ingresada es mas larga a la buscada, intentelo de nuevo\n"
        mensaje_menos_letras: .asciz "La palabra ingresada es mas corta a la buscada, intentelo de nuevo\n"
        mensaje_puntaje_ganaste: .asciz "Adivinaste la palabra! Tu puntaje actual es xxx\n"
	mensaje_puntaje_perdiste: .asciz "Perdiste! Tu puntaje es xxx\n"
	mensaje_seguir_jugando: .asciz "Desea seguir jugando?\n"
	
	mensaje_comienzo_juego: .asciz "Bienvenido a W O R D L E!\nEl objetivo del juego es adivinar una palabra en un total de 5 intentos\nDeberá ingresar una palabra del largo indicado, y se le mostrará la palabra ingresada con las letras de tres colores:\n"
	
	mensaje_comienzo_verde: .asciz "Verde: Si la letra está verde, significa que está en la palabra a adivinar y que además está en la posición correcta\n"

	mensaje_comienzo_amarillo: .asciz "Amarillo: Si la letra es amarilla, significa que está en la palabra a adivinar, pero no está en la posición correcta\n"
	
	mensaje_comienzo_rojo: .asciz "Rojo: Si la letra es roja, significa que no está en la palabra a adivinar\n"
	espacio12: .space 200
	guardar:           .space 100
	colores:           .space 5    @ Guardo en las posiciones el color que corresponda y lo identifico como V,A,R
		
	archivo: .asciz "palabras.txt"
        vector: .asciz ""                  //quedan todos las palabras del txt
	espacio: .zero 10
        espacio1: .zero 600
        palabra_random: .asciz "\n"
        espacio2: .zero 50
        letras_palabra_random: .byte 6
        espacio3: .zero 10
        palabra_usuario: .asciz ""
        espacio4: .zero 10
        letras_palabra_usuario: .byte 0
	espacio5: .space 50
	puntaje: .byte 0
	espacio6: .space 10
	puntaje_ascii: .asciz ""
	espacio7: .space 10
	intentos: .byte 5
	espacio8: .space 10
	espacio9: .space 50
	s_n: .asciz "\n"
	espacio10: .space 10
        seed: .word 1
        const1: .word 1103515245			
        const2: .word 12345
        numero: .word 0
	espacio11: .space 10

	color_default:     .asciz "\033[37m"
	color_verde:       .asciz "\033[32m"
	color_amarillo:    .asciz "\033[33m"
	color_rojo:        .asciz "\033[31m"
	salto_linea:       .asciz "\n"
		
	filename: .asciz "ranking.txt"          @ Nombre del archivo
    	buffer:   .space 200                     @ Buffer para lectura (200 bytes por línea)
    	bufferLength= . - buffer

    	ranking1: .space 22                     @ Espacio para los datos de ranking1
    
    	rankingActual:  .space 22               @ Buffer para almacenar el ranking formateado
    	rankingLength:   .word 22

    	nombre:         .space 19               @ Buffer para el nombre (máx. 19 bytes)
    	valor:          .space 3                @ Buffer para el valor (3 caracteres)

    	txtRankingActual:   .asciz "Ranking actual\n"
    	lengthTxtRA= . - txtRankingActual    

.text
@------------INICIAMOS JUEGO CON MENSAJE DE BIENVENIDA--------------

	imprime_mensaje_comienzo_juego:
        .fnstart
                mov r7, #4
                mov r0, #1
                mov r2, #219				//largo del mensaje
                ldr r1, =mensaje_comienzo_juego	//puntero al mensaje inicial
                swi 0

		cambia_color_verde:			//cambio el color en que se imprime a verde
			mov r7, #4	
			mov r0, #1
			ldr r1, =color_verde
	                mov r2, #6
			swi 0
        	imprime_mensaje_verde:
			mov r7, #4
			mov r0, #1
			mov r2, #123			//largo del mensaje
			ldr r1, =mensaje_comienzo_verde	//puntero al mensaje que explica las letras verdes
			swi 0
		cambia_color_amarillo:			//cambio el color en que se imprime a amarillo
			mov r7, #4
			mov r0, #1
			ldr r1, =color_amarillo
			mov r2, #6
			swi 0
		imprime_mensaje_amarillo:
                        mov r7, #4
                        mov r0, #1
                        mov r2, #121			//largo del mensaje
                        ldr r1, =mensaje_comienzo_amarillo	//puntero al mensaje que explica las letras amarillas
                        swi 0
                cambia_color_rojo:			//cambio el color en que se imprime a rojo
			mov r7, #4
			mov r0, #1
                        ldr r1, =color_rojo
                        mov r2, #6
			swi 0
                imprime_mensaje_rojo:
                        mov r7, #4
                        mov r0, #1
                        mov r2, #76			//largo del mensaje
                        ldr r1, =mensaje_comienzo_rojo	//puntero al mensaje que explica las letras rojas
                        swi 0
		reinicia_color_default:			//restauro a blanco el color en que se imprime
			mov r7, #4
			mov r0, #1
			ldr r1, =color_default
			mov r2, #6
			swi 0
	                bx lr
        .fnend
@-------------------------------------------------------------------



@------------------INICIO LECTURA-CIERRE ARCHIVO--------------------

        abrirArchivo:                           	//abre el archivo txt con las palabras
        .fnstart
                mov r7, #5
                ldr r0, =archivo
                mov r1, #0
                mov r2, #0
                swi 0
                bx lr
        .fnend

        leer_palabras:                          	//carga las palabras del archivo a la memoria
        .fnstart
                mov r7, #3
                ldr r1, =vector
                mov r2, #510                    	//cantidad de caracteres que tengo en el txt
                swi 0
                bx lr
        .fnend

        cierraArchivo:                          	//cierra el archivo txt
        .fnstart
                mov r0, r6
                mov r7, #6
                swi 0
                bx lr
        .fnend
@-------------------FIN LECTURA-CIERRE ARCHIVO------------------------



         sortear_palabra:                        	//elige una palabra según el número random
        .fnstart
                ldr r2, =palabra_random
                mov r3, r0                     		//numero random, lo uso de contador para elegir la palabra
		sub r3, #1				//resto 1 al numero random para que se incluya el 0
                ldr r0, =vector				//cargo el puntero del listado de palabras
                mov r4, #0                      	//desplazador de registro
                mov r5, #0                      	//para "limpiar" r2
                ciclo_sortear:
                        ldrb r1, [r0], #1       	//carga el primer caracter y se mueve al segundo
                        cmp r1, #','
                        beq otra_palabra        	//salta si llego a la coma
                        strb r1, [r2, r4]		//guardo en r2 los ascii para formar la palabra
                        add r4, #1			//sumo 1 al desplazador
                        bal ciclo_sortear
                otra_palabra:
                        sub r3, #1              	//le resto 1 al contador/numero random
                        cmp r3, #0
                        blt fin_ciclo_sortear		//si es menor a 0 encontré la palabra correcta
                        mov r6, r4			//muevo el desplazador a r6
                        mov r4, #0			//reinicio el desplazador
                        borro_r2:
                                strb r5, [r2,r6]        //guardo 0 en todas las posiciones de r2
                                sub r6, #1		//resto 1 a r6
                                cmp r6, #0
                                bge borro_r2		//borro r2 hasta que r6 llegue a 0
                                bal ciclo_sortear	//cuando r6 llega a 0 reinicio el ciclo_sortear para guardar la siguiente palabra
                fin_ciclo_sortear:
                        bx lr
        .fnend
	

	calcula_letras_usuario:
        .fnstart
                ldr r0, =palabra_usuario		//puntero a la palabra del usuario
                mov r1, #0              		//contador de letras
                ciclo_calcula_letras:
                        ldrb r2, [r0], #1		//me desplazo por la palabra del usuario
                        cmp r2, #'\n'   		//salta cuando llega al salto de linea
                        beq fin_ciclo_calcula_letras
                        add r1, #1      		//suma 1 al contador de letras
                        bal ciclo_calcula_letras
                fin_ciclo_calcula_letras:
                        ldr r0, =letras_palabra_usuario	//puntero al largo de la palabra del usuario
                        strb r1, [r0]			//guardo en memoria el largo de la palabra del usuario
                        bx lr
        .fnend



        calcular_letras_random:
        .fnstart
                ldr r0, =palabra_random			//cargo el puntero de la palabra a adivinar
                ldr r2, =letras_palabra_random		//cargo el puntero del largo de la palabra a adivinar
                mov r3, #0                      	//contador de letras
                ciclo_letras:
                        ldrb r1, [r0], #1		//cargo en r1 la primer letra
                        cmp r1, #00             	//salta cuando termina la cadena
                        beq fin_calcular_letras
                        add r3, #1              	//suma 1 por cada caracter
                        bal ciclo_letras
                fin_calcular_letras:
                        strb r3, [r2]           	//guardo el largo de la palabra a adivinar en memoria
                        bx lr
        .fnend


@------------CODIGO PARA INGRESAR-LEER-MODIFICAR 'x'-----------------------

	ingrese_palabra:
        .fnstart
                mov r7, #4
                mov r0, #1
                mov r2, #32				//largo del mensaje
                ldr r1, =mensaje_ingrese		//puntero al mensaje para que el usuario ingrese una palabra
                swi 0
                bx lr
        .fnend

        leer_palabra:
        .fnstart
                mov r7, #3
                mov r0, #0
                mov r2, #20				//numero asignado de más por si el usuario ingresa cualquier cosa
                ldr r1, =palabra_usuario		//puntero a donde se guardará la palabra del usuario
                swi 0
                bx lr
        .fnend


	@ CUANDO ENCUENTRE UNA 'X' MODIFICO EL MENSAJE POR EL N� DE LETRAS
       modifica_mensaje_ingrese:
        .fnstart
                ldr r0, =mensaje_ingrese		//cargo el puntero del mensaje para que el usuario ingrese una palabra
                ldr r1, =letras_palabra_random		//cargo el puntero del largo de la palabra a adivinar
                ldrb r3, [r1]                  	 	//cargo letras de la palabra a adivinar
                add r3, #0x30                   	//lo transformo en ascii
                ciclo_modifica_mensaje:
                        ldrb r2, [r0], #1		//me desplazo por el mensaje para que el usuario ingrese una palabra
                        cmp r2, #'x'            	//cuando llega a la x salta
                        beq fin_modifica_mensaje
                        bal ciclo_modifica_mensaje
                fin_modifica_mensaje:
                        strb r3, [r0, #-1]      	//reemplazo la x por el numero de letras
                                                	//resto 1 para volver a la posicion del x
                        bx lr
        .fnend
@----------------------------FIN DE CODIGO---------------------------------------------


        
       mensaje_mas_largo:
        .fnstart
                mov r7, #4
                mov r0, #1
                mov r2, #67				//largo del mensaje
                ldr r1, =mensaje_mas_letras		//puntero al mensaje que sale si la palabra es mas larga de lo indicado
                swi 0
                bx lr
        .fnend

        mensaje_mas_corto:
        .fnstart
                mov r7, #4
                mov r0, #1
                mov r2, #67				//largo del mensaje
                ldr r1, =mensaje_menos_letras		//puntero al mensaje que sale si la palabra es mas corta de lo indicado
                swi 0
                bx lr
        .fnend

	

@--------------INICIO CODIGO PARA LOS COLORES----------------------------
        
	informar_resultado:
    	.fnstart
	    push {lr}
	    ldr r4, =palabra_usuario			//puntero a la palabra del usuario
	    ldr r5, =palabra_random			//puntero a la palabra a adivinar
	    ldr r6, =letras_palabra_random		//puntero al largo de la palabra a adivinar
	    ldrb r6, [r6]				//cargo el largo de la palabra a adivinar
	    ldr r7, =guardar				//puntero a donde guardo el color que corresponde a cada letra
	    mov r8, #0
	    ldr r10, =colores            		//puntero a los colores para guardar 'V', 'A', 'R'

		verificar_letras:
		    cmp r8, r6                  	//comparo el puntero V con el largo de la palabra a adivinar
		    beq fin_informar_resultado  	// si llego al final salgo

		@------------verde-------------
		    ldrb r0, [r4, r8]			//cargo la primer letra de la palabra del usuario
		    ldrb r1, [r5, r8]			//cargo la primer letra de la palabra a adivinar
		    cmp r0, r1				//comparo la letra del usuario con la letra de la palabra a adivinar
		    beq clasificar_verde        	//si son iguales salta

		@------------amarilla----------
		    mov r9, #0                   	//si vengo aca, no es V
		buscar_amarilla:
		    cmp r9, r6                   	//cmp puntero A con length
		    beq clasificar_roja

		    ldrb r2, [r5, r9]           	//agarro 'm' y me desplazo con r9
		    cmp r0, r2				//comparo la letra del usuario con la letra a adivinar
		    beq clasificar_amarilla		//salta si son iguales
		    add r9, r9, #1			//suma 1 al desplazador
		    bal buscar_amarilla			//reinicia el ciclo de palabra amarilla

		clasificar_verde:
		    mov r2, #'V'
		    strb r2, [r7, r8]			//almaceno en la etiqueta guardar el color que corresponde a la letra
		    strb r2, [r10, r8]   		//Guardar color en la tabla de colores
		    bal siguiente_letra

		clasificar_amarilla:
		    mov r2, #'A'
		    strb r2, [r7, r8]			//almaceno en la etiqueta guardar el color que corresponde a la letra
		    strb r2, [r10, r8]   		//Guardar color
		    bal siguiente_letra

		clasificar_roja:
		    mov r2, #'R'
		    strb r2, [r7, r8]			//almaceno en la etiqueta guardar el color que corresponde a la letra
		    strb r2, [r10, r8]   		//Guardar color

		siguiente_letra:
		    add r8, r8, #1			//aumento el desplzador
		    bal verificar_letras		//reinicio el ciclo

		fin_informar_resultado:
		    pop {lr}
		    bx lr
	    .fnend



	@ Cambia el color del texto a imprimir
	cambiar_color:					//cambia el color en el cual se impreme segun corresponda a la letra
    	.fnstart
		 push {lr}
		 mov r2, #6      			//Largo del cÃ³digo de los colores
		 bl imprimir
		 pop {lr}
		 bx lr
	.fnend

	
	@ Imprime cada letra del usuario con su color correspondiente
	imprimir_resultado:
	.fnstart
		push {lr}
		mov r3, #0      @ Iterador
		ldr r4, =letras_palabra_usuario
		ldrb r4, [r4]

		ciclo_imprimir_resultado:
			ldr r2, =colores
			ldrb r0, [r2, r3]    		//Obtiene la letra del color a imprimir
			cmp r0, #'R'
			beq imprimir_rojo
			cmp r0, #'A'
			beq imprimir_amarillo
			cmp r0, #'V'
			beq imprimir_verde

		imprimir_rojo:				//cambia el color de la impresión a rojo
			ldr r1, =color_rojo
			bl cambiar_color
			b imprimir_caracter

		imprimir_amarillo:			//cambia el color de la impresión a amarillo
			ldr r1, =color_amarillo
			bl cambiar_color
			b imprimir_caracter

		imprimir_verde:				//cambia el color de la impresión a verde
			ldr r1, =color_verde
			bl cambiar_color
			b imprimir_caracter

		imprimir_caracter:                      //obtengo el caracter que se debe imprimir
			ldr r1, =palabra_usuario        //direccion de la palabra que ingreso e user
			add r1, r3                      //le agrego el iterador para llegar a la letra que estoy verificando
			mov r2, #1
			bl imprimir
			@aumento el itereador para pasar a la siguiente letra
			add r3, #1
			cmp r3, r4
			bne ciclo_imprimir_resultado

		fin_imprimir_resultado:			//restaura el color blanco en la impresión
			ldr r1, =color_default
			bl cambiar_color
			//salto de linea
			ldr r1, =salto_linea
			mov r2, #1
			bl imprimir
			pop {lr}
			bx lr
	.fnend


@--------------------FIN CODIGO COLORES----------------------------



@ Imprime un mensaje por pantalla
	imprimir:
	.fnstart
		push {lr}
		mov r0, #1      			// Salida cadena
		mov r7, #4      			// CÃ³digo de interrupciÃ³n: imprimir
		swi 0           			// Llamada al sistema
		pop {lr}
		bx lr
	.fnend




@-------------------INICIO CODIGO PARA PUNTOS----------------------------	
        calcula_puntos:
        .fnstart
                ldr r0, =intentos			//cargo puntero a intentos
                ldrb r1, [r0]				//cargo los intentos restantes
                ldr r2, =puntaje			//cargo puntero al puntaje
		ldrb r3, [r2]				//cargo el puntaje
		ldr r4, =letras_palabra_random		//cargo puntero al largo de la palabra a adivinar
		ldrb r5, [r4]				//cargo el largo de la palabra a adivinar
                mul r1, r5				//multiplico el largo de la palabra por los intentos restantes
		add r3, r1				//y lo sumo al puntaje
                strb r3, [r2]				//guardo el puntaje
                bx lr
        .fnend

        compara_palabras:
        .fnstart
                ldr r0, =palabra_random			//cargo puntero a la palabra a adivinar
                ldr r1, =palabra_usuario		//cargo puntero a la palabra del usuario
                ciclo:
                        ldrb r2, [r0], #1		//cargo la primer letra de la palabra a adivinar y muevo en 1 el puntero
                        ldrb r3, [r1], #1		//cargo la primer letra de la palabra del usuario y muevo en 1 el puntero
                        cmp r2, #00
                        beq palabra_acertada		//si llego a null salta
                        cmp r2, r3			//comparo las letras de ambas palabras
                        bne resta_intento		//si no son iguales salta al final
                        bal ciclo			//si son iguales continua el ciclo
                resta_intento:
                        ldr r0, =intentos		//cargo puntero a los intentos
                        ldrb r1, [r0]			//cargo los intentos
                        sub r1, #1			//y les resto 1
                        strb r1, [r0]			//guardo los intentos actualizados
			bal fin_ciclo
		palabra_acertada:			//salta acá si todas las letras de ambas palabras coinciden
			mov r0, #1			//marca que la palabra del usuario es correcta
                fin_ciclo:
                        bx lr
        .fnend

	convierte_puntos:
	.fnstart
		ldr r0, =puntaje			//cargo el puntero al puntaje
		ldrb r1, [r0]				//cargo el puntaje
		ldr r3, =puntaje_ascii			//cargo el puntero al puntaje guardado en ascii
		mov r2, #0				//contador de restas
		mov r4, #0				//desplazador de registro
			resta100:			//resta de a 100 para conseguir las centenas
				cmp r1, #100
				blt ascii_100		//salta si el puntaje es menor a 100
                                sub r1, #100
                                add r2, #1		//sumo 1 al contador de restas
                                bal resta100
			ascii_100:
				add r2, #0x30		//sumo 30h para hacerlo ascii
				strb r2, [r3, r4]	//guardo el ascii en memoria
				add r4, #1		//aumento el desplazador
				mov r2, #0		//reinicio el contador de restas
			resta10:			//resto de a 10 para conseguir la decena
			 	cmp r1, #10
				blt ascii_10
				sub r1, #10
				add r2, #1
				bal resta10
			ascii_10:
				add r2, #0x30
				strb r2, [r3, r4]
				add r4, #1
				mov r2, #0
			resta1:				//resto de a 1 para conseguir las unidades
                                cmp r1, #1
                                blt ascii_1
                                sub r1, #1
                                add r2, #1
                                bal resta1
                        ascii_1:
                                add r2, #0x30
                                strb r2, [r3, r4]
                                add r4, #1
                                mov r2, #0
			fin_convierte_numeros:
				bx lr
	.fnend

	modifica_mensaje_puntos:
        .fnstart
                ldr r1, =puntaje_ascii			//cargo el puntero al mensaje que indica el puntaje
                ldrb r3, [r1], #1               	//cargo el primer ascii
		mov r4, #3				//contador de x a modificar
		mov r5, #0				//desplazador de registro
                ciclo_modifica_mensaje_puntos:
                        ldrb r2, [r0, r5]		//dependiendo de si se ganó o perdió, r0 apunta el mensaje correspondiente
							//y viene como parámetro externo a la subrutina
                        cmp r2, #'x'            	//cuando llega a la x salta
                        beq fin_modifica_mensaje_puntos
			add r5, #1			//sumo 1 al desplazador
                        bal ciclo_modifica_mensaje_puntos
                fin_modifica_mensaje_puntos:
                        strb r3, [r0, r5]      		//donde está la x reemplazo por el numero de letras
			ldrb r3, [r1], #1		//cargo el siguiente ascii
			add r5, #1			//sumo 1 al desplazador
			sub r4, #1			//resto 1 al contador de x a modificar
			cmp r4, #0
			bgt ciclo_modifica_mensaje_puntos	//si el contador de x llega no es cero reinicia el ciclo
                        bx lr
        .fnend

        

	imprime_mensaje_puntos:				//imprime el mensaje que corresponda segun se gane o pierda
	.fnstart					//recibe por afuera los parametros del largo de la cadena y el puntero al mensaje
		mov r7, #4
		mov r0, #1
		swi 0
		bx lr
	.fnend

@-----------------------FIN CODIGO PUNTOS--------------------------





@-----------------------CODIGO PARA VOLVER A JUGAR-----------------
	
	reinicia_mensaje_ingrese:			//restauro la x en el mensaje
	.fnstart
		ldr r0, =mensaje_ingrese
		mov r1, #'x'
		strb r1, [r0, #23]			//en la posición donde ahora está el largo de la palabra restauro la x
		bx lr
	.fnend

	reinicia_mensaje_puntaje_ganaste:          	//restauro las x en el mensaje
        .fnstart
                ldr r0, =mensaje_puntaje_ganaste	//cargo puntero del mensaje cuando se gana
                mov r1, #'x'
                strb r1, [r0, #44]			//donde está el puntaje restauro las x
		strb r1, [r0, #45]
		strb r1, [r0, #46]
                bx lr
        .fnend

        reinicia_mensaje_puntaje_perdiste:          	//restauro las x en el mensaje
        .fnstart
                ldr r0, =mensaje_puntaje_perdiste	//cargo el puntero del mensaje cuando se pierde
                mov r1, #'x'
                strb r1, [r0, #24]			//donde está el puntaje restauro las x
                strb r1, [r0, #25]
                strb r1, [r0, #26]
                bx lr
        .fnend



	imprime_seguir_jugando:				//imprime mensaje preguntando si se quiere seguir jugando
	.fnstart
		mov r7, #4
		mov r0, #1
		mov r2, #22				//largo del mensaje
		ldr r1, =mensaje_seguir_jugando		//puntero al mensaje de seguir jugando
		swi 0
		bx lr
	.fnend

	leer_seguir_jugando:				//lee el input del usuario para seguir jugando o no
	.fnstart
		mov r7, #3
		mov r0, #0
		mov r2, #2				//largo que se acepta
		ldr r1, =s_n				//puntero a donde se guarda el input del usuario
		swi 0
		bx lr
	.fnend

	seguir_jugando:
		bl imprime_seguir_jugando
		leer_entrada:
            	bl leer_seguir_jugando       		// Lee la entrada del usuario
            	ldrb r2, [r1]               		// Carga el carácter ingresado
            	cmp r2, #'s'                		// ¿Es 's'?
            	beq funcion_myrand          		// Si es 's', vuelve a jugar
            	cmp r2, #'n'                		// ¿Es 'n'?
            	beq fin                     		// Si es 'n', termina el programa
            	bal leer_entrada            		// Si no es 's' ni 'n', vuelve a pedir entrada

@------------------------------------------------------------------




@---------------------------RANDOM---------------------------------
	myrand:
        .fnstart
                push {lr}
                ldr r1, =seed @ leo puntero a semilla
                ldr r0, [ r1 ] @ leo valor de semilla
                ldr r2, =const1
                ldr r2, [ r2 ] @ leo const1 en r2
                mul r3, r0, r2 @ r3= seed * 1103515245
                ldr r0, =const2
                ldr r0, [ r0 ] @ leo const2 en r0
                add r0, r0, r3 @ r0= r3+ 12345
                str r0, [ r1 ] @ guardo en variable seed
        /* Estas dos lÃ­ neas devuelven "seed > >16 & 0x7fff ".
        Con un peque Ã±o truco evitamos el uso del AND */
                LSL r0, # 1
                LSR r0, # 26
                pop {lr}
                bx lr
        .fnend

        mysrand:
        .fnstart
                push {lr}
                ldr r1, =seed
                str r0, [ r1 ]
                pop {lr}
                bx lr
        .fnend

	imprime_palabra_random:
	.fnstart
		mov r7, #4
		mov r0, #1
		mov r2, #10
		ldr r1, =palabra_random
		swi 0
		
		mov r7,#4
		mov r0,#1
		mov r2,#10
		ldr r1, =salto_linea
		swi 0
		bx lr
	.fnend
@-----------------------------------------------------------------

@-----------------------RANKING-----------------------------------

	@ Subrutina para pedir el nombre
	pedir_nombre:
	.fnstart
    		push {r0, r1, r2, r7, lr}              @ Guarda registros usados

    		mov r0, #0                             @ Leer desde stdin
    		ldr r1, =nombre                        @ Buffer donde almacenar el nombre
    		ldr r2, =rankingLength                  @ Longitud máxima permitida
    		ldr r2, [r2]
    		mov r7, #3
    		swi 0                                  @ Syscall: Leer entrada

   	@ bl eliminar_salto_linea                @ Llama a subrutina para eliminar '\n'

    		pop {r0, r1, r2, r7, lr}               @ Restaura registros
    		bx lr                                  @ Retorna
	.fnend



@ Subrutina para pedir el valor
	pedir_valor:
	.fnstart
    		push {r0, r1, r2, r7, lr}              @ Guarda registros usados

    		mov r0, #0                             @ Leer desde stdin
    		ldr r1, =valor                         @ Buffer donde almacenar el valor
   		mov r2, #4                             @ Longitud máxima permitida (4 bytes)
    		mov r7, #3
    		swi 0                                  @ Syscall: Leer entrada

    		bl eliminar_salto_linea                @ Llama a subrutina para eliminar '\n'

    		pop {r0, r1, r2, r7, lr}               @ Restaura registros
    		bx lr                                  @ Retorna
	.fnend



	@ Subrutina para eliminar el carácter '\n'
	eliminar_salto_linea:
	.fnstart
    		push { r1, r2 ,r3 , lr}                @ Guarda registros usados y LR

    		mov r2, #0                             @ Índice inicial
		buscar_salto:
    		ldrb r3, [r1, r2]                      @ Leer un byte del buffer
    		cmp r3, #10                            @ Comparar con '\n'
    		beq reemplazar                         @ Si es '\n', reemplazarlo
    		cmp r3, #0                             @ Si es terminador null, finalizar
    		beq fin_eliminar_salto
    		add r2, r2, #1                         @ Incrementar índice
    		b buscar_salto                         @ Continuar buscando

		reemplazar:
    		mov r3, #0                             @ Cargar terminador null ('\0')
    		strb r3, [r1, r2]                      @ Sobrescribir el '\n' con '\0'

	fin_eliminar_salto:
    		pop { r1, r2 ,r3 , lr}                 @ Restaura registros usados y LR
    		bx lr                                  @ Retorna
	.fnend



	@ Subrutina para formatear rankingActual
	formato_ranking_actual:
	.fnstart
    		push {r0, r1, r2, r3, lr}              @ Guarda registros usados, incluyendo LR

    		ldr r0, =rankingActual                 @ Dirección del buffer de rankingActual
    		ldr r2, =nombre

    		ldr r3, =rankingLength
    		ldr r3, [r3]
    		sub r3, #3
    		bl copiar_nombre_con_puntos            @ Copia el nombre alineado a la derecha con puntos

    		ldr r0, =rankingActual                 @ Reinicia el puntero al inicio del buffer
    		ldr r1, =valor                         @ Dirección del valor
    		mov r3, #3                             @ Longitud del valor (3 caracteres)
    		bl copiar_valor                        @ Copia los 3 caracteres del valor al inicio

    		pop {r0, r1, r2, r3, lr}               @ Restaura registros, incluyendo LR
    		bx lr                                  @ Retorna
	.fnend



	@ Subrutina para copiar el valor al buffer
	copiar_valor:
	.fnstart
    		push {r0, r1, r3, r4 ,lr}              @ Guarda LR antes de cualquier llamada

		copiar_valor_loop:
    		ldrb r4, [r1], #1                      @ Lee un byte del valor y avanza
    		strb r4, [r0], #1                      @ Escribe el byte en el destino y avanza
    		subs r3, r3, #1                        @ Decrementa el contador
    		bne copiar_valor_loop                  @ Repite si no ha terminado

    		pop {r0, r1, r3, r4 ,lr}               @ Restaura LR
    		bx lr                                  @ Retorna
	.fnend


	@ Subrutina para copiar el nombre al buffer con puntos
	copiar_nombre_con_puntos:
	.fnstart
    		push {r0, r1, r2, r3, r4, r5, r6, lr}   @ Guarda registros usados, incluyendo LR

    		mov r1, r2                              @ R1 apunta al nombre (R2 contiene la dirección del nombre)
    		mov r4, #0                              @ Índice para contar la longitud del nombre

		contar_nombre:
    		ldrb r5, [r1, r4]                       @ Lee un byte del nombre
    		cmp r5, #'\n'                           @ Comprueba si es el salto de línea
   		beq rellenar_puntos                     @ Salta si encuentra el salto de línea
    		add r4, r4, #1                          @ Incrementa la longitud
    		cmp r4, r3                              @ Compara con el límite de 19 (espacio disponible)
    		blt contar_nombre                       @ Continúa si no ha llegado al límite

		rellenar_puntos:
    		sub r5, r3, r4                          @ Calcula cuántos puntos necesita (r3 es 19)
		rellenar_puntos_loop:
    		subs r5, r5, #1                         @ Decrementa el contador de puntos
    		mov r6, #'.'                            @ Carga el carácter punto
    		strb r6, [r0], #1                       @ Escribe un punto en el destino
    		bge rellenar_puntos_loop                @ Repite si aún quedan puntos por escribir

		copiar_nombre_loop:
    		ldrb r6, [r1], #1                       @ Lee un byte del nombre
    		cmp r6, #'\n'                           @ Comprueba si es el salto de línea
    		beq copiar_salto_fin                    @ Salta para copiar el salto de línea
    		strb r6, [r0], #1                       @ Escribe el byte en el destino
    		subs r3, r3, #1                         @ Decrementa la longitud disponible
    		bgt copiar_nombre_loop                  @ Continúa si aún hay espacio

		copiar_salto_fin:
   		strb r6, [r0], #1                       @ Copia el salto de línea (`\n`) al destino

		copiar_nombre_fin:
   
    		pop {r0, r1, r2, r3, r4, r5, r6, lr}    @ Restaura registros
    		bx lr                                   @ Retorna
	.fnend



	imprimir_ranking_actual:
	.fnstart
    		push {r0, r1, r2, r7, lr}               @ Guarda en la pila los registros r0, r1, r2, r7 y lr. 
                                    
    		mov r0, #1                              @ Configura r0 .                
    		ldr r1, =txtRankingActual               @ Carga en r1 la dirección de la variable `txtRankingActual`, que contiene los datos a imprimir.
    		ldr r2, =lengthTxtRA                    @ Carga en r2 la dirección de la variable `lengthTxtRA`, que almacena el tamaño del buffer.
    		mov r7, #4  
    		swi 0                                   @ Llama al sistema operativo para ejecutar la syscall.

    		mov r0, #1                           
    		ldr r1, =rankingActual                  @ Carga en r1 la dirección de la variable `rankingActual`, que contiene los datos a imprimir.
    		ldr r2, =rankingLength                   @ Carga en r2 la dirección de la variable `rankingLength`, que almacena el tamaño del buffer.
    		ldr r2, [r2]                            @ Carga el valor de `rankingLength` desde la memoria en r2 (número de bytes a imprimir).                             	@ Syscall número 4 (escribir datos).
    		mov r7, #4  
    		swi 0                                  

    		pop {r0, r1, r2, r7, lr}                @ Restaura los valores originales de los registros r0, r1, r2, r7 y lr desde la pila.
    		bx lr                                   @ Retorna al llamador usando la dirección almacenada en lr.
	.fnend



	@ Leer el archivo y cargar buffer
	cargar_buffer:
	.fnstart
    		push { r0, r1, r2, r4, r7, lr}
    		@ Abrir el archivo
    		ldr r0, =filename                   @ Dirección del nombre del archivo
    		mov r1, #0                          @ Modo de apertura: lectura
    		mov r7, #5                          @ Syscall 
    		swi 0                               @ Llama al sistema operativo
    		mov r4, r0                          @ Guarda el descriptor del archivo en r4

    		@ Leer el contenido en el buffer
    		mov r0, r4                          @ Descriptor del archivo
    		ldr r1, =buffer                     @ Dirección del buffer
    		ldr r2, =bufferLength               @ Tamaño máximo a leer
    		mov r7, #3                          @ Syscall 
    		swi 0                               @ Llama al sistema operativo

    		@ Cerrar el archivo
    		mov r0, r4                          @ Descriptor del archivo a cerrar
   		mov r7, #6                          @ Syscall 
    		swi 0                               @ Llama al sistema operativo

    		pop { r0, r1, r2, r4, r7, lr}
    		bx lr                               @ Retorna de la subrutina
	.fnend



	incrementar_ranking_al_buffer:
	.fnstart
    		push {r0, r1, r2, r3, r4, lr}      @ Guarda registros usados, incluyendo LR

    		ldr r0, =buffer                    @ R0 apunta al inicio del buffer
    		mov r1, r0                         @ R1 será el puntero para encontrar el final

		encontrar_final_buffer:
    		ldrb r2, [r1], #1                  @ Lee un byte y avanza el puntero
    		cmp r2, #0                         @ Comprueba si es el terminador nulo
    		bne encontrar_final_buffer         @ Continúa si no ha encontrado el terminador

    		sub r1, r1, #1                     @ Corrige el puntero (última posición válida antes del nulo)

    		ldr r3, =rankingActual             @ R3 apunta al inicio de rankingActual

		copiar_ranking_actual:
    		ldrb r2, [r3], #1                  @ Lee un byte de rankingActual
    		cmp r2, #0                         @ Comprueba si es el terminador nulo
    		beq terminar_copia                 @ Salta si ha terminado de copiar

    		strb r2, [r1], #1                  @ Copia el byte al buffer y avanza
    		b copiar_ranking_actual            @ Repite el ciclo

		terminar_copia:

    		pop {r0, r1, r2, r3, r4, lr}       @ Restaura registros
    		bx lr                              @ Retorna
	.fnend


	modificar_buffer_con_3_ultimos:
	.fnstart
   		push {r0, r2, r3, r4, r5, r6, lr}           @ Guarda registros usados y enlace
    		ldr r4, =buffer                     @ r4 apunta al inicio del buffer
    		bl calcular_longitud_del_buffer
    		mov r5, r2                          @ r5 contiene el tamaño del buffer (parámetro pasado en r2)
    		mov r2, #0                          @ r2 llevará el contador de saltos de línea encontrados
    		mov r3, #0                          @ r3 llevará el índice del cuarto salto de línea desde el final

		contar_saltos:
    		subs r5, r5, #1                     @ Decrementa el tamaño del buffer (recorremos desde el final)
    		blt fin_conteo                      @ Si hemos recorrido todo el buffer, salir
    		ldrb r6, [r4, r5]                   @ Carga el byte actual desde el buffer
    		cmp r6, #10                         @ Compara el byte con el carácter de salto de línea ('\n')
    		bne contar_saltos                   @ Si no es un salto de línea, continúa contando
    		add r2, r2, #1                      @ Incrementa el contador de saltos de línea encontrados
    		cmp r2, #4                          @ ¿Es el cuarto salto de línea?
    		bne contar_saltos                   @ Si no, sigue contando
    		mov r3, r5                          @ Guarda el índice del cuarto salto de línea desde el final
    		b fin_conteo                        @ Finaliza el conteo

		fin_conteo:
    		cmp r2, #4                          @ ¿Encontramos al menos 4 saltos de línea?
    		blt retornar                        @ Si no, no hay nada que modificar

		modificar_buffer:           
    		add r6, r5, #1                      @ Sumamos una posición
    		ldr r5, =buffer                     @ r5 apunta al inicio del buffer original
    		add r6, r5                          @ Simamos el puntero con el arranque del recorte

		sobreescribir:
    		ldrb r0, [r6], #1                   @ Carga un byte desde el nuevo contenido
    		strb r0, [r5], #1                   @ Sobrescribe el buffer original
    		cmp r0, #0                          @ Verifica si es el final del buffer (carácter nulo)
    		bne sobreescribir                   @ Continúa sobrescribiendo mientras no sea el final

    		mov r0, #10
    		strb r0, [r5], #1                       @ Sumamos un caracter nulo 

    		mov r0, #0
    		strb r0, [r5], #1                       @ Sumamos un caracter nulo      

		retornar:
    		pop {r0, r2, r3, r4, r5, r6, lr}            @ Restaura registros
    		bx lr                               @ Retorna
	.fnend



		imprimir_rankings:
		.fnstart

   	 	mov r0, #1                           
    		ldr r1, =buffer                    @ Carga en r1 la dirección de la variable `rankingActual`, que contiene los datos a imprimir.
    		ldr r2, =bufferLength              @ Carga en r2 la dirección de la variable `rankingLength`, que almacena el tamaño del buffer.
    		mov r7, #4
    		swi 0  
    		bx lr
	.fnend



	modificar_rankings:
	.fnstart
    		push {r0, r1, r2, r6, r7, lr}        @ Guarda registros usados y LR

    		ldr r0, =filename                    @ Dirección del nombre del archivo
    		mov r1, #2                           @ Modo lectura/escritura (2)
    		mov r2, #438                         @ Permisos (0666 en octal, pero no se usa para lectura/escritura)
    		mov r7, #5                           @ Syscall: open
    		swi 0                                @ Llama al sistema operativo para abrir el archivo
    
    		mov r6, r0                           @ Guardar el descriptor del archivo en r6


    		@ Sobrescribir el archivo con el nuevo contenido del buffer
   		mov r0, r6                            @ Descriptor del archivo
    		ldr r1, =buffer                       @ Dirección del buffer
    		bl calcular_longitud_del_buffer       @ En r2 queda la longitud del buffer

    		escribir_archivo:
       		mov r7, #4                       @ Syscall: `write` (4 en ARM Linux)
        	swi #0

    		mov r7, #4                            @ Syscall: write
    		swi 0                                 @ Llama al sistema operativo para escribir el contenido modificado

    		@ Cerrar el archivo
    		mov r0, r6                            @ Descriptor del archivo
    		mov r7, #6                            @ Syscall: close
    		swi 0                                 @ Llama al sistema operativo para cerrar el archivo

    		pop {r0, r1, r2, r6, r7, lr}          @ Restaura registros
    		bx lr                                 @ Retorna
		.fnend


		@calcula la longitud en r2
	calcular_longitud_del_buffer:
	.fnstart

	    	push {r0, r1, r3}
    		ldr r0, =buffer
    		mov r2, #0

    		calcular_longitud:  
        	ldrb r3, [r0, r2]                @ Lee un byte del buffer
        	cmp r3, #0                       @ Compara con terminador nulo
        	beq final_del_buffer             @ Salta si encuentra el final
        	add r2, r2, #1                   @ Incrementa la longitud
        	b calcular_longitud              @ Repite el ciclo
    		final_del_buffer:
    		pop {r0, r1, r3}
    		bx lr                                @ Retorna
	.fnend


@---------------------------------------------------------------------

.global main
        main:
		ldr r11, =buffer

                funcion_imprime_mensaje_comienzo_juego:
                        bl imprime_mensaje_comienzo_juego
                funcion_abrir_archivo:
                        bl abrirArchivo
                        cmp r0, #0
                        blt fin                         //si r0 es menor a 0 hubo error y no se cargÃ³ el archivo
                        mov r6, r0
                funcion_leer_palabras:                  //guardo las palabras en memoria
                        bl leer_palabras
                funcion_cerrar_archivo:                 //cierro el archivo de palabras
                        bl cierraArchivo
		funcion_mysrand:
			mov r0, #42		         //cargo el parámetro para el numero random
			bl mysrand
		funcion_myrand:
			bl myrand
                funcion_sortear_palabra:                //elige la palabra segun el numero aleatorio
                        bl sortear_palabra
                funcion_calcular_letras_random:         //calcula las letras de la palabra a adivinar
                        bl calcular_letras_random
                funcion_modifica_mensaje_ingrese:       //ingresa la cantidad de letras en el mensaje que se da al usuario
                        bl modifica_mensaje_ingrese
                funcion_ingrese_palabra:                //imprime un mensaje con la cantidad de letras a ingresar
                        bl ingrese_palabra
			bl reinicia_mensaje_ingrese
		funcion_imprime_palabra_random:
			ldr r1, =letras_palabra_random
			ldrb r2, [r1]
			bl imprime_palabra_random

        verificar_largo:
                bl leer_palabra                         //usuario ingresa palabra
                bl calcula_letras_usuario               //se calculan las letras de la palabra del usuario
                ldr r0, =letras_palabra_random		//cargo puntero del largo de la palabra random
                ldrb r1, [r0]				//cargo el largo de la palabra random
                ldr r2, =letras_palabra_usuario		//cargo el puntero del largo de la palabra del usuario
                ldrb r3, [r2]				//cargo el largo de la palabra del usuario
                cmp r3, r1                              //comparo el largo de la palabra a buscar y la palabra del usuario
                bgt palabra_mas_larga			//si es mas larga salta a palabra_mas_larga
                blt palabra_mas_corta			//si es mas corta salta a palabra_mas_corta
                bl informar_resultado			//si tiene el largo correcto se verifica si las letras tienen que ser rojas,amarillas o verdes
		bl imprimir_resultado			//se pasa por pantalla la palabra con las letras con colores
		bl compara_palabras			//compara letra por letra ambas palabras
		cmp r0, #1				//si r0 vuelve en 1 de compara_palabras significa que la palabra ingresada es correcta
		beq fin_juego_ganaste			//si r0 vale 1 salta a fin_juego_ganaste
		ldr r0, =intentos			//cargo puntero de intentos
		ldrb r1, [r0]				//cargo los intentos restantes
		cmp r1, #0
		beq fin_juego_perdiste			//si los intentos llegan a 0 salta a fin_juego_perdiste
		bgt verificar_largo			//si los intentos son mayores a 0 se pide otra palabra al usuario
        palabra_mas_larga:
                bl mensaje_mas_largo                    //mensaje si la palabra es mas larga
                bal verificar_largo                     //pide ingresar palabra nuevamente
        palabra_mas_corta:
                bl mensaje_mas_corto                    //mensaje si la palabra es mas corta
                bal verificar_largo                     //pide ingresar la palabra nuevamente
	fin_juego_ganaste:
		bl calcula_puntos			//se calculan los puntos adquiridos
		bl convierte_puntos			//los puntos se pasan a ascii
		ldr r0, =mensaje_puntaje_ganaste	//cargo puntero del mensaje que se muetra al ganar
		bl modifica_mensaje_puntos		//lo modifico para incluír el puntaje logrado
		ldr r1, =mensaje_puntaje_ganaste	//cargo el puntero del mensaje que se muetra al ganar
		mov r2, #49				//cargo en r2 el largo del mensaje
		bl imprime_mensaje_puntos		//imprimo el mensaje ganador
		bl reinicia_mensaje_puntaje_ganaste	//vuelvo a poner x en las posiciones donde va el puntaje en el mensaje
		ldr r0, =intentos			//cargo el puntero de intentos
		mov r1, #5
		strb r1, [r0]				//reinicio el contador de intentos a 5
		bal seguir_jugando
	fin_juego_perdiste:				//todos los comentarios de fin_juego_ganaste aplican acá pero para el mensaje cuando perdes
                bl calcula_puntos
                bl convierte_puntos
		ldr r0, =mensaje_puntaje_perdiste
                bl modifica_mensaje_puntos
		ldr r1, =mensaje_puntaje_perdiste
		mov r2, #29
                bl imprime_mensaje_puntos
		bl reinicia_mensaje_puntaje_perdiste
		ldr r0, =intentos
		mov r1, #5
		strb r1, [r0]

		@pedir los valores del usuario y imprimirlo
    		bl pedir_nombre
    		bl pedir_valor
    		bl formato_ranking_actual              @ Formatear rankingActual
    		bl imprimir_ranking_actual

		@tomar datos del .txt y imprimirlo
   		bl cargar_buffer
    		bl incrementar_ranking_al_buffer

    		bl modificar_buffer_con_3_ultimos

    		bl imprimir_rankings

    		bl modificar_rankings

	fin:
                mov r7, #1
                swi 0


