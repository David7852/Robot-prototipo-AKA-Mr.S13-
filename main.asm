;r0 = registro especial (usado por algunas instrucciones de atmel)
;r1 = registro especial (usado por algunas instrucciones de atmel)
;r2 = I/O puerto C (sector A)
;r3 = I/O puerto D (sector B)
;r4 = I/O puerto F (Bordes bit 0= A horizontal, bit 1= B horizontal, bit 2 = derecha, bit 3 = izquierda )
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
;r29 = vector cuerda 1
;r30 = vector cuerda 2
;r31 = sentido giro. derecha 0, izquierda 1
;.......
;constantes
;step = numero de veces que debe repetirse un RETardo de X milisegundos para avanzar 8cm (media casilla)
;giro = numero de veces que debe repetirse un RETardo de X milisegundos para girar 5 grados
;N0-10 = distancias euclidianas
;N13 = numero de la secuencia (solo para competencia)
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

.equ step=20;un paso es el numero de veces que hay que repetir un delay corto (20 ms es lo mas aDECuado) para generar un avance igual a 11.45cm (maxima inclinacion, a 45 grados es la medida del sector*1.437)
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
JMP  fase1
;**********

;rutinas de asistencia
;**********
;determinar si un sector es rock. (si sector==a && objy<sensor.y) Es roca y devuelve un 0xff en aux1, sino, 00. N de sensor a buscar en aux4
isrocky:
MOV  r1,aux2
MOV  r13,aux3
MOV  aux1,sector
ANDI aux1,0x0f
LDI aux2,0
CPSE aux1,aux2;si estoy en sector b
RJMP isroca
LDI aux2,1
CPSE aux1,aux2;si estoy en sector a
RJMP isroco

isfall:
MOV  r1,aux2
MOV  r13,aux3
LDI aux2,0
CPSE gir,aux2;si estoy a derecha
RJMP isfalla
LDI aux2,1
CPSE gir,aux2;si estoy a izquierda
RJMP isfallo

isroca:
CALL  getxy
CP aux3,objy
BRGE setis
RJMP notis

isroco:
CALL  getxy
CP aux3,objy
BRGE notis
RJMP setis

setis:
MOV  aux2,r1
MOV  aux3,r13
LDI aux1,0xff
RET

notis:
MOV  aux2,r1
MOV  aux3,r13
LDI aux1,0
RET

;determinar si un sector es fall. (si gir==izq && objx>sensor.x) Es roca y devuelve un 0xff en aux1, sino, 00. N de sensor a buscar en aux4
isfalla:
CALL  getxy
CP aux2,objx
BRGE notis
RJMP setis

isfallo:
CALL  getxy
CP aux2,objx
BRGE setis
RJMP notis

;detectar cambios en los sectores especificados
;el estado anterior del puerto a buscar debe estar guardado en aux4, el resultado sera escrito en aux1
;si no hay cambios, aux1 seria igual a 0xff
getchanga:
MOV  r0,r20
CALL  getioa
MOV  aux2,ioa
EOR aux2,aux4
LDI aux1,0
CALL  getchang
MOV  r20,r0
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
MOV  r0,r20
MOV  r1,r21
CALL  getiob
MOV  aux2,iob
EOR aux2,aux4
LDI aux1,0
CALL  getchang
LDI aux2,0xff
LDI aux3,8
CPSE aux1,aux2
ADD aux1,aux3
MOV  r20,r0
MOV  r21,r1
RET

;obtener las coordenadas xy de una casilla
;(el valor de la casilla a buscar debe estar guardado en r22, el X y Y resultado se guardara en r20 y r21.)
getxy:
MOV  r1,r19
LDI r19,0
LDI r20,0
LDI r21,0
RJMP subgetxy

subgetxy:
CPSE r19,r22
RJMP loopxy
MOV  aux1,r1
RET

loopxy:
CPI r20,3
BREQ eqloopxy
INC r20
INC r19
RJMP subgetxy 

eqloopxy:
INC r21
LDI r20,0
INC r19
RJMP subgetxy

;obtener el valor actual de una casilla N
;(la casilla a buscar debe estar guardada en r22, el valor (0,1) es devuelto en aux1)
getval:
MOV  r0,r20
CPI r22,8
BRSH getvalB
RJMP getvalA

getvalB:
CALL  getiob
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
MOV  r20,r0
RET

getvalA:
CALL  getioa
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
MOV  r22,r0
ADD r22,r20
RET

;Rutinas para generar RETardos a (20 mhz)
;10ms (7*0.0000005)(256)(26)=0.013seg
wait10:
MOV  r8,r20
MOV  r11,r21
LDI r20,26
RJMP wait10A

wait10A:
LDI r21,0xff
SUBI r20,1
BRNE wait10B
MOV  r20,r8
MOV  r21,r11
RET

