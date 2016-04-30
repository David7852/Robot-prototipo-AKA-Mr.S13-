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

.equ stepstop=20;delay necesario para drenar el desplazamiento de los motores.
.equ stepb=17;un pasob es el numero de veces que hay que repetir un delay corto (20 ms es lo mas aDECuado) para generar un retroceso igual a 5,8 cm ( 23,52cm es la maxima inclinacion posible, a 45 grados, es la medida del sector*1.437 16*1.437. esto entre dos =11.76)
.equ step=16;un paso es el numero de veces que hay que repetir un delay corto (20 ms es lo mas aDECuado) para generar un avance igual a 10 cm ( 23,52cm es la maxima inclinacion posible, a 45 grados, es la medida del sector*1.437 16*1.437. esto entre dos =11.76)
.equ giro=2;un giro es el numero de veces que hay que repetir un delay corto (20 ms es lo mas aDECuado) para generar un desvio igual a 10 grados.

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
nop nop nop nop
in r12,pinc
CPSE ioa,r12
RJMP getioa
RET

getiobfas:
nop nop nop nop
in r12,pind
CPSE iob,r12
RJMP getiob
RET

getborfas:
in bordes,pinf
nop nop nop nop
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
call getborfas
SBRC bordes,2
rjmp setis
SBRC bordes,3
rjmp setis
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

;dado el numero de la casilla N suministrada por el aux4, devuelve 0 si no lo esta Y TAL CASILLA NO ES LA DEL OBJETO
getvalnobj:
ldi aux1,0
cpse aux4,objn
call getval
ret

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
MOV r12,r23
ldi r23,stepstop
LDI aux1,0xf0
and motores,aux1
OUT portb,motores
ldi r19,0
CALL waitto;(usar siempre el menor tiempo de espera)
mov r19,r0
mov r23,r12
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
CALL waitTo;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
mov r19,r0
mov r23,r12
RET

waitto:
CALL wait20
INC r19
CPSE r19,r23
RJMP waitto
RET
;*********

;****
;inicio
;****
Fase1:
CALL seto
CALL esperanto
RJMP fase2
;****
;acondicionamiento
;****

Fase2:
LDI aux5,step
add aux5,aux5
add aux5,aux5
CALL flare
CALL calcuerda
CALL plan
LDI cua,0
JMP check
;****
;toma de DECisiones
;****

fase3:
LDI aux5,0
CALL cuerdaOUT
call parar
LDI aux5,0
CALL RETrieve
RJMP check
;****

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
LDI sector,0xff
RET;(en caso de estar solos en la pista, simplemente sale y comienza a explorar)
;****

sunless:
CALL adelante
CALL getbordes
LDI aux1,0x03
and bordes,aux1
LDI aux1,0
CP bordes,aux1
BREQ sunless
LDI aux1,1
CP bordes, aux1
BREQ setsecA
RJMP setsecB 
RET

flare:
CALL getioa
CALL getiob
LDI aux1,0xff
CPSE sector,aux1
RJMP launch
CALL sunless
RJMP launch

launch: ;MOVer hasta que se encienda un borde vertical o se encienda un sensor
ldi aux2,0
CPSE aux5,aux2
rjmp keeplaunching
call extingue
call derecha
ldi aux5,step
add aux5,aux5
add aux5,aux5

keeplaunching:
DEC aux5
CALL adelante
LDI aux2,1 ;si estoy en b
CPSE sector,aux2
MOV aux4,ioa
CPSE sector,aux2
;comprobar si algun sensor encendio en mi sector (solo revisa mi sector ya que asi evito falsos positivos con el rival)
CALL getchanga
LDI aux2,0
CPSE sector,aux2
MOV aux4,iob
CPSE sector,aux2
CALL getchangb
LDI aux2,0xff
CPSE aux1,aux2
RJMP exting
;comprobar bordes... si empece en a, compiar el contenido del registro de bordes, negar el bit 0, comprobar si el registro es distinto de 0. si empece en b, compiar el contenido del registro de bordes, negar el bit 1, comprobar si el registro es distinto de 0. si el registro no es 0, ir a extingub 
CALL getbordes
MOV aux3,bordes
LDI aux2,0;si estoy en a
CP sector,aux2
BREQ bordea
RJMP bordeb

bordea:
LDI cua,0xff
SBRC aux3,3
ANDI sector,0x0f;mirando derecha
SBRC aux3,3
RJMP setder
SBRC aux3,3
RJMP extingue
SBRC aux3,2
ORI sector,0x80;mirando izquierda
SBRC aux3,2
RJMP setizq
SBRC aux3,2
RJMP extingue
RJMP launch

bordeb:
LDI cua,0xff
SBRC aux3,3
ORI sector,0x80;mirando derecha
SBRC aux3,3
RJMP setder
SBRC aux3,3
RJMP extingue
SBRC aux3,2
ANDI sector,0x0f;mirando izquierda
SBRC aux3,2
RJMP setizq
SBRC aux3,2
RJMP extingue
RJMP launch

setder:
call parar
LDI gir,0
RJMP extingue

setizq:
call parar
LDI gir,1
RJMP extingue

exting:
MOV cua,aux1
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

