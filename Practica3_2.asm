;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                 ;
;   Para este ultimo ejercicio vamos a programar la               ;
;   funcion de Fibonacci, se le tiene que pedir al                ;
;   usuario por teclado el nmero que quiere de sucesiones         ;
;   que quiere calcular y se tiene que mostrar por pantalla       ;
;   todas las sucesiones que se han generado, por lo que          ;
;   si queremos generar el Fibonacci de 20 tendremos que          ;
;   introducir el numero 19 ya que el programa solo calcula       ;
;   las repeticiones que le pidamos.                              ; 
;                                                                 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          
          
org 100h ; Seleccionamos la posicion 100h
             
   

;Salamos a la etiqueta inicio que se encuentra en 
;una parte inferior del programa, desde  aqui se va iniciar 
;todo el programa              
jmp inicio 




num1 dw 1    ;Variable que va a contener el primer numero
num2 dw 1    ;Variable que va a contener el segundo numero  
result dw ?  ;Variable que va a contener el resultado      


; Mensajes que se van a mostrar por pantalla, se utiliza el $ para rellenar con datos 
msg2 db 0Dh,0Ah, 'Fibonacci: $'  
msg1 db 0Dh,0Ah, 0Dh,0Ah, ' Introduce el numero que quieres calcular: $'
                  
                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; este maro esta copiado de emu8086.inc ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; esta macro imprime un char en AL y avanza
; la posicion actual del cursor:     
PUTC    MACRO   char
    PUSH    AX
    MOV     AL, char
    MOV     AH, 0Eh
    INT     10h     
    POP     AX
endm
     
     
inicio: ; Etiqueta inicio, desde aqui se inicia el programa
      

;Hay que pedir que numero quiere calcular al usuario  
      
lea dx, msg1   ; Cargamos la variable msg en el registro dx
mov ah, 09h    ; Cadena de salida ds:dx
int 21h        ; Interrupcion llamada al DOS
call escanear_numero  ; Llamamos a la función escanear numero    




;Restamos 1 al valor introducido por el usuario, 
;esto se debe a que el valor 1 ya se calcula sin el bucle, 
;por lo que hay que iterar una vez menos               
sub cx,1  ;Restamos 
           
           

mov ax, num1 ;Movemos el valor de la varible num1 a el registro ax

       
       
;Mostramos por pantalla el valor 1 de Fibonacci      
mov dx, offset msg2 ; Cargamos la variable msg2 en el registro dx    
mov ah, 9  ; Cadena de salida ds:dx  
int 21h    ; Interrupcion llamada al DOS          
mov  ax, 1 ; Cargamos el valor 1 en ax para que luego se muestre por pantalla  
call mostrar_numero ; Llamaos a la funcion que muestra por pantalla el registro ax  
                 
                 
;Inicio del loop que se llama Fibonacci
Fibonacci:     

    mov bx, num1 ; Movemos al registro bx el valor de la varible num1
    add bx, num2 ; Sumamos en el registro bx el valor que hay en num2
    mov dx, bx   ; Movemos bx al registo dx
    mov bx, num1 ; Movemos a bx el valor de la varible num1
    mov num2, bx ; Movemos a la variable num2 el valor de bx
    mov bx, dx   ; Movemos a bx el valor de dx
    mov num1, bx ; Movemos a la varible num1 el valor de bx

  
  
    ;Mostramos por pantalla el valor actual de la iteracion de Fibonacci   
    mov dx, offset msg2 ; Cargamos la variable msg2 en el registro dx    
    mov ah, 9 ; Cadena de salida ds:dx   
    int 21h   ; Interrupcion llamada al DOS           
    mov ax, bx ; Cargamos el valor bx en ax para que luego se muestre por pantalla    
    call mostrar_numero ; Llamaos a la funcion que muestra por pantalla el registro ax    
                             
                             
                             
    ;Fin de mostrar el numero y seguiemos con el bucle 
    
        
        
loop Fibonacci  ; Loop que iterara tantas veces como valor tenga en ax  
 

;Una vez acabado el loop tene que acabar el programa 
          
int 16h ; Esperamos que se pulse una tecla para seguir  
int 20h ; Finalizamos la instruccion 
                                                 
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
;                                       ;
;          FIN DEL PROGRAMA             ;
;                                       ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    
; Este procedimiento imprime el número en AX,
; se utiliza con mostrar_numero para imprimir numeros con signo:
mostrar_numero proc    near
        push    dx
        push    ax

        cmp     ax, 0
        jnz     no_zero

        putc    '0'
        jmp     mostrar

no_zero:
        ; Se compruba el signo de ax
        ; y se hace absoluto si es negativo el numero
        cmp     ax, 0
        jns     positivo
        neg     ax

        putc    '-'

positivo:
        call    mostrar_numeros_unidos
mostrar:
        pop     ax
        pop     dx
        ret
mostrar_numero endp  






