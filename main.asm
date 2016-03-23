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
;r19 = aux 1 (return aux)
;r20 = aux 2
;r21 = aux 3
;r22 = aux 4 (N casilla en busqueda o N de la secuencia)
;r23 = cuerda (decimas de segundo, o multiplicador de decimas nescesarias para una distancia especifica) 
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

.equ step=25;un paso es el numero de veces que hay que repetir un delay corto (20 ms es lo mas adecuado) para generar un avance igual a 11.45cm (maxima inclinacion, a 45 grados es la medida del sector*1.437)
.equ giro=4;un giro es el numero de veces que hay que repetir un delay corto (20 ms es lo mas adecuado) para generar un desvio igual a 10 grados.

.cseg 
.include "usb1286def.inc"
.org 0000
ldi r19,0xff
out portc,r19
out portd,r19
out portf,r19
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
;determinar si un sector es rock. (si sector==a && objy<sensor.y) Es roca y devuelve un 0xff en aux1, sino, 00. N de sensor a buscar en aux4
isrocky:
mov aux1,sector
andi aux1,0x0f
ldi aux2,0
cpse aux1,aux2;si estoy en sector b
rjmp isroca
ldi aux2,1
cpse aux1,aux2;si estoy en sector a
rjmp isroco

isfall:
ldi aux2,0
cpse gir,aux2;si estoy a derecha
rjmp isfalla
ldi aux2,1
cpse gir,aux2;si estoy a izquierda
rjmp isfallo

isroca:
call getxy
cp aux3,objy
BRGE setis
rjmp notis

isroco:
call getxy
cp aux3,objy
BRGE notis
rjmp setis

setis:
ldi aux1,0xff
ret

notis:
ldi aux1,0
ret

;determinar si un sector es fall. (si gir==izq && objx>sensor.x) Es roca y devuelve un 0xff en aux1, sino, 00. N de sensor a buscar en aux4
isfalla:
call getxy
cp aux2,objx
BRGE notis
rjmp setis

isfallo:
call getxy
cp aux2,objx
BRGE setis
rjmp notis

cuerdaout:
ldi aux6,0
cp aux5,cuerda
breq setis
inc aux5
rjmp cuentpaso

retrieve:
ldi aux6,0
cp aux5,cuerda
breq setis
inc aux5
rjmp cuentback

cuentpaso:
cpi aux6,step
breq cuerdaout
call adelante
inc aux6
rjmp cuentpaso

cuentback:
cpi aux6,step
breq retrieve
call atras
inc aux6
rjmp cuentback

;detectar cambios en los sectores especificados
;el estado anterior del puerto a buscar debe estar guardado en aux4, el resultado sera escrito en aux1
;si no hay cambios, aux1 seria igual a 0xff
getchanga:
call getioa
mov aux2,ioa
eor aux2,aux4
ldi aux1,0
rjmp getchang

getchang:
SBRC aux2,0
ret
inc aux1
SBRC aux2,1
ret
inc aux1
SBRC aux2,2
ret
inc aux1
SBRC aux2,3
ret
inc aux1
SBRC aux2,4
ret
inc aux1
SBRC aux2,5
ret
inc aux1
SBRC aux2,6
ret
inc aux1
SBRC aux2,7
ret
ldi aux1,0xff
ret

getchangb:
call getiob
mov aux2,iob
eor aux2,aux4
ldi aux1,0
call getchang
ldi aux2,0xff
ldi aux5,8
cpse aux1,aux2
add aux1,aux5
ret

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
cpi r22,8
brsh getvalB
jmp getvalA

