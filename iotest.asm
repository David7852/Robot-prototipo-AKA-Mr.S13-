
.dseg
.def ioa=r2
.def iob=r3
.def bordes=r4
.def motores=r5

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