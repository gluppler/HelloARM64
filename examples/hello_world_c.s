// Assembly function that returns a pointer to a string

.global _get_message
.align 4

_get_message:
    adr x0, msg     // return address of string
    ret

msg:
    .asciz "Hello from Assembly via C!\n"
