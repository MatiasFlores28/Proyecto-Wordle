.data

        archivo: .asciz "palabras.txt"
        espacio: .zero 10
        vector: .asciz ""                  //quedan todos las palabras del txt
        espacio1: .zero 400
        palabra_random: .asciz ""
        espacio2: .zero 50
        letras_palabra_random: .byte 0
        espacio3: .zero 10
        palabra_usuario: .asciz ""
        espacio4: .zero 10
        letras_palabra_usuario: .byte 0
        mensaje_ingrese: .asciz "Ingrese una palabra de x letras\n"
        mensaje_mas_letras: .asciz "La palabra ingresada es mas larga a la buscada, intentelo de nuevo\n"
        mensaje_menos_letras: .asciz "La palabra ingresada es mas corta a la buscada, intentelo de nuevo\n"
        mensaje_comienzo_juego: .asciz "Bienvenido a W O R D L E!\nEl objetivo del juego es adivinar una palabra en una cantidad limitada de intentos\n"
	guardar:           .space 100
	colores:           .space 5  @ Almacena los colores 'V', 'A', 'R'
	espacio5: .space 50
	puntaje: .byte 0
	espacio6: .space 10
	puntaje_ascii: .asciz ""
	espacio7: .space 10
	intentos: .byte 5
	espacio8: .space 10
	mensaje_puntaje_ganaste: .asciz "Adivinaste la palabra! Tu puntaje actual es xxx\n"
	mensaje_puntaje_perdiste: .asciz "Perdiste! Tu puntaje es xxx\n"
	mensaje_jugar_nuevamente: .asciz "Para jugar de vuelta Presiona 's' para continuar o 'n' para salir.\n"
    	respuesta_usuario:        .space 4  @ Espacio para almacenar la respuesta del usuario
	


	@ Datos para los colores y formato de impresi贸n
	color_default:     .asciz "\033[37m"
	color_verde:       .asciz "\033[32m"
	color_amarillo:    .asciz "\033[33m"
	color_rojo:        .asciz "\033[31m"
	salto_linea:       .asciz "\n"

