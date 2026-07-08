[bits 16]
[org 0x8000]
start:
    mov si, msg_readed
    call print_string
    mov si, msg_starting_cpuid
    call print_string
    call cpuid
    call using_cpuid
    call check_msr
    mov si, msg_cpuid_available
    call print_string
    mov si, msg_starting_A20
    call print_string
    call check_a20
    mov si, msg_a20_enabled
    call print_string
    mov si, msg_starting_gmmfb
    call print_string
    call get_memorymap_from_bios
    mov si, msg_gmmfb_success
    call print_string
    mov si, msg_informing_bios_otpm
    call print_string
    call inform_bios_otpm
    mov si, msg_locating_kernel
    call print_string
    jmp stuck
print_string:
    xor ax, ax
    mov ah, 0x0e
.print_char:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .print_char
.done:
    ret
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
    jz .cpuid_error
    jnz .cpuid_available
    ret
.cpuid_error:
    mov si, msg_cpuid_error
    call print_string
    jmp stuck
.cpuid_available:
    ret
using_cpuid:
    mov eax, 0
    cpuid
    cmp ebx, 0x756E6547
    je .intelp
    cmp ebx, 0x68747541
    je .amdp
    jne .unknownp
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
.intelp:
    xor ax, ax
    mov ah, 0x0e
    mov al, 'I'
    int 0x10
    mov al, 'N'
    int 0x10
    mov al, 'T'
    int 0x10
    mov al, 0x0d
    int 0x10
    mov al, 0x0a
    int 0x10
    ret
check_msr:
    mov eax, 1
    cpuid
    test edx, 1 << 5
    jz .msr_no
    jnz .msr_yes
.msr_no:
    mov si, msg_msr_no
    call print_string
    jmp stuck
.msr_yes:
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
    mov al, byte [es:si]
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
    je .enable_a20
    mov ax, 1
    je .a20_enabled
.a20_enabled:
    popf 
    pop ds
    pop es
    pop di
    pop si
    ret
.enable_a20:
    mov ax, 0x2401
    int 0x15
    popf
    pop ds
    pop es
    pop di
    pop si
    ret
get_memorymap_from_bios:
    xor ax, ax
    mov es, ax
    mov di, 0x7e00
    sub di, 24
    xor ebx, ebx
.gmmfs:
    add di, 24
    mov eax, 0xe820
    mov ecx, 24
    mov edx, 0x534D4150
    int 0x15
    jc no15hex
    cmp ebx, 0
    jnz .gmmfs
    ret
no15hex:
    xor ax, ax
    mov ah, 0x0e
    mov al, 'N'
    int 0x10
    mov al, 'O'
    int 0x10
    mov al, '1'
    int 0x10
    mov al, '5'
    int 0x10
    mov al, 'h'
    int 0x10
    mov al, 'e'
    int 0x10
    mov al, 'x'
    int 0x10
    mov al, 'A'
    int 0x10
    mov al, 'X'
    int 0x10
    mov al, '='
    int 0x10
    mov al, '0'
    int 0x10
    mov al, 'x'
    int 0x10
    mov al, 'e'
    int 0x10
    mov al, '8'
    int 0x10
    mov al, '2'
    int 0x10
    mov al, '0'
    int 0x10
    mov al, 0x0d
    int 0x10
    mov al, 0x0a
    int 0x10
    ret
inform_bios_otpm:
    xor ax, ax
    mov bl, 1
    mov ax, 0xEC00
    int 0x15
    jc no15hex
    ret
stuck:
    hlt
    jmp stuck
msg_readed db "Readed second sector of the disk successfully.", 13, 10,  0
msg_starting_cpuid db "Starting CPUID and MSR-registers availability check...", 13, 10, 0
msg_cpuid_error db "CPUID availability check failed.", 13, 10, 0
msg_msr_no db "MSR-registers availability check failed.", 13, 10, 0
msg_cpuid_available db "CPUID and MSR-registers availability check completed successfully.", 13, 10, 0
msg_starting_A20 db "Starting A20 line status check...", 13, 10, 0
msg_a20_enabled db "A20 line status: enabled.", 13, 10, 0
msg_starting_gmmfb db "Getting memory map from BIOS...", 13, 10, 0
msg_gmmfb_success db "Memory map from BIOS successfully recevied.", 13, 10, 0
msg_informing_bios_otpm db "Informing BIOS of target proccessor mode...", 13, 10, 0
msg_locating_kernel db "Locating kernel in memory...", 13, 10, 0
align 4
gdtr:
    dw gdt_end - gdt_start - 1
    dd gdt_start
gdt_start:
    dd 0x00000000
    dd 0x00000000
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0x9A
    db 0xCF
    db 0x00
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0x92
    db 0xCF
    db 0x00
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0xFA
    db 0xCF
    db 0x00
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0xF2
    db 0xCF
    db 0x00
gdt_end:
