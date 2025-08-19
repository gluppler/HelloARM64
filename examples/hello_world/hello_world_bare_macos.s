// examples/hello_world/hello_world_bare_macos.s
// macOS (Apple Silicon) bare: use Mach syscall numbers in x16 (write, exit)

    .section    __TEXT,__text,regular,pure_instructions
    .globl      _start
    .align  2

_start:
    // write(1, msg, len)
    mov     x0, #1
    adrp    x1, msg@PAGE
    add     x1, x1, msg@PAGEOFF
    mov     x2, #28                 // length of "Hello from Apple Silicon!\n"
    movz    x16, #0x0004
    movk    x16, #0x0200, lsl #16   // builds 0x2000004
    svc     #0

    // exit(0)
    mov     x0, #0
    movz    x16, #0x0001
    movk    x16, #0x0200, lsl #16   // builds 0x2000001
    svc     #0

    .section    __TEXT,__cstring,cstring_literals
msg:
    .asciz "Hello from Apple Silicon!\n"
