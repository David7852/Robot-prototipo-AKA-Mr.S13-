;Rutina de inicializacion de puertos y variables aqui. (FALTA POR AHORA)

;del 00 al 1f son regs de proposito general
;del 20 al 5f (00 a 3f) estan los registros validos para I/O, sumando otros 32 regs
;.dseg
;r16 = objeto (# casilla)
;r17 = X objeto
;r18= Y objeto
;r19 = aux 1
;r20 = aux 2
;r21 = aux 3
;r22 = N (casilla en busqueda o N de la secuencia)
;r23 = NDS (Numero de pasos para giro)
;r24 = sector(00 A 01 B)
;r25 = X actual
;r26 = Y actual
;r27 = sentido (abajo 00, arriba 01, derecha 02, izquierda 03,  con el eje ortocentrico en el sector A borde izquierdo)
;r28-19 = aux
;.......
;r2 = I/O puerto C (sector A)
;r3 = I/O puerto D (sector B)
;r4 = I/O puerto F (Bordes / )
;r5 = I/O puerto B (motores)
;***  

.cseg 
.org 0000

start:;lee la posicion de objeto
nop
ldi r19,0;initial setup port
out ddrd,r19
out ddrf,r19
out ddrc,r19
ldi r19,0xff
out ddrb,r19
in r2, pinc
nop
com r2
in r3, pind
nop
com r3;end of initial setup
cp r2,r19
brne startA
cpse r3,r19
jmp startB
jmp start

startA:;setea la posicion del objeto si esta en sector A
nop
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

startB:;setea la posicion del objeto si esta en sector B
nop
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
nop
mov r16,r19
mov r22,r16
call getxy
mov r17,r20
mov r18,r21
jmp stindi;rutina de solucion de sector

setstartB:
nop
ldi r20,8
add r19,r20
mov r16,r19
mov r22,r16
call getxy
mov r17,r20
mov r18,r21
jmp stindi
;fin de rutinas de deteccion de objeto

;obtener las coordenadas xy de una casilla
;el valor de la casilla a buscar debe estar guardado en r22, el X y Y resultado se guardara en r20 y r21.
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
;fin

;obtener el valor actual de una casilla N
;la casilla a buscar debe estar guardada en r22, el valor (0,1) es devuelto en el registro 3
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
jmp retgeval
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
jmp retgeval

;dadas las coordenadas xy guardadas en los registros r20 y r21 respectivamente, guarda el numero de esa casilla en r22
getNxy:
ldi r22,4
mul r22,r21
mov r22,r0
add r22,r20
ret
;fin

;Rutinas para generar retardos a 20 mhz
;002 (7*0,00000005)(256)(256)=0.022
;003 (9*0,00000005)(256)(256)=0.029
;004 (12(0.00000005))(256)(256)=0.039
wait002:
ldi r20,0xff
jmp wait02A

wait02A:
ldi r21,0xff
subi r20,1
brne wait02B
ret

wait02B:
subi r21,1
nop
nop
nop
breq wait02A
rjmp wait02B 

wait003:
ldi r20,0xff
jmp wait03A

wait03A:
ldi r21,0xff
subi r20,1
brne wait03B
ret

wait03B:
subi r21,1
nop
nop
nop
nop
nop
breq wait03A
rjmp wait03B 

wait004:
ldi r20,0xff
jmp wait04A

wait04A:
ldi r21,0xff
subi r20,1
brne wait04B
ret

wait04B:
subi r21,1
nop
nop
nop
nop
nop
nop
nop
nop
breq wait04A
rjmp wait04B 

;rutina de espera.
;cada 0,022 o 0,029 o 0,039 seg va a revisar si algun borde se encendio
;retrasa el carro 5.6 seg, 7,4 seg, 9,9 seg respectivamente
esperanto:
nop
ldi r19,0xff
rjmp wait00

wait00:
nop
call wait003;retraso de 0.029
in r4,pinf
nop
com r4 ;suponiendo que las entradas de los bordes sean logica baja al igual que los sensores
SBRC r4,0 ;si el pin 0 NO es 0, salta, si lo es ignora
rjmp setsecA
sbrc r4,1 ;si el pin 1 NO es 0, salta, si lo es ignora
rjmp setsecB
subi r19,1
breq resolution
rjmp wait00
;fin de rutina de espera

setsecA:
nop
ldi r24,0
ldi r27,0
jmp deteccion

setsecB:
nop
ldi r24,1
ldi r27,1
jmp deteccion

;deteccion de en que casilla estoy
deteccion:
nop



;resolucion de conflictos ya que alguien ha decidido que quiere copiarse de nosotros, razon por la cual su bastardo carro debe ser aniquilado sin clemencia.
resolution:
nop







;deducir la proxima casilla a moder.

backA:
jmp moverdown
in r4,pinf
nop
com r4
SBRS r4,0
jmp backA
jmp gostop

backB:
jmp moverup
in r4,pinf
nop
com r4
SBRS r4,1
jmp backB
jmp gostop

turnleft:
call pasoder
jmp fordward

moverleft:
dec r25
cpi r27,2
breq reverse
cpi r27,3
breq fordward
cpi r27,0
ldi r27,2
breq turnleft
jmp turnright

moverright:
inc r25
cpi r27,2
breq fordward
cpi r27,3
breq reverse
cpi r27,0
ldi r27,2
breq turnright
jmp turnleft

GOBACK:
cpi r24,1
breq backB
jmp backA

RutSel:
cp r18,r26
brlo moverdown
brne moverup
cp r17,r25
brlo moverleft
brne moverright
mov r22,r16
call getval
cpi r19,0
breq GOBACK
jmp fordward

turnright:
call pasoizq
jmp fordward

moverdown:
dec r26
cpi r27,0
breq reverse
cpi r27,1
breq fordward
cpi r27,2
ldi r27,1
breq turnleft
jmp turnright

reverse:
call pasoatra
mov r22,r16
call getval
cpi r19,0
breq GOBACK
mov r20,r25
mov r21,r26
call getNxy
call getval
cpi r19,1
breq deducir
jmp reverse

fordward:
call pasoadel
mov r22,r16
call getval
cpi r19,0
breq GOBACK
mov r20,r25
mov r21,r26
call getNxy
call getval
cpi r19,1
breq deducir
jmp fordward

moverup:
inc r26
cpi r27,0
breq fordward
cpi r27,1
breq reverse
cpi r27,2
ldi r27,0
breq turnright
jmp turnleft

deducir:
mov r22,r16
call getval
ldi r20,0
cpse r19,r20
jmp RutSel
jmp GOBACK













;fin rutinas deducir

gostop:
nop
jmp gostop









stindi:
jmp stindi

pasoizq:

pasoder:

pasoatra:

pasoadel:



/*deprecated 

;Deduce el sector de arranque, el sentido y setea el x y y del carro para cuando esta solo en la pista (INDIVIDUAL)
stindi:
nop
call pasoadel
in r4, pinf
nop
com r4
nop
cpi r4,0
breq stindi
;suponiendo que el borde del sector A entra por el bit 0 y que el del b entra por el bit 1...
cpi r4,2
breq setsecA
jmp setsecB



	;mover hasta encender una casilla dentro del tablero en mi sector
stindiA:
nop
call pasoadel
in r2, pinc
nop
com r2
cpi r2,0
breq stindiA
ldi r22,0
SBRC r2,0
jmp stindiAA
inc r22
SBRC r2,1
jmp stindiAA
inc r22
SBRC r2,2
jmp stindiAA
inc r22
SBRC r2,3
jmp stindiAA
inc r22
SBRC r2,4
jmp stindiAA
inc r22
SBRC r2,5
jmp stindiAA
inc r22
SBRC r2,6
jmp stindiAA
inc r22
jmp stindiAA

stindiAA:
nop
call getxy
mov r25,r20
mov r26,r21
jmp deducir

stindiB:
nop
call pasoadel
in r3, pind
nop
com r3
cpi r3,0
breq stindiB
ldi r22,0
SBRC r3,0
jmp stindiBB
inc r22
SBRC r3,1
jmp stindiBB
inc r22
SBRC r3,2
jmp stindiBB
inc r22
SBRC r3,3
jmp stindiBB
inc r22
SBRC r3,4
jmp stindiBB
inc r22
SBRC r3,5
jmp stindiBB
inc r22
SBRC r3,6
jmp stindiBB
inc r22
jmp stindiBB

stindiBB:
nop
ldi r20,8
add r22,r20
call getxy
mov r25,r20
mov r26,r21
jmp deducir
;fin

*/