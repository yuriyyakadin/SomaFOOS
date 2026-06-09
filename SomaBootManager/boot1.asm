[bits 16]
[org 0x7c00]
global _start
_start:
    ;setting up stack
    cli
    xor ax, ax
    mov sp, ax
    sti
    ;clearing all registers
    mov ds, ax
    mov fs, ax
    mov gs, ax
    mov es, ax
    mov bx, ax
    mov cx, ax
    mov dx, ax
    mov di, ax
    mov si, ax
    mov bp, ax
    jmp read_disk
    ;reading second sector of the disk
read_disk:
    mov ah, 0x02
    mov al, 0x01
    mov ch, 0x00
    mov cl, 0x02
    mov dh, 0x00
    mov dl, 0x80
    mov bx, 0x7e00
    int 0x13 
    jc read_disk_error
    jmp 0x0000:0x7e00
read_disk_error:
    xor ax, ax
    mov ah, 0x0e
    mov al, 'N'
    int 0x10
    jmp stuck
stuck:
    hlt
    jmp stuck
times 510 - ($ - $$) db 0
dw 0xAA55
