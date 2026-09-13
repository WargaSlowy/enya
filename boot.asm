[BITS 16]
[ORG 0x7C00]

mulai:
  cli

  xor ax, ax 

  mov ds, ax
  mov es, ax
  mov ss, ax

  mov sp, 0x7C00

  sti

  mov [drive_boot], dl

  ; reset disk untuk load bootloader
  xor ax, ax
  mov dl, [drive_boot]
  int 0x13
  jc gagal_disk

  ; load dari stage 2
  ; isi sektor = 2 - 5
  ; antara lain 0000:1000
  ; ini adalah physical address dari bootloader kita
  xor ax, ax
  mov es, ax
  mov bx, 0x1000
  mov ah, 0x02

  mov al, 4
  mov ch, 0
  mov cl, 2
  mov dh, 0

  mov dl, [drive_boot]
  int 0x13

  jc gagal_stage2


  ; section untuk load kernel
  ; 6 - 13
  ; 1000:0000
  ; 0x1000 * 16
  ; 0x10000
  mov ax, 0x1000
  mov es, ax
  
  xor bx, bx
  mov ah, 0x02

  mov al, 8

  mov ch, 0

  mov cl, 6

  mov dh, 0
  mov dl, [drive_boot]
  int 0x13
  jc gagal_kernel

  cli

  lgdt [deksriptor_gdt]

  mov eax, cr0
  or eax, 0x1
  mov cr0, eax

  jmp SELECTOR_KODE:protected_mode

gagal_disk:
  mov si, pesan_gagal_disk
  call cetak_bios
  jmp berhenti

gagal_stage2:
  mov si, pesan_gagal_stage2
  call cetak_bios
  jmp berhenti

gagal_kernel:
  mov si, pesan_gagal_kernel
  call cetak_bios
  jmp berhenti

cetak_bios:
  pusha

.loop:
  lodsb

  cmp al, 0
  je .selesai

  mov ah, 0x0E
  mov bh, 0

  int 0x10

  jmp .loop

.selesai:
  popa
  ret

berhenti:
  cli

.loop:
  hlt

  jmp .loop

; base = 0
; limit = 4GB
; exe, readable ring0 32bit

gdt_mulai:
  dq 0x0000000000000000

gdt_kode:
  dw 0xFFFF
  dw 0x0000

  db 0x00
  db 10011010b
  db 11001111b
  db 0x00

gdt_data:
  dw 0xFFFF
  dw 0x0000

  db 0x00
  db 10010010b
  db 11001111b 
  db 0x00

gdt_selesai:

deksriptor_gdt:
  dw gdt_selesai - gdt_mulai - 1
  dd gdt_mulai

SELECTOR_KODE equ gdt_kode - gdt_mulai
SELECTOR_DATA equ gdt_data - gdt_mulai


[BITS 32]

protected_mode:
  mov ax, SELECTOR_DATA

  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax

  mov esp, 0x90000

  mov eax, 0x1000
  call eax

  cli

.loop:
  hlt
  jmp .loop

[BITS 16]

drive_boot:
  db 0

pesan_gagal_disk:
  db "Gagal untuk reset disknya njir!", 0

pesan_gagal_stage2:
  db "Gagal baca Stage 2 njir", 0

pesan_gagal_kernel:
  db "Gagal baca kernelnya njir", 0

times 510 - ($ - $$) db 0
dw 0xAA55
