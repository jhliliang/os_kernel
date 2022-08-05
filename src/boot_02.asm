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

;int 0x10 功能 0x13
;AH          0x13  
;AL          显示模式
;BH          视频页
;BL          属性值（如果AL=0x00或0x01）
;CX          字符串的长度  
;DH,DL       屏幕上显示起始位置的行、列值  
;ES:BP       字符串的段:偏移地址  
;显示模式（AL）：  
;   0x00:字符串只包含字符码，显示之后不更新光标位置，属性值在BL中
;   0x01:字符串只包含字符码，显示之后更新光标位置，属性值在BL中  
;   0x02:字符串包含字符码及属性值，显示之后不更新光标位置  
;   0x03:字符串包含字符码及属性值，显示之后更新光标位置  
mov ax,message
mov bp,ax

mov cx,5
mov ax,0x1301
mov bx, 0x02

int 0x10

jmp $

message db "hello"

times 510-($-$$) db 0

db 0x55
db 0xaa

