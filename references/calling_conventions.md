# Calling Conventions Reference

Complete reference for ARM64 calling conventions and Application Binary Interface (ABI).

**Source**: Procedure Call Standard for the ARM 64-bit Architecture (AAPCS64, IHI0055)

## AAPCS64 Overview

The Procedure Call Standard for the ARM 64-bit Architecture (AAPCS64) defines how functions are called, how arguments are passed, and how values are returned.

**Reference**: AAPCS64 (IHI0055), Section 1

## Register Usage

### Argument Registers
- **X0-X7**: Integer/pointer arguments (first 8 arguments)
- **V0-V7**: Floating-point/vector arguments (first 8 arguments)
- **Stack**: Additional arguments passed on stack

**Reference**: AAPCS64 (IHI0055), Section 5.4.2

### Return Value Registers
- **X0/X1**: Integer/pointer return values (up to 2 registers)
- **V0/V1**: Floating-point/vector return values (up to 2 registers)
- **X8**: Hidden pointer for large return values

**Reference**: AAPCS64 (IHI0055), Section 5.5

### Caller-Saved Registers
Must be preserved by caller if needed after function call:
- **X0-X7**: Argument/result registers
- **X9-X15**: Temporary registers
- **X16-X17**: IP0/IP1 (scratch registers)
- **X18**: Platform register
- **X30 (LR)**: Link register
- **V0-V7**: Floating-point argument/result registers
- **V16-V31**: Floating-point temporary registers

**Reference**: AAPCS64 (IHI0055), Section 5.1.1

### Callee-Saved Registers
Must be preserved by callee:
- **X19-X28**: General-purpose callee-saved
- **X29 (FP)**: Frame pointer
- **V8-V15**: Floating-point callee-saved

**Reference**: AAPCS64 (IHI0055), Section 5.1.1

## Stack Frame

### Stack Alignment
- Stack must be 16-byte aligned at all times
- Function entry must maintain 16-byte alignment
- Stack pointer (SP) must be 16-byte aligned

**Reference**: AAPCS64 (IHI0055), Section 5.2.3

### Frame Record
- **X29 (FP)**: Points to frame record
- Frame record contains:
  - [FP+0]: Previous frame pointer (saved X29)
  - [FP+8]: Return address (saved X30/LR)

**Reference**: AAPCS64 (IHI0055), Section 5.2.2

### Stack Frame Layout
```
High Address
    ...
    [Local variables]
    [Saved callee-saved registers]
    [Frame record]        <- X29 (FP) points here
        [FP+0]: Saved X29
        [FP+8]: Saved X30 (LR)
    [Outgoing arguments]  <- For called functions
    ...
Low Address              <- SP points here (16-byte aligned)
```

**Reference**: AAPCS64 (IHI0055), Section 5.2.2

## Function Prologue

### Standard Prologue
```assembly
my_function:
    // Save frame pointer and link register
    STP  X29, X30, [SP, #-16]!
    MOV  X29, SP                    // Set frame pointer
    
    // Allocate stack space for local variables
    SUB  SP, SP, #local_size
    
    // Save callee-saved registers if used
    STP  X19, X20, [SP, #-16]!
    // ... function body ...
```

**Reference**: AAPCS64 (IHI0055), Section 5.2.2

## Function Epilogue

### Standard Epilogue
```assembly
    // Restore callee-saved registers
    LDP  X19, X20, [SP], #16
    
    // Restore stack pointer
    MOV  SP, X29
    
    // Restore frame pointer and link register
    LDP  X29, X30, [SP], #16
    
    // Return
    RET
```

**Reference**: AAPCS64 (IHI0055), Section 5.2.2

## Argument Passing

### Integer Arguments
- First 8 integer/pointer arguments in X0-X7
- Additional arguments on stack (right-to-left)
- Arguments < 64 bits are zero-extended or sign-extended to 64 bits

**Reference**: AAPCS64 (IHI0055), Section 5.4.2

