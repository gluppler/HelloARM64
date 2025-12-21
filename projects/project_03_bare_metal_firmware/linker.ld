/* Linker script for bare metal ARM64 firmware */
ENTRY(_start)

SECTIONS
{
    . = 0x40000000;        /* Load address */
    
    .text : {
        *(.text)
    }
    
    .rodata : {
        *(.rodata)
    }
    
    .data : {
        *(.data)
    }
    
    .bss : {
        *(.bss)
    }
}
