
.text
//  Fundamentals/08_Arithmetic_Advanced.s
//  Advanced Arithmetic: extended operations, bit manipulation, division
//  Demonstrates arithmetic operations with overflow detection and division by zero prevention

.global _start
.align 4

_start:
    //  ============================================
    //  EXTENDED ARITHMETIC
    //  ============================================
    
    //  umull: Unsigned multiply long (64-bit result from 32-bit operands)
    mov     w0, #1000
    mov     w1, #2000
    umull   x2, w0, w1               //  x2 = w0 * w1 (unsigned 64-bit)
    
    //  smull: Signed multiply long
    mov     w3, #-1000
    mov     w4, #2000
    smull   x5, w3, w4               //  x5 = w3 * w4 (signed 64-bit)
    
    //  umulh: Unsigned multiply high (high 64 bits of 128-bit product)
    movz    x6, #0xDEF0              //  Load 64-bit value
    movk    x6, #0x9ABC, lsl #16
    movk    x6, #0x5678, lsl #32
    movk    x6, #0x1234, lsl #48
    movz    x7, #0x3210              //  Load 64-bit value
    movk    x7, #0x7654, lsl #16
    movk    x7, #0xBA98, lsl #32
    movk    x7, #0xFEDC, lsl #48
    umulh   x8, x6, x7               //  x8 = high 64 bits of (x6 * x7)
    
    //  smulh: Signed multiply high
    smulh   x9, x6, x7                //  x9 = high 64 bits (signed)
    
    //  ============================================
    //  DIVISION
    //  ============================================
    //  Note: AArch64 doesn't have hardware division in all implementations
    //  Use software division or check CPU features
    
    //  udiv: Unsigned divide
    mov     x10, #100
    mov     x11, #3
    udiv    x12, x10, x11             //  x12 = x10 / x11 (unsigned)
    
    //  sdiv: Signed divide
    mov     x13, #-100
    mov     x14, #3
    sdiv    x15, x13, x14             //  x15 = x13 / x14 (signed)
    
    //  Division by zero check
    mov     x16, #100
    mov     x17, #0
    cmp     x17, #0
    b.eq    division_by_zero_error    //  Prevent division by zero
    udiv    x18, x16, x17
    
    //  ============================================
    //  MODULO OPERATIONS
    //  ============================================
    
    //  Use msub to compute modulo: a % b = a - (a / b) * b
    mov     x19, #100
    mov     x20, #7
    udiv    x21, x19, x20             //  x21 = x19 / x20
    msub    x22, x21, x20, x19        //  x22 = x19 - (x21 * x20) = x19 % x20
    
    //  ============================================
    //  BIT MANIPULATION
    //  ============================================
    
    mov     x23, #0b10101010
    
    //  clz: Count leading zeros
    clz     x24, x23                  //  x24 = number of leading zeros in x23
    
    //  cls: Count leading sign bits
    cls     x25, x23                  //  x25 = number of leading sign bits
    
    //  rbit: Reverse bits
    rbit    x26, x23                  //  x26 = x23 with bits reversed
    
    //  rev: Reverse bytes (endianness swap)
    movz    x27, #0xDEF0             //  Load 64-bit value
    movk    x27, #0x9ABC, lsl #16
    movk    x27, #0x5678, lsl #32
    movk    x27, #0x1234, lsl #48
    rev     x28, x27                  //  x28 = x27 with bytes reversed (64-bit)
    rev16   x29, x27                  //  Reverse bytes in each 16-bit halfword
    rev32   x30, x27                  //  Reverse bytes in each 32-bit word
    
    //  ============================================
    //  BIT FIELD OPERATIONS
    //  ============================================
    
    movz    x0, #0xDEF0              //  Load 64-bit value
    movk    x0, #0x9ABC, lsl #16
    movk    x0, #0x5678, lsl #32
    movk    x0, #0x1234, lsl #48
    
    //  bfm: Bit field move (insert bit field)
    bfm     x1, x0, #4, #8            //  Insert bits 4-8 from x0 into x1
    
    //  sbfm: Signed bit field move
    sbfm    x2, x0, #0, #15           //  Extract and sign-extend bits 0-15
    
    //  ubfm: Unsigned bit field move
    ubfm    x3, x0, #0, #15           //  Extract bits 0-15 (zero-extended)
    
    //  bfi: Bit field insert (alias for bfm)
    mov     x4, #0
    mov     x5, #0xFF
    bfi     x4, x5, #8, #8            //  Insert x5[7:0] into x4[15:8]
    
    //  bfxil: Bit field extract and insert low (alias for bfm)
    bfxil   x6, x0, #0, #16           //  Extract bits 0-15 and insert at low bits
    
    //  sbfiz: Signed bit field insert zero (alias for sbfm)
    sbfiz   x7, x0, #16, #8           //  Extract bits, sign-extend, shift left 16
    
    //  ubfiz: Unsigned bit field insert zero (alias for ubfm)
    ubfiz   x8, x0, #16, #8           //  Extract bits, zero-extend, shift left 16
    
    //  ============================================
    //  POPULATION COUNT
    //  ============================================
    
    mov     x9, #0b1010101010101010
    
    //  clz: Count leading zeros (already shown)
    //  ctz: Count trailing zeros (not directly available, use rbit + clz)
    rbit    x10, x9                   //  Reverse bits
    clz     x11, x10                  //  Count leading zeros in reversed = trailing zeros in original
    
    //  ============================================
    //  OVERFLOW DETECTION
    //  ============================================
    //  Check for arithmetic overflow in critical operations
    
    //  Check addition overflow
    movz    x12, #0xFFFF             //  Max positive signed 64-bit (0x7FFFFFFFFFFFFFFF)
    movk    x12, #0xFFFF, lsl #16
    movk    x12, #0xFFFF, lsl #32
    movk    x12, #0x7FFF, lsl #48
    mov     x13, #1
    adds    x14, x12, x13             //  Add and set flags
    b.vs    addition_overflow         //  Branch if overflow (V flag set)
    
    //  Check subtraction overflow
    movz    x15, #0                  //  Min negative signed 64-bit (0x8000000000000000)
    movk    x15, #0x8000, lsl #48
    mov     x16, #1
    subs    x17, x15, x16             //  Subtract and set flags
    b.vs    subtraction_overflow      //  Branch if overflow
    
    //  Check multiplication overflow
    mov     x18, #0x100000000         //  Large value
    mov     x19, #0x100000000
    mul     x20, x18, x19             //  Multiply
    umulh   x21, x18, x19             //  Get high bits
    cmp     x21, #0
    b.ne    multiplication_overflow    //  Overflow if high bits non-zero
    
    b       no_overflow
    
