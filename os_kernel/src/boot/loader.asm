section loader  vstart=0x1000

jmp ppmode



ppmode:

    cli

    in al,0x92
    or al,0b10
    out 0x92,al

    ;
    lgdt[gdt_ptr]

    ;
    mov eax,cr0
    or eax,1
    mov cr0,eax

    jmp dword code_select:pmode

[bits 32]
pmode:

    mov ax,data_select
    mov ds, ax
    mov es,ax
    mov fs,ax
    mov gs,ax


    mov si, LOADER_BASE_SECTOR;从第几扇区开始读
    mov edi, 0x10000;写入内存段地址
    xchg bx,bx

    mov eax,0
    call read_disk_16

    jmp dword code_select:0x10000

   

;--------------------
;开始读扇区
;---------------------
read_disk_16:

    ;要读写的扇区

    mov dx,0x1f2
    mov al,0x05
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
        mov [edi],ax ;0x1000
        add edi,2
        loop .go_on_read
        ret 

LOADER_BASE_ADDR equ 0x10000
LOADER_BASE_SECTOR equ 10


;全局描述符

code_select equ (1<<3)
data_select equ (2<<3)

m_base equ 0 ;基地址
m_limit equ (4*1024*1024*1024)/(4*1024)-1 ;地址长度 4k 

gdt_ptr:
    dw (gdt_end-gdt_base) -1
    dd gdt_base

gdt_base:
    dd 0,0
gdt_code:
    dw m_limit & 0xffff;
    dw m_base & 0xffff;
    db (m_base>>16) & 0xff;
    db 0b1_00_1_1_0_1_0;
    db 0b1_1_0_0_0000 | (m_limit >> 16) & 0xf
    db (m_base >>24) & 0xff

gdt_data:
    dw m_limit & 0xffff;
    dw m_base & 0xffff;
    db (m_base>>16) & 0xff;
    db 0b1_00_1_0_0_1_0;
    db 0b1_1_0_0_0000 | (m_limit >> 16) & 0xf
    db (m_base >>24) & 0xff
gdt_end:


times 510-($-$$) db 0

db 0x55
db 0xaa