wait10B:
SUBI r21,1
BREQ wait10A
RJMP wait10B

;20ms (7*0.0000005)(256)(26)=0.022seg
wait20:
MOV  r8,r20
MOV  r11,r21
LDI r20,26
RJMP wait20A

wait20A:
LDI r21,0xff
SUBI r20,1
BRNE wait20B
MOV  r20,r8
MOV  r21,r11
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
MOV  r8,r20
MOV  r11,r21
LDI r20,26
RJMP wait30A

wait30A:
LDI r21,0xff
SUBI r20,1
BRNE wait30B
MOV  r20,r8
MOV  r21,r11
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
MOV  r8,r20
MOV  r11,r21
LDI r20,26
RJMP wait40A

wait40A:
LDI r21,0xff
SUBI r20,1
BRNE wait40B
MOV  r20,r8
MOV  r21,r11
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

;rutinas de MOV imiento
izquierda:
MOV  r0,aux1
LDI aux1,0xf0
AND motores,aux1
LDI aux1,0x01
EOR motores,aux1
OUT portb,motores
CALL  wait20;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
MOV  aux1,r0
RET

derecha:
MOV  r0,aux1
LDI aux1,0xf0
AND motores,aux1
LDI aux1,0x04
EOR motores,aux1
OUT portb,motores
CALL  wait20;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
MOV  aux1,r0
RET

atras:
MOV  r0,aux1
LDI aux1,0xf0
AND motores,aux1
LDI aux1,0x0a
EOR motores,aux1
OUT portb,motores
CALL  wait20;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
MOV  aux1,r0
RET

adelante:
MOV  r0,aux1
LDI aux1,0xf0
AND motores,aux1
LDI aux1, 0x05
EOR motores,aux1
OUT portb,motores
CALL  wait20;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
MOV  aux1,r0
RET

parar:
MOV  r0,aux1
LDI aux1,0xf0
AND motores,aux1
OUT portb,motores
CALL  wait20;(usar siempre el menor tiempo de espera)
MOV  aux1,r0
RET
;*********
;fin

;inicio
Fase1:
CALL  seto
CALL  esperanto
RJMP fase2
;****
;acondicionamiento
Fase2:
CALL  flare
CALL  calcuerda
RJMP fase3
;****
;toma de DECisiones
fase3:
LDI aux5,0
CALL  cuerdaOUT
LDI aux5,0
CALL  RETrieve
RJMP check
RJMP stopit
;****

seto:;(esperar a que objeto este puesto)
CALL  getioa
CALL  getiob
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
MOV  r16,r19
MOV  r22,r16
CALL  getxy
MOV  r17,r20
MOV  r18,r21
RET

setstartB:
LDI r20,8
ADD r19,r20
MOV  r16,r19
MOV  r22,r16
CALL  getxy
MOV  r17,r20
MOV  r18,r21
RET

;rutina de espera.(RETrasa el carro 5.6 seg, 7,4 seg, 9,9 seg respectivamente)
;cada 22 o 29 o 39 milisegundos se va a revisar si algun borde se encendio
esperanto:
LDI r19,0xff
RJMP waitto

waitto:
CALL  wait20;cambiar aca cual se quiere si 20,30 o 40
DEC r19
CALL  getborfas
;com r4 ;suponiendo que las entradas de los bordes sean logica baja al igual que los sensores
SBRC r4,0 ;si el pin 0 NO es 0, salta, si lo es continua
RJMP setsecb
SBRC r4,1 ;si el pin 1 NO es 0, salta, si lo es continua
RJMP setseca
CPI r19,0
BREQ resolution
RJMP waitto

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
CALL  adelante
CALL  getbordes
LDI aux1,0x03
AND bordes,aux1
LDI aux1,0
CP bordes,aux1
BREQ sunless
LDI aux1,1
CP bordes, aux1
BREQ setsecA
RJMP setsecB 
RET

flare:
CALL  getioa
CALL  getiob
LDI aux1,0xff
CPSE sector,aux1
RJMP launch
CALL  sunless
RJMP launch

launch: ;MOV er hasta que: se encienda un borde vertical o se encienda un sensor.
CALL  adelante
;comprobar si algun sensor encendio en mi sector (solo revisa mi sector ya que asi evito falsos positivos con el rival)
LDI aux2,1 ;si estoy en b
CPSE sector,aux2
MOV  aux4,ioa
CPSE sector,aux2
CALL  getchanga
LDI aux2,0
CPSE sector,aux2
MOV  aux4,iob
CPSE sector,aux2
CALL  getchangb
LDI aux2,0xff
CPSE aux1,aux2
RJMP exting
;comprobar bordes... si empece en a, compiar el contenido del registro de bordes, negar el bit 0, comprobar si el registro es distinto de 0.
;					 si empece en b, compiar el contenido del registro de bordes, negar el bit 1, comprobar si el registro es distinto de 0.
; si el registro no es 0, ir a extingub. 
CALL  getbordes
;determinar si fueron los bordes o los sensores (que deberian conservar el valor que envio a extingue)
MOV  aux3,bordes
LDI aux2,0;si estoy en a
CP sector,aux2
BREQ bordea
RJMP bordeb

