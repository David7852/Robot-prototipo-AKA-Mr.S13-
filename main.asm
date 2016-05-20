.dseg
#define CPU_2MHz        0x03
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
 in r16,pind
 andi r16,0x0f
 cpi r16,0
 breq rutinatest
 in r16,pind
 ldi r17,2
 cpi r16,1
 breq ade
 in r16,pind
 ldi r17,3
 cpi r16,2
 breq ade
 in r16,pind
 ldi r17,4
 cpi r16,4
 breq ade
 in r16,pind
 ldi r17,5
 cpi r16,8
 breq ade
 rjmp rutinatest
 
 ade:
 mov objx,r17

 adel:
 dec r17
 ldi r19,42
 cpse r18,r17
 rjmp adeladel
 rjmp stop

 adeladel:
 call derecha
 dec r19
 cpi r19,0
 breq adel
 rjmp adeladel

 stop:
 call parar
 mov r17,objx
 in r16,pind
 andi r16,0x0f
 cpi r16,0
 breq atra
 rjmp stop

 atra:
 dec r17
 ldi r19,42
 cpse r18,r17
 rjmp atraatra
 rjmp rutinatest

 atraatra:
 call izquierda
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