getvalB:
call getiob
ldi r20,8
ldi r19,0
SBRC r3,0
ldi r19,1
cp r22,r20
breq retgeval
inc r20
ldi r19,0
SBRC r3,1
ldi r19,1
cp r22,r20
breq retgeval
inc r20
ldi r19,0
SBRC r3,2
ldi r19,1
cp r22,r20
breq retgeval
inc r20
ldi r19,0
SBRC r3,3
ldi r19,1
cp r22,r20
breq retgeval
inc r20
ldi r19,0
SBRC r3,4
ldi r19,1
cp r22,r20
breq retgeval
inc r20
ldi r19,0
SBRC r3,5
ldi r19,1
cp r22,r20
breq retgeval
inc r20
ldi r19,0
SBRC r3,6
ldi r19,1
cp r22,r20
breq retgeval
ldi r19,0
SBRC r3,7
ldi r19,1
jmp retgeval
retgeval:
ret
getvalA:
call getioa
ldi r20,0
ldi r19,0
SBRC r2,0
ldi r19,1
cp r22,r20
breq retgeval
inc r20
ldi r19,0
SBRC r2,1
ldi r19,1
cp r22,r20
breq retgeval
inc r20
ldi r19,0
SBRC r2,2
ldi r19,1
cp r22,r20
breq retgeval
inc r20
ldi r19,0
SBRC r2,3
ldi r19,1
cp r22,r20
breq retgeval
inc r20
ldi r19,0
SBRC r2,4
ldi r19,1
cp r22,r20
breq retgeval
inc r20
ldi r19,0
SBRC r2,5
ldi r19,1
cp r22,r20
breq retgeval
inc r20
ldi r19,0
SBRC r2,6
ldi r19,1
cp r22,r20
breq retgeval
ldi r19,0
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

;Rutinas para generar retardos a (20 mhz)
;20ms (7*0.0000005)(256)(26)=0.022seg
wait20:
ldi r20,26
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
;30 (9*0.0000005)(256)(26)=0.029seg
wait30:
ldi r20,26
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
;40 (12(0.0000005))(256)(26)=0.039seg
wait40:
ldi r20,26
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
call wait20;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
ret

derecha:
ldi aux1,0xf0
and motores,aux1
ldi aux1,0x04
eor motores,aux1
out portb,motores
call wait20;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
ret

atras:
ldi aux1,0xf0
and motores,aux1
ldi aux1,0x0a
eor motores,aux1
out portb,motores
call wait20;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
ret

adelante:
ldi aux1,0xf0
and motores,aux1
ldi aux1, 0x05
eor motores,aux1
out portb,motores
call wait20;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
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
call calcuerda
rjmp fase3
;****
;toma de decisiones
fase3:
ldi aux5,0
call cuerdaout
ldi aux5,0
call retrieve
call check
rjmp fase3
;****

seto:;(iniciar puertos y )
call getioa
call getiob
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
call wait20;cambiar aca cual se quiere si 20,30 o 40
dec r19
call getborfas
;com r4 ;suponiendo que las entradas de los bordes sean logica baja al igual que los sensores
SBRC r4,0 ;si el pin 0 NO es 0, salta, si lo es continua
rjmp setsecb
sbrc r4,1 ;si el pin 1 NO es 0, salta, si lo es continua
rjmp setseca
cpi r19,0
breq resolution
rjmp waitto
setsecA:
ldi r24,0
ret
setsecB:
ldi r24,1
ret
;fin de rutina de espera
resolution:;(en caso de que algun otro carro TAMBIEN (malditos) este esperando o nosotros estemos solos)
ldi sector,0xff
ret ;(en caso de estar solos en la pista, simplemente sale y comienza a explorar)
;****

sunless:
call adelante
call getbordes
ldi aux1,0x03
and bordes,aux1
ldi aux1,0
cp bordes,aux1
breq sunless
ldi aux1,1
cp bordes, aux1
breq setsecA
rjmp setsecB 
ret

flare:
call getioa
call getiob
ldi aux1,0xff
cpse sector,aux1
rjmp launch
call sunless
rjmp launch

