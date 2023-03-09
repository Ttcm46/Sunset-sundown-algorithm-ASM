.code
ALIGN 16
Adder proc
	mov rax,rcx
	add eax,edx
	ret
Adder endp

t_fpu proc
	movss xmm0,dword ptr [rcx] 
	addss	xmm0	, dword ptr [rdx]
	movss dword ptr [rcx],xmm0
	ret
t_fpu endp
end	