.text
        abrirArchivo:                           //abre el archivo txt con las palabras
        .fnstart
                mov r7, #5
                ldr r0, =archivo
                mov r1, #0
                mov r2, #0
                swi 0
                bx lr
        .fnend

        leer_palabras:                          //carga las palabras del archivo a la memoria
        .fnstart
                mov r7, #3
                ldr r1, =vector
                mov r2, #368                    //cantidad de caracteres que tengo en el txt
                swi 0
                bx lr
        .fnend

        cierraArchivo:                          //cierra el archivo txt
        .fnstart
                mov r0, r6
                mov r7, #6
                swi 0
                bx lr
        .fnend

        sortear_palabra:                        //elige una palabra seg煤n el n煤mero random
        .fnstart
                ldr r2, =palabra_random
                mov r3, #3                     //palabra a elegir
                ldr r0, =vector
                mov r4, #0                      //desplazador de registro
                mov r5, #0                      //para "limpiar" r2
                ciclo_sortear:
                        ldrb r1, [r0], #1       //carga el primer caracter y se mueve al segundo
                        cmp r1, #','
                        beq otra_palabra        //salta si llego a la coma
                        strb r1, [r2, r4]
                        add r4, #1
                        bal ciclo_sortear
                otra_palabra:
                        sub r3, #1              //le resto 1 al numero random
                        cmp r3, #0              //si llego a 0 encontr茅 la palabra correcta
                        beq fin_ciclo_sortear
                        mov r6, r4
                        mov r4, #0
                        borro_r2:
                                strb r5, [r2,r6]        //guardo 0 en todas las posiciones de r2
                                sub r6, #1
                                cmp r6, #0
                                bge borro_r2
                                bal ciclo_sortear
                fin_ciclo_sortear:
                        bx lr
        .fnend

        calcular_letras_random:
        .fnstart
                ldr r0, =palabra_random
                ldr r2, =letras_palabra_random
                mov r3, #0                      //contador de letras
                ciclo_letras:
                        ldrb r1, [r0], #1
                        cmp r1, #00             //salta cuando termina la cadena
                        beq fin_calcular_letras
                        add r3, #1              //suma 1 por cada caracter
                        bal ciclo_letras
                fin_calcular_letras:
                        strb r3, [r2]           //guardo el total de letras
                        bx lr
        .fnend

        modifica_mensaje_ingrese:
        .fnstart
                ldr r0, =mensaje_ingrese
                ldr r1, =letras_palabra_random
                ldrb r3, [r1]                   //cargo letras de la palabra random
                add r3, #0x30                   //lo transformo en ascii
                ciclo_modifica_mensaje:
                        ldrb r2, [r0], #1
                        cmp r2, #'x'            //cuando llega a la x salta
                        beq fin_modifica_mensaje
                        bal ciclo_modifica_mensaje
                fin_modifica_mensaje:
                        strb r3, [r0, #-1]      //donde est谩 la x reemplazo por el numero de letras
                                                //resto 1 para volver a la posicion del x
                        bx lr
        .fnend

        ingrese_palabra:
        .fnstart
                mov r7, #4
                mov r0, #1
                mov r2, #32
                ldr r1, =mensaje_ingrese
                swi 0
                bx lr
        .fnend

        leer_palabra:
        .fnstart
                mov r7, #3
                mov r0, #0
                mov r2, #20
                ldr r1, =palabra_usuario
                swi 0
                bx lr
        .fnend

        calcula_letras_usuario:
        .fnstart
                ldr r0, =palabra_usuario
                mov r1, #0              //contador de letras
                ciclo_calcula_letras:
                        ldrb r2, [r0], #1
                        cmp r2, #'\n'   //salta cuando llega al salto de linea
                        beq fin_ciclo_calcula_letras
                        add r1, #1      //suma 1 al contador de letras
                        bal ciclo_calcula_letras
                fin_ciclo_calcula_letras:
                        ldr r0, =letras_palabra_usuario
                        strb r1, [r0]
                        bx lr
        .fnend

        mensaje_mas_largo:
        .fnstart
                mov r7, #4
                mov r0, #1
                mov r2, #67
                ldr r1, =mensaje_mas_letras
                swi 0
                bx lr
        .fnend

        mensaje_mas_corto:
        .fnstart
                mov r7, #4
                mov r0, #1
                mov r2, #67
                ldr r1, =mensaje_menos_letras
                swi 0
                bx lr
        .fnend

        imprime_mensaje_comienzo_juego:
        .fnstart
                mov r7, #4
                mov r0, #1
                mov r2, #110
                ldr r1, =mensaje_comienzo_juego
                swi 0
                bx lr
        .fnend

	informar_resultado:
    	.fnstart
	    push {lr}
	    ldr r4, =palabra_usuario
	    ldr r5, =palabra_random
	    ldr r6, =letras_palabra_random
	    ldrb r6, [r6]
	    ldr r7, =guardar
	    mov r8, #0
	    ldr r10, =colores            @ Puntero a los colores para guardar 'V', 'A', 'R'

		verificar_letras:
		    cmp r8, r6                   @ comparo el puntero V con length
		    beq fin_informar_resultado   @ si llego al final salgo

		@------------verde-------------
		    ldrb r0, [r4, r8]
		    ldrb r1, [r5, r8]
		    cmp r0, r1                   @ cmp 'a' con 'm'
		    beq clasificar_verde         @ si son == entro

		@------------amarilla----------
		    mov r9, #0                   @ si vengo aca, no es V
		buscar_amarilla:
		    cmp r9, r6                   @ cmp puntero A con length
		    beq clasificar_roja

		    ldrb r2, [r5, r9]            @ agarro 'm' y me desplazo con r9
		    cmp r0, r2
		    beq clasificar_amarilla
		    add r9, r9, #1
		    bal buscar_amarilla

		clasificar_verde:
		    mov r2, #'V'
		    strb r2, [r7, r8]
		    strb r2, [r10, r8]   @ Guardar color en la tabla de colores
		    bal siguiente_letra

		clasificar_amarilla:
		    mov r2, #'A'
		    strb r2, [r7, r8]
		    strb r2, [r10, r8]   @ Guardar color
		    bal siguiente_letra

		clasificar_roja:
		    mov r2, #'R'
		    strb r2, [r7, r8]
		    strb r2, [r10, r8]   @ Guardar color

		siguiente_letra:
		    add r8, r8, #1
		    bal verificar_letras

		fin_informar_resultado:
		    pop {lr}
		    bx lr
	    .fnend

	@INICIO CODIGO PROFESORES
	//////////////////////////////////////////////////////////////////////////
	@ Cambia el color del texto a imprimir
	cambiar_color:
    	.fnstart
		 push {lr}
		 mov r2, #6      @ Largo del c贸digo de los colores
		 bl imprimir
		 pop {lr}
		 bx lr
	.fnend

	//////////////////////////////////////////////////////////////////////////
	@ Imprime un mensaje por pantalla
	imprimir:
	.fnstart
		push {lr}
		mov r0, #1      @ Salida cadena
		mov r7, #4      @ C贸digo de interrupci贸n: imprimir
		swi 0           @ Llamada al sistema
		pop {lr}
		bx lr
	.fnend

	//////////////////////////////////////////////////////////////////////////
	@ Imprime cada letra del usuario con su color correspondiente
	imprimir_resultado:
	.fnstart
		push {lr}
		mov r3, #0      @ Iterador
		ldr r4, =letras_palabra_usuario
		ldrb r4, [r4]

		ciclo_imprimir_resultado:
			ldr r2, =colores
			ldrb r0, [r2, r3]    @ Obtiene la letra del color
			cmp r0, #'R'
			beq imprimir_rojo
			cmp r0, #'A'
			beq imprimir_amarillo
			cmp r0, #'V'
			beq imprimir_verde

		imprimir_rojo:
			ldr r1, =color_rojo
			bl cambiar_color
			b imprimir_caracter

		imprimir_amarillo:
			ldr r1, =color_amarillo
			bl cambiar_color
			b imprimir_caracter

		imprimir_verde:
			ldr r1, =color_verde
			bl cambiar_color
			b imprimir_caracter

		imprimir_caracter:                      @obtengo el caracter que se debe imprimir
			ldr r1, =palabra_usuario            @direccion de la palabra que ingreso e user
			add r1, r3                          @le agrego el iterador para llegar a la letra que estoy verificando
			mov r2, #1
			bl imprimir
			@aumento el itereador para pasar a la siguiente letra
			add r3, #1
			cmp r3, r4
			bne ciclo_imprimir_resultado

		fin_imprimir_resultado:
			ldr r1, =color_default
			bl cambiar_color
			//salto de linea
			ldr r1, =salto_linea
			mov r2, #1
			bl imprimir
			pop {lr}
			bx lr
	.fnend

        calcula_puntos:
        .fnstart
                ldr r0, =intentos
                ldrb r1, [r0]				//cargo los intentos restantes
                ldr r2, =puntaje
		ldrb r3, [r2]				//cargo el puntaje
		ldr r4, =letras_palabra_random
		ldrb r5, [r4]				//cargo el largo de la palabra
                mul r1, r5				//multiplico el largo de la palabra por los intentos restantes
		add r3, r1				//y lo sumo al puntaje
                strb r3, [r2]
                bx lr
        .fnend

        compara_palabras:
        .fnstart
                ldr r0, =palabra_random
                ldr r1, =palabra_usuario
        ciclo:
                ldrb r2, [r0], #1       @ Carga un byte de la palabra random
                ldrb r3, [r1], #1       @ Carga un byte de la palabra usuario
                cmp r2, #0              @ 縃emos llegado al final de la palabra?
                beq palabra_acertada
                cmp r2, r3              @ 縇os bytes coinciden?
                bne resta_intento
                bal ciclo               @ Sigue verificando las siguientes letras
        resta_intento:
                ldr r0, =intentos
                ldrb r1, [r0]
                sub r1, #1              @ Resta 1 intento
                strb r1, [r0]           @ Guarda el nuevo valor de intentos
                bal fin_ciclo           @ Salta al final del ciclo
        palabra_acertada:
                mov r0, #1              @ Marca que la palabra es correcta
        fin_ciclo:
                bx lr                   @ Retorna al flujo principal
        .fnend


	


	convierte_puntos:
	.fnstart
		ldr r0, =puntaje
		ldrb r1, [r0]				//cargo el puntaje
		ldr r3, =puntaje_ascii
		mov r2, #0				//contador de restas
		mov r4, #0				//desplazador de registro
			resta100:			//resta de a 100 para conseguir las centenas
				cmp r1, #100
				blt ascii_100
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
                ldr r1, =puntaje_ascii
                ldrb r3, [r1], #1               //cargo el primer ascii
		mov r4, #3			//contador de x a modificar
		mov r5, #0
                ciclo_modifica_mensaje_puntos:
                        ldrb r2, [r0, r5]
                        cmp r2, #'x'            //cuando llega a la x salta
                        beq fin_modifica_mensaje_puntos
			add r5, #1
                        bal ciclo_modifica_mensaje_puntos
                fin_modifica_mensaje_puntos:
                        strb r3, [r0, r5]      //donde est谩 la x reemplazo por el numero de letras
                                                //resto 1 para volver a la posicion del x
			ldrb r3, [r1], #1	//cargo el siguiente ascii
			add r5, #1
			sub r4, #1
			cmp r4, #0
			bgt ciclo_modifica_mensaje_puntos
                        bx lr
        .fnend

	imprime_mensaje_puntos:
	.fnstart
		mov r7, #4
		mov r0, #1
		swi 0
		bx lr
	.fnend


	jugar_de_nuevo:
    .fnstart
        @ Mostrar mensaje
        mov r7, #4
        mov r0, #1
        ldr r1, =mensaje_jugar_nuevamente
        mov r2, #100
        swi 0

        @ Leer respuesta
        mov r7, #3
        mov r0, #0
        ldr r1, =respuesta_usuario
        mov r2, #2
        swi 0

        @ Verificar entrada v醠ida
        ldr r1, =respuesta_usuario
        ldrb r0, [r1]
        cmp r0, #'s'
        bne fin      

    .fnend

		

.global main
        main:
	
		
                funcion_imprime_mensaje_comienzo_juego:
                        bl imprime_mensaje_comienzo_juego
                funcion_abrir_archivo:
                        bl abrirArchivo
                        cmp r0, #0
                        blt fin                         //si r0 es menor a 0 hubo error y no se carg贸 el archivo
                        mov r6, r0
                funcion_leer_palabras:                  //guardo las palabras en memoria
                        bl leer_palabras
                funcion_cerrar_archivo:                 //cierro el archivo de palabras
                        bl cierraArchivo
                funcion_sortear_palabra:                //elige la palabra segun el numero aleatorio
                        bl sortear_palabra
                funcion_calcular_letras_random:         //calcula las letras de la palabra a adivinar
                        bl calcular_letras_random
                funcion_modifica_mensaje_ingrese:       //ingresa la cantidad de letras en el mensaje que se da al usuario
                        bl modifica_mensaje_ingrese
		funcion_ingrese_palabra:                //imprime un mensaje con la cantidad de letras a ingresar
                        bl ingrese_palabra
        
	verificar_largo:
                bl leer_palabra                         //usuario ingresa palabra
                bl calcula_letras_usuario               //se calculan las letras de la palabra del usuario
                ldr r0, =letras_palabra_random
                ldrb r1, [r0]
                ldr r2, =letras_palabra_usuario
                ldrb r3, [r2]
                cmp r3, r1                              //comparo el largo de la palabra a buscar y la palabra del usuario
                bgt palabra_mas_larga
                blt palabra_mas_corta
                bl informar_resultado
		bl imprimir_resultado
		bl compara_palabras
		cmp r0, #1
		beq fin_juego_ganaste
		ldr r0, =intentos
		ldrb r1, [r0]
		cmp r1, #0
		beq fin_juego_perdiste
		bgt verificar_largo
        palabra_mas_larga:
                bl mensaje_mas_largo                    //mensaje si la palabra es mas larga
                bal verificar_largo                     //pide ingresar palabra nuevamente
        palabra_mas_corta:
                bl mensaje_mas_corto                    //mensaje si la palabra es mas corta
                bal verificar_largo                     //pide ingresar la palabra nuevamente
	


	fin_juego_ganaste:
		bl calcula_puntos
		bl convierte_puntos
		ldr r0, =mensaje_puntaje_ganaste
		bl modifica_mensaje_puntos
		ldr r1, =mensaje_puntaje_ganaste
		mov r2, #49
		bl imprime_mensaje_puntos
		bl reiniciar

		

	fin_juego_perdiste:
                bl calcula_puntos
                bl convierte_puntos
		ldr r0, =mensaje_puntaje_perdiste
                bl modifica_mensaje_puntos
		ldr r1, =mensaje_puntaje_perdiste
		mov r2, #29
                bl imprime_mensaje_puntos
	        bl reiniciar

	reiniciar:

		ldr r0, =color_rojo
		mov r2,#0
		str r2,[r0,#1]	

		ldr r0, =color_amarillo
		mov r2,#0
		str r2,[r0,#1]

		ldr r0, =color_verde
		mov r2,#0
		str r2,[r0,#1]
		
		bl jugar_de_nuevo
		
		
		
		
        fin:
                mov r7, #1
                swi 0



