launch: ;mover hasta que: se encienda un borde vertical o se encienda un sensor.
call adelante
;comprobar si algun sensor encendio en mi sector (solo revisa mi sector ya que asi evito falsos positivos con el rival)
ldi aux2,1 ;si estoy en b
cpse sector,aux2
mov aux4,ioa
cpse sector,aux2
call getchanga
ldi aux2,0
cpse sector,aux2
mov aux4,iob
cpse sector,aux2
call getchangb
ldi aux2,0xff
cpse aux1,aux2
rjmp exting
;comprobar bordes... si empece en a, compiar el contenido del registro de bordes, negar el bit 0, comprobar si el registro es distinto de 0.
;					 si empece en b, compiar el contenido del registro de bordes, negar el bit 1, comprobar si el registro es distinto de 0.
; si el registro no es 0, ir a extingub. 
call getbordes
;determinar si fueron los bordes o los sensores (que deberian conservar el valor que envio a extingue)
mov aux3,bordes
ldi aux2,0;si estoy en a
cp sector,aux2
breq bordea
rjmp bordeb

bordea:
SBRC aux3,3
andi sector,0x0f;mirando derecha
SBRC aux3,3
rjmp setder
SBRC aux3,3
rjmp extingue
SBRC aux3,2
ori sector,0x80;mirando izquierda
SBRC aux3,2
rjmp setizq
SBRC aux3,2
rjmp extingue
rjmp launch
bordeb:
SBRC aux3,3
ori sector,0x80;mirando derecha
SBRC aux3,3
rjmp setder
SBRC aux3,3
rjmp extingue
SBRC aux3,2
andi sector,0x0f;mirando izquierda
SBRC aux3,2
rjmp setizq
SBRC aux3,2
rjmp extingue
rjmp launch

setder:
ldi gir,0
rjmp extingue
setizq:
ldi gir,1
rjmp extingue

exting:
ldi aux2,0;si estoy en a
cp sector,aux2
breq extinga
ldi aux2,1
cp sector,aux2;si estoy en b
breq extingb

extinga:
mov aux4,aux1
call getxy
cp objx,aux2
BRGE setizq
rjmp setder

extingb:
mov aux4,aux1
call getxy
cp objx,aux2
BRGE setder
rjmp setizq

extingue:
call atras
call getbordes
mov aux3,bordes
mov aux1,sector
andi aux1,0x03
sbrc aux1,0
rjmp extb
sbrs aux1,0
rjmp exta
rjmp extingue

extb:
sbrc aux3,1
ret
rjmp extingue
exta:
sbrc aux3,0
ret
rjmp extingue

calcuerda:;si a cuerda=objy*2-1 
mov aux1,sector
mov aux3,objy
inc aux3
ldi aux4,5
sub aux4,aux3
add aux4,aux4
dec aux4
add aux3,aux3
dec aux3
andi aux1,0x0f
ldi aux2,0
cpse aux1,aux2;si estoy en sector b
mov cuerda, aux4
ldi aux2,1
cpse aux1,aux2;si estoy en sector a
mov cuerda,aux3
ret

check:
mov aux4, objn
call getval
cpi aux1,0
breq stopit
call planit
ldi aux2,1
cpse gir,aux2
call derechagir
ldi aux2,0
cpse gir,aux2
call izquiergir
ret

stopit:
call parar
rjmp stopit

planit:;calcula cuanto girar, si 5,10,15,etc, guardando el numero de veces que girar 5 grados en el aux7.
ldi aux7,1
ret

derechagir:
ldi aux8,0
cpse aux7,aux8
rjmp girder
ret

girder:
inc aux8
ldi aux3,giro
cpse aux8,aux3
call derecha
cpse aux8,aux3
rjmp girder
dec aux7
rjmp derechagir

izquiergir:
ldi aux8,0
cpse aux7,aux8
rjmp girizq
ret

girizq:
inc aux8
ldi aux3,giro
cpse aux8,aux3
call izquierda
cpse aux8,aux3
rjmp girizq
dec aux7
rjmp izquiergir

;rutinas para delay de lecturas
getborfas:
in bordes,pinf
nop
in r7,pinf
cpse bordes,r7
rjmp getbordes
ret

getioa:
in ioa,pinc
call wait20
in r7,pinc
cpse ioa,r7
rjmp getioa
ret

getiob:
in iob,pind
call wait20
in r7,pind
cpse iob,r7
rjmp getiob
ret

getbordes:
in bordes,pinf
call wait20
in r7,pinf
cpse bordes,r7
rjmp getbordes
ret

