;.model flat, stdcall
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

n1 proc
	mov rax,rcx			;mover dato a rax
	mov rbx,0275d
	mul rbx		;multiplicar por 275
	mov rbx,09d
	div	rbx			;dividir entre 9
	ret					;valor de regreso en rax
n1 endp	

n2 proc 
	mov rax,rcx
	add	rax,09d
	mov rbx,012d
	div	rbx
	ret
n2 endp

n3 proc
	mov eax,dword ptr[rcx]	;esta usa punteros pq usamos un mismo valor varias veces, enntonces para copiarlo directamente de la dir
	mov rbx,04d
	div rbx
	mov rbx,04d
	mul	rbx
	mov rbx,rax
	mov eax,dword ptr[rcx]
	sub rax,rbx
	add rax,02d
	mov rbx,03d
	div rbx
	inc rax
	ret
n3 endp	

nfin proc
	mov rax,rdx
	mul r8
	sub rax,rcx
	add rax,r10
	sub rax,030d
nfin endp
end	