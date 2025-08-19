// examples/hello_world/hello_world_sys_linux.s
// Expose function get_message() -> pointer to message (Linux ABI, no underscore)

    .section .text
    .global get_message
    .align 4
get_message:
    adrp    x0, msg@PAGE
    add     x0, x0, msg@PAGEOFF
    ret

    .section .data
msg:
    .ascii "Hello from Assembly on Linux!\n"
