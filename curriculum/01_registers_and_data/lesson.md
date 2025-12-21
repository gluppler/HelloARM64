# Lesson 01: Registers and Data

> **References**: This lesson is cross-referenced with [`references/registers_and_flags.md`](../references/registers_and_flags.md) and [`references/arm_architecture.md`](../references/arm_architecture.md) for authoritative ARM64 register architecture documentation.

## Learning Objectives

By the end of this lesson, you will be able to:
- Understand ARM64 register architecture
- Distinguish between 64-bit and 32-bit register usage
- Use the zero register effectively
- Understand condition flags (NZCV)
- Load immediate values and perform basic data movement

## Register Architecture

### General-Purpose Registers

ARM64 provides 31 general-purpose registers (X0-X30), each 64 bits wide.

**Reference**: See [`references/registers_and_flags.md`](../references/registers_and_flags.md) - General-Purpose Registers section. Original source: ARMv8-A Architecture Reference Manual, Section B1.1.1, AAPCS64 Section 5.1.1

#### Register Categories

**Argument/Result Registers (X0-X7)**
- Used for function arguments and return values
- Caller-saved (may be modified by called functions)
- X0 typically holds return value

**Temporary Registers (X9-X15)**
- Scratch registers for temporary values
- Caller-saved
- Can be freely used within functions

**Callee-Saved Registers (X19-X28)**
- Must be preserved by functions
- Use for values that must survive function calls
- Save to stack if modified

**Special Registers**
- **X29 (FP)**: Frame pointer
- **X30 (LR)**: Link register (return address)
- **XZR**: Zero register (always 0)

**Reference**: AAPCS64 (IHI0055), Section 5.1.1

### 32-bit vs 64-bit Access

#### 64-bit Registers (X0-X30)
```assembly
MOV  X0, #0x1234567890ABCDEF  // Full 64-bit value
ADD  X0, X1, X2               // 64-bit arithmetic
```

#### 32-bit Registers (W0-W30)
- Access lower 32 bits of X registers
- Writing to Wn zero-extends to Xn
- Reading Wn reads lower 32 bits

```assembly
MOV  W0, #100                 // 32-bit value, zero-extended to X0
ADD  W0, W1, W2               // 32-bit arithmetic
LDR  W0, [X1]                 // Load 32-bit value
```

**Why use 32-bit?**
- Smaller instruction encoding
- Better performance for values that fit in 32 bits
- Memory efficiency

**Reference**: ARMv8-A Architecture Reference Manual, Section B1.1.1

### Zero Register (XZR/WZR)

The zero register always reads as 0 and discards writes.

```assembly
MOV  X0, XZR                 // X0 = 0
ADD  X0, X1, XZR             // X0 = X1 + 0 = X1
CMP  X0, XZR                 // Compare X0 with 0
```

**Common uses**:
- Clearing registers
- Comparisons with zero
- Subtracting from zero (negation)

**Reference**: ARMv8-A Architecture Reference Manual, Section B1.1.2

## Stack Pointer (SP)

### Stack Pointer Characteristics
- 64-bit register
- Must be 16-byte aligned at all times
- Grows downward (decrements on allocation)
- Cannot be used as general-purpose register in most contexts

**Reference**: AAPCS64 (IHI0055), Section 5.2.3

### Stack Operations
```assembly
SUB  SP, SP, #16             // Allocate 16 bytes
ADD  SP, SP, #16             // Deallocate 16 bytes
STR  X0, [SP, #-16]!         // Pre-indexed store (SP updated)
LDR  X0, [SP], #16           // Post-indexed load (SP updated)
```

**Why 16-byte alignment?**
- Required by AAPCS64 ABI
- Enables efficient load/store pair operations
- Alignment faults if violated

**Reference**: ARMv8-A Architecture Reference Manual, Section B2.5.1

## Condition Flags (NZCV)

### Flag Register (PSTATE)

The processor state includes condition flags that are set by arithmetic and comparison operations.

**Reference**: ARMv8-A Architecture Reference Manual, Section B1.2.1