### Floating-Point Arguments
- First 8 floating-point arguments in V0-V7
- Additional arguments on stack
- Single-precision in lower 32 bits, double-precision in 64 bits

**Reference**: AAPCS64 (IHI0055), Section 5.4.2

### Composite Types
- Structures passed by value if small (<= 16 bytes)
- Large structures passed by reference (hidden pointer in X8)
- Arrays always passed by reference

**Reference**: AAPCS64 (IHI0055), Section 5.4.3

### Variadic Functions
- Integer arguments in X0-X7
- Floating-point arguments in V0-V7
- Additional arguments on stack
- Caller must save floating-point argument registers if variadic

**Reference**: AAPCS64 (IHI0055), Section 5.5.2

## Return Values

### Integer Return Values
- Up to 128 bits in X0 and X1
- Larger values returned via hidden pointer in X8

**Reference**: AAPCS64 (IHI0055), Section 5.5

### Floating-Point Return Values
- Up to 128 bits in V0 and V1
- Larger values returned via hidden pointer

**Reference**: AAPCS64 (IHI0055), Section 5.5

## Leaf Functions

### Leaf Function Optimization
- Functions that don't call other functions
- May omit frame pointer setup
- May omit link register save if no calls made

**Reference**: AAPCS64 (IHI0055), Section 5.2.2

### Example Leaf Function
```assembly
leaf_add:
    ADD  X0, X0, X1      // X0 = X0 + X1 (first two args)
    RET                  // Return (X0 is return value)
```

## Function Calls

### Calling a Function
```assembly
    // Set up arguments
    MOV  X0, #42          // First argument
    MOV  X1, #100         // Second argument
    
    // Call function
    BL   my_function      // Branch and link (saves return address in LR)
    
    // Return value in X0
```

### Indirect Function Calls
```assembly
    // Function pointer in X0
    MOV  X1, #arg1        // First argument
    MOV  X2, #arg2        // Second argument
    BLR  X0               // Branch with link to register
```

## Inter-Procedure Calls

### IP0 and IP1 (X16, X17)
- Intra-procedure-call scratch registers
- Used by linker for PLT (Procedure Linkage Table) calls
- Caller-saved, may be modified by called function

**Reference**: AAPCS64 (IHI0055), Section 5.1.1.2

## Stack Usage Examples

### Simple Function
```assembly
simple_function:
    // Prologue
    STP  X29, X30, [SP, #-16]!
    MOV  X29, SP
    
    // Function body (no local variables, no calls)
    ADD  X0, X0, X1       // X0 = X0 + X1
    
    // Epilogue
    MOV  SP, X29
    LDP  X29, X30, [SP], #16
    RET
```

### Function with Local Variables
```assembly
function_with_locals:
    // Prologue
    STP  X29, X30, [SP, #-16]!
    MOV  X29, SP
    SUB  SP, SP, #32      // Allocate 32 bytes for locals
    
    // Use locals at [SP+0], [SP+8], etc.
    STR  X0, [SP, #0]     // Save first argument to local
    LDR  X1, [SP, #0]     // Load from local
    
    // Epilogue
    MOV  SP, X29
    LDP  X29, X30, [SP], #16
    RET
```

### Function Calling Other Functions
```assembly
calling_function:
    // Prologue
    STP  X29, X30, [SP, #-16]!
    MOV  X29, SP
    SUB  SP, SP, #16      // Space for outgoing arguments if needed
    
    // Call another function
    MOV  X0, #10          // First argument
    MOV  X1, #20          // Second argument
    BL   called_function
    
    // Epilogue
    MOV  SP, X29
    LDP  X29, X30, [SP], #16
    RET
```

## References

- Procedure Call Standard for the ARM 64-bit Architecture (AAPCS64, IHI0055): https://developer.arm.com/documentation/ihi0055/latest
- ARMv8-A Architecture Reference Manual (DDI0487): https://developer.arm.com/documentation/ddi0487/latest
