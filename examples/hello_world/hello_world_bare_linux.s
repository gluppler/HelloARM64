// examples/hello_world/hello_world_bare_linux.s
// AArch64 Linux: bare minimal hello using write(64) and exit(93)

    .section .text
    .global _start
    .align  2

_start:
    // write(1, msg, len)
    mov     x0, #1
    adrp    x1, msg@PAGE
    add     x1, x1, msg@PAGEOFF
    mov     x2, #23         // len of "Hello from Linux!\n"
    mov     x8, #64         // syscall: write
    svc     #0

    // exit(0)
    mov     x0, #0
    mov     x8, #93         // syscall: exit
    svc     #0

    .section .data
msg:
    .ascii "Hello from Linux!\n"
