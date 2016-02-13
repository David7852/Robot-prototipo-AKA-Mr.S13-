;r0 = registro especial (usado por algunas instrucciones de atmel)
;r1 = registro especial (usado por algunas instrucciones de atmel)
;r2 = I/O puerto C (sector A)
;r3 = I/O puerto D (sector B)
;r4 = I/O puerto F (Bordes bit 0= A horizontal, bit 1= B horizontal, bit 2 = derecha, bit 3 = izquierda )
;r5 = I/O puerto B (motores)
;.......
;Variables del sistema
;r16 = objeto (# casilla)
;r17 = X objeto
;r18 = Y objeto
;r19 = aux 1 (return aux)
;r20 = aux 2
;r21 = aux 3
;r22 = aux 4 (N casilla en busqueda o N de la secuencia)
;r23 = cuerda (decimas de segundo, o multiplicador de decimas nescesarias para una distancia especifica) 
;r24 = sectores (primeros 4 bits: 0000 A, 0001 B. ultimos 4 bits: 0000 derecha, 1000 izquierda)
;r25 = vector rocks 1
;r26 = vector rocks 2
;r27 = vector fall 1
;r28 = vector fall 2
;r29 = vector cuerda 1
;r30 = vector cuerda 2
;r31 = vector cuerda 3
;.......
;constantes
;step = numero de veces que debe repetirse un retardo de X milisegundos para avanzar 8cm (media casilla)
;giro = numero de veces que debe repetirse un retardo de X milisegundos para girar 5 grados
;N0-10 = distancias euclidianas
;N13 = numero de la secuencia (solo para competencia)
;*** 
.dseg

.def ioa=r2
.def iob=r3
.def bordes=r4
.def motores=r5

.def objn=r16
.def objx=r17
.def objy=r18
.def aux1=r19		             
.def aux2=r20
.def aux3=r21
.def N=r22
.def cuerda=r23
.def sector=r24
.def rocka=r25
.def rockb=r26
.def falla=r27
.def fallb=r28
.def cua=r29
.def cub=r30
.def cuc=r31

.equ step=0x00
.equ giro=0x00
;distancias
;secuencia
;otros

.cseg 
.org 0100
ldi r19,0xff;initial setup port
out ddrb,r19
ldi r19,0
out portb,r19
out ddrd,r19
out ddrf,r19
out ddrc,r19
jmp fase1
;**********
;rutinas de asistencia
;**********
;obtener las coordenadas xy de una casilla
;(el valor de la casilla a buscar debe estar guardado en r22, el X y Y resultado se guardara en r20 y r21.)
getxy:
ldi r19,0
ldi r20,0
ldi r21,0
rjmp subgetxy
subgetxy:
cpse r19,r22
jmp loopxy
ret
loopxy:
cpi r20,3
breq eqloopxy
inc r20
inc r19
jmp subgetxy 
eqloopxy:
inc r21
ldi r20,0
inc r19
jmp subgetxy

;obtener el valor actual de una casilla N
;(la casilla a buscar debe estar guardada en r22, el valor (0,1) es devuelto en el registro 3)
getval:
ldi r19,0
cpi r22,8
brsh getvalB
jmp getvalA
getvalB:
in r3,pind
nop
com r3
ldi r20,8
SBRC r3,0
ldi r19,1
cp r22,r20
breq retgeval
inc r20
SBRC r3,1
ldi r19,1
cp r22,r20
breq retgeval
inc r20
SBRC r3,2
ldi r19,1
cp r22,r20
breq retgeval
inc r20
SBRC r3,3
ldi r19,1
cp r22,r20
breq retgeval
inc r20
SBRC r3,4
ldi r19,1
cp r22,r20
breq retgeval
inc r20
SBRC r3,5
ldi r19,1
cp r22,r20
breq retgeval
inc r20
SBRC r3,6
ldi r19,1
cp r22,r20
breq retgeval
SBRC r3,7
ldi r19,1
ret
retgeval:
ret
getvalA:
in r2,pinc
nop
com r2
ldi r20,0
SBRC r2,0
ldi r19,1
cp r22,r20
breq retgeval
inc r20
SBRC r2,1
ldi r19,1
cp r22,r20
breq retgeval
inc r20
SBRC r2,2
ldi r19,1
cp r22,r20
breq retgeval
inc r20
SBRC r2,3
ldi r19,1
cp r22,r20
breq retgeval
inc r20
SBRC r2,4
ldi r19,1
cp r22,r20
breq retgeval
inc r20
SBRC r2,5
ldi r19,1
cp r22,r20
breq retgeval
inc r20
SBRC r2,6
ldi r19,1
cp r22,r20
breq retgeval
inc r20
SBRC r2,7
ldi r19,1
ret

;dadas las coordenadas xy guardadas en los registros r20 y r21 respectivamente, guarda el numero de esa casilla en r22
getNxy:
ldi r22,4
mul r22,r21
mov r22,r0
add r22,r20
ret

;Rutinas para generar retardos a (20 mhz)
;20 (7*0,00000005)(256)(256)=0.022seg
wait20:
ldi r20,0xff
jmp wait20A
wait20A:
ldi r21,0xff
subi r20,1
brne wait20B
ret
wait20B:
subi r21,1
nop
nop
nop
breq wait20A
rjmp wait20B 
;30 (9*0,00000005)(256)(256)=0.029seg
wait30:
ldi r20,0xff
jmp wait30A
wait30A:
ldi r21,0xff
subi r20,1
brne wait30B
ret
wait30B:
subi r21,1
nop
nop
nop
nop
nop
breq wait30A
rjmp wait30B 
;40 (12(0.00000005))(256)(256)=0.039seg
wait40:
ldi r20,0xff
jmp wait40A
wait40A:
ldi r21,0xff
subi r20,1
brne wait40B
ret
wait40B:
subi r21,1
nop
nop
nop
nop
nop
nop
nop
nop
breq wait40A
rjmp wait40B 

;rutinas de movimiento
izquierda:
ldi aux1,0xf0
and motores,aux1
ldi aux1,0x01
eor motores,aux1
out portb,motores
call wait30;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
ret

derecha:
ldi aux1,0xf0
and motores,aux1
ldi aux1,0x04
eor motores,aux1
out portb,motores
call wait30;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
ret

atras:
ldi aux1,0xf0
and motores,aux1
ldi aux1,0x0a
eor motores,aux1
out portb,motores
call wait30;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
ret

adelante:
ldi aux1,0xf0
and motores,aux1
ldi aux1, 0x05
eor motores,aux1
out portb,motores
call wait30;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
ret

parar:
ldi aux1,0xf0
and motores,aux1
out portb,motores
call wait20;(usar siempre el menor tiempo de espera)
ret

;*********
;fin

;inicio
Fase1:
call seto
call esperanto
rjmp fase2
;****
;acondicionamiento
Fase2:
call flare
call fillrocks
call fillfalls
rjmp fase3
;****
;toma de decisiones
fase3:


seto:;(iniciar puertos y )
in r2, pinc
nop
com r2
in r3, pind
nop
com r3
cp r2,r19
brne startA
cpse r3,r19
jmp startB
jmp seto
startA:;setea la posicion del objeto (si esta en sector A)
SBRC r2,0
jmp setstartA
inc r19
SBRC r2,1
jmp setstartA
inc r19
SBRC r2,2
jmp setstartA
inc r19
SBRC r2,3
jmp setstartA
inc r19
SBRC r2,4
jmp setstartA
inc r19
SBRC r2,5
jmp setstartA
inc r19
SBRC r2,6
jmp setstartA
inc r19
jmp setstartA
startB:;setea la posicion del objeto (si esta en sector B)
SBRC r3,0
jmp setstartB
inc r19
SBRC r3,1
jmp setstartB
inc r19
SBRC r3,2
jmp setstartB
inc r19
SBRC r3,3
jmp setstartB
inc r19
SBRC r3,4
jmp setstartB
inc r19
SBRC r3,5
jmp setstartB
inc r19
SBRC r3,6
jmp setstartB
inc r19
jmp setstartB
setstartA:
mov r16,r19
mov r22,r16
call getxy
mov r17,r20
mov r18,r21
ret
setstartB:
ldi r20,8
add r19,r20
mov r16,r19
mov r22,r16
call getxy
mov r17,r20
mov r18,r21
ret

;rutina de espera.(retrasa el carro 5.6 seg, 7,4 seg, 9,9 seg respectivamente)
;cada 22 o 29 o 39 milisegundos se va a revisar si algun borde se encendio
esperanto:
ldi r19,0xff
rjmp waitto
waitto:
call wait30;cambiar aca cual se quiere si 20,30 o 40
in r4,pinf
nop
com r4 ;suponiendo que las entradas de los bordes sean logica baja al igual que los sensores
SBRC r4,0 ;si el pin 0 NO es 0, salta, si lo es ignora
rjmp setsecA
sbrc r4,1 ;si el pin 1 NO es 0, salta, si lo es ignora
rjmp setsecB
rjmp resolution
setsecA:
ldi r24,0
ldi r27,0
ret
setsecB:
ldi r24,1
ldi r27,1
ret
;fin de rutina de espera

resolution:;(en caso de que algun otro carro este esperando o nosotros estemos solos)
ret ;(en caso de estar solos en la pista, simplemente sale y comienza a explorar)