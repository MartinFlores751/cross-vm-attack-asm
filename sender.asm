; Executable Name : sender
; Version	  : 0.1a
; Created data	  : 2019-11-10
; Last Update	  : 2019-11-10
; Author	  : Martin Jaime Flores Jr.
; Description	  : A program that forces strict memory ordering to attempt to send a "high" bit by leaving artifacts in the execution pipeline for the receiver.
;
; Build using these commands:
;	nasm -f elf32 -gdwarf sender.asm
;	gcc sender.o -o sender
;

[SECTION .data]			; Section containing initialized data
	numLoops equ 100000	; Number of loops to perform

[SECTION .bss]			; Section containing uninitialized data
	randomData resd 1	; Some random data

[SECTION .text]			; Section containing code

global main			; Linker needs this to find the entry point!

main:
	push ebp
	mov ebp,esp
	push ebx
	push esi
	push edi

;;; Real code begins below

;;; Do a whole bunch of random stuff using mfence n stuff
	mov ecx,0

.loop:
	nop
	mov DWORD[randomData],1
	mfence
	mov eax,[randomData]
	nop

	nop
	mov DWORD[randomData],0
	mfence
	mov eax,[randomData]
	nop

	nop
	mov DWORD[randomData],1
	mfence
	mov eax,[randomData]
	nop

	nop
	mov DWORD[randomData],0
	mfence
	mov eax,[randomData]
	nop

	nop
	mov DWORD[randomData],1
	mfence
	mov eax,[randomData]
	nop

	nop
	mov DWORD[randomData],0
	mfence
	mov eax,[randomData]
	nop

	nop
	mov DWORD[randomData],1
	mfence
	mov eax,[randomData]
	nop

	nop
	mov DWORD[randomData],0
	mfence
	mov eax,[randomData]
	nop

	nop
	mov DWORD[randomData],1
	mfence
	mov eax,[randomData]
	nop

	nop
	mov DWORD[randomData],0
	mfence
	mov eax,[randomData]
	nop

	nop
	mov DWORD[randomData],1
	mfence
	mov eax,[randomData]
	nop

	nop
	mov DWORD[randomData],0
	mfence
	mov eax,[randomData]
	nop

	inc ecx
	cmp ecx,numLoops
	jne .loop
	
;;; Real code ends here
	pop edi
	pop esi
	pop ebx
	mov esp,ebp
	pop ebp
	ret
