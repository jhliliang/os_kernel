;
app_lba_start equ 2

section mbr align=16 vstart=0x7c00 ;16位对齐，地址从0x7c00开始
;清屏
mov ax,3
int 0x10
;初始化
mov ax,0
mov ds,ax
mov es,ax
mov ss,ax
mov fs,ax
mov sp,0x7c0

;计算代码存放内存地址
mov ax,[phy_base] 
mov dx,[phy_base+0x02]
mov bx,16
div bx
mov ds,ax
mov es,ax

;读硬盘
xor di,di
mov si,app_lba_start
xor bx,bx;魔术断点
call read_hard_disk_0
xchg bx,bx;
jmp 0x1000:0


read_hard_disk_0:
    ;保护现场
    push ax
    push bx
    push cx
    push dx

    ;设置读取的扇区数量
    mov dx,0x1f2 
    mov al,0x01
    out dx,al

    ;设置0-7位
    inc dx
    mov ax,si
    out dx,al

    ;设置 8-15
    inc dx
    shr ax,8
    out dx,al ;out 只支持al,ax 寄存器

    ;设置16-23
    inc dx 
    mov ax,di
    out dx,al

    inc dx
    mov al,0xe0 ;lab模式，主盘
    or al,ah ;
    out dx,al

    inc dx ;0x1f7
    mov al,0x20   ;读命令
    out dx,al

   ;判断硬盘状态
    .waits:
        ;先判断忙完没有
        ;再判断准备好没有
        in al,dx
        and al,0x88
        cmp al,0x08
        jnz .waits
    
    mov cx,256;读一个扇区
    mov dx,0x1f0

    .readw:
        in ax,dx
        mov [bx],ax
        add bx,2
        loop .readw

    pop dx
    pop cx
    pop bx
    pop ax

    ret

phy_base dd 0x10000 ;用户程序被加载的物理起始地址



times 510-($-$$) db 0

db 0x55
db 0xaa