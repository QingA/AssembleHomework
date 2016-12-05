data segment
i 		db 0;
j		db 0;
c   	db 0;
data ends

code segment
assume cs:code, ds:data

main:
  mov ax, data
  mov ds, ax;

  mov ax, 03h
  int 10h

  mov ax, 0b800h
  mov es, ax

  mov di, 0
  push di

  DrawLine:
  	mov i, 0
  	DrawColumn:

  		Char:
		  	mov al, c
		  	mov ah, 0ch
		  	mov word ptr es:[di], ax
	  	Hex:
		  	mov ah, 0ah
		  	mov bl, c
		  	shr bl, 1
		  	shr bl, 1
		  	shr bl, 1
		  	shr bl, 1
		  	cmp bl, 9
		  	ja FirstBigger10
		  		mov al, '0'
		  		add al, bl
		  		mov word ptr es:[di+2], ax
		  		jmp FirstDone

		  	FirstBigger10:
		  		mov al, 'A'
		  		sub bl, 10
		  		add al, bl
		  		mov word ptr es:[di+2], ax
		FirstDone:
		  	mov bl, c
		  	and bl, 0fh
		  	cmp bl, 9
		  	ja SecondBigger10
		  		mov al, '0'
		  		add al, bl
		  		mov word ptr es:[di+4], ax
		  		jmp SecondDone

		  	SecondBigger10:
		  		mov al, 'A'
		  		sub bl, 10
		  		add al, bl
		  		mov word ptr es:[di+4], ax
		SecondDone:
		  	inc c
		  	jz  Outspace
		  	add di, 160
		  	inc i
		  	cmp i, 25
		  	jb  DrawColumn
  	pop di
  	add di, 14
  	push di
	inc j
	cmp j,11
	jb DrawLine

	Outspace:
		mov ah, 0
		int 16h
code ends
end main