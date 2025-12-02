//  Fundamentals/02_Basic_Instructions.s
//  Basic AArch64 Instructions: mov, add, sub, mul, and, orr, eor, etc.

.global _start
.align 4

_start:
    //  ============================================
    //  MOVE INSTRUCTIONS
    //  ============================================
    
    //  mov: Move immediate or register (alias for orr with zero)
    mov     x0, #42                  //  x0 = 42 (immediate)
    mov     x1, x0                   //  x1 = x0 (register copy)
    
    //  movz: Move with zero (16-bit immediate, shifted)
    movz    x2, #0x1234              //  x2 = 0x0000000000001234
    movz    x3, #0x5678, lsl #16     //  x3 = 0x0000000056780000
    
    //  movk: Move with keep (preserves other bits)
    movk    x3, #0x9ABC, lsl #32     //  x3 = 0x00009ABC56780000
    
    //  movn: Move with NOT (bitwise complement)
    movn    x4, #0                   //  x4 = 0xFFFFFFFFFFFFFFFF
    
    //  ============================================
    //  ARITHMETIC INSTRUCTIONS
    //  ============================================
    
    //  add: Addition
    mov     x5, #10
    mov     x6, #20
    add     x7, x5, x6               //  x7 = x5 + x6 = 30
    add     x8, x5, #5               //  x8 = x5 + 5 = 15 (immediate)
    add     x9, x5, x6, lsl #2       //  x9 = x5 + (x6 << 2) = 10 + 80 = 90
    
    //  adc: Add with carry
    mov     x10, #0xFFFFFFFFFFFFFFFF
    mov     x11, #1
    adc     x12, x10, x11            //  x12 = x10 + x11 + C (carry flag)
    
    //  sub: Subtraction
    mov     x13, #50
    mov     x14, #30
    sub     x15, x13, x14            //  x15 = x13 - x14 = 20
    sub     x16, x13, #10            //  x16 = x13 - 10 = 40 (immediate)
    
    //  sbc: Subtract with carry
    mov     x17, #0
    mov     x18, #1
    sbc     x19, x17, x18            //  x19 = x17 - x18 - (1 - C)
    
    //  mul: Multiply (32x32 or 64x64)
    mov     x20, #6
    mov     x21, #7
    mul     x22, x20, x21            //  x22 = x20 * x21 = 42
    
    //  madd: Multiply and add
    mov     x23, #5
    mov     x24, #4
    mov     x25, #10
    madd    x26, x23, x24, x25       //  x26 = (x23 * x24) + x25 = 30
    
    //  msub: Multiply and subtract
    msub    x27, x23, x24, x25       //  x27 = x25 - (x23 * x24) = -10
    
    //  smull: Signed multiply long (64-bit result from 32-bit operands)
    mov     w28, #1000
    mov     w29, #2000
    smull   x30, w28, w29            //  x30 = w28 * w29 (signed 64-bit)
    
    //  ============================================
    //  LOGICAL INSTRUCTIONS
    //  ============================================
    
    //  and: Bitwise AND
    mov     x0, #0b1010
    mov     x1, #0b1100
    and     x2, x0, x1               //  x2 = 0b1000
    
    //  orr: Bitwise OR
    orr     x3, x0, x1               //  x3 = 0b1110
    
    //  eor: Bitwise XOR (exclusive OR)
    eor     x4, x0, x1               //  x4 = 0b0110
    
    //  bic: Bit clear (AND with NOT)
    bic     x5, x0, x1               //  x5 = x0 & ~x1 = 0b0010
    
    //  orn: Bitwise OR with NOT
    orn     x6, x0, x1               //  x6 = x0 | ~x1
    
    //  eon: Bitwise XOR with NOT
    eon     x7, x0, x1               //  x7 = x0 ^ ~x1
    
    //  ============================================
    //  SHIFT INSTRUCTIONS
    //  ============================================
    
    mov     x8, #0b1010
    
    //  lsl: Logical shift left
    lsl     x9, x8, #2               //  x9 = x8 << 2 = 0b101000
    
    //  lsr: Logical shift right
    lsr     x10, x8, #1              //  x10 = x8 >> 1 = 0b0101
    
    //  asr: Arithmetic shift right (sign-extending)
    mov     x11, #0x8000000000000000
    asr     x12, x11, #1             //  x12 = x11 >> 1 (arithmetic)
    
    //  ror: Rotate right
    mov     x13, #0b1010
    ror     x14, x13, #2             //  x14 = rotate right by 2 bits
    
    //  ============================================
    //  COMPARISON INSTRUCTIONS
    //  ============================================
    
    mov     x15, #10
    mov     x16, #20
    
    //  cmp: Compare (subtract, sets flags, discards result)
    cmp     x15, x16                 //  Sets flags: x15 - x16
    //  Result: N=1 (negative), Z=0, C=0, V=0
    
    //  cmn: Compare negative (add, sets flags)
    cmn     x15, x16                 //  Sets flags: x15 + x16
    
    //  tst: Test bits (AND, sets flags, discards result)
    tst     x15, #0b1111             //  Sets flags: x15 & 0b1111
    
    //  ============================================
    //  EXTEND INSTRUCTIONS
    //  ============================================
    
    mov     w17, #0x8000             //  16-bit value in 32-bit register
    
    //  sxtb: Sign extend byte
    sxtb    x18, w17                 //  Sign extend byte to 64-bit
    
    //  sxth: Sign extend halfword
    sxth    x19, w17                 //  Sign extend halfword to 64-bit
    
    //  sxtw: Sign extend word
    sxtw    x20, w17                 //  Sign extend word to 64-bit
    
    //  uxtb: Zero extend byte
    uxtb    x21, w17                 //  Zero extend byte to 64-bit
    
    //  uxth: Zero extend halfword
    uxth    x22, w17                 //  Zero extend halfword to 64-bit
    
    //  uxtw: Zero extend word
    uxtw    x23, w17                 //  Zero extend word to 64-bit
    
    //  ============================================
    //  SECURE PRACTICES
    //  ============================================
    //  1. Check for overflow in arithmetic operations
    //  2. Validate immediate values are within range
    //  3. Use appropriate signed/unsigned operations
    //  4. Clear sensitive intermediate values
    
    //  Clear working registers
    mov     x0, xzr
    mov     x1, xzr
    
    //  Exit
    mov     x0, #0
    movz    x16, #0x0001
    movk    x16, #0x0200, lsl #16
    svc     #0
