[org 0x7c00]
[bits 16]
start:
    cli
    xor ax, ax
    mov ss, ax
    mov sp, 0x7c00
    sti
    mov ds, ax
    mov fs, ax
    mov gs, ax
    mov es, ax
    mov bx, ax
    mov cx, ax
    mov dx, ax
    mov si, ax
    mov di, ax
    mov bp, ax
    jmp reset_disk
reset_disk:
    mov si, msg_start_reset
    call print_string
    mov ah, 0
    mov dl, 0x80
    int 0x13
    jc reset_disk
    mov si, msg_reset_disk
    call print_string
    jmp read_second_sector
read_second_sector:
    mov si, msg_start_read
    call print_string
    xor ax, ax
    mov ah, 0x02
    mov al, 4 
    mov ch, 0
    mov dh, 0
    mov cl, 2
    mov dl, 0x80
    mov bx, 0x8000
    int 0x13
    jc read_second_sector
    jmp 0x0000:0x8000
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
msg_start_reset db "Starting disk reset...", 13, 10, 0
msg_reset_disk db "Disk reset completed successfully.", 13, 10, 0
msg_start_read db "Starting reading second sector of the disk...", 13, 10, 0
times 510 - ($ - $$) db 0
dw 0xAA55
