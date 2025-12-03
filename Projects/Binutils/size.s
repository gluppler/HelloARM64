.text
//  Binutils: size - List section sizes from ELF files
//  Demonstrates ELF header parsing in ARM64 assembly

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
.equ EI_NIDENT, 16
.equ ELF_MAGIC, 0x464C457F  //  "\x7FELF"

//  ELF Header offsets
.equ E_IDENT, 0
.equ E_TYPE, 16
.equ E_MACHINE, 18
.equ E_VERSION, 20
.equ E_ENTRY, 24
.equ E_PHOFF, 32
.equ E_SHOFF, 40
.equ E_FLAGS, 48
.equ E_EHSIZE, 52
.equ E_PHENTSIZE, 54
.equ E_PHNUM, 56
.equ E_SHENTSIZE, 58
.equ E_SHNUM, 60
.equ E_SHSTRNDX, 62

//  Section Header offsets
.equ SH_NAME, 0
.equ SH_TYPE, 4
.equ SH_FLAGS, 8
.equ SH_ADDR, 16
.equ SH_OFFSET, 24
.equ SH_SIZE, 32
.equ SH_LINK, 40
.equ SH_INFO, 44
.equ SH_ADDRALIGN, 48
.equ SH_ENTSIZE, 56

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
    ldr     w22, [x20, #E_IDENT]
    movz    w23, #0x457F                //  Load ELF_MAGIC (0x464C457F)
    movk    w23, #0x464C, lsl #16
    cmp     w22, w23
    b.ne    not_elf
    
    //  Get section header table offset
    ldr     w24, [x20, #E_SHOFF]        //  e_shoff
    ldrh    w25, [x20, #E_SHENTSIZE]    //  e_shentsize
    ldrh    w26, [x20, #E_SHNUM]        //  e_shnum
    
    //  Print header
    mov     x0, #STDOUT_FILENO
    adr     x1, header_msg
    mov     x2, #header_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Allocate space for section header
    sub     sp, sp, #64
    mov     x27, sp
    
    //  Initialize totals
    mov     x28, #0                     //  text size
    mov     x29, #0                     //  data size
    mov     x30, #0                     //  bss size
    mov     x0, #0                      //  total (reuse x0)
    
    //  Save totals on stack since we need registers
    sub     sp, sp, #32
    str     x0, [sp]                    //  total
    str     x28, [sp, #8]               //  text
    str     x29, [sp, #16]              //  data
    str     x30, [sp, #24]              //  bss
    
    //  Read each section header
    mov     x0, #0                      //  Section index
section_loop:
    cmp     w0, w26
    b.ge    print_totals
    
    //  Calculate section header offset
    mul     x1, x0, x25                 //  index * shentsize
    add     x1, x1, x24                 //  + shoff
    
    //  Seek to section header
    mov     x2, x19                     //  Save fd
    mov     x3, #SEEK_SET
    mov     x8, #SYS_LSEEK
    svc     #0
    
    //  Read section header
    mov     x0, x2                      //  Restore fd
    mov     x1, x27                     //  buffer
    mov     x2, #64
    mov     x8, #SYS_READ
    svc     #0
    
    //  Get section size
    ldr     x21, [x27, #SH_SIZE]
    
    //  Add to total
    ldr     x22, [sp]                   //  Load total
    add     x22, x22, x21               //  Add section size
    str     x22, [sp]                   //  Save total
    
    //  Get section type (simplified - just add to text for demo)
    ldr     w23, [x27, #SH_TYPE]
    cmp     w23, #1                     //  SHT_PROGBITS
    b.ne    next_section
    ldr     x22, [sp, #8]               //  Load text
    add     x22, x22, x21               //  Add to text
    str     x22, [sp, #8]               //  Save text
    
next_section:
    add     x0, x0, #1
    b       section_loop
    
print_totals:
    //  Print totals (simplified output)
    mov     x0, #STDOUT_FILENO
    adr     x1, text_label
    mov     x2, #text_label_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Convert x27 to string and print (simplified - just print hex)
    //  For full implementation, would convert to decimal
    
    //  Close file
    mov     x0, x19
    mov     x8, #SYS_CLOSE
    svc     #0
    
    //  Restore stack
    add     sp, sp, #96                 //  64 + 32
    
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
    .asciz  "Usage: size <file>\n"
usage_len = . - usage_msg

error_msg:
    .asciz  "Error: Cannot open file\n"
error_len = . - error_msg

not_elf_msg:
    .asciz  "Error: Not an ELF file\n"
not_elf_len = . - not_elf_msg

header_msg:
    .asciz  "   text    data     bss     dec     hex filename\n"
header_len = . - header_msg

text_label:
    .asciz  "text: "
text_label_len = . - text_label
