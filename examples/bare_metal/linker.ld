/* Linker script for bare metal ARM64 */
ENTRY(_start)

SECTIONS
{
    . = 0x40000000;        /* Load address */
    
    .text : {
        *(.text)
    }
    
    .data : {
        *(.data)
    }
    
    .bss : {
        *(.bss)
    }
}
