section mbr  vstart=0x7c00

;初始化寄存器
mov ax,cs
mov ds,ax
mov es,ax
mov ss,ax
mov fs,ax
mov sp,0x7c00


mov ax,0xb800
mov ds,ax
mov byte [0],'H'

jmp $

message db "hello,sms!"

times 510-($-$$) db 0

db 0x55
db 0xaa

