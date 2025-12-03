.text
//  Binutils: readelf - Display ELF file information
//  Demonstrates comprehensive ELF file parsing in ARM64 assembly

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
    //  Save original stack pointer
    mov     x19, sp
    
    //  Get argc
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
    ldr     w22, [x20]
    movz    w23, #0x457F                //  Load ELF_MAGIC (0x464C457F)
    movk    w23, #0x464C, lsl #16
    cmp     w22, w23
    b.ne    not_elf
    
    //  Print ELF header info
    mov     x0, #STDOUT_FILENO
    adr     x1, magic_msg
    mov     x2, #magic_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Get class (32/64 bit)
    ldrb    w22, [x20, #4]              //  EI_CLASS
    cmp     w22, #1
    b.eq    class32
    cmp     w21, #2
    b.eq    class64
    b       class_unknown
    
class32:
    mov     x0, #STDOUT_FILENO
    adr     x1, class32_msg
    mov     x2, #class32_len
    mov     x8, #SYS_WRITE
    svc     #0
    b       print_endian
    
class64:
    mov     x0, #STDOUT_FILENO
    adr     x1, class64_msg
    mov     x2, #class64_len
    mov     x8, #SYS_WRITE
    svc     #0
    b       print_endian
    
class_unknown:
    mov     x0, #STDOUT_FILENO
    adr     x1, class_unknown_msg
    mov     x2, #class_unknown_len
    mov     x8, #SYS_WRITE
    svc     #0
    
print_endian:
    //  Get endianness
    ldrb    w22, [x20, #5]              //  EI_DATA
    cmp     w22, #1
    b.eq    little_endian
    cmp     w21, #2
    b.eq    big_endian
    b       endian_unknown
    
little_endian:
    mov     x0, #STDOUT_FILENO
    adr     x1, le_msg
    mov     x2, #le_len
    mov     x8, #SYS_WRITE
    svc     #0
    b       print_machine
    
big_endian:
    mov     x0, #STDOUT_FILENO
    adr     x1, be_msg
    mov     x2, #be_len
    mov     x8, #SYS_WRITE
    svc     #0
    b       print_machine
    
endian_unknown:
    mov     x0, #STDOUT_FILENO
    adr     x1, endian_unknown_msg
    mov     x2, #endian_unknown_len
    mov     x8, #SYS_WRITE
    svc     #0
    
print_machine:
    //  Get machine type
    ldrh    w22, [x20, #18]             //  e_machine
    cmp     w22, #0xB7                  //  EM_AARCH64
    b.eq    machine_aarch64
    b       machine_unknown
    
machine_aarch64:
    mov     x0, #STDOUT_FILENO
    adr     x1, aarch64_msg
    mov     x2, #aarch64_len
    mov     x8, #SYS_WRITE
    svc     #0
    
machine_unknown:
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
    .asciz  "Usage: readelf <file>\n"
usage_len = . - usage_msg

error_msg:
    .asciz  "Error: Cannot open file\n"
error_len = . - error_msg

not_elf_msg:
    .asciz  "Error: Not an ELF file\n"
not_elf_len = . - not_elf_msg

magic_msg:
    .asciz  "ELF Header:\n  Magic:   7f 45 4c 46\n"
magic_len = . - magic_msg

class32_msg:
    .asciz  "  Class:   ELF32\n"
class32_len = . - class32_msg

class64_msg:
    .asciz  "  Class:   ELF64\n"
class64_len = . - class64_msg

class_unknown_msg:
    .asciz  "  Class:   Unknown\n"
class_unknown_len = . - class_unknown_msg

le_msg:
    .asciz  "  Data:    2's complement, little endian\n"
le_len = . - le_msg

be_msg:
    .asciz  "  Data:    2's complement, big endian\n"
be_len = . - be_msg

endian_unknown_msg:
    .asciz  "  Data:    Unknown\n"
endian_unknown_len = . - endian_unknown_msg

aarch64_msg:
    .asciz  "  Machine: AArch64\n"
aarch64_len = . - aarch64_msg
