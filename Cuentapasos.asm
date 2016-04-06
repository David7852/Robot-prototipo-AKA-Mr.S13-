/*last update oldmain*/
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
;r28 = numero de pasos para 16cm
;.......
;r2 = I/O puerto C (sector A)
;r3 = I/O puerto D (sector B)
;r4 = I/O puerto F (Bordes / )
;r5 = I/O puerto B (motores)
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
.def aux4=r22

.cseg 
.include "usb1286def.inc"
.org 0000

;lee la posicion de objeto
;initial setup port
LDI r23,40
LDI r28,35
LDI r19,0xff
OUT portc,r19
OUT portd,r19
OUT portf,r19
OUT ddrb,r19
LDI r19,0
OUT portb,r19
OUT ddrd,r19
OUT ddrf,r19
OUT ddrc,r19
start:;end of initial setup
CALL getioa
CALL getiob
LDI r19,0
CP r2,r19
BRNE starta
CPSE r3,r19
JMP startb
RJMP start

startA:;setea la posicion del objeto si esta en sector A
SBRC r2,0
JMP setstartA
INC r19
SBRC r2,1
JMP setstartA
INC r19
SBRC r2,2
JMP setstartA
INC r19
SBRC r2,3
JMP setstartA
INC r19
SBRC r2,4
JMP setstartA
INC r19
SBRC r2,5
JMP setstartA
INC r19
SBRC r2,6
JMP setstartA
INC r19
JMP setstartA

;rutinas para delay de lecturas
getioa:
in ioa,pinc
NOP 
CALL wait20
in r7,pinc
NOP 
CPSE ioa,r7
RJMP getioa
RET

getiob:
in iob,pind
NOP 
CALL wait20
in r7,pind
NOP 
CPSE iob,r7
RJMP getiob
RET

getbordes:
in bordes,pinf
NOP 
CALL wait20
in r7,pinf
NOP 
CPSE bordes,r7
RJMP getbordes
RET
;Rutinas para generar RETardos a (20 mhz)
;20ms (7*0.0000005)(256)(26)=0.022seg

waitdo:
CALL wait20
INC r19
CPSE r19,r28
RJMP waitdo
RET

waitto:
CALL wait20
INC r19
CPSE r19,r23
RJMP waitto
RET

wait10:
LDI r20,26
JMP wait10A
wait10A:
LDI r21,0xff
SUBI r20,1
BRNE wait10B
RET
wait10B:
SUBI r21,1
BREQ wait10A
RJMP wait10B 

wait20:
LDI r20,26
JMP wait20A
wait20A:
LDI r21,0xff
SUBI r20,1
BRNE wait20B
RET
wait20B:
SUBI r21,1
NOP 
NOP 
NOP 
BREQ wait20A
RJMP wait20B 
;30 (9*0.0000005)(256)(26)=0.029seg
wait30:
LDI r20,26
JMP wait30A
wait30A:
LDI r21,0xff
SUBI r20,1
BRNE wait30B
RET
wait30B:
SUBI r21,1
NOP 
NOP 
NOP 
NOP 
NOP 
BREQ wait30A
RJMP wait30B 
;40 (12(0.0000005))(256)(26)=0.039seg
wait40:
LDI r20,26
JMP wait40A
wait40A:
LDI r21,0xff
SUBI r20,1
BRNE wait40B
RET
wait40B:
SUBI r21,1
NOP 
NOP 
NOP 
NOP 
NOP 
NOP 
NOP 
NOP 
BREQ wait40A
RJMP wait40B 

;rutinas de MOVimiento
pasoizq:
LDI aux1,0xf0
and motores,aux1
LDI aux1,0x01
EOR motores,aux1
OUT portb,motores
LDI r19,0
CALL waitto;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
RET

pasoder:
LDI aux1,0xf0
and motores,aux1
LDI aux1,0x04
EOR motores,aux1
OUT portb,motores
LDI r19,0
CALL waitto;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
RET

pasoatra:
LDI aux1,0xf0
and motores,aux1
LDI aux1,0x0a
EOR motores,aux1
OUT portb,motores
LDI r19,0
CALL waitdo;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
RET

pasoadel:
LDI aux1,0xf0
and motores,aux1
LDI aux1, 0x05
EOR motores,aux1
OUT portb,motores
LDI r19,0
CALL waitdo;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
RET

parar:
LDI aux1,0xf0
and motores,aux1
OUT portb,motores
CALL wait30
RET

