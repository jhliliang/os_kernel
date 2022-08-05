section loader  vstart=0x1000


mov si,message

call printf

jmp $

printf:
    mov ah,0x0e
.next:
    mov al,[si]

    cmp al,0
    jz  .done

    int 0x10
    inc si
    jmp .next 
    ret
.done:
    ret

message db "loooooder",10,13,0

times 510-($-$$) db 0

db 0x55
db 0xaa

