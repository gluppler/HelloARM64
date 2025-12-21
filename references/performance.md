# Performance and Optimization Reference

Complete reference for ARM64 performance optimization and best practices.

**Source**: ARM Architecture Reference Manual, ARM Optimization Guides, Performance Analysis Tools

## Performance Principles

### ARM64 Performance Characteristics
- Out-of-order execution
- Branch prediction
- Cache hierarchy (L1, L2, L3)
- Pipeline stages
- Instruction-level parallelism

**Reference**: ARM Architecture Reference Manual, Performance Optimization Guides

## Instruction Selection

### Efficient Instructions

#### Use Appropriate Instruction Variants
```assembly
// Prefer ADD over MOV when possible (better encoding)
ADD  X0, XZR, #42        // Same as MOV X0, #42, but may be faster

// Use immediate forms when possible
ADD  X0, X1, #100        // Better than loading immediate separately
```

#### Prefer 32-bit Operations When Sufficient
```assembly
// If 32-bit result is sufficient, use W registers
ADD  W0, W1, W2          // May be more efficient than 64-bit
```

### Avoid Expensive Operations

#### Minimize Memory Accesses
```assembly
// Bad: Multiple loads
LDR  X0, [SP, #0]
LDR  X1, [SP, #8]
LDR  X2, [SP, #16]

// Good: Load pair
LDP  X0, X1, [SP]
LDR  X2, [SP, #16]
```

#### Use Load/Store Pair
```assembly
// Efficient: Load/store pairs
LDP  X0, X1, [SP]        // Single instruction, two loads
STP  X0, X1, [SP, #-16]! // Single instruction, two stores
```

## Register Usage

### Minimize Register Spills
- Keep frequently used values in registers
- Minimize stack accesses
- Use callee-saved registers for long-lived values

### Register Allocation Strategy
```assembly
// Good: Keep values in registers
MOV  X0, #10
MOV  X1, #20
ADD  X2, X0, X1          // All in registers

// Bad: Unnecessary memory access
STR  X0, [SP, #-16]!
MOV  X0, #20
LDR  X1, [SP], #16
ADD  X2, X0, X1          // Unnecessary store/load
```

## Branch Optimization

### Branch Prediction
- Forward branches typically not taken
- Backward branches typically taken (loops)
- Minimize unpredictable branches

### Conditional Execution
```assembly
// Use conditional select instead of branches when possible
CMP  X0, X1
CSEL X2, X3, X4, GT      // X2 = (X0 > X1) ? X3 : X4
// Avoids branch misprediction penalty
```

### Loop Optimization
```assembly
// Unroll small loops
// Instead of:
loop:
    LDR  X0, [X1], #8
    SUBS X2, X2, #1
    B.NE loop

// Consider:
loop:
    LDP  X0, X3, [X1], #16  // Load pair, unroll 2 iterations
    SUBS X2, X2, #2
    B.NE loop
```

## Memory Access Optimization

### Alignment
- Ensure 64-bit values are 8-byte aligned
- Ensure 32-bit values are 4-byte aligned
- Unaligned accesses are slower

### Cache-Friendly Access Patterns
- Sequential access is faster than random access
- Access data in cache line order (typically 64 bytes)
- Minimize cache misses

### Prefetching
```assembly
// Use PRFM (prefetch memory) for predictable access
PRFM PLDL1KEEP, [X0, #64]  // Prefetch for load
```

## SIMD/NEON Optimization

### Vectorization
- Use NEON for parallel operations
- Process multiple elements simultaneously
- 128-bit registers can hold:
  - 16 x 8-bit values
  - 8 x 16-bit values
  - 4 x 32-bit values
  - 2 x 64-bit values

### Example: Vector Addition
```assembly
// Scalar (slow)
ADD  X0, X1, X2
ADD  X3, X4, X5
ADD  X6, X7, X8

// Vectorized (fast)
LD1  {V0.4S}, [X1]        // Load 4 32-bit values
LD1  {V1.4S}, [X2]        // Load 4 32-bit values
ADD  V2.4S, V0.4S, V1.4S  // Add 4 values in parallel
ST1  {V2.4S}, [X0]        // Store 4 values
```

## Function Call Optimization

### Leaf Functions
- Functions that don't call other functions
- Can omit frame pointer setup
- Can omit link register save
- Faster entry/exit

### Inline Small Functions
- Consider inlining small, frequently called functions
- Eliminates call overhead
- Enables further optimization

### Minimize Function Call Overhead
```assembly
// Leaf function (no frame setup needed)
leaf_add:
    ADD  X0, X0, X1
    RET

// Non-leaf function (minimal setup)
function:
    STP  X29, X30, [SP, #-16]!
    MOV  X29, SP
    // ... function body ...
    MOV  SP, X29
    LDP  X29, X30, [SP], #16
    RET
```

## Arithmetic Optimization

### Use Efficient Instructions
```assembly
// Multiplication by power of 2: use shift
LSL  X0, X1, #3          // X0 = X1 * 8 (faster than MUL)

// Division by power of 2: use shift
LSR  X0, X1, #3          // X0 = X1 / 8 (faster than division)
```

### Avoid Expensive Operations
- Minimize division (use shifts when possible)
- Minimize modulo operations
- Use bit manipulation instead of arithmetic when possible

## Code Size Optimization

### Instruction Selection
- Use shorter instruction encodings when possible
- Prefer immediate forms
- Use register forms efficiently

### Common Patterns
```assembly
// Clear register: use MOV with zero register
MOV  X0, XZR             // X0 = 0

// Negate: use SUB from zero
SUB  X0, XZR, X1         // X0 = -X1

// Compare with zero: use SUBS
SUBS XZR, X0, #0         // Compare X0 with 0 (sets flags)
```

## Profiling and Measurement

### Performance Counters
- Use hardware performance counters
- Measure cycles, instructions, cache misses
- Identify bottlenecks

### Benchmarking
- Measure before and after optimization
- Use consistent test data
- Run multiple iterations for accuracy

## Common Optimization Patterns

### Strength Reduction
```assembly
// Replace expensive operations with cheaper ones
// Multiplication by constant -> shifts and adds
// X * 5 = X * 4 + X = (X << 2) + X
LSL  X1, X0, #2          // X1 = X0 * 4
ADD  X0, X0, X1          // X0 = X0 + X1 = X0 * 5
```

### Loop Invariant Code Motion
```assembly
// Move calculations outside loop
// Bad: Calculate inside loop
loop:
    ADD  X2, X1, #100    // X1 + 100 calculated every iteration
    // ... use X2 ...
    SUBS X0, X0, #1
    B.NE loop

// Good: Calculate before loop
ADD  X2, X1, #100        // Calculate once
loop:
    // ... use X2 ...
    SUBS X0, X0, #1
    B.NE loop
```

## References

- ARM Architecture Reference Manual (DDI0487): https://developer.arm.com/documentation/ddi0487/latest
- ARM Optimization Guides
- ARM Performance Analysis Tools Documentation
