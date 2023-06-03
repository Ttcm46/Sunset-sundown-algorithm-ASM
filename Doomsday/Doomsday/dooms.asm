;extern "C" float sunRS(float lat, float lon, float zen, int dia, int mes, int anho,bool sunset);
.data	
;constantes

veinticuatro real4	24.0
noventa real4 90.0				;TODO: buscar todos los 90 y reemplazarlos con esta const
tresSesenta real4 360.0
quince real4 15.0
menosUno real4 -1.0
unoOchenta real4 180.0
	;contantes de el algoritmo como tal
toRads real4 0.01745329252
toDegs real4 57.29577951
smeanA real4 0.9856
smeanB real4 3.289
stLongA real4 1.916
stLongB real4 0.020	
stLongC real4 282.634
sRA real4 0.91764
sDA real4	0.39782
lmtA real4 0.06571
lmtB real4 6.622

;variables
actualDay dword 0
t real4 0.0
lngHour real4 0.0
M real4 0.0
L real4	0.0
RA real4 0.0
LQ dword 0		;enteros de 32 bits
RQ dword 0
sinDec real4 0.0
cosDec real4 0.0
cosH real4 0.0
H real4 0.0
Time real4 0.0
UT real4 0.0

lat real4 0.0
longitud real4 0.0
zenith real4 0.0

sunset db 0
sunRises db 0

;tmp
tmpD dword 0
tmpQ qword 0
tmpR4 real4 0.0

;codigo
.code
ALIGN 16

LoadArea proc		;inputs: ptr->lat;ptr->longl;ptr->zenith
	movss lat,xmm0
	movss longitud,xmm1
	movss zenith,xmm2

	ret
LoadArea endp

calculateDay proc	; inputs :; dia , mes anho ->enteros
	mov tmpQ,rdx
	mov rax,tmpQ
	mov ebx,0275d
	mul rbx	
	mov rbx,09d
	div rbx
	mov r9,rax

	mov rax,tmpQ	;parametro mes  a eax
	add	eax,9		;eax+9
	cdq				;si no se convuerte a qword el dword, la cosa crashea npi
	mov ebx,0Ch		;ebx = 12
	idiv ebx		;eax /12
	mov r10,rax

	mov tmpQ,r8;esta usa punteros pq usamos un mismo valor varias veces, enntonces para copiarlo directamente de la dir
	mov rax,tmpQ
	mov rbx,04d				;rbx = 4						;esto para que no crashee la cosa cuando divida, esta duplica el espacio que se acoupa en el registro 
	cdq	
	div rbx					;div rax /4
	mul	rbx					;mul rax solo el entero por 4
	mov rbx,rax				;pasamos a rbx lo que hay en rax 
	mov rax,tmpQ	;anho a rax
	sub rax,rbx				;anho - rbx
	add rax,02d				;sumamos 2 a rax
	cdq	
	mov rbx,03d				;rbx = 3
	idiv rbx					;rax / 3
	inc rax					;rax +1

	mul r10	
	sub r9,rax
	add r9,rcx
	sub r9,030d

	mov rax,r9

	mov actualDay,eax
	;mov eax,actualDay
	ret
calculateDay endp

lngHourCal proc	
	;movss xmm0,longitud
	xor rax,rax
	movss xmm0,	quince
	divss	xmm1,xmm0
	movss lngHour,xmm1

	mov al,sunset
	cmp al,01h
	jz snst

	mov rax,06d
	cvtsi2ss	xmm0,rax
	jmp cnt

	snst:
	mov rax,018d
	cvtsi2ss	xmm0,rax

	cnt:
	subss xmm0,xmm1
	movss xmm1,veinticuatro
	divss	xmm0,xmm1
	mov eax,actualDay
	cvtsi2ss xmm1,rax
	addss xmm0,xmm1
	movss t,xmm0
	ret	
lngHourCal endp

sunManom proc
	movss xmm0,t
	movss xmm1,smeanA
	mulss	xmm0,xmm1
	movss xmm1,smeanB
	subss xmm0,xmm1
	movss M,xmm0
	ret
sunManom ENDP	

