;  __  __       _ _   _  ____      _            _       _
; |  \/  |_   _| | |_(_)/ ___|__ _| | ___ _   _| | __ _| |_ ___  _ __
; | |\/| | | | | | __| | |   / _` | |/ __| | | | |/ _` | __/ _ \| '__|
; | |  | | |_| | | |_| | |__| (_| | | (__| |_| | | (_| | || (_) | |
; |_|  |_|\__,_|_|\__|_|\____\__,_|_|\___|\__,_|_|\__,_|\__\___/|_|
.386
data segment use16

buf db 80, 0, 80 dup(0)

xstr db 10 dup(0)
ystr db 10 dup(0)
xval dw 0
yval dw 0

t db '0123456789ABCDEF'
s db 5 dup(" "), 0Dh, 0Ah, '$'

endofline db 0Dh,0Ah,'$'

decimal db 20 dup(0)
hex 	db 20 dup(0)
binary 	db 20 dup(0)

data ends

code segment use16
assume cs:code, ds:data
input:
	push cx
	push dx
	push si 
	push di
	mov ah, 0Ah
	mov dx, offset buf
	int 21h
	mov ch, 0
	mov cl, buf[1]
	push cx
	lea si, buf[2]
input_next:
	cmp cx, 0
	je input_done
	mov al, [si]
	mov [di], al
	inc si
	inc di
	dec cx 
	jmp input_next
input_done:
	mov byte ptr [di], 0
	inc di
	mov byte ptr [di], '$'
	pop ax
	pop di
	pop si
	pop dx
	pop cx
	ret

convert:
	push cx
	mov di, cx
	mov dx, 0
	mov ax, 0
	mov dh, 0
convert_again:
	mov cx, 0
	mov cl, [si]
	sub cl, '0'
	mov bx, 10
	mul bx
	add ax, cx
	inc si
	sub di, 1
	jnz convert_again
	pop cx
	ret

print:
	push ax
	push dx
	mov dx, di
	mov ah, 09h
	int 21h
	mov dx, offset endofline
	int 21h
	pop dx
	pop ax
	ret

getdec:
	push dx
	push ax
	; extend dx:ax to eax, to make sure the result after divided by 10 is 32bit
	push ax
	mov eax, 0
	mov ax, dx
	shl eax, 16
	pop ax

	mov cx, 0 
again:
	mov edx, 0
	mov ebx, 10
	div ebx 
	add dl,'0'
	push dx
	inc cx
	cmp eax,0
	jne again
pop_again:
	pop dx
	mov [di],dl
	inc di
	dec cx
	jnz pop_again
	mov byte ptr [di], '$'
	pop ax
	pop dx
	ret
	
hextravel:	
	rol cx, 4
	mov dx, cx
	and dx, 0fh
	mov bx, offset t
	mov al, dl
	xlat
	mov [di], al
	inc di
	dec si
	jne hextravel
	ret

gethex:
	push di
	push dx
	push ax
	mov cx, dx; travel dx
	mov si, 4
	call hextravel
	pop ax
	push ax
	mov cx, ax; travel ax
	mov si, 4
	call hextravel
	mov byte ptr [di], 'h'
	inc di
	mov byte ptr [di], '$'
	pop ax
	pop dx
	pop di
	ret

bintravel:
	rol cx, 1
	mov dx, cx
	and dl, 01h
	add dl, '0'
	mov [di], dl
	inc di
	dec si
	jne bintravel
	ret
	
getbin:
	push di
	push dx
	push ax
	mov si, 16; Loop times = 16
	mov cx, dx; travel dx
	call bintravel
	mov cx, ax; travel ax
	mov si, 16
	call bintravel
	mov byte ptr [di], '$'
	pop ax
	pop dx
	pop di
	ret

main:
	mov ax, data
	mov ds, ax

	mov di, offset xstr
	call input
	mov cx, ax
	mov si, offset xstr	
	call convert
	mov xval, ax

	mov di, offset ystr
	call input
	mov cx, ax
	mov si, offset ystr
	call convert
	mov yval, ax

	mov dx, offset xstr
	mov ah, 09h
	int 21h
	mov dl, '*'
	mov ah, 02h
	int 21h
	mov dx, offset ystr
	mov ah, 09h
	int 21h
	mov dl, '='
	mov ah, 02h
	int 21h
	mov dx, offset endofline
	mov ah, 09h
	int 21h

	mov ax, xval
	mov bx, yval
	mul bx;   dx:ax is the result

	mov di, offset decimal
	call getdec
	mov di, offset decimal
	call print

	mov di, offset hex
	call gethex
	call print

	mov di, offset binary
	call getbin
	call print

	mov ah, 4Ch
	int 21h
code ends
end main