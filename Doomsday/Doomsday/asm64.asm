;no se usa ninguna variable global porque no encontramos la manera de que fueran aceptadas, todo esta en un contexto "global" de este archivo


;__________Info importante para leer la documentacion_______________
		;  x  -''  y     significa a x le asignamos y, usariamos flechita pero el compilador no leagradan las flechitas en los comentarios
		;  x  -''  *y 	 significa que a x le asignamos el contenido de lo que apunta y

.data	
;aqui se declaran constantes de numeros flotantes con valores despues de el punto decimal, el compilador no deja hacerlos en linea como con words enteros eg 8
noventa real4 90.0				;TODO: buscar todos los 90 y reemplazarlos con esta const
tresSesenta real4 360.0
quince real4 15.0

smeanA real4 0.9856
smeanB real4 3.289

stLongA real4 1.916
stLongB real4 0.020
stLongC real4 282.634

sRA real4 0.91764

sDA real4	0.39782

lmtA real4 0.06571
lmtB real4 6.622

;variable temporal para algunos procesos 
tmps real4 0.0
tmpsB real4  0.0
tmpsC real4  0.0
;variables locales para almacenar direcciones de memoria para asaiganr a direfentes variables
tmpPtr qword 0
tmpPtr2 qword 0
tmpPtr3 qword 0


;variables generales que se usan atravez de todo el programa,		TODO: involucrarlas para no tener que estar usando punteros
time real4 0.0
lngHour real4 0.0
RA real4 0.0
locHour real4 0.0
TimeBig real4 0.0
UT real4 0.0

.code
ALIGN 16

t_fpu proc
	mov tmpPtr,rcx
	finit
	movss xmm0, dword ptr[rcx]
	movss tmps,xmm0
	fld tmps
	fld1
	fpatan
	fst tmps
	movss xmm0,tmps
	movss dword ptr[rcx],xmm0
	mov rax,080d
	mov tmpTest,rax

	ret
t_fpu endp
		;Optimizar todo estos n para conseguir el dia
nf1 proc
	mov rax,rcx			;mover dato a rax
	mov rbx,0275d
	mul rbx				;multiplicar por 275
	mov rbx,09d
	div	rbx				;dividir entre 9
	ret					;valor de regreso en rax
nf1 endp	

nf2 proc 
	xor rax,rax		;limpiar rax
	mov eax,ecx		;parametro 1  a eax
	add	eax,9		;eax+9
	cdq				;si no se convuerte a qword el dword, la cosa crashea npi
	mov ebx,0Ch		;ebx = 12
	idiv ebx		;eax /12
	ret			
nf2 endp

nf3 proc
	mov eax,dword ptr[rcx]	;esta usa punteros pq usamos un mismo valor varias veces, enntonces para copiarlo directamente de la dir
	mov rbx,04d				;rbx = 4
	cdq						;esto para que no crashee la cosa cuando divida, esta duplica el espacio que se acoupa en el registro 
	div rbx					;div rax /4
	mul	rbx					;mul rax solo el entero por 4
	mov rbx,rax				;pasamos a rbx lo que hay en rax 
	mov eax,dword ptr[rcx]	;anho a rax
	sub rax,rbx				;anho - rbx
	add rax,02d				;sumamos 2 a rax
	mov rbx,03d				;rbx = 3
	div rbx					;rax / 3
	inc rax					;rax +1
	ret
nf3 endp	

