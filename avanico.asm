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
;r27 = gua
;r28 = gub
;r29 = cua : guarda valores relacionados a sensores activos, en especifico, el ultimo sensor
;r30 = cub : guarda la conclusion del recorrido. ff=esta en 90 grados, ee=45 izquieda, dd=45 derecha. cc=avismo.
;r31 = sentido giro. derecha 0, izquierda 1
;.......
;constantes
;step = numero de veces que debe repetirse un RETardo de X milisegundos para avanzar 8cm (media casilla)
;giro = numero de veces que debe repetirse un RETardo de X milisegundos para girar 5 grados
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
.def gua=r27
.def gub=r28
.def cua=r29
.def cub=r30
.def gir=r31

.equ stepb=20;un pasob es el numero de veces que hay que repetir un delay corto (20 ms es lo mas aDECuado) para generar un retroceso igual a 5,8 cm ( 23,52cm es la maxima inclinacion posible, a 45 grados, es la medida del sector*1.437 16*1.437. esto entre dos =11.76)
.equ step=13;un paso es el numero de veces que hay que repetir un delay corto (20 ms es lo mas aDECuado) para generar un avance igual a 5,8 cm ( 23,52cm es la maxima inclinacion posible, a 45 grados, es la medida del sector*1.437 16*1.437. esto entre dos =11.76)
.equ giro=7;un giro es el numero de veces que hay que repetir un delay corto (20 ms es lo mas aDECuado) para generar un desvio igual a 10 grados.

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
JMP fase1
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
CALL getiobfas
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
CALL getioafas
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
MOV aux1,r0
CALL wait20;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
RET

derecha:
MOV r0,aux1
LDI aux1,0xf0
and motores,aux1
LDI aux1,0x04
EOR motores,aux1
OUT portb,motores
MOV aux1,r0
CALL wait20;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
RET

atras:
MOV r0,aux1
LDI aux1,0xf0
and motores,aux1
LDI aux1,0x0a
EOR motores,aux1
OUT portb,motores
MOV aux1,r0
CALL wait20;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
RET

adelante:
MOV r0,aux1
LDI aux1,0xf0
and motores,aux1
LDI aux1, 0x05
EOR motores,aux1
OUT portb,motores
MOV aux1,r0
CALL wait20;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
RET

parar:
MOV r0,aux1
LDI aux1,0xf0
and motores,aux1
OUT portb,motores
MOV aux1,r0
CALL wait20;(usar siempre el menor tiempo de espera)
RET

stopit:
CALL parar
RJMP stopit

;rutinas de MOVimiento por periodo fijo
pasoizq:
mov r0,r19
mov r12,r23
ldi r23,giro
LDI aux1,0xf0
AND motores,aux1
LDI aux1,0x01
EOR motores,aux1
OUT portb,motores
LDI r19,0
CALL  waitto;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
mov r19,r0
mov r23,r12
RET

pasoder:
mov r0,r19
mov r12,r23
ldi r23,giro
LDI aux1,0xf0
AND motores,aux1
LDI aux1,0x04
EOR motores,aux1
OUT portb,motores
LDI r19,0
CALL  waitto;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
mov r19,r0
mov r23,r12
RET

pasoatra:
mov r0,r19
mov r12,r23
ldi r23,stepb
LDI aux1,0xf0
and motores,aux1
LDI aux1,0x0a
EOR motores,aux1
OUT portb,motores
LDI r19,0
mov r19,r0
CALL waitdo;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
mov r19,r0
mov r23,r12
RET

pasoadel:
mov r0,r19
mov r12,r23
ldi r23,step
LDI aux1,0xf0
and motores,aux1
LDI aux1, 0x05
EOR motores,aux1
OUT portb,motores
LDI r19,0
CALL waitdo;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
mov r19,r0
mov r23,r12
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
ldi cua,0xff
ldi gua,0xff
ldi gub,0xff
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

returnori: ;restar aux3 hasta hacerlo cero
ldi aux2,0
cpse aux3,aux2
rjmp toori
call parar
com gir
andi gir,0x01
ret

toori:
dec aux3
cpse gir,aux2
call derecha
ldi aux2, 1
cpse gir,aux2
call izquierda
rjmp returnori

fase1:
call pasoadel
ldi aux3,0
ldi gir,0

derechagav:
cpi aux3,giro
brlo derechag
ldi gua,0xff
call returnori
jmp izqgav

derechag:
ldi aux2,0
cpse sector,aux2;si b
call getchangb;****getchanga y getchangb deben ser cambiados para esta rutina, a su version fast****
ldi aux2,1
cpse sector,aux2;si a
call getchanga ;****getchanga y getchangb deben ser cambiados para esta rutina, a su version fast****
inc aux3
call derecha
cpi aux1,0xff
breq derechagav

componD:
mov cua,aux1
mov gua,aux3
call returnori

izqgav:
cpi aux3,giro
brlo izqg
ldi gub,0xff
call returnori
rjmp checkonori

izqg:
ldi aux2,0
cpse sector,aux2;si b
call getchangb;****getchanga y getchangb deben ser cambiados para esta rutina, a su version fast****
ldi aux2,1
cpse sector,aux2;si a
call getchanga ;****getchanga y getchangb deben ser cambiados para esta rutina, a su version fast****
inc aux3
call izquierda
cpi aux1,0xff
breq izqgav

componI:
mov cua,aux1
mov gub,aux3
call returnori

checkonori:
cpse gua,gub
rjmp nonequal
cpi gua,0xff
breq fase1;aca es porque aun no llega al acance de algun sensor
jmp stopit;aca es porque esta en linea recta entre dos sensores

nonequal:
cpi gua,0xff
breq guaff
cpi gub,0xff
breq gubff
cp gua,gub
brlo guamin

gubmin:
mov cub,gua
sub cub,gub
ldi aux2,0
jmp derecub

guamin:
mov cub,gub
sub cub,gua
ldi aux2,0
jmp izqcub

gubff:
mov cub,giro
sub cub,gua
rjmp izqcub

guaff:
ldi cub,giro
sub cub,gub
rjmp derecub

derecub:
call derecha
dec cub
cpse cub,aux2
rjmp derecub
jmp stopit

izqcub:
call izquierda
dec cub
cpse cub,aux2
rjmp izqcub
jmp stopit
