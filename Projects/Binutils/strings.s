.text
//  Binutils: strings - Print printable strings from files
//  Demonstrates file reading and string detection in ARM64 assembly

.global _start
.align 4

//  Constants
.equ SYS_EXIT, 93
.equ SYS_OPEN, 56
.equ SYS_READ, 63
.equ SYS_WRITE, 64
.equ SYS_CLOSE, 57
.equ O_RDONLY, 0
.equ STDIN_FILENO, 0
.equ STDOUT_FILENO, 1
.equ STDERR_FILENO, 2
.equ MIN_STRING_LEN, 4
.equ BUFFER_SIZE, 4096

_start:
    //  Save original stack pointer before any modifications
    mov     x19, sp
    
    //  Get argc from stack (at sp)
    ldr     x0, [x19]                   //  argc
    cmp     x0, #2
    b.lt    usage_error                 //  Need at least program name + file
    
    //  Get argv[1] (filename) - save it before modifying stack
    ldr     x20, [x19, #16]             //  argv[1] (skip argc and argv[0])
    
    //  Allocate buffer on stack (after saving argv pointer)
    sub     sp, sp, #BUFFER_SIZE
    mov     x21, sp                    //  Save buffer address in x21
    
    //  Open file (use saved argv pointer)
    //  x20 contains pointer to filename string
    //  Validate pointer is not NULL
    cmp     x20, #0
    b.eq    open_error
    
    //  Use openat syscall (SYS_openat = 56) with AT_FDCWD (-100)
    //  openat(AT_FDCWD, pathname, flags, mode)
    mov     x0, #-100                   //  AT_FDCWD (current directory)
    mov     x1, x20                     //  pathname (pointer to string)
    mov     x2, #O_RDONLY               //  flags
    mov     x3, #0                      //  mode
    mov     x8, #56                     //  SYS_openat
    svc     #0
    
    //  Check for error (negative return value)
    cmp     x0, #0
    b.lt    open_error
    
    mov     x19, x0                     //  Save file descriptor in x19 (reuse register)
    mov     x20, x21                    //  Use x20 for buffer address
    
    //  Read file and find strings
read_loop:
    mov     x0, x19                     //  fd
    mov     x1, x20                     //  buffer
    mov     x2, #BUFFER_SIZE            //  count
    mov     x8, #SYS_READ
    svc     #0
    
    cmp     x0, #0
    b.le    read_done                   //  EOF or error
    
    mov     x22, x0                     //  Save bytes read
    mov     x23, #0                     //  Current position in buffer
    mov     x24, #-1                    //  String start position (-1 if not in string)
    
scan_loop:
    cmp     x23, x22
    b.ge    read_loop                   //  Processed all bytes, read more
    
    //  Load byte from buffer
    ldrb    w25, [x20, x23]             //  Load byte
    
    //  Check if printable (0x20-0x7E)
    cmp     w25, #0x20
    b.lt    not_printable
    cmp     w25, #0x7E
    b.gt    not_printable
    
    //  Printable character
    cmp     x24, #-1
    b.ne    in_string
    mov     x24, x23                    //  Start of new string
in_string:
    add     x23, x23, #1
    b       scan_loop
    
not_printable:
    //  Check if we have a string to print
    cmp     x24, #-1
    b.eq    skip_print
    
    //  Check string length
    sub     x26, x23, x24               //  String length
    cmp     x26, #MIN_STRING_LEN
    b.lt    skip_print
    
    //  Print string
    mov     x0, #STDOUT_FILENO
    add     x1, x20, x24                //  String start
    mov     x2, x26                     //  Length
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Print newline
    mov     x0, #STDOUT_FILENO
    adr     x1, newline
    mov     x2, #1
    mov     x8, #SYS_WRITE
    svc     #0
    
skip_print:
    mov     x24, #-1                    //  Reset string start
    add     x23, x23, #1
    b       scan_loop
    
read_done:
    //  Close file
    mov     x0, x19
    mov     x8, #SYS_CLOSE
    svc     #0
    
    //  Restore stack
    add     sp, sp, #BUFFER_SIZE
    
    //  Exit successfully
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
    
halt_loop:
    b       halt_loop

.data
.align 4
usage_msg:
    .asciz  "Usage: strings <file>\n"
usage_len = . - usage_msg

error_msg:
    .asciz  "Error: Cannot open file\n"
error_len = . - error_msg

newline:
    .byte   0x0A
