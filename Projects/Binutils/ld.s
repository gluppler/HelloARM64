.text
//  Binutils: ld - Linker
//  Demonstrates basic linking functionality in ARM64 assembly
//  Note: Full linker implementation is extremely complex

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
.equ ELF_MAGIC, 0x464C457F

_start:
    //  Get argc
    //  Save original stack pointer before any modifications
    mov     x19, sp
    
    ldr     x0, [x19]
    cmp     x0, #3
    b.lt    usage_error
    
    //  Get argv[1] (input object file)
    ldr     x0, [x19, #16]
    
    //  Open input file
    mov     x2, #O_RDONLY
    mov     x2, #0
    mov     x0, #-100
    mov     x8, #56
    svc     #0
    
    cmp     x0, #0
    b.lt    open_input_error
    
    mov     x19, x0                     //  Save input fd
    
    //  Read ELF header
    sub     sp, sp, #64
    mov     x20, sp
    
    mov     x0, x19
    mov     x1, x20
    mov     x2, #64
    mov     x8, #SYS_READ
    svc     #0
    
    //  Verify ELF magic
    ldr     w21, [x20]
    movz    w22, #0x457F                //  Load ELF_MAGIC (0x464C457F)
    movk    w22, #0x464C, lsl #16
    cmp     w21, w22
    b.ne    not_elf
    
    //  Get argv[2] (output file)
    ldr     x0, [x19, #24]
    
    //  Open output file
    mov     x1, #O_WRONLY | O_CREAT | O_TRUNC
    mov     x2, #S_IRUSR | S_IWUSR
    mov     x0, #-100
    mov     x8, #56
    svc     #0
    
    cmp     x0, #0
    b.lt    open_output_error
    
    mov     x21, x0                     //  Save output fd
    
    //  Simplified linking: copy input to output
    //  (Full linker would resolve symbols, relocate, etc.)
    mov     x0, x19
    mov     x1, x20
    mov     x2, #64
    mov     x8, #SYS_READ
    svc     #0
    
    mov     x0, x21
    mov     x1, x20
    mov     x2, #64
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Print success message
    mov     x0, #STDOUT_FILENO
    adr     x1, success_msg
    mov     x2, #success_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Close files
    mov     x0, x19
    mov     x8, #SYS_CLOSE
    svc     #0
    
    mov     x0, x21
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
    
open_input_error:
    mov     x0, #STDERR_FILENO
    adr     x1, open_input_msg
    mov     x2, #open_input_len
    mov     x8, #SYS_WRITE
    svc     #0
    mov     x0, #1
    mov     x8, #SYS_EXIT
    svc     #0
    
open_output_error:
    mov     x0, x19
    mov     x8, #SYS_CLOSE
    svc     #0
    mov     x0, #STDERR_FILENO
    adr     x1, open_output_msg
    mov     x2, #open_output_len
    mov     x8, #SYS_WRITE
    svc     #0
    mov     x0, #1
    mov     x8, #SYS_EXIT
    svc     #0
    
not_elf:
    mov     x0, x19
    mov     x8, #SYS_CLOSE
    svc     #0
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
    .asciz  "Usage: ld <input> <output>\n"
usage_len = . - usage_msg

open_input_msg:
    .asciz  "Error: Cannot open input file\n"
open_input_len = . - open_input_msg

open_output_msg:
    .asciz  "Error: Cannot open output file\n"
open_output_len = . - open_output_msg

not_elf_msg:
    .asciz  "Error: Not an ELF file\n"
not_elf_len = . - not_elf_msg

success_msg:
    .asciz  "Linking complete\n"
success_len = . - success_msg