sunsTrueLong proc	
	finit	
	;(0.020 * sin(2 * M))
	;deg a rad
	fld toRads	
	fld M	;cargar valor en deg
	fmul	;deg * factor de con = factor en rads
	fld1
	fld1	;2
	fadd	
	fmul	;2*M
	fsin	;sin(2*M)
	fld stLongB
	fmul	;0.020 *sin(2*M)
	fld toDegs	;a degs
	fmul
	
	;(1.916 * sin(M))
	fld toRads
	fld M
	fmul	
	fsin	;sin(M)
	fld stLongA
	fmul	;1.916 * sin(M)
	fld toDegs	;a degs
	fmul

	;M + (1.916 * sin(M)) + (0.020 * sin(2 * M)) + 282.634
	fld	M
	fld	stLongC

	fadd	
	fadd
	fadd	
	;ajustar en rango de 0 a 360
	compsSun:			;rev que 360 es la may
	fld tresSesenta
	fcom                             ;compare st0 with st1
    fstsw  ax                        ;ax := fpu status register
	fstp st(0)
    and    eax, 0100011100000000B ;take only condition code flags
    cmp    eax, 0000000000000000B ;is st0 > source ?
    je     sunsg			;360 es mayor
    cmp    eax, 0000000100000000B ;is st0 < source ?
    je     subTresS		;360 es menor
    cmp    eax, 0100000000000000B ;is st0 = source ?
    je     sunsg

	sunsg:			;rev que 0 es el menor
	fldz
	fcom                             ;compare st0 with st1
    fstsw  ax                        ;ax := fpu status register
	fstp st(0)
    and    eax, 0100011100000000B ;take only condition code flags
    cmp    eax, 0000000000000000B ;is st0 > source ?
    je     addTresS
    cmp    eax, 0000000100000000B ;is st0 < source ?
    je     doneSuns
    cmp    eax, 0100000000000000B ;is st0 = source ?
    je     doneSuns
    ;jmp    example_11_error      ;else, st0 or source are undefined

	addTresS:
	fld tresSesenta
	fadd	
	jmp compsSun

	subTresS:
	fld tresSesenta
	fsub 	
	jmp compsSun

	doneSuns:
	fstp L

	ret
sunsTrueLong endp


sunRightAsc proc

	finit	
	fld toRads
	fld L
	fmul	
	fcos
	fld toRads
	fld L
	fmul	
	fsin	
	fdiv st(0),st(1)
	fld	sRA
	fmul	
	fld1	
	fpatan
	fld toDegs
	fmul

	compsRight:			;rev que 360 es la may
	fld tresSesenta
	fcom                             ;compare st0 with st1
    fstsw  ax                        ;ax := fpu status register
	fstp st(0)
    and    eax, 0100011100000000B ;take only condition code flags
    cmp    eax, 0000000000000000B ;is st0 > source ?
    je     rightgR			;360 es mayor
    cmp    eax, 0000000100000000B ;is st0 < source ?
    je     subTresSR		;360 es menor
    cmp    eax, 0100000000000000B ;is st0 = source ?
    je     rightgR

	rightgR:			;rev que 0 es el menor
	fldz
	fcom                             ;compare st0 with st1
    fstsw  ax                        ;ax := fpu status register
	fstp st(0)
    and    eax, 0100011100000000B ;take only condition code flags
    cmp    eax, 0000000000000000B ;is st0 > source ?
    je     addTresSR
    cmp    eax, 0000000100000000B ;is st0 < source ?
    je     doneSunsR
    cmp    eax, 0100000000000000B ;is st0 = source ?
    je     doneSunsR
    ;jmp    example_11_error      ;else, st0 or source are undefined

	addTresSR:
	fld tresSesenta
	fadd	
	jmp compsRight

	subTresSR:
	fld tresSesenta
	fsub 	
	jmp compsRight

	doneSunsR:
	fstp RA
	ret
sunRightAsc endp

