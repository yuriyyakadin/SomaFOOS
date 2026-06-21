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
    call cpuid
    call using_cpuid
    jmp stuck
cpuid:
    pushfd
    pushfd
    xor dword [esp], 0x00200000
    popfd
    pushfd
    pop eax
    xor eax, [esp]
    popfd
    and eax, 0x00200000
    jz .cpuid_notavaliable
    jnz .cpuid_avaliable
.cpuid_notavaliable:
    xor ax, ax
    mov ah, 0x0e
    mov al, 'C'
    int 0x10 
    mov al, 'P'
    int 0x10 
    mov al, 'U'
    int 0x10 
    mov al, 'B'
    int 0x10
    mov al, 0x0d
    int 0x10
    mov al, 0x0a
    int 0x10
    ret
.cpuid_avaliable:
    xor ax, ax
    mov ah, 0x0e
    mov al, 'C'
    int 0x10
    mov al, 'P'
    int 0x10
    mov al, 'U'
    int 0x10
    mov al, 'A'
    int 0x10
    mov al, 0x0d
    int 0x10
    mov al, 0x0a
    int 0x10
    ret
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
    je .check_a20_notcorrect
    jne .check_a20_correct
    mov ax, 1
.check_a20_correct:
    xor ax, ax
    mov ah, 0x0e
    mov al, 'A'
    int 0x10
    mov al, '2'
    int 0x10
    mov al, '0'
    int 0x10
    mov al, 'W'
    int 0x10
    mov al, 'E'
    int 0x10
    mov al, 0x0d
    int 0x10
    mov al, 0x0a
    int 0x10
    pop si
    pop di
    pop es
    pop ds
    popf
    ret
.check_a20_notcorrect:
    in al, 0x92
    or al, 2
    out 0x92, al
    xor ax, ax
    mov ah, 0x0e
    mov al, 'A'
    int 0x10
    mov al, '2'
    int 0x10
    mov al, '0'
    int 0x10
    mov al, 'E'
    int 0x10
    mov al, 0x0d
    int 0x10
    mov al, 0x0a
    int 0x10
    pop si
    pop di
    pop es
    pop ds
    popf
    ret
using_cpuid:
    mov eax, 0
    cpuid
    cmp ebx, 0x6568747541
    je .amdp
    cmp ebx, 0x756e6547
    je .intelp
    jne .unknownp
.amdp:
    xor ax, ax
    mov ah, 0x0e
    mov al, 'A'
    int 0x10
    mov al, 'M'
    int 0x10
    mov al, 'D'
    int 0x10
    mov al, 0x0d
    int 0x10
    mov al, 0x0a
    int 0x10
    ret
.unknownp:
    xor ax, ax
    mov ah, 0x0e
    mov al, 'U'
    int 0x10
    mov al, 'N'
    int 0x10
    mov al, 'K'
    int 0x10
    mov al, 0x0d
    int 0x10
    mov al, 0x0a
    int 0x10
    ret
.intelp:
    xor ax, ax
    mov ah, 0x0e
    mov al, 'I'
    int 0x10
    mov al, 'N'
    int 0x10
    mov al, 'T'
    int 0x10
    ret
stuck:
    hlt
    jmp stuck
