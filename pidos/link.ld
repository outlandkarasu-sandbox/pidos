MEMORY
{
  ram (rxw) : ORIGIN = 0x8000, LENGTH = 0x10000
}

SECTIONS
{
  /DISCARD/ : {
    *(.ARM.extab*)
    *(.ARM.exidx*)
  }
  .text : {
    *(.text)
    *(.text*)

    . = ALIGN(4);
    *(.rodata)
    *(.rodata*)
  } > ram

  .bss : {
    *(.bss*)
  } > ram
}