sunRightAscDos proc
	xor rax,rax
	movss xmm0,L
	movss xmm1,noventa
	divss xmm0,xmm1
	;redondear -> floor
	cvtss2si	eax,xmm0
	;esto se supone que es para seleccionar p donde redondear pero me da error y tengo suenho y sin usar esto me esta redondeando abajo :)
		;stmxcsr	tmpD	;p redondear podemos usar la serie de inst SSE con el "director" mxcsr y la inst cvt...
			; los bits 13 y 14 de mxcsr indican como rendondearemos: 00 para int mas cercano(default), 01 red abajo, 10 red arriba , 11 red hacia 0(truncar)
		;btr	tmpD,14		;resetear bit 14 a 0
		;bts	tmpD,13		;setear bit 13 a 1
		;mov tmpD,eax		;regresar para restaurar reg
		;ldmxcsr	tmpD		;restaurar reg mxcsr
		;roundps	
		;cvtss2si	eax,xmm0
	mov rbx,090d
	mul	bl
	mov LQ,eax		;Lquadrant  = (floor( L/90)) * 90
	mov rcx,rax	

	xor rax,rax
	movss xmm0,RA
	movss xmm1,noventa
	divss xmm0,xmm1
	cvtss2si	eax,xmm0
	mul bl
	mov RQ,eax	;RAquadrant = (floor(RA/90)) * 90

	;RA = RA + (Lquadrant - RAquadrant)
	cvtsi2ss	xmm0,rax
	cvtsi2ss	xmm1,rcx
	subss xmm0,xmm1	;(Lquadrant - RAquadrant)
	movss xmm1,RA
	addss xmm1,xmm0		;xmm1=RA
	;RA = RA / 15
	movss xmm0,quince
	divss xmm1,xmm0
	movss RA,xmm1

	ret
sunRightAscDos endp

sunsDeclin proc
	;sinDec = 0.39782 * sin(L)
	finit	
	fld L
	fld toRads	
	fmul	
	fsin	
	fld sDA
	fmul	
	fst cosDec		;guardamos esto aqui porque lo vamos a ocupar en rads para cosdedc, y aqui ya lo tenemos, nos ahorramos 2 insts
	fld toDegs
	fmul
	fstp sinDec
		;cos(arsin(x)) = \sqrt{ 1 - x^2}
	fld cosDec	;este es el pow
	fld cosDec
	fmul
	fld1		;1-x&^2
	fsub st(0),st(1)
	fsqrt	;\sqrt{ 1 - x^2}
	fld toDegs
	fmul
	fstp cosDec

	ret
sunsDeclin endp

sunsLocalHour proc
	finit
	;(cosDec * cos(latitude))
	fld lat
	fld toRads
	fmul	
	fcos
	fld toDegs
	fld cosDec
	fmul
	fmul	
	;(sinDec * sin(latitude)))
	fld lat
	fld toRads
	fmul
	fsin	
	fld sinDec
	fld toDegs 
	fmul
	fmul
	;cos(zenith)
	fld zenith
	fld toRads
	fmul
	fcos	
	fld toDegs
	fmul	
	fsub st(0),st(1)	;(cos(zenith) - (sinDec * sin(latitude)))
	fstp st(1)		;pop valor st(1)
	fdiv st(0),st(1);(cos(zenith) - (sinDec * sin(latitude))) / (cosDec * cos(latitude))

	fst cosH	;	cosH = (cos(zenith) - (sinDec * sin(latitude))) / (cosDec * cos(latitude))
	movss xmm0,cosH
	

	compsLoc:			;rev que 1 es la may
	fld1
	fcom                             ;compare st0 with st1
    fstsw  ax                        ;ax := fpu status register
	fstp st(0)
    and    eax, 0100011100000000B ;take only condition code flags
    cmp    eax, 0000000000000000B ;is st0 > source ?
    je     rightgRig			;360 es mayor
    cmp    eax, 0000000100000000B ;is st0 < source ?
    je     subRig		;360 es menor
    cmp    eax, 0100000000000000B ;is st0 = source ?
    je     rightgRig

	rightgRig:			;rev que -1 es el menor
	fld1
	fchs	
	fcom                             ;compare st0 with st1
    fstsw  ax                        ;ax := fpu status register
	fstp st(0)
    and    eax, 0100011100000000B ;take only condition code flags
    cmp    eax, 0000000000000000B ;is st0 > source ?
    je     addRig
    cmp    eax, 0000000100000000B ;is st0 < source ?
    je     doneSunsRig
    cmp    eax, 0100000000000000B ;is st0 = source ?
    je     doneSunsRig
    ;jmp    example_11_error      ;else, st0 or source are undefined

	addRig:
	mov al,00d
	mov sunRises,al
	jmp continue
	subRig:
	mov al,00d
	mov sunRises,al		
	jmp continue
	doneSunsRig:
	mov al,01d	

	continue:	
	finit		;compute acos=2atan(\frac{\sqrt{1-x^2}}{1+x})
	fld cosH
	fld toRads
	fmul
	fld1
	fmul st(0),st(1) ;duplicar cosH
	fmul			;;cosH^2		x^2
	fld1
	fsub	st(0),st(1)			;1-x^2
	fsqrt						;\sqrt{1-x^2}

	fld cosH
	fld toRads
	fmul	
	fld1
	fadd		;1+x
	fdiv st(0),st(1)			;\frac{\sqrt{1-x^2}}{1+x}
	fld1
	fpatan	
	mov al,sunset
	cmp al,01h
	jz sunRSNS

	fld tresSesenta
	fsub	st(0),st(1)

	sunRSNS:

	fld toDegs
	fmul	
	fst H
	fld quince
	fdiv st(1),st(0)
	fstp st(0)
	fstp H
	ret
