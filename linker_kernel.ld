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
    *(.bss*)
    *(COMMON)
  }

  /DISCARD/ : 
  {
    *(.comment)
    *(.note*)
    *(.eh_frame*)
    *(.gcc_except_table*)
  }
}
