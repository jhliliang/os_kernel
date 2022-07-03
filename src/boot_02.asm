;
section mbr vstart=0x7c00
;清屏
mov ax,3
int 0x10
;初始化
mov ax,0
mov ds,ax
mov es,ax
mov ss,ax
mov fs,ax
mov sp,0x7c00


mov ax,0xb800
mov es,ax
mov di,0

mov ax,0x7c00
mov ds,ax
mov si,message;

reds:
    mov ax,[si]
    mov [es:di],ax
    inc si
    add di,2

    mov al, [si]
    cmp al,0;比较是不是0
    jnz reds
    
message:
     db "LeeOS",0


times 510-($-$$) db 0

db 0x55
db 0xaa