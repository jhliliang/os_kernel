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
mov ds,ax
mov byte [0],'L'


times 510-($-$$) db 0

db 0x55
db 0xaa
