section mbr  vstart=0x7c00

;清屏
mov ax,3
int 0x10

;初始化寄存器
mov ax,cs
mov dx,ax
mov ds,ax
mov es,ax
mov ss,ax
mov fs,ax
mov sp,0x7c00




mov ax,message
mov bp,ax

mov cx,9
mov ax,0x1301
mov bx, 0x02

int 0x10


;读硬盘loader
;读第几扇区，一个几个
;把代码加载到哪里
mov si, LOADER_BASE_SECTOR;从第几扇区开始读
mov bx, LOADER_BASE_ADDR;写入内存段地址

call read_disk_16

jmp LOADER_BASE_ADDR

;--------------------
;开始读扇区
;---------------------
read_disk_16:

    ;要读写的扇区

    mov dx,0x1f2
    mov al,0x04
    out dx,al

    ;
    inc dx
    mov ax,si;前8位
    out dx,al

    inc dx
    shr ax,8
    out dx,al

    inc dx
    shr ax,8
    out dx,al

    inc dx ;0x1f6
    and al,0x0f;24-27 为0
    or al,0xe0;1110
    out dx,al

    inc dx ;输出
    mov al,0x20
    out dx,al

    .not_ready:
        in al,dx
        and al,0x88
        cmp al,0x08
        jnz .not_ready

   
    mov dx,0x1f0
    mov cx,256
    .go_on_read:

        in ax,dx
        mov [bx],ax ;0x1000
        add bx,2
        loop .go_on_read
        ret 


message db "booooooot"

LOADER_BASE_ADDR equ 0x1000
LOADER_BASE_SECTOR equ 0x0002

times 510-($-$$) db 0

db 0x55
db 0xaa

