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
  }
}