sunsLocalHour endp
	
localMeantimeRiseSet proc
	finit
	fld H
	fld RA
	fld t
	fld lmtA
	fmul
	fld lmtB
	fsub
	fsub
	fadd	
	fstp Time
	ret
localMeantimeRiseSet endp

UTCAdjust proc
	finit
	fld Time
	fld lngHour
	fsub	
	;ajuste a rango de 0-24
	compsUTC:			;rev que 360 es la may
	fld veinticuatro
	fcom                             ;compare st0 with st1
    fstsw  ax                        ;ax := fpu status register
	fstp st(0)
    and    eax, 0100011100000000B ;take only condition code flags
    cmp    eax, 0000000000000000B ;is st0 > source ?
    je     rightUTC			;360 es mayor
    cmp    eax, 0000000100000000B ;is st0 < source ?
    je     subUTC		;360 es menor
    cmp    eax, 0100000000000000B ;is st0 = source ?
    je     rightUTC

	rightUTC:			;rev que 0 es el menor
	fldz
	fcom                             ;compare st0 with st1
    fstsw  ax                        ;ax := fpu status register
	fstp st(0)
    and    eax, 0100011100000000B ;take only condition code flags
    cmp    eax, 0000000000000000B ;is st0 > source ?
    je     addUTC
    cmp    eax, 0000000100000000B ;is st0 < source ?
    je     doneUTC
    cmp    eax, 0100000000000000B ;is st0 = source ?
    je     doneUTC
    ;jmp    example_11_error      ;else, st0 or source are undefined

	addUTC:
	fld veinticuatro
	fadd	
	jmp compsUTC

	subUTC:
	fld veinticuatro
	fsub 	
	jmp compsUTC
	doneUTC:
	fstp UT
	ret
UTCAdjust endp

UTToLocalTime proc
	movss xmm0,UT
	movss xmm1,longitud
	movss xmm2,quince
	divss xmm1,xmm2
	roundss	xmm1,xmm1,00B				;https://www.felixcloutier.com/x86/roundpd#fig-4-24 revisar tabla pra modos de redondeo
	addss xmm0,xmm1
	ret	
UTToLocalTime endp

sunRS proc
;carga de datos necesarios
	;mov eax,[ebp+8]
	call	LoadArea	

	;sacar paramentros restantes de stack
	push rbp
	mov rbp,rsp	;rsp apunta a stack
	mov rax,[rbp+48]	;prim er valor esta en [6] del stack			hay que saltar el shadow stack(seguridad) y otros valores que la convencion pushea   posicion*cant de bytes(8)
	and rax,011111111b		;=and para solo sacar el valor
	mov rdx,rax
	mov	rax,[rbp+56]	;seg valor esta en [7] ddel stack
	and rax,01111111111111111b		;and para solo sacar el valor
	mov r8,rax	
	mov	rax,[rbp+64]	;seg valor esta en [8] ddel stack
	and rax,0001b		;and para solo sacar el valor
	mov sunset,al
	mov rcx	,r9


	;calc dia
	call	calculateDay
	;algoritmo
	call lngHourCal
	call sunManom	
	call sunsTrueLong		
	call sunRightAsc
	call sunRightAscDos
	call sunsDeclin
	call sunsLocalHour
	call localMeantimeRiseSet		
	call UTCAdjust
	call UTToLocalTime
	pop rbp ;restaurar rbp
	ret	
sunRS endp
end	