startB:;setea la posicion del objeto si esta en sector B
SBRC r3,0
JMP setstartB
INC r19
SBRC r3,1
JMP setstartB
INC r19
SBRC r3,2
JMP setstartB
INC r19
SBRC r3,3
JMP setstartB
INC r19
SBRC r3,4
JMP setstartB
INC r19
SBRC r3,5
JMP setstartB
INC r19
SBRC r3,6
JMP setstartB
INC r19
JMP setstartB

setstartA:
MOV r16,r19
MOV r22,r16
CALL getxy
MOV r17,r20
MOV r18,r21
RJMP stindi;rutina de solucion de sector

setstartB:
LDI r20,8
ADD r19,r20
MOV r16,r19
MOV r22,r16
CALL getxy
MOV r17,r20
MOV r18,r21
RJMP stindi
;fin de rutinas de deteccion de objeto

;obtener las coordenadas xy de una casilla
;el valor de la casilla a buscar debe estar guardado en r22, el X y Y resultado se guardara en r20 y r21.
getxy:
LDI r19,0
LDI r20,0
LDI r21,0
RJMP subgetxy

subgetxy:
CPSE r19,r22
JMP loopxy
RET
loopxy:
CPI r20,3
BREQ eqloopxy
INC r20
INC r19
JMP subgetxy 
eqloopxy:
INC r21
LDI r20,0
INC r19
JMP subgetxy
;fin

;obtener el valor actual de una casilla N
;la casilla a buscar debe estar guardada en r22, el valor (0,1) es devuelto en el registro 3
getval:
CPI r22,8
BRSH getvalB
JMP getvalA

getvalB:
CALL getiob
LDI r20,8
LDI r19,0
SBRC r3,0
LDI r19,1
CP r22,r20
BREQ RETgeval
INC r20
LDI r19,0
SBRC r3,1
LDI r19,1
CP r22,r20
BREQ RETgeval
INC r20
LDI r19,0
SBRC r3,2
LDI r19,1
CP r22,r20
BREQ RETgeval
INC r20
LDI r19,0
SBRC r3,3
LDI r19,1
CP r22,r20
BREQ RETgeval
INC r20
LDI r19,0
SBRC r3,4
LDI r19,1
CP r22,r20
BREQ RETgeval
INC r20
LDI r19,0
SBRC r3,5
LDI r19,1
CP r22,r20
BREQ RETgeval
INC r20
LDI r19,0
SBRC r3,6
LDI r19,1
CP r22,r20
BREQ RETgeval
LDI r19,0
SBRC r3,7
LDI r19,1
JMP RETgeval
RETgeval:
RET
getvalA:
CALL getioa
LDI r20,0
LDI r19,0
SBRC r2,0
LDI r19,1
CP r22,r20
BREQ RETgeval
INC r20
LDI r19,0
SBRC r2,1
LDI r19,1
CP r22,r20
BREQ RETgeval
INC r20
LDI r19,0
SBRC r2,2
LDI r19,1
CP r22,r20
BREQ RETgeval
INC r20
LDI r19,0
SBRC r2,3
LDI r19,1
CP r22,r20
BREQ RETgeval
INC r20
LDI r19,0
SBRC r2,4
LDI r19,1
CP r22,r20
BREQ RETgeval
INC r20
LDI r19,0
SBRC r2,5
LDI r19,1
CP r22,r20
BREQ RETgeval
INC r20
LDI r19,0
SBRC r2,6
LDI r19,1
CP r22,r20
BREQ RETgeval
LDI r19,0
SBRC r2,7
LDI r19,1
JMP RETgeval

;Deduce el sector de arranque, el sentido y setea el x y y del carro para cuando esta solo en la pista (INDIVIDUAL)
stindiAA:
CP r22,objn
BREQ RETgeval
CALL getxy
MOV r25,r20
MOV r26,r21
POP r0
POP r0
JMP deducir

stindiBB:
LDI r20,8
ADD r20,r22
CP r20,objn
BREQ RETgeval
MOV r22,r20
CALL getxy
MOV r25,r20
MOV r26,r21
POP r0
POP r0
JMP deducir
;MOVer hasta encender una casilla dentro del tablero en mi sector

stindiA:
CALL pasoadel
CALL getioa
MOV r25,r2
CPI r25,0
BREQ stindiA
LDI r22,0
SBRC r25,0
CALL stindiAA
INC r22
SBRC r25,1
CALL stindiAA
INC r22
SBRC r25,2
CALL stindiAA
INC r22
SBRC r25,3
CALL stindiAA
INC r22
SBRC r25,4
CALL stindiAA
INC r22
SBRC r25,5
CALL stindiAA
INC r22
SBRC r25,6
CALL stindiAA
INC r22
SBRC r25,7
CALL stindiAA
RJMP stindia

