.text
//  Binutils: ar - Create, modify, and extract from archives
//  Demonstrates archive file format handling in ARM64 assembly

.global _start
.align 4

//  Constants
.equ SYS_EXIT, 93
.equ SYS_OPEN, 56
.equ SYS_READ, 63
.equ SYS_WRITE, 64
.equ SYS_CLOSE, 57
.equ O_RDONLY, 0
.equ O_WRONLY, 1
.equ O_CREAT, 64
.equ O_TRUNC, 512
.equ S_IRUSR, 256
.equ S_IWUSR, 128
.equ STDOUT_FILENO, 1
.equ STDERR_FILENO, 2
.equ AR_MAGIC, 0x213C6172              //  "!<arch>\n"

_start:
    //  Get argc
    //  Save original stack pointer before any modifications
    mov     x19, sp
    
    ldr     x0, [x19]
    cmp     x0, #3
    b.lt    usage_error
    
    //  Get argv[1] (operation: r, t, x, etc.)
    ldr     x0, [x19, #16]
    ldrb    w21, [x0]                   //  First character
    
    //  Get argv[2] (archive file)
    ldr     x0, [x19, #24]
    
    //  Check operation
    cmp     w21, #0x74                  //  't' - list
    b.eq    list_archive
    cmp     w21, #0x78                  //  'x' - extract
    b.eq    extract_archive
    cmp     w21, #0x72                  //  'r' - replace
    b.eq    replace_archive
    b       unknown_operation
    
list_archive:
    //  Open archive
    mov     x2, #O_RDONLY
    mov     x2, #0
    mov     x0, #-100
    mov     x8, #56
    svc     #0
    
    cmp     x0, #0
    b.lt    open_error
    
    mov     x19, x0
    
    //  Read magic
    sub     sp, sp, #8
    mov     x20, sp
    
    mov     x0, x19
    mov     x1, x20
    mov     x2, #8
    mov     x8, #SYS_READ
    svc     #0
    
    //  Verify archive magic
    ldr     w21, [x20]
    movz    w22, #0x6172                //  Load AR_MAGIC (0x213C6172)
    movk    w22, #0x213C, lsl #16
    cmp     w21, w22
    b.ne    not_archive
    
    //  Print header
    mov     x0, #STDOUT_FILENO
    adr     x1, archive_header_msg
    mov     x2, #archive_header_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Close file
    mov     x0, x19
    mov     x8, #SYS_CLOSE
    svc     #0
    
    //  Restore stack
    add     sp, sp, #8
    
    //  Exit
    mov     x0, #0
    mov     x8, #SYS_EXIT
    svc     #0
    
extract_archive:
replace_archive:
    //  Simplified implementation
    mov     x0, #STDOUT_FILENO
    adr     x1, not_implemented_msg
    mov     x2, #not_implemented_len
    mov     x8, #SYS_WRITE
    svc     #0
    mov     x0, #0
    mov     x8, #SYS_EXIT
    svc     #0
    
unknown_operation:
    mov     x0, #STDERR_FILENO
    adr     x1, unknown_op_msg
    mov     x2, #unknown_op_len
    mov     x8, #SYS_WRITE
    svc     #0
    mov     x0, #1
    mov     x8, #SYS_EXIT
    svc     #0
    
open_error:
    mov     x0, #STDERR_FILENO
    adr     x1, error_msg
    mov     x2, #error_len
    mov     x8, #SYS_WRITE
    svc     #0
    mov     x0, #1
    mov     x8, #SYS_EXIT
    svc     #0
    
not_archive:
    mov     x0, #STDERR_FILENO
    adr     x1, not_archive_msg
    mov     x2, #not_archive_len
    mov     x8, #SYS_WRITE
    svc     #0
    mov     x0, #1
    mov     x8, #SYS_EXIT
    svc     #0
    
usage_error:
    mov     x0, #STDERR_FILENO
    adr     x1, usage_msg
    mov     x2, #usage_len
    mov     x8, #SYS_WRITE
    svc     #0
    mov     x0, #1
    mov     x8, #SYS_EXIT
    svc     #0
    
halt_loop:
    b       halt_loop

.data
.align 4
usage_msg:
    .asciz  "Usage: ar <operation> <archive>\n"
usage_len = . - usage_msg

error_msg:
    .asciz  "Error: Cannot open file\n"
error_len = . - error_msg

not_archive_msg:
    .asciz  "Error: Not an archive file\n"
not_archive_len = . - not_archive_msg

unknown_op_msg:
    .asciz  "Error: Unknown operation\n"
unknown_op_len = . - unknown_op_msg

archive_header_msg:
    .asciz  "Archive contents:\n"
archive_header_len = . - archive_header_msg

not_implemented_msg:
    .asciz  "Operation not fully implemented\n"
not_implemented_len = . - not_implemented_msg
