// baremetal/00_registers/registers.s
// Demonstrates moving immediates, copying registers, and exiting with a code.

.global _main
.align 4

_main:
    // Move immediates into registers
    mov     x0, #42          // x0 = 42
    mov     x1, #7           // x1 = 7

    // Copy between registers
    mov     x2, x0           // x2 = 42
    mov     x3, x1           // x3 = 7

    // Do a tiny operation (optional preview of 01_arithmetic)
    add     x4, x2, x3       // x4 = 42 + 7 = 49

    // Return x4 as the process exit code (so `echo $?` shows 49)
    mov     x0, x4           // x0 holds our exit status

    // --- macOS exit(status) ---
    // x0 = status already set
    // x16 = 0x2000001 (exit)
    movz    x16, #0x0001
    movk    x16, #0x0200, lsl #16
    svc     #0
