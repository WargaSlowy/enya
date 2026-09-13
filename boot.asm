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

  ; ES:BX = 0000:1000

  ; 0x0000 * 16 + 0x1000
  ; = 0x1000

  mov bx, 0x1000

  mov ah, 0x02

  mov al, 8
  
  mov ch, 0

  mov cl, 2

  mov dh, 0

  mov dl, [drive_boot]
  int 0x13

  jc gagal_membaca_disk


  ; ini bagian dari protected modenya
  ; 32 bit protected modenya

  cli

  lgdt [deksriptor_gdt]

  mov eax, cr0
  or eax, 0x1

  mov cr0, eax

  jmp SELECTOR_KODE:protected_mode

gagal_membaca_disk:
  cli

.berhenti:
  hlt
  jmp .berhenti

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

selesai:
  cli

.loop:
  hlt
  jmp .loop

drive_boot:
  db 0

times 510 - ($ - $$) db 0
dw 0xAA55
