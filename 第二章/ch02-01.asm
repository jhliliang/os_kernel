;显存地址
;起始      结束      大小       用途
;c0000     c7fff     32kb      显示适配器BIOS
;b8000     bffff     32kb      用于文本模式显示器适配器
;b0000     b7fff     32kb      用于黑白显示适配器
;a0000     affff     64kb      用于彩色显示适配器


mov ax,0xb800
mov ds,ax ;段地址 0xb800:0====>物理地址:0xb8000

mov byte [0x00] ,'L'
mov byte [0x01],0x07
mov byte [0x02] ,'E'
mov byte [0x03],0x07
mov byte [0x04] ,'E'
mov byte [0x05],0x07
mov byte [0x06] ,'O'
mov byte [0x07],0x07
mov byte [0x08] ,'S'
mov byte [0x09],0x07
mov byte [0x0a] ,':'
mov byte [0x0b],0x07

jmp $

times 510-($-$$) db 0


db 0x55
db 0xaa