; Procedimiento que imprime numeros sin el signo
; solo imprimer numero, no texto
mostrar_numeros_unidos   proc    near
        push    ax
        push    bx
        push    cx
        push    dx

        ; Para evitar la impresión de ceros antes del numero:
        mov     cx, 1

        ; (el resultado de "/ 10000" es siempre menor o igual a 9).
        mov     bx, 10000  

        ; Si es cero, mostrar
        cmp     ax, 0
        jz      mostrar_cero

empezar_mostrar:

        ; comprueba el divisor (si es cero pasa a fin_mostrar):
        cmp     bx,0
        jz      fin_mostrar

        ; evitar imprimir ceros antes del numero:
        cmp     cx, 0
        je      calcular
        ; si ax<bx entonces el resultado de div sera cero:
        cmp     ax, bx
        jb      siguiente
calcular:
        mov     cx, 0   ;  fijar la bandera.

        mov     dx, 0
        div     bx      ; ax = dx:ax / bx   (dx=resto).

        ; imprimir el ultimo digito
        ; ah es siempre cero, por lo que se ignora
        add     al, 30h    ; convertir a codigo ascii.
        putc    al


        mov     ax, dx ; obtener el resto de la ultima division.

siguiente:
        ; caslcular bx=bx/10
        push    ax
        mov     dx, 0
        mov     ax, bx
        div     cs:ten  ; ax = dx:ax / 10 (dx=resto).
        mov     bx, ax
        pop     ax

        jmp     empezar_mostrar
        
mostrar_cero:
        putc    '0'
        
fin_mostrar:

        pop     dx
        pop     cx
        pop     bx
        pop     ax
        ret  
           
mostrar_numeros_unidos   endp
        


;
;  Procedimiento que imprime un texto y
;  escanea unb numero por teclado
; 
escanear_numero        proc    near
        push    dx
        push    ax
        push    si
        
        mov     cx, 0

        ; resetamos las banderas
        mov     cs:crear_minimo, 0

siguiente_digito:

        ; obtener char del teclado
        ; en el AL
        mov     ah, 00h
        int     16h
        ; e imprimirlo:
        mov     ah, 0eh
        int     10h

        ; comprobar si hay algun singno negativo:
        cmp     al, '-'
        je      establecer_minimo

        ; comprueba la tecla enter:
        cmp     al, 0dh  ; retorno de carro?
        jne     no_cr
        jmp     parar_input
no_cr:


        cmp     al, 8                   ; "Retroceso" pulsado?
        jne     comporbar_espacio
        mov     dx, 0                   ; eliminar el ultimo digito por
        mov     ax, cx                  ; division:
        div     cs:ten                  ; ax = dx:ax / 10 (dx-rem).
        mov     cx, ax
        putc    ' '                     ; limpiar posicion
        putc    8                       ; retroceso de nuevo.
        jmp     siguiente_digito
comporbar_espacio:


        ;  solo se permiten digitos:
        cmp     al, '0'
        jae     ok_ae_0
        jmp     quitar_no_digito
ok_ae_0:        
        cmp     al, '9'
        jbe     digito_bien
quitar_no_digito:       
        putc    8       ; retroceso.
        putc    ' '     ; borrar el ultimo dugito no introducido
        putc    8       ; retroceso de nuevo.   
        jmp     siguiente_digito ; esperar a la siguiente numero.     
digito_bien:


        ; multiplicar cx por 10 (la primera vez el resultado es cero)
        push    ax
        mov     ax, cx
        mul     cs:ten                  ; dx:ax = ax*10
        mov     cx, ax
        pop     ax

        ; comprobar si el numero es demasiado grande
        ; (el resultado debe ser de 16 bits)
        cmp     dx, 0
        jne     establecer_maximo

        ; convertir desde el codigo ascii:
        sub     al, 30h

        ; anyadir al a cx:
        mov     ah, 0
        mov     dx, cx      ; copia de seguridad, en caso de que el resultado sea demasiado grande.
        add     cx, ax
        jc      establecer_maximo2    ; saltar si el numero es demasiado grande.

        jmp     siguiente_digito

establecer_minimo:
        mov     cs:crear_minimo, 1
        jmp     siguiente_digito

establecer_maximo2:
        mov     cx, dx      ; restaurar el valor respaldado antes de añadir.
        mov     dx, 0       ; el dx era cero antes de la copia de seguridad
establecer_maximo:
        mov     ax, cx
        div     cs:ten  ; invertir la ultima dx:ax = ax*10, hacer ax = dx:ax / 10
        mov     cx, ax
        putc    8       ; retroceso.
        putc    ' '     ; borrar el ultimo digito introducido.
        putc    8       ; retroceso de nuevo.         
        jmp     siguiente_digito ; esperar a enter/retroceder.
        
        
parar_input:
        ; comprobar la bandera:
        cmp     cs:crear_minimo, 0
        je      no_niminos
        neg     cx
no_niminos:

        pop     si
        pop     ax
        pop     dx
        ret
crear_minimo      db      ?       ; utilizado como bandera.
escanear_numero        endp
        
ten DW 10 ; Usado como multiplicador o divisor en las funciones de mostrar numero y pedir numero
