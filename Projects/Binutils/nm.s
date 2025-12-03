.text
//  Binutils: nm - List symbols from object files
//  Demonstrates symbol table parsing in ARM64 assembly

.global _start
.align 4

//  Constants
.equ SYS_EXIT, 93
.equ SYS_OPEN, 56
.equ SYS_READ, 63
.equ SYS_WRITE, 64
.equ SYS_CLOSE, 57
.equ SYS_LSEEK, 62
.equ O_RDONLY, 0
.equ STDOUT_FILENO, 1
.equ STDERR_FILENO, 2
.equ SEEK_SET, 0
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
    
    //  Get section header table info
    ldr     w23, [x20, #40]             //  e_shoff
    ldrh    w24, [x20, #58]             //  e_shentsize
    ldrh    w25, [x20, #60]             //  e_shnum
    
    //  Print header
    mov     x0, #STDOUT_FILENO
    adr     x1, header_msg
    mov     x2, #header_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Allocate space for section header
    sub     sp, sp, #64
    mov     x26, sp
    
    //  Search for symbol table section
    mov     x0, #0                      //  Section index
find_symtab:
    cmp     w0, w25
    b.ge    no_symbols
    
    //  Calculate section header offset
    mul     x1, x0, x24
    add     x1, x1, x23
    
    //  Seek to section header
    mov     x0, x19
    mov     x2, #SEEK_SET
    mov     x8, #SYS_LSEEK
    svc     #0
    
    //  Read section header
    mov     x0, x19
    mov     x1, x26
    mov     x2, #64
    mov     x8, #SYS_READ
    svc     #0
    
    //  Check if this is symbol table (SHT_SYMTAB = 2)
    ldr     w21, [x26, #4]              //  sh_type
    cmp     w21, #2
    b.eq    found_symtab
    
    add     x0, x0, #1
    b       find_symtab
    
found_symtab:
    //  Get symbol table info
    ldr     x27, [x26, #24]             //  sh_offset
    ldr     x28, [x26, #32]             //  sh_size
    ldr     x29, [x26, #56]             //  sh_entsize
    
    //  Calculate number of symbols
    udiv    x30, x28, x29
    
    //  Print symbol count message
    mov     x0, #STDOUT_FILENO
    adr     x1, symtab_found_msg
    mov     x2, #symtab_found_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Close file
    mov     x0, x19
    mov     x8, #SYS_CLOSE
    svc     #0
    
    //  Restore stack
    add     sp, sp, #128
    
    //  Exit
    mov     x0, #0
    mov     x8, #SYS_EXIT
    svc     #0
    
no_symbols:
    mov     x0, #STDOUT_FILENO
    adr     x1, no_symbols_msg
    mov     x2, #no_symbols_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Close file
    mov     x0, x19
    mov     x8, #SYS_CLOSE
    svc     #0
    
    //  Restore stack
    add     sp, sp, #128
    
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
    .asciz  "Usage: nm <file>\n"
usage_len = . - usage_msg

error_msg:
    .asciz  "Error: Cannot open file\n"
error_len = . - error_msg

not_elf_msg:
    .asciz  "Error: Not an ELF file\n"
not_elf_len = . - not_elf_msg

header_msg:
    .asciz  "Symbol table:\n"
header_len = . - header_msg

symtab_found_msg:
    .asciz  "Symbol table found\n"
symtab_found_len = . - symtab_found_msg

no_symbols_msg:
    .asciz  "No symbol table found\n"
no_symbols_len = . - no_symbols_msg