bordea:
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
LDI gir,0
RJMP extingue

setizq:
LDI gir,1
RJMP extingue

exting:
LDI aux2,0;si estoy en a
CP sector,aux2
BREQ extinga
LDI aux2,1
CP sector,aux2;si estoy en b
BREQ extingb

extinga:
MOV  aux4,aux1
CALL  getxy
CP objx,aux2
BRGE setizq
RJMP setder

extingb:
MOV  aux4,aux1
CALL  getxy
CP objx,aux2
BRGE setder
RJMP setizq

extingue:
CALL  atras
CALL  getbordes
MOV  aux3,bordes
MOV  aux1,sector
ANDI aux1,0x03
SBRC aux1,0
RJMP extb
SBRS aux1,0
RJMP exta
RJMP extingue

extb:
SBRC aux3,1
RET
RJMP extingue

exta:
SBRC aux3,0
RET
RJMP extingue

calcuerda:;si a cuerda=objy*2-1 
MOV  aux1,sector
MOV  aux3,objy
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
MOV  cuerda, aux4
LDI aux2,1
CPSE aux1,aux2;si estoy en sector a
MOV  cuerda,aux3
RET

;MOV er adelante por cuerda
cuerdaOUT:
LDI aux6,0
CP aux5,cuerda
BREQ RETurn
INC aux5
RJMP cuentpaso

RETrieve:
LDI aux6,0
CP aux5,cuerda
BREQ RETurn
INC aux5
RJMP cuentback

RETurn:
RET

cuentpaso:
CPI aux6,step
BREQ cuerdaOUT
CALL  adelante
INC aux6
RJMP cuentpaso

cuentback:
CPI aux6,step
BREQ RETrieve
CALL  atras
INC aux6
RJMP cuentback

check:
MOV  aux4, objn
CALL  getval
CPI aux1,0
BREQ stopit
CALL  planit
LDI aux2,1
CPSE gir,aux2
CALL  derechagir
LDI aux2,0
CPSE gir,aux2
CALL  izquiergir
JMP  fase3

stopit:
CALL  parar
RJMP stopit

;calcula cuanto girar, si 5,10,15,etc, guardando el numero de veces que girar 5 grados en el aux7.
planit:
LDI aux7,1
RET

derechagir:
LDI aux8,0
CPSE aux7,aux8
RJMP girder
RET

girder:
INC aux8
LDI aux3,giro
CPSE aux8,aux3
CALL  derecha
CPSE aux8,aux3
RJMP girder
DEC aux7
RJMP derechagir

izquiergir:
LDI aux8,0
CPSE aux7,aux8
RJMP girizq
RET

girizq:
INC aux8
LDI aux3,giro
CPSE aux8,aux3
CALL  izquierda
CPSE aux8,aux3
RJMP girizq
DEC aux7
RJMP izquiergir

;rutinas para delay de lecturas
getborfas:
in bordes,pinf
NOP 
in r12,pinf
CPSE bordes,r12
RJMP getbordes
RET

getioa:
in ioa,pinc
CALL  wait10
in r21,pinc
CPSE ioa,r12
RJMP getioa
RET

getiob:
in iob,pind
CALL  wait10
in r12,pind
CPSE iob,r12
RJMP getiob
RET

getbordes:
in bordes,pinf
CALL  wait10
in r12,pinf
CPSE bordes,r12
RJMP getbordes
RET

;********************************************


;**** mean while, in a parallel universe ****


;********************************************

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

;rutinas de MOVimiento

der45:
LDI aux1,0xf0
AND motores,aux1
LDI aux1,0x04
EOR motores,aux1
OUT portb,motores
LDI r19,20
CALL  waitto;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
RET

izq45:
LDI aux1,0xf0
AND motores,aux1
LDI aux1,0x01
EOR motores,aux1
OUT portb,motores
LDI r19,20
CALL  waitto;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
RET

SUBIndie:
LDI r23,40
LDI r28,35
CALL  izq45
ANDI sector,0x03
CPI sector,1
BREQ ssetsecB
RJMP ssetseca

SUBIndid:
LDI r23,40
LDI r28,35
CALL  der45
ANDI sector,0x03
CPI sector,1
BREQ ssetsecB
RJMP ssetseca