nfin proc
	mov eax,edx				;mov parametro 2 a eax
	mul r8					;mul eax por par 3 (r8)
	mov ebx,eax				;movemos  a ebx el con de eax
	mov eax,ecx				;movemos a eax el parametro 1
	sub eax,ebx				;restamos eax -ebx
	mov rbx,r9				;movemos a rbx el parametro 4
	add eax,ebx				;sumamos eax + ebx
	sub eax,030d			;-30
	ret						;regreso, muy importante poner si no la cosa se traba, llevo 1 h intentando saber porque chrasheaba esta funcion y todo porque se me olvido esta linea :(
nfin endp

lngHourP proc				;TODO: comentar/documentar
	mov eax,015d
	cvtsi2ss	xmm1,rax
	movss	xmm0,dword ptr[rdx]	
	divss	xmm0,xmm1
	movss lngHour,xmm0
	cmp		r8,01d
	jz		sunrise

	sunset:
	mov		eax,018d
	jmp		here

	sunrise:
	mov		eax,06d

	here:
	cvtsi2ss xmm1,rax
	subss	 xmm1,xmm0	
	movss	 xmm0,xmm1	
	mov		 eax,024d
	cvtsi2ss xmm1,rax
	divss	 xmm0,xmm1
	cvtsi2ss xmm1,rcx
	addss	 xmm0,xmm1
	movss time,xmm0
	movss xmm0,time
	movss	 dword ptr[r9],xmm0	
	ret
lngHourP endp

anomPromSol proc 
	movss		xmm1,smeanA
	movss		xmm0, dword ptr [rcx]
	mulss		xmm0,xmm1
	movss		xmm1,smeanB
	subss		xmm0,xmm1
	movss		dword ptr [rdx],xmm0
	ret
anomPromSol endp

suntLong proc			;L = M + (1.916 * sin(M)) + (0.020 * sin(2 * M)) + 282.634				TODO:optimizar		TEST:
	mov tmpPtr,rcx		;salvamos direccion de puntero de M
	mov rcx,tmpPtr		;movemos a ecx la direccion
	;proceso de (1.916 * sin(M))
	movss xmm0,dword ptr [rcx]		;movemos a ammo el contenido de ecx
	movss tmps,xmm0					;movemos a tmps el cpntenido de xmm0, estos movimientos porque no podemos mover directamente a tmps
	finit							;inicializacion/purga de fpu para que este en 0's
	fld tmps						;push a stack de fpu de tmps
	fsin							;sin
	fst	tmps						;guardado de resultado en tmps
	movss xmm0,tmps					;movemos el resultado a xmm0
	movss xmm1,stLongA				;xmm1 -'' stlongA
	mulss xmm0,xmm1					;xmm0 * xmm1
	movss xmm2,xmm0					;xmm2 -'' xmm0			resultado de (1.916 * sin(M)) en xmm2
	;(0.020 * sin(2 * M))
	finit 							;inicializacion/purga de fpu para que este en 0's
	movss xmm0,dword ptr [rcx]		;xmm0 -'' *rcx
	mov rax,02d						;rax -'' 2
	cvtsi2ss	xmm1,rax			;xmm1 -'' rax pero en un formato de signle point precision scalar floating point
	mulss xmm0,xmm1					;xmm0 * xmm1		M*2
	movss tmps,xmm0					;tmps -'' xmm0		valor se guada en tmps				CHECK: redundante/paso extra innecesario?
	fld tmps						;carga de valor a fpu
	fsin							;sin de valor
	fst	tmps						;guardamos valor a tmps
	movss xmm0,stLongB				;xmm0 -'' stLongB
	movss xmm1,tmps					;xmm1 -''  tmps
	mulss xmm0,xmm1					;xmm0 * xmm1
	;(1.916 * sin(M)) + (0.020 * sin(2 * M))			sumas
	addss xmm0,xmm2					;xmm0 + xmm2
	;+m
	movss xmm1,dword ptr [rcx]		;xmm1 -'' *rcx
	;+stLongC					
	movss xmm2,stLongC
	;en este momento lo contenido en los registros xmm es:
	;											xmm0:(1.916 * sin(M)) + (0.020 * sin(2 * M))
	;											xmm1:M
	;											xmm2:StlongC(282.634)
	addss xmm0,xmm1
	addss xmm0,xmm2
	movss dword ptr [rcx],xmm0
	ret					;devolvemos en el puntero que nos dieron el resultado, sobreescribimos M
suntLong endp

sunRAsc proc								; DONE: tests pasados
	mov tmpPtr,rcx
	mov tmpPtr2,rdx
	movss xmm0,dword ptr [rcx]
	movss tmps,xmm0
	finit
	fld tmps
	fsin
	fld sRA
	fmul
	fld1		;cargamos la constante 1 porque para hacer atan, se hacer stan(st(1)/st(0))
	fpatan
	comparaciones:
	fld tresSesenta
	fcom						;valor debe de estar en [0,360]
	fstsw  ax
	and    eax, 0100011100000000B ;solo banderas de condicion
	cmp    eax, 0000000000000000B ; st0(360) > val 
    je     smaller
	cmp    eax, 0000000100000000B ;is 360 < source 
    je     greater

	greater:			
	fsub	st(0),st(1)			;valor -360 para meterlo en el rango de[0,360]
	jmp comparaciones
	smaller:
	fstp st(0)		;ocupamos popear s a 360 del stack, usamos la variable descartable tmpsC
	fldz
	fcom
	fstsw  ax
	and    eax, 0100011100000000B ;solo banderas de condicion
	cmp    eax, 0000000100000000B ;is 0 < source ?
    je inRange							;saltamos a done si el valor se mayor a 0
	cmp    eax, 0000000000000000B ; st0(0) > val ?
	fstp st(0)				;pop de valor
	fld tresSesenta			;cargamos 360
	fadd					;sumamos 360 para meterlo en el rango de [0,360]
	jmp comparaciones
	inRange:
	fstp st(0)
	fst tmps	
	;Lquadrant  = (floor( L/90)) * 90
	movss xmm1,noventa
	movss xmm0,dword ptr [rcx]
	divss xmm0,xmm1
	movss xmm1,noventa
	mulss xmm0,xmm1
	movss xmm0,tmpsB
	movss xmm1,noventa
	;RAquadrant = (floor(RA/90)) * 90
	movss xmm0,tmps
	divss xmm0,xmm1
	movss xmm1,noventa
	mulss xmm0,xmm1
	;RA = RA + (Lquadrant - RAquadrant)
	movss xmm0,tmpsC
	movss xmm1,tmpsC
	movss xmm0,tmpsB
	subss xmm0,xmm1
	movss xmm1,tmps
	addss xmm0,xmm1
	;RA = RA / 15
	movss xmm1,quince
	divss xmm0,xmm1
	movss RA,xmm0
	mov rax,tmpPtr2
	movss dword ptr [rax],xmm0
	;movss xmm0,tmpsB
	;movss dword ptr [rcx],xmm0
	ret
sunRAsc endp

sunsDeclination proc					;TEST: 
	mov tmpPtr,rcx					;remover?
	mov tmpPtr2,rdx
	mov tmpPtr3,r8
	movss xmm0,dword ptr [rcx]		;movemos a ammo el contenido de ecx
	movss tmps,xmm0					;movemos a tmps el cpntenido de xmm0, estos movimientos porque no podemos mover directamente a tmps
	finit							;inicializacion/purga de fpu para que este en 0's
	;sinDec = 0.39782 * sin(L)
	fld	tmps
	fsin
	fld sDA
	fmul
	fst	tmps
	movss xmm0,tmps
	mov rax,tmpPtr3
	movss dword ptr [rax],xmm0
	;z=tmps=sinDec
	;cosDec = cos(asin(sinDec))
		;asin(z) = atan( z / (sqrt((1-z)*(1+z)) ) = atan(Y/X) 
		;1+z
		fld1
		fadd	
		;1-z
		fld tmps
		fld1
		fsub
		;(1-z)*(1+z)
		fmul	
		;(sqrt((1-z)*(1+z))
		fsqrt
		;z / (sqrt((1-z)*(1+z))
		fld tmps
		fdiv	
		;atan( z / (sqrt((1-z)*(1+z)) )
		fld1
		fpatan	
		fcos	
		fst tmpsB	; tmpsB-''cosDec
	mov rcx,tmpPtr2



	ret
sunsDeclination endp

sunLhourAng proc
	
	ret
sunLhourAng endp

hToHour proc
	
	ret
hToHour endp

localMeanT proc

	ret
localMeanT endp

utcAdj proc

	ret
utcAdj endp

locUtcAdj proc

	ret
locUtcAdj endp

end	