addition_overflow:
subtraction_overflow:
multiplication_overflow:
    //  Handle overflow error
    mov     x0, #1
    b       exit_error
    
no_overflow:
division_by_zero_error:
    //  ============================================
    //  ABSOLUTE VALUE
    //  ============================================
    
    mov     x22, #-100
    cmp     x22, #0
    b.ge    already_positive
    neg     x22, x22                 //  x22 = -x22 (two's complement)
    
already_positive:
    //  x22 now contains absolute value
    
    //  ============================================
    //  MIN/MAX OPERATIONS
    //  ============================================
    
    mov     x23, #10
    mov     x24, #20
    
    //  Minimum (using conditional select)
    cmp     x23, x24
    csel    x25, x23, x24, lt        //  x25 = (x23 < x24) ? x23 : x24
    
    //  Maximum
    csel    x26, x23, x24, gt        //  x26 = (x23 > x24) ? x23 : x24
    
    //  ============================================
    //  ROUNDING OPERATIONS
    //  ============================================
    
    //  Round to nearest (for division)
    mov     x27, #100
    mov     x28, #3
    udiv    x29, x27, x28            //  x29 = 33 (truncated)
    //  For rounding: (a + b/2) / b
    lsr     x30, x28, #1             //  x30 = b/2
    add     x0, x27, x30             //  x0 = a + b/2
    udiv    x1, x0, x28              //  x1 = (a + b/2) / b (rounded)
    
    //  ============================================
    //  ARITHMETIC BEST PRACTICES
    //  ============================================
    //  Always check for division by zero before division operations
    //  Validate operands before arithmetic operations
    //  Check for overflow in critical operations using flag checks
    //  Use appropriate signed/unsigned operations based on data semantics
    //  5. Clear sensitive intermediate values
    
    //  Clear working registers
    mov     x0, xzr
    mov     x1, xzr
    
    //  Exit
    //  Linux syscall: x8 = 93 (SYS_exit), x0 = exit code
    mov     x0, #0
    mov     x8, #93                  //  Linux exit syscall (SYS_exit)
    svc     #0

exit_error:
    //  Linux syscall: x8 = 93 (SYS_exit), x0 = exit code
    mov     x0, #1
    mov     x8, #93                  //  Linux exit syscall (SYS_exit)
    svc     #0