stindiB:
CALL pasoadel
CALL getiob
MOV r30,r3
CPI r30,0
BREQ stindiB
LDI r22,0
SBRC r30,0
CALL stindibb
INC r22
SBRC r30,1
CALL stindibb
INC r22
SBRC r30,2
CALL stindibb
INC r22
SBRC r30,3
CALL stindibb
INC r22
SBRC r30,4
CALL stindibb
INC r22
SBRC r30,5
CALL stindibb
INC r22
SBRC r30,6
CALL stindibb
INC r22
SBRC r30,7
CALL stindibb
RJMP stindib

;mueve hacia adelante hasta que se encienda un borde
stindi:
CALL pasoadel
CALL getbordes
MOV aux4,r4
ANDI aux4,0x03
CPI aux4,0
BREQ stindi
;suponiendo que el borde del sector A entra por el bit 0 y que el del b entra por el bit 1...
CPI aux4,2
BREQ setsecB
RJMP setseca

setsecA:
LDI r24,0
LDI r27,0
RJMP stindia

setsecB:
LDI r24,1
LDI r27,1
RJMP stindib
;fin

;dadas las coordenadas xy guardadas en los registros r20 y r21 respectivamente, guarda el numero de esa casilla en r22
getNxy:
LDI r22,4
MUL r22,r21
MOV r22,r0
ADD r22,r20
RET
;fin

MOVerright:
BREQ RETre
RJMP MOVeright

RETre:
RET

turnleft:
CALL pasoder
JMP fordward

MOVerleft:
DEC r25
CPI r27,2
BREQ reverse
CPI r27,3
BREQ fordward
CPI r27,0
LDI r27,3
BREQ turnleft
JMP turnright

GOBACK:
LDI r31,1
CPSE r24,r31
JMP backA
JMP backB

MOVeright:
INC r25
CPI r27,2
BREQ fordward
CPI r27,3
BREQ reverse
CPI r27,0
LDI r27,2
BREQ turnright
JMP turnleft

RutSel:
CP r18,r26
BRLO MOVerdown
BRNE MOVerup
CP r17,r25
BRLO MOVerleft
CALL MOVerright
MOV r22,r16
CALL getval
CPI r19,0
BREQ GOBACK
CALL adelante
RJMP deducir

MOVerdown:
DEC r26
CPI r27,0
BREQ reverse
CPI r27,1
BREQ fordward
CPI r27,2
LDI r27,1
BREQ turnleft
JMP turnright

reverse:
CALL pasoatra
MOV r22,r16
CALL getval
CPI r19,0
BREQ GOBACK
RJMP deducir

fordward:
CALL pasoadel
MOV r22,r16
CALL getval
CPI r19,0
BREQ GOBACK
RJMP deducir

turnright:
CALL pasoizq
JMP fordward

MOVerup:
INC r26
CPI r27,0
BREQ fordward
CPI r27,1
BREQ reverse
CPI r27,2
LDI r27,0
BREQ turnright
JMP turnleft

deducir:
CALL parar
MOV r22,r16
CALL getval
LDI r20,0
CPSE r19,r20
JMP RutSel
JMP GOBACK
;fin rutinas deducir

gostop:
CALL parar
JMP gostop

backA:
CALL getbordes
MOV r31,r4
SBRC r31,0
JMP gostop
SBRS r27,1
CALL atras
SBRS r27,1
RJMP backa
LDI r30,2
LDI r29,3
CPSE r27,r30
CALL pasoizq
CPSE r27,r29
CALL pasoder
LDI r27,0
RJMP backa

backB:
CALL getbordes
MOV r31,r4
SBRC r31,1
JMP gostop
SBRS r27,1
CALL atras
SBRS r27,1
RJMP backb
LDI r30,2
LDI r29,3
CPSE r27,r30
CALL pasoder
CPSE r27,r29
CALL pasoizq
LDI r27,1
RJMP backb
;fin

atras:
LDI aux1,0xf0
and motores,aux1
LDI aux1,0x0a
EOR motores,aux1
OUT portb,motores
CALL wait20;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
RET

adelante:
LDI aux1,0xf0
and motores,aux1
LDI aux1, 0x05
EOR motores,aux1
OUT portb,motores
CALL wait20;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
RET