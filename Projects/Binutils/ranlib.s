.text
//  Binutils: ranlib - Generate index to archive
//  Demonstrates archive index generation in ARM64 assembly

.global _start
.align 4

//  Constants
.equ SYS_EXIT, 93
.equ SYS_OPEN, 56
.equ SYS_READ, 63
.equ SYS_WRITE, 64
.equ SYS_CLOSE, 57
.equ O_RDWR, 2
.equ STDOUT_FILENO, 1
.equ STDERR_FILENO, 2
.equ AR_MAGIC, 0x213C6172

_start:
    //  Get argc
    //  Save original stack pointer before any modifications
    mov     x19, sp
    
    ldr     x0, [x19]
    cmp     x0, #2
    b.lt    usage_error
    
    //  Get argv[1] - save before modifying stack
    ldr     x20, [x19, #16]             //  argv[1]
    
    //  Allocate space for magic
    sub     sp, sp, #8
    mov     x21, sp
    
    //  Open file (use saved argv[1])
    //  Use openat with AT_FDCWD
    mov     x0, #-100                   //  AT_FDCWD
    mov     x1, x20                     //  pathname
    mov     x2, #O_RDWR                 //  flags
    mov     x3, #0                      //  mode
    mov     x8, #56                     //  SYS_openat
    svc     #0
    
    cmp     x0, #0
    b.lt    open_error
    
    mov     x19, x0                     //  Save fd (reuse x19)
    mov     x20, x21                    //  Use x20 for buffer
    
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
    
    //  Print success message
    mov     x0, #STDOUT_FILENO
    adr     x1, success_msg
    mov     x2, #success_len
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
    
usage_error:
    mov     x0, #STDERR_FILENO
    adr     x1, usage_msg
    mov     x2, #usage_len
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
    
halt_loop:
    b       halt_loop

.data
.align 4
usage_msg:
    .asciz  "Usage: ranlib <archive>\n"
usage_len = . - usage_msg

error_msg:
    .asciz  "Error: Cannot open file\n"
error_len = . - error_msg

not_archive_msg:
    .asciz  "Error: Not an archive file\n"
not_archive_len = . - not_archive_msg

success_msg:
    .asciz  "Archive index generated\n"
success_len = . - success_msg
