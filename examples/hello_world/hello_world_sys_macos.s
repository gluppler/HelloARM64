// examples/hello_world/hello_world_sys_macos.s
// Assembly helper for macOS: must export _get_message for C to call it.

    .section    __TEXT,__text,regular,pure_instructions
    .globl      _get_message
    .align 4
_get_message:
    adrp    x0, msg@PAGE
    add     x0, x0, msg@PAGEOFF
    ret

    .section    __TEXT,__cstring,cstring_literals
msg:
    .asciz "Hello from Assembly via C on macOS!\n"
