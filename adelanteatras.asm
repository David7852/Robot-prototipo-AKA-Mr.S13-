.dseg
#define CPU_2MHz        0x03
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
.def rocka=r25
.def rockb=r26
.def falla=r27
.def fallb=r28
.def cua=r29
.def cub=r30
.def cuc=r31

.equ step=0x00
.equ giro=0x00

.cseg 
.org 0000

 start:
 ldi r19,0xff
 call waitto
 ldi aux3,0xff
 out ddrb,r3
 ldi aux3,0x03
 out ddrd,r3
 ldi aux3,0
 out portb,r3
 rjmp rutinatest

waitto:
call wait30;cambiar aca cual se quiere si 20,30 o 40
dec r19
cpi r19,0
brne waitto
ret

 rutinatest:
 in cua, pind
 andi cua,0x03
 ldi aux1,0
 cp cua,aux1
 breq adelante
 ldi aux1,3
 cp cua,aux1
 breq atras
 ldi aux1,1
 cp cua,aux1
 breq derecha
 rjmp izquierda

 ;rutinas de movimiento
izquierda:
ldi aux1,0xf0
and motores,aux1
ldi aux1,0x01
eor motores,aux1
out portb,motores
call wait30;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
rjmp rutinatest

derecha:
ldi aux1,0xf0
and motores,aux1
ldi aux1,0x04
eor motores,aux1
out portb,motores
call wait30;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
rjmp rutinatest

atras:
ldi aux1,0xf0
and motores,aux1
ldi aux1,0x0a
eor motores,aux1
out portb,motores
call wait30;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
rjmp rutinatest

adelante:
ldi aux1,0xf0
and motores,aux1
ldi aux1, 0x05
eor motores,aux1
out portb,motores
call wait30;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
rjmp rutinatest

parar:
ldi aux1,0xf0
and motores,aux1
out portb,motores
call wait20;(usar siempre el menor tiempo de espera)
rjmp rutinatest
;*********
;fin
 
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

