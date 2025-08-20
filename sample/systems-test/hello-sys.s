// A minimal assembly function that calls the 'puts' function
// from the C standard library to print a message.

.global _print_message_from_asm
.align 4

// This function will be called by C++
_print_message_from_asm:
    // Standard function prologue: save frame and link registers
    stp     x29, x30, [sp, #-16]!

    // The address of our message becomes the first argument to puts,
    // which according to the ABI, goes in x0.
    adrp    x0, msg@PAGE
    add     x0, x0, msg@PAGEOFF

    // Call the 'puts' function. The linker will resolve its address.
    bl      _puts

    // Standard function epilogue: restore frame and link registers
    ldp     x29, x30, [sp], #16
    ret

.section __TEXT,__cstring,cstring_literals
msg:
    .asciz "Hello Systems!"