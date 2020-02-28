%include "common_code.asm"

extern printf
extern fopen
extern fscanf

%define STIN			0
%define STOUT			1
%define SYSCALL_EXIT	1
%define SYSCALL_READ	3
%define SYSCALL_WRITE	4
%define EOF				-1

section .data
	read_char	db 'r', 0
	format		db "%d",10,0
	filename	dd 0
	file_pointer	dd 0
	dataSize dd 0
	dataSum dd 0
	currentRead dd 0
	myArray times 1000 dd 0
	sorted db 0
	
	
	loopOverMsg db "Reached end of file while still counting. Nice try.", 10, 0
	sumMsg db "The sum of all the data is: %d", 10, 0
	sortMsg db "The sorted list: ", 10, 0
	
section .text
	global main
	
main:
	; Get filename
	push dword filename
	call GetCommandLine
	add esp, 4
	
	; check filename
	push dword read_char
	push dword [filename]
	call fopen
	add esp, 8
	
	; check file opened correctly, else exit
	cmp	eax, 0
	je	exit		
	mov	[file_pointer], eax
	
	; read data size (first line of input file)
	push dword dataSize
	push dword format
	push dword [file_pointer]
	call fscanf
	add esp, 12
	
	; create a loop to sum the data and store it in an array
	mov ecx, 0
loop1:
	call ReadData
	
	; saving the sum of the current data
	mov eax, [currentRead]
	mov ebx, [dataSum]
	add ebx, eax
	mov [dataSum], ebx
	
	; adding an element to the array. Current index = ecx*4 (Each dword is 4 bytes)
	mov [myArray+(ecx*4)], eax
	
	inc ecx
	cmp ecx, [dataSize]
	jnz loop1
	
PrintResults:
	Push_Regs eax, ecx, edx
	push dword [dataSum]
	push dword sumMsg
	call printf
	add esp, 8
	Pop_Regs eax, ecx, edx
	call SortArray
	call PrintArray
	jmp exit


; Subroutine to read in a line of data - checks for end of file while reading
ReadData:
	Push_Regs eax, ecx, edx
	push dword currentRead
	push dword format
	push dword [file_pointer]
	call fscanf
	add esp, 12
	Pop_Regs eax, ecx, edx
	ret

; sorting algorithm
SortArray:
	xor ecx, ecx
	mov dh, [dataSize]
	dec dh
	
	mov dl, dh
	loop3:
		mov cl, dh
		mov eax, myArray
		loop4:
			mov ebx, [eax]
			cmp [eax+4], ebx
			jl noSwap
			xchg ebx, [eax+4]
			mov [eax], ebx
			
			noSwap:
				add eax, 4
				dec cl
				jnz loop4
				
		dec dl
		jnz loop3
		
	ret
	
; prints the data in the array at address myArray
PrintArray:
	mov ecx, 0
	loop2:
		Push_Regs eax, ebx, ecx
		push dword [myArray+(ecx*4)]
		push dword format
		call printf
		add esp, 8
		Pop_Regs eax, ebx, ecx
		inc ecx
		cmp ecx, [dataSize]
		jne loop2
		ret

; Subroutine to exit normally
exit:
	mov     EAX, SYSCALL_EXIT       
    mov     EBX, 0                
    int     080h                    
	ret	
	
