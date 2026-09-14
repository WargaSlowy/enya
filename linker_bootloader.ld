ENTRY(mulai_bootloader)

SECTIONS
{
  . = 0x1000;

  .text :
  {
    KEEP(*(.text.mulai))

    *(.text*)
  }

  .rodata :
  {
    *(.rodata)
  }

  .data :
  {
    *(.data)
  }

  .bss :
  {
    __bss_mulai = .;

    *(.bss*)
    *(COMMON)
    
    __bss_akhir = .;
  }

  /DISCARD/ :
  {
    *(.comment)
    *(.note*)
    *(.eh_frame*)
    *(.gcc_except_table*)
  }
}
