// examples/hello_world.s
// macOS ARM64 Hello World
// Syscalls: write (0x2000004), exit (0x2000001)

.global _main
.align 4

_main:
    // write(1, "Hello World!\n", 13)
    mov     x0, #1                      // stdout fd
    adrp    x1, helloworld@PAGE          // load address of string (page)
    add     x1, x1, helloworld@PAGEOFF   // add page offset
    mov     x2, #13                      // length

    movz    x16, #0x4
    movk    x16, #0x200, lsl #16
    svc     #0

    // exit(0)
    mov     x0, #0
    movz    x16, #0x1
    movk    x16, #0x200, lsl #16
    svc     #0

helloworld:
    .asciz "Hello World!\n"