extingue:
CALL atras
CALL getbordes
MOV aux3,bordes
MOV aux1,sector
ANDI aux1,0x03
SBRC aux1,0
RJMP extb
SBRS aux1,0
RJMP exta

extb:
SBRC aux3,1
RET
RJMP extingue

exta:
SBRC aux3,0
RET
RJMP extingue

compxo:
SUB aux2,objx
MOV gua,aux2
;INC gua ??
RET
    
compox:
MOV gua,objx
SUB gua,aux2
;INC gua ??
RET
    
plan:
LDI aux2,0xff
CPSE cua,aux2
RJMP pla
RET
    
pla:
MOV aux4,cua
CALL getxy
CP objx,aux2
BRLO compxo
CPSE objx,aux2
RJMP compox
RET
    
calcuerda:;si a cuerda=objy*2-1 
MOV aux1,sector
MOV aux3,objy
INC aux3
LDI aux4,5
SUB aux4,aux3
ADD aux4,aux4
DEC aux4
ADD aux3,aux3
DEC aux3
ANDI aux1,0x0f
LDI aux2,0
CPSE aux1,aux2;si estoy en sector b
MOV cuerda, aux4
LDI aux2,1
CPSE aux1,aux2;si estoy en sector a
MOV cuerda,aux3
RET

;esto agrega mas de 10 ms al paso de ORIginalmente 22, asi que step deberia dividirse 1.5 de su cantidad ORIginal.
;MOVer adelante por cuerda
cuerdaOUT:
LDI aux6,0
CP aux5,cuerda
BREQ RETurn
INC aux5
;***
LDI aux4,0
LDI aux1,0
;***
RJMP cuentpaso

setff:
LDI cub,0xff
INC aux6
RJMP cuentpaso

check90:
;si cua es igual a aux1+4 o aux1-4, cub igual ff
LDI aux2,4
ADD aux1,aux2
CP cua,aux1
BREQ setff
SUBI aux1,8
CP cua,aux1
BREQ setff
ADD aux1,aux2
RET

setee:
LDI cub,0xee
INC aux6
RJMP cuentpaso

setdd:
LDI cub,0xdd
INC aux6
RJMP cuentpaso

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

cuentpaso:
CPI aux6,step
BREQ cuerdaOUT
CALL adelante
;aux1 es resultado de getchang
SBRC sector,0
CALL getchangb
SBRS sector,0
CALL getchanga
;*** revisa si en mi sector tengo una convinacion con desviacion conocida.
CALL check90
CALL check45
;***
;si aux1 es distinto de  ff, guardar en cua aux1
LDI aux2,0xff
CPSE aux1,aux2
MOV cua,aux1
;*** comprueba que no se golpearan rocas o avismos
MOV aux4,aux1
CALL isrocky
CPI aux1,0xff
BREQ rockshock
CALL isfall
CPI aux1,0xff
BREQ fallfall
INC aux6
RJMP cuentpaso

rockshock: ;ir atras hasta que se encida mi borde, saltar a fase3.
CALL parar
POP r0
POP r0
MOV aux1,sector
CALL extingue
RJMP check

fallfall: ;ir atras hasta que se encienda borde, invertir giro, saltar a fase3.
CALL parar
POP r0
POP r0
COM gir
ANDI gir,0x01
CALL extingue
RJMP check

RETrieve:
LDI aux6,0
CP aux5,cuerda
BREQ RETurn
INC aux5
RJMP cuentback

cuentback:
CPI aux6,stepb
BREQ RETrieve
CALL atras
INC aux6
RJMP cuentback

check:
CALL parar
CPI cub,0xff;saltar a cuenta paso
BREQ stop
CPI cub,0xee;girar 45 grados izquierda, saltar a cuenta paso
BREQ stop
CPI cub,0xdd;girar 45 grados derecha, saltar a cuenta paso
BREQ stop
MOV aux4, objn
CALL getval
CPI aux1,0
BREQ stop
CALL planit
LDI aux2,1
CPSE gir,aux2
CALL derechagir
LDI aux2,0
CPSE gir,aux2
CALL izquiergir
JMP fase3

stop:
JMP stopit

planit:;calcula cuanto girar, si 5,10,15,etc, guardando el numero de veces que girar 5 grados en el gua.
;queda por hacer un forMULa que de un numero al que ir restando 1 en uno y que tome como valor la posicion inicial y el obejto
;planit nunca devolvera nada menor a 1
LDI gub,1
CPSE gua,gub
RJMP planb
RET

planb:
LDI gub,0
CPSE gua,gub
RJMP plana
LDI gua,1
RET

plana:
DEC gua
RET

derechagir:
LDI gub,0
CPSE gua,gub
RJMP girder
RET

girder:
INC gub
LDI aux3,giro
CPSE gub,aux3
CALL derecha
CPSE gub,aux3
RJMP girder
DEC gua
RJMP derechagir

izquiergir:
LDI gub,0
CPSE gua,gub
RJMP girizq
RET

girizq:
INC gub
LDI aux3,giro
CPSE gub,aux3
CALL izquierda
CPSE gub,aux3
RJMP girizq
DEC gua
RJMP izquiergir
