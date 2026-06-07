[bits 16]
[org 0]
global _start1
_start1:
    mov ah, 0x0e
    mov al, 'Y'
    int 0x10
    jmp stuck
stuck:
    hlt
    jmp stuck
