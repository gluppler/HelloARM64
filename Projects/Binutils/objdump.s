.text
//  Binutils: objdump - Display information from object files
//  Demonstrates disassembly and object file analysis in ARM64 assembly

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
    //  Get argc
    //  Save original stack pointer before any modifications
    mov     x19, sp
    
    ldr     x0, [x19]
    cmp     x0, #2
    b.lt    usage_error
    
    //  Get argv[1] - save before modifying stack
    ldr     x20, [x19, #16]             //  argv[1]
    
    //  Allocate space for ELF header
    sub     sp, sp, #64
    mov     x21, sp
    
    //  Open file (use saved argv[1])
    //  Use openat with AT_FDCWD
    mov     x0, #-100                   //  AT_FDCWD
    mov     x1, x20                     //  pathname
    mov     x2, #O_RDONLY               //  flags
    mov     x3, #0                      //  mode
    mov     x8, #56                     //  SYS_openat
    svc     #0
    
    cmp     x0, #0
    b.lt    open_error
    
    mov     x19, x0                     //  Save fd (reuse x19)
    mov     x20, x21                    //  Use x20 for buffer
    
    //  Read ELF header
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
    
    //  Print file header
    mov     x0, #STDOUT_FILENO
    adr     x1, file_header_msg
    mov     x2, #file_header_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Get file type
    ldrh    w21, [x20, #16]             //  e_type
    cmp     w21, #1                     //  ET_REL
    b.eq    type_rel
    cmp     w21, #2                     //  ET_EXEC
    b.eq    type_exec
    cmp     w21, #3                     //  ET_DYN
    b.eq    type_dyn
    b       type_unknown
    
type_rel:
    mov     x0, #STDOUT_FILENO
    adr     x1, type_rel_msg
    mov     x2, #type_rel_len
    mov     x8, #SYS_WRITE
    svc     #0
    b       print_sections
    
type_exec:
    mov     x0, #STDOUT_FILENO
    adr     x1, type_exec_msg
    mov     x2, #type_exec_len
    mov     x8, #SYS_WRITE
    svc     #0
    b       print_sections
    
type_dyn:
    mov     x0, #STDOUT_FILENO
    adr     x1, type_dyn_msg
    mov     x2, #type_dyn_len
    mov     x8, #SYS_WRITE
    svc     #0
    b       print_sections
    
type_unknown:
    mov     x0, #STDOUT_FILENO
    adr     x1, type_unknown_msg
    mov     x2, #type_unknown_len
    mov     x8, #SYS_WRITE
    svc     #0
    
print_sections:
    //  Print sections header
    mov     x0, #STDOUT_FILENO
    adr     x1, sections_header_msg
    mov     x2, #sections_header_len
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
    .asciz  "Usage: objdump <file>\n"
usage_len = . - usage_msg

error_msg:
    .asciz  "Error: Cannot open file\n"
error_len = . - error_msg

not_elf_msg:
    .asciz  "Error: Not an ELF file\n"
not_elf_len = . - not_elf_msg

file_header_msg:
    .asciz  "\nFile: <file>\n"
file_header_len = . - file_header_msg

type_rel_msg:
    .asciz  "Type: Relocatable file\n"
type_rel_len = . - type_rel_msg

type_exec_msg:
    .asciz  "Type: Executable file\n"
type_exec_len = . - type_exec_msg

type_dyn_msg:
    .asciz  "Type: Shared object file\n"
type_dyn_len = . - type_dyn_msg

type_unknown_msg:
    .asciz  "Type: Unknown\n"
type_unknown_len = . - type_unknown_msg

sections_header_msg:
    .asciz  "\nSections:\n"
sections_header_len = . - sections_header_msg