#### N (Negative)
- Set when result MSB is 1 (negative in two's complement)
- Cleared when result is non-negative

#### Z (Zero)
- Set when result is exactly zero
- Cleared when result is non-zero

#### C (Carry)
- Set when unsigned addition overflows
- Set when unsigned subtraction underflows (no borrow)
- Used for unsigned comparisons

#### V (Overflow)
- Set when signed addition/subtraction overflows
- Used for signed comparisons

### Setting Flags

Instructions with 'S' suffix set condition flags:

```assembly
ADDS X0, X1, X2             // Add and set flags
SUBS X0, X1, X2             // Subtract and set flags
ADDS W0, W1, W2             // 32-bit add with flags
```

Comparison instructions always set flags:

```assembly
CMP  X0, X1                  // Compare (X0 - X1, sets flags)
TST  X0, X1                  // Test bits (X0 & X1, sets flags)
CMN  X0, X1                  // Compare negative (X0 + X1, sets flags)
```

**Reference**: ARM A64 ISA (DDI0602), Section C6.2.6

### Using Flags

Conditional branches use flags:

```assembly
CMP  X0, X1
B.EQ equal_label             // Branch if equal (Z=1)
B.NE not_equal_label         // Branch if not equal (Z=0)
B.GT greater_label          // Branch if greater (signed)
B.HI higher_label            // Branch if higher (unsigned)
```

**Reference**: ARM A64 ISA (DDI0602), Section C6.4.2

## Immediate Values

### Loading Immediate Values

#### Small Immediate (12-bit)
```assembly
MOV  X0, #42                 // 12-bit immediate (0-4095)
MOV  X0, #0xFFF              // Maximum 12-bit value
```

#### Large Immediate (16-bit with shift)
```assembly
MOV  X0, #0x1234, LSL #0     // 16-bit value
MOV  X0, #0x12, LSL #8       // 8-bit value shifted left
```

#### Very Large Immediate
```assembly
// Use MOVZ (move with zero), MOVN (move with not), MOVK (move with keep)
MOVZ X0, #0x1234, LSL #0     // Lower 16 bits
MOVK X0, #0x5678, LSL #16    // Middle 16 bits
MOVK X0, #0x9ABC, LSL #32    // Upper 16 bits
MOVK X0, #0xDEF0, LSL #48    // Top 16 bits
// Result: X0 = 0xDEF09ABC56781234
```

**Reference**: ARM A64 ISA (DDI0602), Section C1.2

### Immediate Encoding Limitations

Not all values can be encoded as immediates:
- Arithmetic immediates: 12-bit with optional 12-bit shift
- Logical immediates: Complex bitmask encoding
- Load/store offsets: 9-bit signed or 12-bit unsigned

**Solution**: Load from memory or construct with multiple instructions.

## Data Movement

### MOV Instruction

```assembly
MOV  X0, X1                  // X0 = X1 (alias for ORR X0, XZR, X1)
MOV  X0, #42                 // X0 = 42
MOV  W0, W1                  // W0 = W1 (32-bit)
```

### ADR (Address)

```assembly
ADR  X0, label               // Load address of label into X0
ADRP X0, label               // Load page address (4KB aligned)
```

**Use cases**:
- Loading addresses of data
- PC-relative addressing

**Reference**: ARM A64 ISA (DDI0602), Section C6.2.8

## Practical Examples

### Example 1: Register Operations
```assembly
.section .text
.global _start
_start:
    // Load immediate values
    MOV  X0, #10             // X0 = 10
    MOV  X1, #20             // X1 = 20
    
    // Copy register
    MOV  X2, X0              // X2 = X0 = 10
    
    // Clear register (using zero register)
    MOV  X3, XZR             // X3 = 0
    
    // Add with flags
    ADDS X4, X0, X1          // X4 = 30, flags set
    
    // Compare
    CMP  X0, X1              // Compare 10 and 20, flags set
    // Z=0 (not equal), N=1 (10-20 is negative)
    
    // Exit
    MOV  X8, #93
    MOV  X0, #0
    SVC  #0
```

### Example 2: 32-bit vs 64-bit
```assembly
.section .text
.global _start
_start:
    // 64-bit operations
    MOV  X0, #0x1234567890ABCDEF
    MOV  X1, #0xFFFFFFFFFFFFFFFF
    ADD  X2, X0, X1          // 64-bit addition
    
    // 32-bit operations
    MOV  W3, #0x12345678
    MOV  W4, #0xFFFFFFFF
    ADD  W5, W3, W4          // 32-bit addition, zero-extended to X5
    
    // Exit
    MOV  X8, #93
    MOV  X0, #0
    SVC  #0
```

### Example 3: Condition Flags
```assembly
.section .text
.global _start
_start:
    MOV  X0, #10
    MOV  X1, #20
    
    // Compare and check flags
    CMP  X0, X1              // 10 - 20 = -10
    // N=1 (negative), Z=0 (not zero), C=0 (borrow), V=0 (no overflow)
    
    // Compare equal values
    MOV  X2, #10
    CMP  X0, X2              // 10 - 10 = 0
    // N=0, Z=1 (zero!), C=1 (no borrow), V=0
    
    // Add with overflow check
    MOV  X3, #0x7FFFFFFFFFFFFFFF  // Max positive signed
    MOV  X4, #1
    ADDS X5, X3, X4          // Overflow!
    // V=1 (overflow detected)
    
    // Exit
    MOV  X8, #93
    MOV  X0, #0
    SVC  #0
```

## Exercises

1. **Register Basics**: Write a program that:
   - Loads values into X0-X7
   - Copies X0 to X8
   - Clears X9 using the zero register
   - Adds X0 and X1, storing result in X2

2. **32-bit Operations**: Write a program that:
   - Performs 32-bit arithmetic
   - Demonstrates zero extension
   - Compares 32-bit and 64-bit results

3. **Condition Flags**: Write a program that:
   - Sets flags with ADDS
   - Compares values with CMP
   - Demonstrates all four flags (NZCV)

## Key Takeaways

- ARM64 has 31 general-purpose 64-bit registers (X0-X30)
- 32-bit access (W0-W30) zero-extends to 64-bit
- Zero register (XZR) is useful for comparisons and clearing
- Stack pointer (SP) must be 16-byte aligned
- Condition flags (NZCV) are set by arithmetic and comparison operations
- Immediate values have encoding limitations; use multiple instructions for large values

## Next Steps

- Lesson 02: Instruction Basics - Learn core ARM64 instructions
- Practice with register operations
- Experiment with condition flags in GDB

## References

- ARMv8-A Architecture Reference Manual (DDI0487), Section B1.1
- AAPCS64 (IHI0055), Section 5.1.1
- ARM A64 ISA (DDI0602), Section C6.2
- ARM Developer Documentation - Registers
