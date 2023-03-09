.code
ALIGN 16
Adder proc
	mov rax,rcx
	add eax,edx
	ret
Adder endp

t_fpu proc
	movss xmm0,dword ptr [rcx]		;mover un valor Scalar-Single precision floating point unit con dir en rcx a el registro de 128bits para la fpu(xmm0)
	addss	xmm0	, dword ptr [rdx]
	movss dword ptr [rcx],xmm0
	ret
t_fpu endp
end	