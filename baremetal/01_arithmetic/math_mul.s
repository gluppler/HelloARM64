// baremetal/00_registers/math_mul.s
// Compute (7 + 3) * 2 and return result as exit code

.global _main
.align 4

_main:
    // Load constants
    mov x0, #7        // first operand
    mov x1, #3        // second operand
    add x2, x0, x1    // x2 = 7 + 3 = 10

    mov x4, #2        // multiplier
    mul x0, x2, x4    // x0 = x2 * x4 = 20

    // Exit syscall (macOS: 0x2000001)
    movz x16, #0x1
    movk x16, #0x200, lsl #16
    svc #0
