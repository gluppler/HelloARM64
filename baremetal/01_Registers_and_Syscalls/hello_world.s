// baremetal/00_registers/hello_world.s
// Writes "Hello, World!" via the macOS write syscall, then exits.

.global _start
.align 4

_start:
    // --- write(fd=1, buf=message, count=len) ---
    mov     x0, #1                  // fd = stdout
    adrp    x1, message@PAGE        // load page of 'message'
    add     x1, x1, message@PAGEOFF // x1 = &message
    mov     x2, #14                 // length ("Hello World!\n")
    // x16 = 0x2000004 (write)
    movz    x16, #0x0004
    movk    x16, #0x0200, lsl #16
    svc     #0

    // --- exit(0) ---
    mov     x0, #0
    movz    x16, #0x0001            // exit
    movk    x16, #0x0200, lsl #16
    svc     #0

// Keep strings in a data section
.data
message:
    .asciz  "Hello World!\n"
