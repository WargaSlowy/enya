ENTRY(mulai_kernel)

SECTIONS 
{
  . = 0x10000;

  .text :
  {
    KEEP(*(.text.mulai))
    *(.text*)
  }

  .rodata :
  {
    *(.rodata*)
  }

  .data : 
  {
    *(.data*)
  }

  .bss : 
  {
    __bss_mulai_kernel = .;

    *(.bss*)
    *(COMMON)

    __bss_akhir_kernel = .;
  }

  /DISCARD/ : 
  {
    *(.comment)
    *(.note*)
    *(.eh_frame*)
    *(.gcc_except_table*)
  }
}
