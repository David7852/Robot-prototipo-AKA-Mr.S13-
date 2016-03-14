.dseg
.def ioa=r2
.def iob=r3
.def bordes=r4
.def motores=r5
.def angle=r6

.def objn=r16
.def objx=r10
.def objy=r18
.def aux1=r25		             
.def aux2=r26
.def aux3=r27
.def aux4=r28

.equ step=0x00
.equ giro=0x00

.cseg 
.include "usb1286def.inc"
.org 0000

 start:

 ldi r18,0xff
 out ddrb,r18
 out portd,r18
 ldi r18,0x00
 out ddrd,r18
 out portb,r18
 out portb,r18
 rjmp rutinatest

waitto:
call wait20;cambiar aca cual se quiere si 20,30 o 40
dec r19
cpi r19,0
brne waitto
ret

 rutinatest:
 out portb,r18
 ldi r17,0
 call getiob
 mov r16,r3
 andi r16,0xf0
 cpi r16,0
 breq rutinatest
 call getiob
 mov r16,r3
 andi r16,0xf0
 ldi r17,2
 cpi r16,0x10
 breq ade
 call getiob
 mov r16,r3
 andi r16,0xf0
 ldi r17,3
 cpi r16,0x20
 breq ade
 call getiob
 mov r16,r3
 andi r16,0xf0
 ldi r17,4
 cpi r16,0x40
 breq ade
 call getiob
 mov r16,r3
 andi r16,0xf0
 ldi r17,5
 cpi r16,0x80
 breq ade
 rjmp rutinatest
 
 ade:
 mov objx,r17

 adel:
 dec r17
 ldi r19,36
 cpse r18,r17
 rjmp adeladel
 rjmp stop

 adeladel:
 call adelante
 dec r19
 cpi r19,0
 breq adel
 rjmp adeladel

 stop:
 call parar
 mov r17,objx
 call getiob
 mov r16,r3
 andi r16,0xf0
 cpi r16,0
 breq atra
 rjmp stop

 atra:
 dec r17
 ldi r19,36
 cpse r18,r17
 rjmp atraatra
 rjmp rutinatest

 atraatra:
 call atras
 dec r19
 cpi r19,0
 breq atra
 rjmp atraatra
  
;rutinas de movimiento
izquierda:
ldi aux1,0xf0
and motores,aux1
ldi aux1,0x01
eor motores,aux1
out portb,motores
call wait20;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
ret

;izquierda:
;ldi aux1,0xf0
;and motores,aux1
;ldi aux1,0x09
;eor motores,aux1
;out portb,motores
;call wait20;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
;ret

derecha:
ldi aux1,0xf0
and motores,aux1
ldi aux1,0x04
eor motores,aux1
out portb,motores
call wait20;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
ret

;derecha:
;ldi aux1,0xf0
;and motores,aux1
;ldi aux1,0x06
;eor motores,aux1
;out portb,motores
;call wait20;(si se requiere un ajuste mas fino, usar 20ms, si 30 no alcanza usar 40ms)
;ret


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


getioa:
in ioa,pinc
call wait20
in r5,pinc
cpse ioa,r5
rjmp getioa
ret

getiob:
in iob,pind
call wait20
in r5,pind
cpse iob,r5
rjmp getiob
ret

getbordes:
in bordes,pinf
call wait20
in r5,pinf
cpse bordes,r5
rjmp getbordes
ret