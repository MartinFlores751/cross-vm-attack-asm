; Executable Name : reciever
; Version	  : 0.1a
; Created Date	  : 2019-11-10
; Last Update	  : 2019-11-13
; Author	  : Martin Jaime Flores Jr.
; Description	  : A program that will recieve some data from the sender
;
; BEWARE: This is an x86 program ONLY! I've yet to (figure out) make a x86_64 version!
;
; Build using these commands:
;	nasm -f elf32 -gdwarf reciever.asm
;	gcc -m32 -lpthread reciever.o -o reciever
;

[SECTION .data]						; Section containing initialized data	
	printBit   db 'Bit recived is: %u',10,0		; String to print the bit received
	printSum   db 'Sum is: %u',10,0			; Prints sum of OoOEs that occured
	numFrames equ      8				; Number of time frames/Number of bits to receive
	numIter   equ   1000				; Number or iterations per time frame
	numPass   equ    500				; Number of 'positives' needed to count as 'high' bit
	varA	   dd      0				; The data to load and save to for thread 1
	varB	   dd      0				; The data to load and save to for thread 2

[SECTION .bss]			; Section contianing uninitialized data
	sumIters    resd 1	; The sumation of OoOE
	pThreadID1  resd 1 	; The thread id of thread 1
	pThreadID2  resd 1	; The thread id of thread 2
	res1	    resd 1	; Results of thread 1
	res2	    resd 1	; Results of thread 2
	
[SECTION .text]			; Section contianing code

EXTERN pthread_create		; Import pthread_create from pthread lib
EXTERN pthread_join		; Import pthread_join from pthread lib
EXTERN printf			; Import printf
		
;---------------------------------------------------------------------------------
; ReceiveBit:	Retrives a bit of information
; UPDATED:	2019-11-12
; IN:		Nothing
; RETURNS:	Bit read
; MODIFIES:	All but ECX
; CALLS:	pthread pthread_create
;		pthread pthread_join
; DESCRIPTION:	Creates two threads and does a short computation to determine the
;		bit sent by 'sender'.

ReceiveBit:
	push ecx			; Save caller's ecx register
;;; Procedure code begins now

	mov DWORD[sumIters],0		; Initialize sumIters to 0
	mov ecx,0			; Current Iteration starts at 0

.readBit:	
	push ecx			; Save ecx register
;;; Set the variables and registers to zero!
	mov DWORD[varA],0		; Set varA to zero
	mov eax,0			; Set eax to zero
	mov DWORD[varB],0		; Set varB to zero

;;; Call the parallel function
	push 0				; Push NULL for *arg
	push Parallel2			; Push Parallel proc addr
	push 0				; Push NULL for pthread_attr_t
	push pThreadID2			; Push the *thread

	push 0				; Push NULL for *arg
	push Parallel			; Push Parallel proc addr
	push 0				; Push NULL for pthread_attr_t
	push pThreadID1			; Push the *thread

	call pthread_create		; Create thread 1
	add esp,16			; Clean the stack of thread 1 args
	call pthread_create		; Create thread 2
	add esp,16			; Clean the stack of thread 2 args

;;; Join both threads
	push res1			; Push NULL for **retval
	push DWORD[pThreadID1]		; Push thread ID 1
	call pthread_join		; Join thread 1
	add esp,8			; Clean the stack by adding 8 bytes

	push res2			; Push NULL for **retval
	push DWORD[pThreadID2]		; Push thread ID 2
	call pthread_join		; Join thread 2
	add esp,8			; Clean the stack by adding 8 bytes

;;; Compare return values
	movzx eax,WORD[res1]		; Load the value returned by thread 1
	cmp eax,0			; Check if eax is 0
	jne .loopUpdate			; Begin counting next loop in not equal

	movzx eax,WORD[res2]		; Load the value returned by thread 2
	cmp eax,0			; Check if eax is 0
	jne .loopUpdate			; Begin counting next loop if not equal

	inc DWORD[sumIters]		; Implies OoOE occurred!
	
;;; Perform loop update
.loopUpdate:
	pop ecx				; Restore the value of ecx
	inc ecx				; Increment current iter by 1
	cmp ecx,numIter			; Compare the current iter to set max iters
	jne .readBit			; Check if equal

;;; DEBUG: print the number of iters
	push DWORD[sumIters]		; Push the number of iters
	push printSum			; Print format for the sum of OoOEs that occured
	call printf			; Print the sum of OoOEs that occured
	add esp,8			; Clear the stack

;;; Check if sum reached threshold
	mov eax,[sumIters]		; Move sumIters into eax
	cmp eax,numPass			; Compare with amount needed to count as high
	jb .setLow			; If eax < numPass, set as low bit

.setHigh:
	mov eax,1			; Return 'high' bit
	pop ecx
	ret				; Might all well ret right here
	
.setLow:
	mov eax,0			; Return 'low' bit

;;; Procedure code ends here
	pop ecx				; Restore caller's ecx register
	ret				; Return to caller

;-----------------------------------------------------------------------------------------
; Parallel:	Does a small computation
; UPDATED:	2019-11-10
; IN:		Nothing
; RETURNS:	Nothing
; MODIFIES:	Nothing
; CALLS:	Nothing
; DESCRIPTION:	Loads 1 into memory and then loads the memory into selected register.
;

Parallel:
;;; Parallel might not work due to both functions using EAX and not different registers...
	%rep 90
	nop			; A series of nops since this executes before the other thread
	%endrep
	mov DWORD[varA],1	; Store 1 into varA
	mov eax,[varB]		; Load varB into eax
	ret			; Return to caller

;------------------------------------------------------------------------------------------
; Parallel2:	Does a small computation
; UPDATED:	2019-11-10
; IN:		Nothing
; RETURNS:	Whatever is in EAX
; MODIFIES:	EAX
; CALLS:	Nothing
; Description:	A hacky way of having Parallel acessing different areas of memory. This can
;		be fixed once I learn how to access a passed variable...
;

Parallel2:
;;; Parallel might not work due to both functions using EAX and not different registers...
	mov DWORD[varB],1	; Store 1 into varB
	mov eax,[varA]		; Load varA into eax
	ret			; Return to caller


GLOBAL main

;---------------------------------------------------------------------------------------------
; MAIN PROGRAM BEGINS HERE
;---------------------------------------------------------------------------------------------

main:
	push ebp		; Set up stack frame for debugger
	mov ebp,esp
	push ebx		; Must preserve ebp, ebx, esi, and edi
	push esi
	push edi
;;; Real code begins below
	mov ecx,0		; Clear out ecx

.loop:
	call ReceiveBit		; Receives bit of data
	
	push ecx		; Save ecx just in case
	push eax		; Push eax for '%u'
	push printBit		; Push printBit for string
	call printf		; Calls printf
	add esp,8		; Clear the stack!

	pop ecx			; Restore ecx value
	inc ecx			; Increment ecx
	cmp ecx,numFrames	; Check if number of frames achieved
	jne .loop		; Jump to .loop if not achieved

;;; Real code ends here
	pop edi			; Restore saved registers
	pop esi
	pop ebx
	mov esp,ebp		; Destroy stack frame before returning
	pop ebp
	ret			; Return control to Linux