;esta rutina es la conexion entre cuerda y cuenta paso.
SUBIndi: 
LDI r23,40
LDI r28,35
ANDI sector,0x03
CPI sector,1
BREQ ssetsecB
RJMP ssetseca

ssetsecA:
LDI r27,0
RJMP stindia

ssetsecB:
LDI r27,1
RJMP stindib

;Deduce el sector de arranque, el sentido y setea el x y y del carro para cuando esta solo en la pista (INDIVIDUAL)
stindiAA:
CP r22,objn
BREQ RETt
CALL  getxy
MOV  r25,r20
MOV  r26,r21
POP r0
POP r0
JMP  deducir

RETt:
RET

stindiBB:
LDI r20,8
ADD r20,r22
CP r20,objn
BREQ RETt
MOV  r22,r20
CALL  getxy
MOV  r25,r20
MOV  r26,r21
POP r0
POP r0
JMP  deducir
;MOV er hasta encender una casilla dentro del tablero en mi sector

stindiA:
CALL  adelante
CALL  getioa
MOV  r25,r2
CPI r25,0
BREQ stindiA
LDI r22,0
SBRC r25,0
CALL  stindiAA
INC r22
SBRC r25,1
CALL  stindiAA
INC r22
SBRC r25,2
CALL  stindiAA
INC r22
SBRC r25,3
CALL  stindiAA
INC r22
SBRC r25,4
CALL  stindiAA
INC r22
SBRC r25,5
CALL  stindiAA
INC r22
SBRC r25,6
CALL  stindiAA
INC r22
SBRC r25,7
CALL  stindiAA
RJMP stindia

stindiB:
CALL  adelante
CALL  getiob
MOV  r30,r3
CPI r30,0
BREQ stindiB
LDI r22,0
SBRC r30,0
CALL  stindibb
INC r22
SBRC r30,1
CALL  stindibb
INC r22
SBRC r30,2
CALL  stindibb
INC r22
SBRC r30,3
CALL  stindibb
INC r22
SBRC r30,4
CALL  stindibb
INC r22
SBRC r30,5
CALL  stindibb
INC r22
SBRC r30,6
CALL  stindibb
INC r22
SBRC r30,7
CALL  stindibb
RJMP stindib

MOVerright:
BREQ RETre
RJMP MOVeright

RETre:
RET

turnleft:
CALL  pasoder
JMP  fordward

MOVerleft:
DEC r25
CPI r27,2
BREQ reverse
CPI r27,3
BREQ fordward
CPI r27,0
LDI r27,3
BREQ turnleft
JMP  turnright

GOBACK:
LDI r31,1
CPSE r24,r31
JMP  backA
JMP  backB

MOVeright:
INC r25
CPI r27,2
BREQ fordward
CPI r27,3
BREQ reverse
CPI r27,0
LDI r27,2
BREQ turnright
JMP  turnleft

RutSel:
CP r18,r26
BRLO MOVerdown
BRNE MOVerup
CP r17,r25
BRLO MOVerleft
CALL  MOVerright
MOV  r22,r16
CALL  getval
CPI r19,0
BREQ GOBACK
JMP  fordward

MOVerdown:
DEC r26
CPI r27,0
BREQ reverse
CPI r27,1
BREQ fordward
CPI r27,2
LDI r27,1
BREQ turnleft
JMP  turnright

reverse:
CALL  atras
JMP  reverse

fordward:
CALL  adelante
MOV  r22,r16
CALL  getval
CPI r19,0
BREQ GOBACK
MOV  r20,r25
MOV  r21,r26
CALL  getNxy
CALL  getval
CPI r19,1
BREQ deducir
JMP  fordward

turnright:
CALL  pasoizq
JMP  fordward

MOVerup:
INC r26
CPI r27,0
BREQ fordward
CPI r27,1
BREQ reverse
CPI r27,2
LDI r27,0
BREQ turnright
JMP  turnleft

deducir:
CALL  parar
MOV  r22,r16
CALL  getval
LDI r20,0
CPSE r19,r20
JMP  RutSel
JMP  GOBACK
;fin rutinas deducir

backA:
CALL  getbordes
MOV  r31,r4
SBRC r31,0
JMP  stopit
SBRS r27,1
CALL  atras
SBRS r27,1
RJMP backa
LDI r30,2
LDI r29,3
CPSE r27,r30
CALL  pasoizq
CPSE r27,r29
CALL  pasoder
LDI r27,0
RJMP backa

backB:
CALL  getbordes
MOV  r31,r4
SBRC r31,1
JMP  stopit
SBRS r27,1
CALL  atras
SBRS r27,1
RJMP backb
LDI r30,2
LDI r29,3
CPSE r27,r30
CALL  pasoder
CPSE r27,r29
CALL  pasoizq
LDI r27,1
RJMP backb

;rutinas de MOVimiento
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
;fin