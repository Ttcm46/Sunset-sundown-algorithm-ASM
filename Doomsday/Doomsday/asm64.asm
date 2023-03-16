;.model flat, stdcall
;no se usa ninguna variable global porque no encontramos la manera de que fueran aceptadas
.code
ALIGN 16
Adder proc
	mov rax,rcx
	add eax,edx
	ret
Adder endp

t_fpu proc
	finit										;iniciacion de fpu(no se ocupa, solo limpia los registros, pero por precaucion usar)
	movss xmm0,dword ptr[rcx]					;mover un valor Scalar-Single precision floating point unit con dir en rcx a el registro de 128bits para la fpu(xmm0); el dword ptr es para apuntar a el contenido, se supone que la mem ya esta reservada pero la cosa no compila si no se ponen  
	addss	xmm0	, dword ptr [rdx]			;sumar un FPUnit con otro apuntado por la direccion contenida en rdx
	movss dword ptr [rcx],xmm0					;mover a la direccion contenida en rcx el resultado de la suma, este se encuentra en xmm0(128bits)
	jmp hola

	hola:
	ret
	
t_fpu endp

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
	mov eax,edx
	mul r8
	sub eax,ecx
	mov rbx,r9
	add eax,ebx				
	sub eax,030d			;-30
	ret						;regreso, muy importante poner si no la cosa se traba, llevo 1 h intentando saber porque chrasheaba esta funcion y todo porque se me olvido esta linea :(
nfin endp
end	