;加载器
;从硬盘获取第一个扇区，加载到指定内存中
;获取用户程序头文件：程序大小，程序入口地址
;从硬盘读取剩下用户程序，并加载到内存中
;执行程序

app_lba_start equ 100  ;指定用户程序存储扇区100


SECTION mbr align=16 vstart=0x7c00 

message db "LEEOSLoding"

start:

    ;清屏
    ;Loding
    mov ax,0xb800
    mov es,ax

    mov si,message
    mov di,0
    mov cx,start-message
@g:
    mov al,[si]
    mov [es:di],al
    inc di 
    mov byte [es:di], 0x07
    inc di
    inc si
    loop @g

    ;设置堆栈段和栈指针 
    mov ax,0      
    mov ss,ax
    mov sp,ax

    ;加载,
    mov ax,[cs:phy_base];段寄存器0，偏移量= (vstart=0x7c00)+(phy_base 偏移量) 
    mov dx,[cs:phy_base+2];高16位 dx:ax /bx  =ax(商) + dx(余数)
    mov bx,16
    div bx  ;32位除法，ax=1000,

    mov ds,ax
    mov es,ax
    xor di,di
    mov si,app_lba_start            ;程序在硬盘上的起始逻辑扇区号 
    xor bx,bx     
    call read_hard_disk_0


    ;获取用户程序信息
    ;获取程序大小，并计算扇区数
    mov dx,[2]
    mov ax,[0]
    mov bx,512
    div bx
    cmp dx,0
    jnz @1                          ;未除尽，因此结果比实际扇区数少1 
    dec ax                          ;已经读了一个扇区，扇区总数减1  

@1:
    cmp ax,0                        ;考虑实际长度小于等于512个字节的情况 
    jz direct
    
    ;读取剩余的扇区
    push ds                         ;以下要用到并改变DS寄存器 

    mov cx,ax                       ;循环次数（剩余扇区数）
@2:
    mov ax,ds
    add ax,0x20                     ;得到下一个以512字节为边界的段地址
    mov ds,ax  
                        
    xor bx,bx                       ;每次读时，偏移地址始终为0x0000 
    inc si                          ;下一个逻辑扇区 
    call read_hard_disk_0
    loop @2                         ;循环读，直到读完整个功能程序 

    pop ds                          ;恢复数据段基址到用户程序头部段 

    ;计算入口点代码段基址 
direct:
        mov dx,[0x08]
        mov ax,[0x06]
        call calc_segment_base
        mov [0x06],ax                   ;回填修正后的入口点代码段基址 
    
        ;开始处理段重定位表
        mov cx,[0x0a]                   ;需要重定位的项目数量
        mov bx,0x0c                     ;重定位表首地址

 realloc:
         mov dx,[bx+0x02]                ;32位地址的高16位 
         mov ax,[bx]
         call calc_segment_base
         mov [bx],ax                     ;回填段的基址
         add bx,4                        ;下一个重定位项（每项占4个字节） 
         loop realloc 
      
         jmp far [0x04]                  ;转移到用户程序  

read_hard_disk_0:
    push ax
    push bx
    push cx
    push dx

    ;要读取的扇区数
    mov dx,0x1f2
    mov al,1
    out dx,al
    ;0-7位
    inc dx
    mov ax,si;16位 100
    mov al,al
    out dx,al

    ;8-15位
    inc dx
    mov al,ah
    out dx,al
    ;16-23位
    inc dx
    mov ax,di
    out dx,al

    ;24-27位，状态
    inc dx
    mov al,0xe0                     ;LBA28模式，主盘
    or al,ah                        ;LBA地址27~24
    out dx,al

    inc dx                          ;0x1f7
    mov al,0x20                     ;读命令
    out dx,al

.waits:
    in al,dx ;0x1f7
    and al,0x88
    cmp al,0x08
    jnz .waits                      ;不忙，且硬盘已准备好数据传输

    mov cx,256                      ;总共要读取的字数
    mov dx,0x1f0
.readw:
    in  ax,dx
    mov [bx],ax
    add bx,2
    loop .readw

    pop dx
    pop cx
    pop bx
    pop ax

    ret
;-------------------------------------------------------------------------------
calc_segment_base:                       ;计算16位段地址
                                         ;输入：DX:AX=32位物理地址
                                         ;返回：AX=16位段基地址 
         push dx                          
         
         add ax,[cs:phy_base]
         adc dx,[cs:phy_base+0x02]
         shr ax,4
         ror dx,4
         and dx,0xf000
         or ax,dx
         
         pop dx
         
         ret

;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
    phy_base dd 0x10000             ;用户程序被加载的物理起始地址


 times 510-($-$$) db 0
                  db 0x55,0xaa

