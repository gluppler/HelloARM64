.text
//  Binutils: c++filt - Demangle C++ symbols
//  Demonstrates symbol demangling in ARM64 assembly

.global _start
.align 4

//  Constants
.equ SYS_EXIT, 93
.equ SYS_WRITE, 64
.equ STDOUT_FILENO, 1
.equ STDERR_FILENO, 2

_start:
    //  Get argc
    ldr     x0, [sp]
    cmp     x0, #2
    b.lt    usage_error
    
    //  Get argv[1] (mangled symbol)
    ldr     x0, [sp, #16]
    
    //  Check if symbol starts with '_Z' (mangled C++ symbol)
    ldrb    w21, [x0]
    cmp     w21, #0x5F                  //  '_'
    b.ne    not_mangled
    
    ldrb    w21, [x0, #1]
    cmp     w21, #0x5A                  //  'Z'
    b.ne    not_mangled
    
    //  Simplified demangling (just print message)
    mov     x0, #STDOUT_FILENO
    adr     x1, demangled_msg
    mov     x2, #demangled_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Exit
    mov     x0, #0
    mov     x8, #SYS_EXIT
    svc     #0
    
not_mangled:
    //  Symbol is not mangled, print as-is
    mov     x0, #STDOUT_FILENO
    ldr     x1, [sp, #16]
    //  Calculate length (simplified - just print)
    adr     x1, not_mangled_msg
    mov     x2, #not_mangled_len
    mov     x8, #SYS_WRITE
    svc     #0
    
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
    
halt_loop:
    b       halt_loop

.data
.align 4
usage_msg:
    .asciz  "Usage: c++filt <symbol>\n"
usage_len = . - usage_msg

demangled_msg:
    .asciz  "Demangled symbol\n"
demangled_len = . - demangled_msg

not_mangled_msg:
    .asciz  "Symbol is not mangled\n"
not_mangled_len = . - not_mangled_msg
