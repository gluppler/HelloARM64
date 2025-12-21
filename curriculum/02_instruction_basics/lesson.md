# Lesson 02: Instruction Basics

> **References**: This lesson is cross-referenced with [`references/instruction_set.md`](../references/instruction_set.md) and [`references/arm_architecture.md`](../references/arm_architecture.md) for complete A64 instruction set documentation.

## Learning Objectives

By the end of this lesson, you will be able to:
- Understand ARM64 instruction format and encoding
- Use arithmetic instructions (ADD, SUB, MUL)
- Use logical instructions (AND, ORR, EOR)
- Perform shift and rotate operations
- Understand instruction categories and their purposes

## Instruction Format

### Fixed-Length Instructions
- All A64 instructions are 32 bits wide
- Instructions are naturally aligned (4-byte boundaries)
- PC-relative addressing for many operations

**Reference**: ARM A64 ISA (DDI0602), Section A1.1

### Instruction Categories
1. **Data Processing**: Arithmetic, logical, bit manipulation
2. **Load/Store**: Memory access
3. **Branch**: Control flow
4. **System**: System registers, barriers
5. **SIMD/NEON**: Vector operations

## Arithmetic Instructions

### ADD (Add)
```assembly
ADD  Xd, Xn, Xm           // Xd = Xn + Xm
ADD  Xd, Xn, #imm         // Xd = Xn + immediate
ADDS Xd, Xn, Xm           // Add and set flags
```

**Architectural reasoning**: ADD performs two's complement addition. The 'S' suffix updates condition flags, enabling subsequent conditional operations.

**Reference**: ARM A64 ISA (DDI0602), Section C6.2.1

### SUB (Subtract)
```assembly
SUB  Xd, Xn, Xm           // Xd = Xn - Xm
SUB  Xd, Xn, #imm        // Xd = Xn - immediate
SUBS Xd, Xn, Xm          // Subtract and set flags
```

**Architectural reasoning**: SUB performs two's complement subtraction. Internally implemented as addition with negation.

**Reference**: ARM A64 ISA (DDI0602), Section C6.2.2

### MUL (Multiply)
```assembly
MUL  Xd, Xn, Xm           // Xd = (Xn * Xm)[63:0] (lower 64 bits)
UMULH Xd, Xn, Xm          // Xd = (Xn * Xm)[127:64] (unsigned high)
SMULH Xd, Xn, Xm          // Xd = (Xn * Xm)[127:64] (signed high)
```

**Architectural reasoning**: MUL computes lower 64 bits of product. For full 128-bit result, use UMULH/SMULH for upper bits.

**Reference**: ARM A64 ISA (DDI0602), Section C6.2.3

## Logical Instructions

### AND (Bitwise AND)
```assembly
AND  Xd, Xn, Xm           // Xd = Xn & Xm
AND  Xd, Xn, #imm        // Xd = Xn & immediate
```

**Use cases**: Masking bits, clearing bits, testing bits

**Reference**: ARM A64 ISA (DDI0602), Section C6.2.4

### ORR (Bitwise OR)
```assembly
ORR  Xd, Xn, Xm           // Xd = Xn | Xm
ORR  Xd, Xn, #imm        // Xd = Xn | immediate
```

**Use cases**: Setting bits, combining bit patterns

**Reference**: ARM A64 ISA (DDI0602), Section C6.2.4

### EOR (Bitwise Exclusive OR)
```assembly
EOR  Xd, Xn, Xm           // Xd = Xn ^ Xm
EOR  Xd, Xn, #imm        // Xd = Xn ^ immediate
```

**Use cases**: Toggling bits, swapping values (with three EORs)

**Reference**: ARM A64 ISA (DDI0602), Section C6.2.4

### BIC (Bit Clear)
```assembly
BIC  Xd, Xn, Xm           // Xd = Xn & ~Xm
```

**Use cases**: Clearing specific bits based on mask

**Reference**: ARM A64 ISA (DDI0602), Section C6.2.4

## Shift and Rotate Instructions

### LSL (Logical Shift Left)
```assembly
LSL  Xd, Xn, #imm         // Xd = Xn << imm
LSL  Xd, Xn, Xm           // Xd = Xn << Xm
```

**Architectural reasoning**: Left shift multiplies by 2^imm. Zeros fill from right.

**Reference**: ARM A64 ISA (DDI0602), Section C6.2.5

### LSR (Logical Shift Right)
```assembly
LSR  Xd, Xn, #imm         // Xd = Xn >> imm (unsigned)
LSR  Xd, Xn, Xm           // Xd = Xn >> Xm
```

**Architectural reasoning**: Right shift divides by 2^imm (unsigned). Zeros fill from left.

**Reference**: ARM A64 ISA (DDI0602), Section C6.2.5

