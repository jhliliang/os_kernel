
jmp near start

mytext db 'L',0x07,'a',0x07,'b',0x07,'e',0x07,'l',0x07,' ',0x07,'o',0x07,\
            'f',0x07,'f',0x07,'s',0x07,'e',0x07,'t',0x07,':',0x07
number db 0,0,0,0,0


start:
    mov ax,0x07c0
    mov ds,ax

    mov ax,0xb800
    mov es,ax

    cld ;方向标志(DF)清零，指示传送是正方向的。std (DF)设置1，传送的方向从高地址到低地址。

    mov si,mytext
    mov di,0

    mov cx,(number-mytext)/2

    rep movsw  ; movesw 默认复制一次，rep 重复执行

 ;计算各个数位
         mov bx,ax
         mov cx,5                      ;循环次数 
         mov si,10                     ;除数 
  digit: 
         xor dx,dx
         div si
         mov [bx],dl                   ;保存数位
         inc bx 
         loop digit
         
         ;显示各个数位
         mov bx,number 
         mov si,4                      
   show:
         mov al,[bx+si]
         add al,0x30
         mov ah,0x04
         mov [es:di],ax
         add di,2
         dec si
         jns show
         
         mov word [es:di],0x0744

         jmp near $

  times 510-($-$$) db 0
                   db 0x55,0xaa




