// baremetal/00_registers/exit_codes.s
// Set your own exit code; check with `echo $?` after running.
// 0 - 255
.set EXIT_CODE, 7

.global _main
.align 4

_main:
    mov     x0, #EXIT_CODE   // x0 = your code

    // --- macOS exit(status) ---
    movz    x16, #0x0001
    movk    x16, #0x0200, lsl #16
    svc     #0
