.text
//  Binutils: addr2line - Convert addresses to file names and line numbers
//  Demonstrates debug information parsing in ARM64 assembly

.global _start
.align 4

//  Constants
.equ SYS_EXIT, 93
.equ SYS_OPEN, 56
.equ SYS_READ, 63
.equ SYS_WRITE, 64
.equ SYS_CLOSE, 57
.equ O_RDONLY, 0
.equ STDOUT_FILENO, 1
.equ STDERR_FILENO, 2
.equ ELF_MAGIC, 0x464C457F

_start:
    //  Save original stack pointer
    mov     x19, sp
    
    //  Get argc
    ldr     x0, [x19]
    cmp     x0, #3
    b.lt    usage_error
    
    //  Get argv[1] (executable file) - save before modifying stack
    ldr     x20, [x19, #16]             //  argv[1]
    
    //  Get argv[2] (address) - save before modifying stack
    ldr     x21, [x19, #24]             //  argv[2]
    
    //  Allocate space for ELF header
    sub     sp, sp, #64
    mov     x22, sp
    
    //  Open file (use saved argv[1])
    mov     x0, x20                     //  pathname
    mov     x2, #O_RDONLY
    mov     x2, #0
    mov     x0, #-100
    mov     x8, #56
    svc     #0
    
    cmp     x0, #0
    b.lt    open_error
    
    mov     x19, x0                     //  Save fd (reuse x19)
    
    //  Read ELF header
    mov     x0, x19
    mov     x1, x22
    mov     x2, #64
    mov     x8, #SYS_READ
    svc     #0
    
    //  Verify ELF magic
    ldr     w23, [x22]
    movz    w24, #0x457F                //  Load ELF_MAGIC (0x464C457F)
    movk    w24, #0x464C, lsl #16
    cmp     w23, w24
    b.ne    not_elf
    
    //  Use saved argv[2] (address) - already in x21
    mov     x0, x21
    
    //  Parse address (simplified - just print message)
    mov     x0, #STDOUT_FILENO
    adr     x1, address_msg
    mov     x2, #address_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Print "unknown" for file/line (full implementation would parse DWARF)
    mov     x0, #STDOUT_FILENO
    adr     x1, unknown_msg
    mov     x2, #unknown_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Close file
    mov     x0, x19
    mov     x8, #SYS_CLOSE
    svc     #0
    
    //  Restore stack
    add     sp, sp, #64
    
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
    
not_elf:
    mov     x0, #STDERR_FILENO
    adr     x1, not_elf_msg
    mov     x2, #not_elf_len
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
    .asciz  "Usage: addr2line <executable> <address>\n"
usage_len = . - usage_msg

error_msg:
    .asciz  "Error: Cannot open file\n"
error_len = . - error_msg

not_elf_msg:
    .asciz  "Error: Not an ELF file\n"
not_elf_len = . - not_elf_msg

address_msg:
    .asciz  "Address: "
address_len = . - address_msg

unknown_msg:
    .asciz  "??:0\n"
unknown_len = . - unknown_msg
