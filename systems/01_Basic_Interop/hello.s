// systems/00_hello_syscall/hello.s
//
// Assembly function: write_message()
// Uses macOS syscall: write(fd=1, buf=msg, len)

.global _write_message
.align 4

_write_message:
    // --- write(fd=1, buf=message, count=len) ---
    mov     x0, #1              // fd = stdout
    adrp    x1, message@PAGE    // load address of string
    add     x1, x1, message@PAGEOFF
    mov     x2, #20             // length of string
    mov     x16, #4             // macOS syscall: write
    svc     #0                  // perform syscall
    ret

// Data section
.data
message:
    .ascii  "Hello, Syscall World!\n"
