# Lesson 04: Memory and Stack

> **References**: This lesson is cross-referenced with [`references/memory_management.md`](../references/memory_management.md) for memory operations and [`references/calling_conventions.md`](../references/calling_conventions.md) for stack frame management.

## Learning Objectives

By the end of this lesson, you will be able to:
- Load and store data from/to memory
- Understand addressing modes
- Manage stack frames correctly
- Use load/store pair instructions
- Understand memory alignment requirements

## Load/Store Instructions

### LDR (Load Register)
```assembly
LDR  Xd, [Xn]             // Load 64-bit from [Xn]
LDR  Wd, [Xn]             // Load 32-bit from [Xn]
LDR  Hd, [Xn]             // Load 16-bit (halfword)
LDR  Bd, [Xn]             // Load 8-bit (byte)
```

**Reference**: ARM A64 ISA (DDI0602), Section C6.3.1

### STR (Store Register)
```assembly
STR  Xd, [Xn]             // Store 64-bit to [Xn]
STR  Wd, [Xn]             // Store 32-bit to [Xn]
STR  Hd, [Xn]             // Store 16-bit
STR  Bd, [Xn]             // Store 8-bit
```

**Reference**: ARM A64 ISA (DDI0602), Section C6.3.2

## Addressing Modes

### Base Register
```assembly
LDR  Xd, [Xn]             // Address = Xn
```

### Immediate Offset
```assembly
LDR  Xd, [Xn, #imm]       // Address = Xn + imm
STR  Xd, [Xn, #imm]       // Address = Xn + imm
```

### Pre-indexed
```assembly
LDR  Xd, [Xn, #imm]!      // Xn = Xn + imm, then load from [Xn]
```

### Post-indexed
```assembly
LDR  Xd, [Xn], #imm       // Load from [Xn], then Xn = Xn + imm
```

### Register Offset
```assembly
LDR  Xd, [Xn, Xm]         // Address = Xn + Xm
LDR  Xd, [Xn, Xm, LSL #3] // Address = Xn + (Xm << 3)
```

**Reference**: ARM A64 ISA (DDI0602), Section C6.3.3

## Load/Store Pair

### LDP/STP (Load/Store Pair)
```assembly
LDP  Xd1, Xd2, [Xn]       // Load pair from [Xn] and [Xn+8]
STP  Xd1, Xd2, [Xn]       // Store pair to [Xn] and [Xn+8]
LDP  Xd1, Xd2, [Xn, #imm]! // Pre-indexed pair
LDP  Xd1, Xd2, [Xn], #imm  // Post-indexed pair
```

**Architectural reasoning**: Pair operations are more efficient than two separate loads/stores. Single instruction, atomic operation, better cache utilization.

**Reference**: ARM A64 ISA (DDI0602), Section C6.3.4

## Stack Operations

### Stack Frame Layout
```
High Address
    ...
    [Local variables]
    [Saved callee-saved registers]
    [Frame record]        <- X29 (FP) points here
        [FP+0]: Saved X29
        [FP+8]: Saved X30 (LR)
    [Outgoing arguments]
    ...
Low Address              <- SP points here (16-byte aligned)
```

**Reference**: AAPCS64 (IHI0055), Section 5.2.2

### Stack Allocation
```assembly
SUB  SP, SP, #16          // Allocate 16 bytes
ADD  SP, SP, #16          // Deallocate 16 bytes
```

### Saving Registers
```assembly
STP  X29, X30, [SP, #-16]! // Save FP and LR (pre-indexed)
STP  X19, X20, [SP, #-16]! // Save callee-saved registers
```

### Restoring Registers
```assembly
LDP  X19, X20, [SP], #16   // Restore callee-saved (post-indexed)
LDP  X29, X30, [SP], #16   // Restore FP and LR
```

## Alignment Requirements

### Natural Alignment
- 64-bit values: 8-byte aligned
- 32-bit values: 4-byte aligned
- 16-bit values: 2-byte aligned
- Stack pointer: 16-byte aligned (always)

**Reference**: ARMv8-A Architecture Reference Manual, Section B2.5.1

### Alignment Checking
```assembly
// Ensure alignment before access
AND  X0, X0, #~0x7        // Align X0 to 8-byte boundary
```

## Practical Examples

### Example 1: Basic Memory Operations
```assembly
.section .data
value:
    .quad 0x1234567890ABCDEF

.section .text
.global _start
_start:
    ADR  X0, value         // Load address
    LDR  X1, [X0]          // Load 64-bit value
    MOV  X2, #0xFFFFFFFFFFFFFFFF
    STR  X2, [X0]          // Store new value
    
    MOV  X8, #93
    MOV  X0, #0
    SVC  #0
```

### Example 2: Stack Operations
```assembly
.section .text
.global _start
_start:
    // Allocate stack frame
    SUB  SP, SP, #32       // Allocate 32 bytes
    
    // Store values on stack
    MOV  X0, #10
    STR  X0, [SP, #0]      // Store at SP+0
    MOV  X0, #20
    STR  X0, [SP, #8]      // Store at SP+8
    
    // Load values from stack
    LDR  X1, [SP, #0]      // Load from SP+0
    LDR  X2, [SP, #8]      // Load from SP+8
    
    // Deallocate stack frame
    ADD  SP, SP, #32
    
    MOV  X8, #93
    MOV  X0, #0
    SVC  #0
```

### Example 3: Load/Store Pair
```assembly
.section .text
.global _start
_start:
    SUB  SP, SP, #16
    
    MOV  X0, #10
    MOV  X1, #20
    STP  X0, X1, [SP]      // Store pair efficiently
    
    LDP  X2, X3, [SP]      // Load pair efficiently
    
    ADD  SP, SP, #16
    
    MOV  X8, #93
    MOV  X0, #0
    SVC  #0
```

## Exercises

1. **Memory Access**: Load and store values using different addressing modes
2. **Stack Management**: Create a function that uses local variables on the stack
3. **Pair Operations**: Optimize code using load/store pair instructions

## Key Takeaways

- Load/store instructions access memory
- Multiple addressing modes provide flexibility
- Stack must be 16-byte aligned
- Load/store pair is more efficient than separate operations
- Alignment is critical for correct operation

## Next Steps

- Lesson 05: Functions and ABI - Learn function calling conventions
- Practice stack frame management
- Understand memory layout and addressing

## References

- ARM A64 ISA (DDI0602), Section C6.3
- AAPCS64 (IHI0055), Section 5.2
- ARMv8-A Architecture Reference Manual, Section B2.5
