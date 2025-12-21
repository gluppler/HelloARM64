# Lesson 05: Functions and ABI

> **References**: This lesson is cross-referenced with [`references/calling_conventions.md`](../references/calling_conventions.md) for complete AAPCS64 documentation and [`references/registers_and_flags.md`](../references/registers_and_flags.md) for register usage conventions.

## Learning Objectives

By the end of this lesson, you will be able to:
- Understand AAPCS64 calling convention
- Write functions with proper prologue/epilogue
- Pass arguments and return values correctly
- Manage caller-saved and callee-saved registers
- Implement leaf function optimizations

## AAPCS64 Overview

The Procedure Call Standard for ARM 64-bit Architecture defines how functions are called, arguments passed, and values returned.

**Reference**: AAPCS64 (IHI0055)

## Register Usage

### Argument Registers
- **X0-X7**: Integer/pointer arguments (first 8)
- **V0-V7**: Floating-point/vector arguments (first 8)
- **Stack**: Additional arguments

**Reference**: AAPCS64 (IHI0055), Section 5.4.2

### Return Value Registers
- **X0/X1**: Integer/pointer return values
- **V0/V1**: Floating-point/vector return values

**Reference**: AAPCS64 (IHI0055), Section 5.5

### Caller-Saved vs Callee-Saved
- **Caller-saved**: X0-X7, X9-X15, X16-X17, X18, X30, V0-V7, V16-V31
- **Callee-saved**: X19-X28, X29 (FP), V8-V15

**Reference**: AAPCS64 (IHI0055), Section 5.1.1

## Function Prologue

### Standard Prologue
```assembly
my_function:
    STP  X29, X30, [SP, #-16]!  // Save FP and LR
    MOV  X29, SP                 // Set frame pointer
    SUB  SP, SP, #local_size     // Allocate local variables
    // Save callee-saved registers if used
    STP  X19, X20, [SP, #-16]!
```

**Reference**: AAPCS64 (IHI0055), Section 5.2.2

## Function Epilogue

### Standard Epilogue
```assembly
    // Restore callee-saved registers
    LDP  X19, X20, [SP], #16
    MOV  SP, X29                 // Restore stack pointer
    LDP  X29, X30, [SP], #16     // Restore FP and LR
    RET                          // Return
```

**Reference**: AAPCS64 (IHI0055), Section 5.2.2

## Function Examples

### Simple Function
```assembly
add_numbers:
    ADD  X0, X0, X1              // X0 = X0 + X1 (arguments in X0, X1)
    RET                          // Return value in X0
```

### Function with Frame
```assembly
complex_function:
    STP  X29, X30, [SP, #-16]!
    MOV  X29, SP
    SUB  SP, SP, #32
    
    // Function body
    STR  X0, [SP, #0]            // Save first argument
    LDR  X1, [SP, #0]            // Load it back
    
    MOV  SP, X29
    LDP  X29, X30, [SP], #16
    RET
```

### Calling Functions
```assembly
    MOV  X0, #10                 // First argument
    MOV  X1, #20                 // Second argument
    BL   add_numbers              // Call function
    // Return value in X0
```

## Leaf Functions

Leaf functions (no function calls) can omit frame setup:

```assembly
leaf_add:
    ADD  X0, X0, X1
    RET
```

**Reference**: AAPCS64 (IHI0055), Section 5.2.2

## Exercises

1. Write a function that adds three numbers
2. Implement a function with local variables
3. Create a leaf function optimization

## Key Takeaways

- AAPCS64 defines calling conventions
- Arguments in X0-X7, return in X0
- Save/restore callee-saved registers
- Frame pointer (X29) points to frame record
- Leaf functions can be optimized

## Next Steps

- Lesson 06: System Calls - Learn OS interfaces
- Practice writing and calling functions
- Understand register preservation

## References

- AAPCS64 (IHI0055)
- ARMv8-A Architecture Reference Manual
