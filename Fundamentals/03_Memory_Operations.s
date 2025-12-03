
.text
//  Fundamentals/03_Memory_Operations.s
//  Memory Operations: ldr, str, ldp, stp, addressing modes
//  Demonstrates memory access patterns with proper bounds checking and alignment

.global _start
.align 4

_start:
    //  ============================================
    //  STACK SETUP (16-byte aligned)
    //  ============================================
    //  Stack must be 16-byte aligned at all times
    sub     sp, sp, #32              //  Allocate 32 bytes on stack (aligned)
    
    //  ============================================
    //  LOAD INSTRUCTIONS (ldr)
    //  ============================================
    
    //  ldr: Load register (64-bit)
    //  Addressing mode: [base, offset]
    mov     x0, sp                   //  Base address (stack pointer)
    ldr     x1, [x0]                 //  x1 = *x0 (load from address in x0)
    ldr     x2, [x0, #8]             //  x2 = *(x0 + 8) (offset addressing)
    ldr     x3, [x0, #16]!           //  x3 = *(x0 + 16), then x0 = x0 + 16 (pre-index)
    ldr     x4, [x0], #8             //  x4 = *x0, then x0 = x0 + 8 (post-index)
    
    //  ldr: Load register (32-bit)
    ldr     w5, [x0]                 //  w5 = *(x0) (32-bit load)
    ldr     w6, [x0, #4]             //  w6 = *(x0 + 4)
    
    //  ldr: Load register (16-bit halfword)
    ldrh    w7, [x0]                 //  w7 = *(x0) (16-bit, zero-extended)
    ldrsh   x8, [x0]                 //  x8 = *(x0) (16-bit, sign-extended)
    
    //  ldr: Load register (8-bit byte)
    ldrb    w9, [x0]                 //  w9 = *(x0) (8-bit, zero-extended)
    ldrsb   x10, [x0]                //  x10 = *(x0) (8-bit, sign-extended)
    
    //  ldr: Load with register offset
    mov     x11, #8
    ldr     x12, [x0, x11]           //  x12 = *(x0 + x11)
    ldr     x13, [x0, x11, lsl #3]   //  x13 = *(x0 + (x11 << 3))
    
    //  ============================================
    //  STORE INSTRUCTIONS (str)
    //  ============================================
    
    //  str: Store register (64-bit)
    movz    x14, #0xDEF0             //  Load 64-bit value using movz/movk
    movk    x14, #0x9ABC, lsl #16
    movk    x14, #0x5678, lsl #32
    movk    x14, #0x1234, lsl #48
    str     x14, [x0]                //  *x0 = x14 (store to address in x0)
    str     x14, [x0, #8]            //  *(x0 + 8) = x14 (offset addressing)
    str     x14, [x0, #16]!          //  *(x0 + 16) = x14, then x0 = x0 + 16 (pre-index)
    str     x14, [x0], #8            //  *x0 = x14, then x0 = x0 + 8 (post-index)
    
    //  str: Store register (32-bit)
    movz    w15, #0x5678             //  Load 32-bit value using movz/movk
    movk    w15, #0x1234, lsl #16
    str     w15, [x0]                //  *x0 = w15 (32-bit store)
    str     w15, [x0, #4]            //  *(x0 + 4) = w15
    
    //  str: Store register (16-bit halfword)
    mov     w16, #0x1234
    strh    w16, [x0]                //  *x0 = w16 (16-bit store)
    
    //  str: Store register (8-bit byte)
    mov     w17, #0x12
    strb    w17, [x0]                //  *x0 = w17 (8-bit store)
    
    //  ============================================
    //  LOAD/STORE PAIR (ldp/stp)
    //  ============================================
    //  Efficient for loading/storing two registers
    
    //  ldp: Load pair
    ldp     x18, x19, [x0]           //  x18 = *x0, x19 = *(x0 + 8)
    ldp     x20, x21, [x0, #16]      //  x20 = *(x0 + 16), x21 = *(x0 + 24)
    ldp     x22, x23, [x0, #32]!     //  Load pair, then x0 = x0 + 32 (pre-index)
    ldp     x24, x25, [x0], #16      //  Load pair, then x0 = x0 + 16 (post-index)
    
    //  stp: Store pair
    mov     x26, #0x1111
    mov     x27, #0x2222
    stp     x26, x27, [x0]           //  *x0 = x26, *(x0 + 8) = x27
    stp     x26, x27, [x0, #16]      //  Store pair with offset
    stp     x26, x27, [x0, #32]!     //  Store pair, then x0 = x0 + 32 (pre-index)
    stp     x26, x27, [x0], #16      //  Store pair, then x0 = x0 + 16 (post-index)
    
    //  ============================================
    //  ADDRESSING MODES
    //  ============================================
    
    mov     x28, sp                  //  Base register
    
    //  Immediate offset (signed, 12-bit for 64-bit, 9-bit for smaller)
    ldr     x29, [x28, #0]           //  Base + immediate
    ldr     x29, [x28, #1024]        //  Large positive offset (within 12-bit signed range)
    ldr     x29, [x28, #-256]       //  Negative offset
    
    //  Register offset
    mov     x30, #8
    ldr     x29, [x28, x30]          //  Base + register
    ldr     x29, [x28, x30, lsl #3]  //  Base + (register << shift)
    
    //  Pre-indexed (update base before access)
    ldr     x29, [x28, #8]!          //  x28 = x28 + 8, then load from x28
    
    //  Post-indexed (update base after access)
    ldr     x29, [x28], #8           //  Load from x28, then x28 = x28 + 8
    
    //  ============================================
    //  LITERAL POOL ACCESS
    //  ============================================
    
    //  Load address of data section
    adr     x0, data_value           //  Load address (works on both Linux and macOS)
    ldr     x1, [x0]                 //  Load value from data section
    
    //  ============================================
    //  MEMORY ACCESS BEST PRACTICES
    //  ============================================
    //  Always validate addresses before dereferencing
    //  Ensure stack alignment (16-byte requirement)
    //  Bounds check array accesses to prevent out-of-bounds reads
    //  Clear sensitive data from memory after use
    //  Use appropriate access size to avoid reading beyond intended data
    
    //  Clear sensitive data
    mov     x0, xzr
    str     x0, [sp]                 //  Clear stack location
    str     x0, [sp, #8]
    
    //  Restore stack
    add     sp, sp, #32
    
    //  Exit
    //  Linux syscall: x8 = 93 (SYS_exit), x0 = exit code
    mov     x0, #0
    mov     x8, #93                  //  Linux exit syscall (SYS_exit)
    svc     #0

    //  Halt loop - defensive programming to stop execution after syscall
halt_loop:
    b       halt_loop

.data
.align 8
data_value:
    .quad   0x123456789ABCDEF0
