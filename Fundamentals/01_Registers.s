//  Fundamentals/01_Registers.s
.text
//  AArch64 Register Architecture and Usage
//  Demonstrates all register types: General Purpose, Stack Pointer, Link Register, etc.


.align 4

.global _start

_start:
    //  ============================================
    //  GENERAL PURPOSE REGISTERS (x0-x30)
    //  ============================================
    //  64-bit registers: x0-x30 (31 total)
    //  32-bit views: w0-w30 (lower 32 bits)
    
    //  x0-x7: Argument/Result registers (caller-saved)
    mov     x0, #0                  //  x0: First argument / Return value
    mov     x1, #1                  //  x1: Second argument
    mov     x2, #2                  //  x2: Third argument
    mov     x3, #3                  //  x3: Fourth argument
    mov     x4, #4                  //  x4: Fifth argument
    mov     x5, #5                  //  x5: Sixth argument
    mov     x6, #6                  //  x6: Seventh argument
    mov     x7, #7                  //  x7: Eighth argument
    
    //  x8: Indirect result location register (caller-saved)
    mov     x8, #8
    
    //  x9-x15: Temporary registers (caller-saved)
    mov     x9, #9
    mov     x10, #10
    mov     x11, #11
    mov     x12, #12
    mov     x13, #13
    mov     x14, #14
    mov     x15, #15
    
    //  x16-x17: IP0/IP1 - Intra-Procedure-call scratch registers (caller-saved)
    //  x16 is also used for syscall numbers on macOS
    mov     x16, #16
    mov     x17, #17
    
    //  x18: Platform register (reserved for platform use, caller-saved)
    //  On Apple Silicon: Reserved, do not use
    //  mov     x18, #18              //  AVOID on Apple Silicon
    
    //  x19-x28: Callee-saved registers (must be preserved by callee)
    mov     x19, #19
    mov     x20, #20
    mov     x21, #21
    mov     x22, #22
    mov     x23, #23
    mov     x24, #24
    mov     x25, #25
    mov     x26, #26
    mov     x27, #27
    mov     x28, #28
    
    //  x29: Frame Pointer (FP) - Callee-saved
    //  Points to the current stack frame
    //  Note: Use add instead of mov for SP to ensure compatibility
    add     x29, sp, #0             //  Initialize frame pointer from stack pointer
    
    //  x30: Link Register (LR) - Stores return address
    //  Callee-saved, but typically saved by callee if it calls other functions
    //  Note: In _start, LR is not set (no return address)
    //  Example: Load address of current location
    adr     x30, lr_example_label   //  Example: store address
lr_example_label:
    
    //  ============================================
    //  SPECIAL REGISTERS
    //  ============================================
    
    //  SP: Stack Pointer (x31 alias)
    //  Points to the top of the stack
    //  Must be 16-byte aligned at all times
    mov     x0, sp                  //  Read stack pointer (use mov, not add/sub directly)
    
    //  XZR/WZR: Zero Register (x31/w31 alias when used as source)
    //  Always reads as zero, writes are ignored
    mov     x0, xzr                  //  x0 = 0 (efficient way to zero register)
    mov     w0, wzr                  //  w0 = 0 (32-bit zero)
    
    //  ============================================
    //  32-BIT REGISTER VIEWS (w0-w30)
    //  ============================================
    //  Writing to w register zero-extends to x register
    mov     w0, #0xFFFFFFFF         //  w0 = 0xFFFFFFFF
                                    //  x0 = 0x00000000FFFFFFFF (zero-extended)
    
    //  ============================================
    //  REGISTER USAGE CONVENTIONS
    //  ============================================
    //  Function arguments: x0-x7 (up to 8 arguments)
    //  Return value: x0 (or x0-x1 for 128-bit values)
    //  Caller-saved: x0-x18 (can be modified by called function)
    //  Callee-saved: x19-x28, x29 (FP), x30 (LR) (must be preserved)
    
    //  ============================================
    //  REGISTER MANAGEMENT BEST PRACTICES
    //  ============================================
    //  Clear registers containing sensitive data before function return
    mov     x0, xzr                  //  Clear return value if not needed
    mov     x1, xzr                  //  Clear argument registers
    
    //  Platform-specific considerations:
    //  - x18 is reserved on Apple Silicon (platform register)
    //  - Maintain 16-byte stack alignment at all times
    //  - Preserve callee-saved registers (x19-x30) when modifying them
    
    //  Exit with success code
    //  Linux syscall: x8 = 93 (SYS_exit), x0 = exit code
    mov     x0, #0                   //  Exit code 0
    mov     x8, #93                  //  Linux exit syscall (SYS_exit)
    svc     #0
    
    //  Halt loop - defensive programming to stop execution after syscall
halt_loop:
    b       halt_loop
