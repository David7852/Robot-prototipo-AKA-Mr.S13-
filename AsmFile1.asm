/*
 * AsmFile1.asm
 *
 *  Created: 2/4/2016 4:51:59 PM
 *   Author: David
 */
.cseg 
.org 1000

 start:
 ldi r3,0xff
 out ddrf,r3
 out ddrb,r3
 ldi r3,0
 out ddrd,r3
 out portf,r3
 out portb,r3

 rutinatest:
 in r3, pind
 cpi r3,0
 breq onb ;si 0 b enciende
 rjmp onf ;sino, f enciende

 onb:
 ldi r3,0xff
 out portb,r3
 ldi r3,0
 out portf,r3
 rjmp rutinatest
 
 onf:
 ldi r3,0xff
 out portf,r3
 ldi r3,0
 out portb,r3
 rjmp rutinatest
