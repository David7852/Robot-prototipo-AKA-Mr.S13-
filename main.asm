;Rutina de inicializacion de puertos y variables aqui. (FALTA POR AHORA)

;del 00 al 1f son regs de proposito general, marcados como r0 a r31
;del 20 al 5f (00 a 3f) estan los registros validos para I/O, sumando otros 32 regs
;.dseg
;r0 = objeto (# casilla)
;r1 = X objeto
;r2 = Y objeto
;r3 = aux 1
;r4 = aux 2
;r5 = aux 3
;r6 = N (casilla en busqueda o N de la secuencia)
;r7 = NDS (Numero de pasos para giro)
;r8 = sector(00 A 01 B)
;r9 = X actual
;r10 = Y actual
;r11 = sentido (abajo 00, arriba 01, derecha 02, izquierda 03,  con el eje ortocentrico en el sector A borde izquierdo)
;r12-19 = aux
;.......
;r20 = I/O puerto C (sector A)
;r21 = I/O puerto D (sector B)
;r22 = I/O puerto F (Bordes / )
;r23 = I/O puerto B (motores)
;***  

.cseg 
.org 1000

start:
nop
ldi r3,0;initial setup port
out ddrd,r3
out ddrf,r3
out ddrc,r3
ldi r3,1
out ddrb,r3
in r20, pinc
nop
com r20
in r21, pind
nop
com r21;end of initial setup
cp r20,r3
brne startA
cpse r21,r3
jmp startB
jmp start

startA:
nop
SBRC r20,0
jmp setstartA
inc r3
SBRC r20,1
jmp setstartA
inc r3
SBRC r20,2
jmp setstartA
inc r3
SBRC r20,3
jmp setstartA
inc r3
SBRC r20,4
jmp setstartA
inc r3
SBRC r20,5
jmp setstartA
inc r3
SBRC r20,6
jmp setstartA
inc r3
jmp setstartA

startB:
nop
SBRC r21,0
jmp setstartB
inc r3
SBRC r21,1
jmp setstartB
inc r3
SBRC r21,2
jmp setstartB
inc r3
SBRC r21,3
jmp setstartB
inc r3
SBRC r21,4
jmp setstartB
inc r3
SBRC r21,5
jmp setstartB
inc r3
SBRC r21,6
jmp setstartB
inc r3
jmp setstartB

setstartA:
nop
mov r0,r3
mov r6,r0
call getxy
jmp deduindi

setstartB:
nop
ldi r4,8
add r3,r4
mov r0,r3
mov r6,r0
call getxy
mov r1,r4
mov r2,r5
jmp stindi
;fin de rutinas de deteccion de objeto

;obtener las coordenadas xy de una casilla
;el valor de la casilla a buscar debe estar guardado en r6, el X y Y resultado se guardara en r4 y r5.
getxy:
nop
ldi r3,0
ldi r4,0
ldi r5,0
rjmp subgetxy

subgetxy:
nop
cpse r3,r6
jmp loopxy
ret
loopxy:
nop
cpi r4,3
breq eqloopxy
inc r4
inc r3
jmp subgetxy 
eqloopxy:
nop
inc r5
ldi r4,0
inc r3
jmp subgetxy
;fin

;obtener el valor actual de una casilla N
;la casilla a buscar debe estar guardada en r6, el valor (0,1) es devuelto en el registro 3
getval:
nop
ldi r3,0
cpi r6,8
brsh getvalB
jmp getvalA

getvalB:
nop
in r21,pind
nop
com r21
ldi r4,8
SBRC r21,0
ldi r3,1
cp r6,r4
breq retgeval
inc r4
SBRC r21,1
ldi r3,1
cp r6,r4
breq retgeval
inc r4
SBRC r21,2
ldi r3,1
cp r6,r4
breq retgeval
inc r4
SBRC r21,3
ldi r3,1
cp r6,r4
breq retgeval
inc r4
SBRC r21,4
ldi r3,1
cp r6,r4
breq retgeval
inc r4
SBRC r21,5
ldi r3,1
cp r6,r4
breq retgeval
inc r4
SBRC r21,6
ldi r3,1
cp r6,r4
breq retgeval
SBRC r21,7
ldi r3,1
jmp retgeval

getvalA:
nop
in r20,pinc
nop
com r20
ldi r4,0
SBRC r20,0
ldi r3,1
cp r6,r4
breq retgeval
inc r4
SBRC r20,1
ldi r3,1
cp r6,r4
breq retgeval
inc r4
SBRC r20,2
ldi r3,1
cp r6,r4
breq retgeval
inc r4
SBRC r20,3
ldi r3,1
cp r6,r4
breq retgeval
inc r4
SBRC r20,4
ldi r3,1
cp r6,r4
breq retgeval
inc r4
SBRC r20,5
ldi r3,1
cp r6,r4
breq retgeval
inc r4
SBRC r20,6
ldi r3,1
cp r6,r4
breq retgeval
inc r4
SBRC r20,7
ldi r3,1
jmp retgeval

regeval
nop
ret
;fin

;dadas las coordenadas xy guardadas en los registros r4 y r5 respectivamente, guarda el numero de esa casilla en r6
getNxy:
nop
mov r12,r0
mov r13,r1
ldi r6,4
mul r6,r5
mov r6,r0
mov r0,12
mov r1,13
add r6,r4
ret
;fin

;Rutinas para generar retardos a 20 mhz
;002 (7*0,00000005)(256)(256)=0.022
;003 (9*0,00000005)(256)(256)=0.029
;004 (12(0.00000005))(256)(256)=0.039
wait002:
nop
ldi r4,0xff
jmp wait02A

wait02A:
nop
ldi r5,0xff
subi r4,1
brne wait02B
ret

wait02B:
nop
subi r5,1
nop
nop
nop
breq wait02A
rjmp wait02B 

wait003:
nop
ldi r4,0xff
jmp wait03A

wait03A:
nop
ldi r5,0xff
subi r4,1
brne wait03B
ret

wait03B:
nop
subi r5,1
nop
nop
nop
nop
nop
breq wait03A
rjmp wait03B 

wait004:
nop
ldi r4,0xff
jmp wait04A

wait04A:
nop
ldi r5,0xff
subi r4,1
brne wait04B
ret

wait04B:
nop
subi r5,1
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
;fin

;rutina de espera.
;cada 0,022 o 0,029 o 0,039 seg va a revisar si algun borde se encendio
;retrasa el carro 5.6 seg, 7,4 seg, 9,9 seg respectivamente
esperanto:
nop
ldi r3,0xff
rjmp wait00

wait00:
nop
call wait003;retraso de 0.029
in r22,pinf
nop
com r22 ;suponiendo que las entradas de los bordes sean logica baja al igual que los sensores
SBRC r22,0 ;si el pin 0 NO es 0, salta, si lo es ignora
rjmp setsecA
sbrc r22,1 ;si el pin 1 NO es 0, salta, si lo es ignora
rjmp setsecB
subi r3,1
breq resolution
rjmp wait00
;fin de rutina de espera

setsecA:
nop
ldi r8,0
ldi r11,0
jmp deteccion

setsecB:
nop
ldi r8,1
ldi r11,1
jmp deteccion

;deteccion de en que casilla estoy
deteccion:
nop



;resolucion de conflictos ya que alguien ha decidido que quiere copiarse de nosotros, razon por la cual su bastardo carro debe ser aniquilado sin clemencia.
resolution:
nop











;deducir la proxima casilla a moder.
deducir:
nop
mov r6,r0
call getval
cpi r3,0
breq GOBACK
jmp RutSel

RutSel:
nop
cp r2,r10
brlo moverdown
brne moverup
cp r1,r9
brlo moverleft
brne moverright
mov r6,r0
call getval
cpi r3,0
breq GOBACK
jmp moveradel

moverup:
nop
inc r10
cpi r11,0
breq forward
cpi r11,1
breq reverse
cpi r11,2
ldi r11,0
breq turnright
jmp turnleft

moverdown:
nop
dec r10
cpi r11,0
breq reverse
cpi r11,1
breq forward
cpi r11,2
ldi r11,1
breq turnleft
jmp turnright

moverright:
nop
inc r9
cpi r11,2
breq forward
cpi r11,3
breq reverse
cpi r11,0
ldi r11,2
breq turnright
jmp turnleft

moverleft:
nop
dec r9
cpi r11,2
breq reverse
cpi r11,3
breq fordward
cpi r11,0
ldi r11,2
breq turnleft
jmp turnright

fordward:
nop
call pasoadel
mov r6,r0
call getval
cpi r3,0
breq GOBACK
mov r4,r9
mov r5,r10
call getNxy
call getval
cpi r3,1
breq deducir
jmp forward

reverse:
nop
call pasoatra
mov r6,r0
call getval
cpi r3,0
breq GOBACK
mov r4,r9
mov r5,r10
call getNxy
call getval
cpi r3,1
breq deducir
jmp reverse

turnright:
nop
mov r3,r7
jmp turnr

turnr:
nop
call pasoizq
cpi r3,0
breq fordward
dec r3
jmp turnr

turnleft:
nop
mov r3,r7
jmp turnl

turnl:
nop
call pasoder
cpi r3,0
breq fordward
dec r3
jmp turnr
;fin rutinas deducir

GOBACK:
nop
cpi r8,1
breq backB
jmp backA

backB:
nop
jmp moverup
in r22,pinf
nop
com r22
SBRS r22,1
jmp backB
jmp gostop

backA:
nop
jmp moverdown
in r22,pinf
nop
com r22
SBRS r22,0
jmp backA
jmp gostop

gostop:
nop
jmp gostop












;Deduce el sector de arranque, el sentido y setea el x y y del carro para cuando esta solo en la pista (INDIVIDUAL)
stindi:
nop
call pasoadel
in r22, pinf
nop
com r22
nop
cpi r22,0
breq stindi
;suponiendo que el borde del sector A entra por el bit 0 y que el del b entra por el bit 1...
cpi r22,2
breq setsecA
jmp setsecB



	;mover hasta encender una casilla dentro del tablero en mi sector
stindiA:
nop
call pasoadel
in r20, pinc
nop
com r20
cpi r20,0
breq stindiA
ldi r6,0
SBRC r20,0
jmp stindiAA
inc r6
SBRC r20,1
jmp stindiAA
inc r6
SBRC r20,2
jmp stindiAA
inc r6
SBRC r20,3
jmp stindiAA
inc r6
SBRC r20,4
jmp stindiAA
inc r6
SBRC r20,5
jmp stindiAA
inc r6
SBRC r20,6
jmp stindiAA
inc r6
jmp stindiAA

stindiAA:
nop
call getxy
mov r9,r4
mov r10,r5
jmp deducir

stindiB:
nop
call pasoadel
in r21, pind
nop
com r21
cpi r21,0
breq stindiB
ldi r6,0
SBRC r21,0
jmp stindiBB
inc r6
SBRC r21,1
jmp stindiBB
inc r6
SBRC r21,2
jmp stindiBB
inc r6
SBRC r21,3
jmp stindiBB
inc r6
SBRC r21,4
jmp stindiBB
inc r6
SBRC r21,5
jmp stindiBB
inc r6
SBRC r21,6
jmp stindiBB
inc r6
jmp stindiBB

stindiBB:
nop
ldi r4,8
add r6,r4
call getxy
mov r9,r4
mov r10,r5
jmp deducir
;fin