### ASR (Arithmetic Shift Right)
```assembly
ASR  Xd, Xn, #imm         // Xd = Xn >> imm (signed, sign-extended)
ASR  Xd, Xn, Xm           // Xd = Xn >> Xm
```

**Architectural reasoning**: Preserves sign bit for signed division. Sign bit fills from left.

**Reference**: ARM A64 ISA (DDI0602), Section C6.2.5

### ROR (Rotate Right)
```assembly
ROR  Xd, Xn, #imm         // Rotate right by imm bits
ROR  Xd, Xn, Xm           // Rotate right by Xm bits
```

**Use cases**: Bit rotation, circular shifts

**Reference**: ARM A64 ISA (DDI0602), Section C6.2.5

## Comparison Instructions

### CMP (Compare)
```assembly
CMP  Xn, Xm               // Compare (sets flags, Xn - Xm)
CMP  Xn, #imm            // Compare with immediate
```

**Architectural reasoning**: CMP is alias for SUBS XZR, Xn, Xm. Sets flags without storing result.

**Reference**: ARM A64 ISA (DDI0602), Section C6.2.6

### TST (Test Bits)
```assembly
TST  Xn, Xm               // Test bits (sets flags, Xn & Xm)
TST  Xn, #imm            // Test with immediate
```

**Architectural reasoning**: TST is alias for ANDS XZR, Xn, Xm. Tests bit patterns without storing result.

**Reference**: ARM A64 ISA (DDI0602), Section C6.2.6

### CMN (Compare Negative)
```assembly
CMN  Xn, Xm               // Compare negative (sets flags, Xn + Xm)
```

**Use cases**: Comparing with negative values efficiently

**Reference**: ARM A64 ISA (DDI0602), Section C6.2.6

## Practical Examples

### Example 1: Arithmetic Operations
```assembly
.section .text
.global _start
_start:
    MOV  X0, #10
    MOV  X1, #20
    
    // Addition
    ADD  X2, X0, X1        // X2 = 30
    
    // Subtraction
    SUB  X3, X1, X0        // X3 = 10
    
    // Multiplication
    MUL  X4, X0, X1        // X4 = 200
    
    // Exit
    MOV  X8, #93
    MOV  X0, #0
    SVC  #0
```

### Example 2: Logical Operations
```assembly
.section .text
.global _start
_start:
    MOV  X0, #0b1010      // 10 in binary
    MOV  X1, #0b1100      // 12 in binary
    
    // AND: 1010 & 1100 = 1000 (8)
    AND  X2, X0, X1
    
    // OR: 1010 | 1100 = 1110 (14)
    ORR  X3, X0, X1
    
    // EOR: 1010 ^ 1100 = 0110 (6)
    EOR  X4, X0, X1
    
    // BIC: 1010 & ~1100 = 0010 (2)
    BIC  X5, X0, X1
    
    // Exit
    MOV  X8, #93
    MOV  X0, #0
    SVC  #0
```

### Example 3: Shift Operations
```assembly
.section .text
.global _start
_start:
    MOV  X0, #8            // 8 = 0b1000
    
    // Left shift: 8 << 2 = 32
    LSL  X1, X0, #2        // X1 = 32
    
    // Right shift: 8 >> 1 = 4
    LSR  X2, X0, #1        // X2 = 4
    
    // Arithmetic right shift (signed)
    MOV  X3, #-8           // -8 in two's complement
    ASR  X4, X3, #1        // X4 = -4 (sign preserved)
    
    // Exit
    MOV  X8, #93
    MOV  X0, #0
    SVC  #0
```

## Instruction Aliases

Many instructions have aliases for readability:

```assembly
MOV  Xd, Xn               // Alias for ORR Xd, XZR, Xn
MVN  Xd, Xn               // Alias for ORN Xd, XZR, Xn
NOP                       // Alias for HINT #0
```

**Reference**: ARM A64 ISA (DDI0602), Section C1.3

## Exercises

1. **Basic Arithmetic**: Write a program that calculates (a + b) * c - d
2. **Bit Manipulation**: Write a program that sets bit 5, clears bit 3, and toggles bit 7
3. **Shift Operations**: Write a program that multiplies by 8 and divides by 4 using shifts

## Key Takeaways

- ARM64 instructions are 32 bits wide and naturally aligned
- Arithmetic instructions (ADD, SUB, MUL) perform basic math operations
- Logical instructions (AND, ORR, EOR, BIC) manipulate bits
- Shift operations (LSL, LSR, ASR, ROR) move bits within registers
- Comparison instructions (CMP, TST, CMN) set flags without storing results
- Instruction aliases improve code readability

## Next Steps

- Lesson 03: Control Flow - Learn branching and loops
- Practice with arithmetic and logical operations
- Experiment with shift operations for optimization

## References

- ARM A64 Instruction Set Architecture (DDI0602), Section C6.2
- ARMv8-A Architecture Reference Manual (DDI0487)
- ARM Developer Documentation - Instruction Set
