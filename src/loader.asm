;
section loader vstart=0

mov ax,0xb800
mov es,ax
mov di,0
mov si,message;

call reds
jmp $
reds:
    mov al,[si]
    mov [es:di],al
    inc si
    add di,2

    mov al, [si]
    cmp al,0;比较是不是0
    jnz reds
    
message db "LeeOS",0


times 510-($-$$) db 0

db 0x55
db 0xaa