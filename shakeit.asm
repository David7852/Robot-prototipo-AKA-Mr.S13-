;r0 = registro especial (usado por algunas instrucciones de atmel)
;r1 = registro especial (usado por algunas instrucciones de atmel)
;r2 = I/O puerto C (sector A)
;r3 = I/O puerto D (sector B)
;r4 = I/O puerto F (Bordes bit 0= A hORIzontal, bit 1= B hORIzontal, bit 2 = derecha, bit 3 = izquierda )
;r5 = I/O puerto B (motores)
;r6 = angulo del vehiculo
;.......
;Variables del sistema
;r16 = objeto (# casilla)
;r17 = X objeto
;r18 = Y objeto
;r19 = aux 1 (RETurn aux)
;r20 = aux 2
;r21 = aux 3
;r22 = aux 4 (N casilla en busqueda o N de la secuencia)
;r23 = cuerda (DECimas de segundo, o MULtiplicador de DECimas nescesarias para una distancia especifica) 
;r24 = sectores (primeros 4 bits: 0000 A, 0001 B. ultimos 4 bits: 0000 derecha, 1000 izquierda, 11111111 es unknow)
;r25 = aux 5
;r26 = aux 6
;r27 = aux 7
;r28 = aux 8
;r29 = cua : guarda valores relacionados a sensores activos, en especifico, el ultimo sensor
;r30 = cub : guarda la conclusion del recorrido. ff=esta en 90 grados, ee=45 izquieda, dd=45 derecha. cc=avismo.
;r31 = sentido giro. derecha 0, izquierda 1
;*** 
.dseg
.def ioa=r2
.def iob=r3
.def bordes=r4
.def motores=r5
.def angle=r6

.def objn=r16
.def objx=r17
.def objy=r18
.def aux1=r19		             
.def aux2=r20
.def aux3=r21
.def aux4=r22
.def cuerda=r23
.def sector=r24
.def aux5=r25
.def aux6=r26
.def aux7=r27
.def aux8=r28
.def cua=r29
.def cub=r30
.def gir=r31

.equ maxstep=6;representa el numero maximo de veces que puede repetirse un step para alcanzar 16cm de avance 5*6=30 ->14cm
.equ step=5;un paso es el numero de veces que hay que repetir para lograr el avance corto que se quiere. deberia ser poco
.equ giro=40;un giro es el numero de veces a repetir para 90 grados 

.cseg 
.include "usb1286def.inc"
.org 0000
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
JMP fase0
;**********

;rutinas de asistencia
;**********

;rutinas para delay de lecturas
getioafas:
in ioa,pinc
nop nop nop
in r12,pinc
CPSE ioa,r12
RJMP getioa
RET

getiobfas:
in iob,pind
nop nop nop
in r12,pind
CPSE iob,r12
RJMP getiob
RET

getborfas:
in bordes,pinf
nop nop nop
in r12,pinf
CPSE bordes,r12
RJMP getbordes
RET

getioa:
in ioa,pinc
CALL wait10
in r12,pinc
CPSE ioa,r12
RJMP getioa
RET

getiob:
in iob,pind
CALL wait10
in r12,pind
CPSE iob,r12
RJMP getiob
RET

getbordes:
in bordes,pinf
CALL wait10
in r12,pinf
CPSE bordes,r12
RJMP getbordes
RET

;determinar si un sector es rock. (si sector==a && objy<sensor.y) Es roca y devuelve un 0xff en aux1, sino, 00. N de sensor a buscar en aux4
isrocky:
MOV r1,aux2
MOV r13,aux3
MOV aux1,sector
ANDI aux1,0x0f
LDI aux2,0
CPSE aux1,aux2;si estoy en sector b
RJMP isroca
LDI aux2,1
CPSE aux1,aux2;si estoy en sector a
RJMP isroco

isfall:
MOV r1,aux2
MOV r13,aux3
LDI aux2,0
CPSE gir,aux2;si estoy a derecha
RJMP isfalla
LDI aux2,1
CPSE gir,aux2;si estoy a izquierda
RJMP isfallo

isroca:
CALL getxy
CP aux3,objy
BRGE setis
RJMP notis

isroco:
CALL getxy
CP aux3,objy
BRGE notis
RJMP setis

setis:
MOV aux2,r1
MOV aux3,r13
LDI aux1,0xff
RET

notis:
MOV aux2,r1
MOV aux3,r13
LDI aux1,0
RET

;determinar si un sector es fall. (si gir==izq && objx>sensor.x) Es roca y devuelve un 0xff en aux1, sino, 00. N de sensor a buscar en aux4
isfalla:
CALL getxy
CP aux2,objx
BRGE notis
RJMP setis

isfallo:
CALL getxy
CP aux2,objx
BRGE setis
RJMP notis

;detectar cambios en los sectores especificados
;el estado anterior del puerto a buscar debe estar guardado en aux4, el resultado sera escrito en aux1
;si no hay cambios, aux1 seria igual a 0xff
getchanga:
MOV r0,r20
CALL getioafas
MOV aux2,ioa
EOR aux2,aux4
LDI aux1,0
CALL getchang
MOV r20,r0
RET

getchang:
SBRC aux2,0
RET
INC aux1
SBRC aux2,1
RET
INC aux1
SBRC aux2,2
RET
INC aux1
SBRC aux2,3
RET
INC aux1
SBRC aux2,4
RET
INC aux1
SBRC aux2,5
RET
INC aux1
SBRC aux2,6
RET
INC aux1
SBRC aux2,7
RET
LDI aux1,0xff
RET

getchangb:
MOV r0,r20
MOV r1,r21
CALL getiobfas
MOV aux2,iob
EOR aux2,aux4
LDI aux1,0
CALL getchang
LDI aux2,0xff
LDI aux3,8
CPSE aux1,aux2
ADD aux1,aux3
MOV r20,r0
MOV r21,r1
RET

;obtener las coordenadas xy de una casilla
;(el valor de la casilla a buscar debe estar guardado en r22, el X y Y resultado se guardara en r20 y r21.)
getxy:
MOV r1,r19
LDI r19,0
LDI r20,0
LDI r21,0
RJMP SUBgetxy

SUBgetxy:
CPSE r19,r22
RJMP loopxy
MOV aux1,r1
RET

loopxy:
CPI r20,3
BREQ eqloopxy
INC r20
INC r19
RJMP SUBgetxy 

eqloopxy:
INC r21
LDI r20,0
INC r19
RJMP SUBgetxy

;obtener el valor actual de una casilla N
;(la casilla a buscar debe estar guardada en r22, el valor (0,1) es devuelto en aux1)
getval:
MOV r0,r20
CPI r22,8
BRSH getvalB
RJMP getvalA

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

RETgeval:
MOV r20,r0
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
RJMP RETgeval

;dadas las coordenadas xy guardadas en los registros r20 y r21 respectivamente, guarda el numero de esa casilla en r22
getNxy:
LDI r22,4
MUL r22,r21
MOV r22,r0
ADD r22,r20
RET

;Rutinas para generar RETardos a (20 mhz)
;10ms (7*0.0000005)(256)(26)=0.013seg
wait10:
MOV r8,r20
MOV r11,r21
LDI r20,26
RJMP wait10A

wait10A:
LDI r21,0xff
SUBI r20,1
BRNE wait10B
MOV r20,r8
MOV r21,r11
RET

wait10B:
SUBI r21,1
BREQ wait10A
RJMP wait10B

;20ms (7*0.0000005)(256)(26)=0.022seg
wait20:
MOV r8,r20
MOV r11,r21
LDI r20,26
RJMP wait20A

wait20A:
LDI r21,0xff
SUBI r20,1
BRNE wait20B
MOV r20,r8
MOV r21,r11
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
MOV r8,r20
MOV r11,r21
LDI r20,26
RJMP wait30A

wait30A:
LDI r21,0xff
SUBI r20,1
BRNE wait30B
MOV r20,r8
MOV r21,r11
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
MOV r8,r20
MOV r11,r21
LDI r20,26
RJMP wait40A

wait40A:
LDI r21,0xff
SUBI r20,1
BRNE wait40B
MOV r20,r8
MOV r21,r11
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
izquierda:
MOV r0,aux1
LDI aux1,0xf0
and motores,aux1
LDI aux1,0x01
EOR motores,aux1
OUT portb,motores
CALL wait20;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
MOV aux1,r0
RET

derecha:
MOV r0,aux1
LDI aux1,0xf0
and motores,aux1
LDI aux1,0x04
EOR motores,aux1
OUT portb,motores
CALL wait20;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
MOV aux1,r0
RET

atras:
MOV r0,aux1
LDI aux1,0xf0
and motores,aux1
LDI aux1,0x0a
EOR motores,aux1
OUT portb,motores
CALL wait20;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
MOV aux1,r0
RET

adelante:
MOV r0,aux1
LDI aux1,0xf0
and motores,aux1
LDI aux1, 0x05
EOR motores,aux1
OUT portb,motores
CALL wait20;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
MOV aux1,r0
RET

parar:
MOV r0,aux1
LDI aux1,0xf0
and motores,aux1
OUT portb,motores
CALL wait20;(usar siempre el menor tiempo de espera)
MOV aux1,r0
RET

stopit:
CALL parar
RJMP stopit

;rutinas de MOVimiento por periodo fijo
pasoizq:
LDI aux1,0xf0
AND motores,aux1
LDI aux1,0x01
EOR motores,aux1
OUT portb,motores
LDI r19,0
CALL  waitto;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
RET

pasoder:
LDI aux1,0xf0
AND motores,aux1
LDI aux1,0x04
EOR motores,aux1
OUT portb,motores
LDI r19,0
CALL  waitto;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
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

;*********
;fin
fase0:
CALL seto
CALL esperanto
ldi aux5,0
JMP fase1

seto:;(esperar a que objeto este puesto)
CALL getioa
CALL getiob
CP r2,r19
BRNE startA
CPSE r3,r19
RJMP startB
RJMP seto

startA:;setea la posicion del objeto (si esta en sector A)
SBRC r2,0
RJMP setstartA
INC r19
SBRC r2,1
RJMP setstartA
INC r19
SBRC r2,2
RJMP setstartA
INC r19
SBRC r2,3
RJMP setstartA
INC r19
SBRC r2,4
RJMP setstartA
INC r19
SBRC r2,5
RJMP setstartA
INC r19
SBRC r2,6
RJMP setstartA
INC r19
RJMP setstartA

startB:;setea la posicion del objeto (si esta en sector B)
SBRC r3,0
RJMP setstartB
INC r19
SBRC r3,1
RJMP setstartB
INC r19
SBRC r3,2
RJMP setstartB
INC r19
SBRC r3,3
RJMP setstartB
INC r19
SBRC r3,4
RJMP setstartB
INC r19
SBRC r3,5
RJMP setstartB
INC r19
SBRC r3,6
RJMP setstartB
INC r19
RJMP setstartB

setstartA:
MOV r16,r19
MOV r22,r16
CALL getxy
MOV r17,r20
MOV r18,r21
RET

setstartB:
LDI r20,8
ADD r19,r20
MOV r16,r19
MOV r22,r16
CALL getxy
MOV r17,r20
MOV r18,r21
RET

;rutina de espera.(RETrasa el carro 5.6 seg, 7,4 seg, 9,9 seg respectivamente)
;cada 22 o 29 o 39 milisegundos se va a revisar si algun borde se encendio
esperanto:
LDI r19,0xff
RJMP wait

wait:
CALL wait20;cambiar aca cual se quiere si 20,30 o 40
DEC r19
CALL getborfas
;com r4 ;suponiendo que las entradas de los bordes sean logica baja al igual que los sensores
SBRC r4,0 ;si el pin 0 NO es 0, salta, si lo es continua
RJMP setsecb
SBRC r4,1 ;si el pin 1 NO es 0, salta, si lo es continua
RJMP setseca
CPI r19,0
BREQ resolution
RJMP wait

setsecA:
LDI r24,0
RET

setsecB:
LDI r24,1
RET

;fin de rutina de espera
resolution:;(en caso de que algun otro carro TAMBIEN (maLDItos) este esperando o nosotros estemos solos)
CALL adelante
CALL getbordes
LDI aux1,0x03
and bordes,aux1
LDI aux1,0
CP bordes,aux1
BREQ resolution
LDI aux1,1
CP bordes, aux1
BREQ setsecA
RJMP setsecB

fase1:
ldi r28,step;si se integra con cuerda o cuenta paso, aca cambiar
ldi r23,giro;si se integra con cuerda o cuenta paso, aca cambiar
ldi aux3,0
call moveit
ldi aux3,0
call shakeit
ldi aux3,0
inc aux5
cpi aux5,maxstep
breq pushit
rjmp fase1

pushit:
call derecha
inc aux3
cpi aux3,giro
brlo pushit
jmp pushpush

pushpush:;3 pasos adelante son 8cm aprox
ldi aux3,0
call pasoadel
call pasoadel
call pasoadel
rjmp rushit

rushit:
call izquierda
inc aux3
cpi aux3,giro
brlo rushit
ldi aux3,0
jmp kick

kick:
call pasoatra
dec aux5
cpi aux5,0
breq fase1
rjmp kick

moveit:
cpi aux3,step
brlo move
ret

move:
call pasoadel
inc aux3
ldi aux2,0
cpse sector,aux2;si b
call getchangb;****getchanga y getchangb deben ser cambiados para esta rutina, a su version fast****
ldi aux2,1
cpse sector,aux2;si a
call getchanga;****getchanga y getchangb deben ser cambiados para esta rutina, a su version fast****
cpi aux1,0xff
breq moveit
mov cua,aux1
pop r0
pop r0
ldi aux3,0
jmp xxxx;xxxx rutina para cuando encendio en line recta.

shakeit:
cpi aux3,giro
brlo shake
jmp unshakeit

shake:
call derecha
inc aux3
ldi aux2,0
cpse sector,aux2;si b
call getchangb;****getchanga y getchangb deben ser cambiados para esta rutina, a su version fast****
ldi aux2,1
cpse sector,aux2;si a
call getchanga ;****getchanga y getchangb deben ser cambiados para esta rutina, a su version fast****
cpi aux1,0xff
breq shakeit
mov cua,aux1
mov cub,aux3
pop r0
pop r0
jmp baby

unshakeit:
call izquierda
dec aux3
ldi aux2,0
nop nop nop nop
cpse aux3,aux2
rjmp unshakeit
ret

baby:
call izquierda
dec aux3
ldi aux2,0
nop nop nop nop
cpse aux3,aux2
rjmp baby
ldi aux3,giro
sub aux3,cub
rjmp shakeagain

shakeagain:
call izquierda
dec aux3
ldi aux2,0
nop nop nop nop
cpse aux3,aux2
rjmp shakeagain
jmp gohome;yyyy rutina para cuando encendio en giro.

check90:
;si cua es igual a aux1+4 o aux1-4, cub igual ff
LDI aux2,4
ADD aux1,aux2
CP cua,aux1
BREQ gohome
SUBI aux1,8
CP cua,aux1
BREQ gohome
ADD aux1,aux2
RET

setee:
LDI cub,0xee
LDI aux1,0xf0
AND motores,aux1
LDI aux1,0x01
EOR motores,aux1
OUT portb,motores
LDI r19,20
ldi r23,40
CALL  waitto;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
jmp gohome

setdd:
LDI cub,0xdd
LDI aux1,0xf0
AND motores,aux1
LDI aux1,0x04
EOR motores,aux1
OUT portb,motores
LDI r19,20
ldi r23,40
CALL  waitto;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
jmp gohome

gohome:
call atras
call getborfas
mov aux3,bordes
andi aux3,0x03
SBRC sector,0
andi aux3,0x02
SBRS sector,0
andi aux3,0x01
cpi aux3,0
breq gohome
;jmp fase1;se llego al inicio y vuelve a empezar porque.... algo paso.... aca quizas deba pasar a cuerda? cuentapaso?
jmp exting

check45:
;si cua es igual a aux1+4 o aux1-4, cub igual ff
LDI aux2,3
ADD aux1,aux2
CP cua,aux1
BREQ setdd
SUBI aux1,6
CP cua,aux1
BREQ setdd
ADD aux1,aux2
LDI aux2,5
ADD aux1,aux2
CP cua,aux1
BREQ setee
SUBI aux1,10
CP cua,aux1
BREQ setee
ADD aux1,aux2
RET

RETurn:
RET

xxxx:
CPI aux6,maxstep
BREQ gohome
CALL adelante
;*** revisa si en mi sector tengo una convinacion con desviacion conocida.
;aux1 es resultado de getchang
SBRC sector,0
CALL getchangb
SBRS sector,0
CALL getchanga
;***
CALL check90
CALL check45
;***
;si aux1 es distinto de  ff, guardar en cua aux1
LDI aux2,0xff
CPSE aux1,aux2
MOV cua,aux1
;***
INC aux6
RJMP xxxx

setder:
LDI gir,0
RJMP subindid

setizq:
LDI gir,1
RJMP subindie

exting:
MOV aux1,cua
LDI aux2,0;si estoy en a
CP sector,aux2
BREQ extinga
LDI aux2,1
CP sector,aux2;si estoy en b
BREQ extingb

extinga:
MOV aux4,aux1
CALL getxy
CP objx,aux2
BRGE setizq
RJMP setder

extingb:
MOV aux4,aux1
CALL getxy
CP objx,aux2
BRGE setder
RJMP setizq

SUBIndie:
LDI r23,40
LDI r28,35
ANDI sector,0x03
CPI sector,1
BREQ sets12
RJMP sets00

;en caso de que al desviar 45 grados se quede en medio de un sector, usar cua +-5 o +-3 para obtener la casilla de inicio?? si no, ir a rutinca cuenta filas (por crear)
    
SUBIndid:
LDI r23,40
LDI r28,35
ANDI sector,0x03
CPI sector,1
BREQ sets15
RJMP sets03

sets00:
ldi r22,0
call getxy
mov r25,r20
mov r26,r21
LDI r27,0
;*** mover un paso puesto que se empieza desde el borde, no desde el sector
call pasoadel
;***
RJMP deducir

sets03:
ldi r22,3
call getxy
mov r25,r20
mov r26,r21
LDI r27,0
;*** mover un paso puesto que se empieza desde el borde, no desde el sector
call pasoadel
;***
RJMP deducir

sets12:
ldi r22,12
call getxy
mov r25,r20
mov r26,r21
LDI r27,1
;*** mover un paso puesto que se empieza desde el borde, no desde el sector
call pasoadel
;***
RJMP deducir

sets15:
ldi r22,15
call getxy
mov r25,r20
mov r26,r21
LDI r27,1
;*** mover un paso puesto que se empieza desde el borde, no desde el sector
call pasoadel
;***
RJMP deducir

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

backA:
CALL getbordes
MOV r31,r4
SBRC r31,0
JMP stopit
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
JMP stopit
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

