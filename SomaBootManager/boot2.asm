[bits 16]
[org 0]
global _start1
_start1:
    xor ax, ax
    mov ah, 0x0e
    mov al, 'Y'
    int 0x10
    mov al, 0x0d
    int 0x10
    mov al, 0x0a
    int 0x10
    ;check a20 line
    call check_a20
    jmp stuck
check_a20:
    pushf
    push ds
    push es
    push di
    push si
    cli
    xor ax, ax
    mov es, ax
    not ax
    mov ds, ax
    mov di, 0x0500
    mov si, 0x0510
    mov al, byte [es:di]
    push ax
    mov al, byte [ds:si]
    push ax
    mov byte [es:di], 0x00
    mov byte [ds:si], 0xFF
    cmp byte [es:di], 0xFF
    pop ax
    mov byte [ds:si], al
    pop ax
    mov byte [es:di], al
    mov ax, 0
    je check_a20_notcorrect
    jne check_a20_correct
    mov ax, 1
check_a20_correct:
    xor ax, ax
    mov ah, 0x0e
    mov al, 'A'
    int 0x10
    xor ax, ax
    mov ah, 0x0e
    mov al, '2'
    int 0x10
    xor ax, ax
    mov ah, 0x0e
    mov al, '0'
    int 0x10
    xor ax, ax
    mov ah, 0x0e
    mov al, 'W'
    int 0x10
    xor ax, ax
    mov ah, 0x0e
    mov al, 'E'
    int 0x10
    pop si
    pop di
    pop es
    pop ds
    popf
    ret
check_a20_notcorrect:
    in al, 0x92
    or al, 2
    out 0x92, al
    xor ax, ax
    mov ah, 0x0e
    mov al, 'A'
    int 0x10
    xor ax, ax
    mov ah, 0x0e
    mov al, '2'
    int 0x10
    xor ax, ax
    mov ah, 0x0e
    mov al, '0'
    int 0x10
    xor ax, ax
    mov ah, 0x0e
    mov al, 'E'
    int 0x10
    pop si
    pop di
    pop es
    pop ds
    popf
    ret
stuck:
    hlt
    jmp stuck
