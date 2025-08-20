// A minimal bare-metal test program for macOS and Linux.
// It uses preprocessor directives to select the correct syscall numbers at compile time.
.global _start
.align 4

_start:
    // --- Syscall to write "Hello Bare-Metal!\n" to stdout ---
    mov     x0, #1                  // fd = 1 (stdout)
    adrp    x1, msg@PAGE            // Load address of the message
    add     x1, x1, msg@PAGEOFF
    mov     x2, #18                 // The length of the string

    // Syscall number depends on the OS
#if defined(__APPLE__)
    movz    x16, #0x0004        // macOS write syscall is 0x2000004
    movk    x16, #0x0200, lsl #16
#else
    mov     x8, #64             // Linux write syscall is 64
#endif
    svc     #0

    // --- Syscall to exit the program ---
    mov     x0, #0                  // Exit code 0
#if defined(__APPLE__)
    movz    x16, #0x0001        // macOS exit syscall is 0x2000001
    movk    x16, #0x0200, lsl #16
#else
    mov     x8, #93             // Linux exit syscall is 93
#endif
    svc     #0

// The .section directive ensures the data is placed in the correct part of the executable.
.section __TEXT,__cstring,cstring_literals
msg:
    .asciz "Hello Bare-Metal!\n"