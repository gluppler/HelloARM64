# Contributing Examples – ARM64

This file shows small code snippets that demonstrate how to follow our coding principles when contributing to this repository.
All examples are written for **ARM64 (AArch64)** assembly, and where needed, are annotated for both **Linux** and **Apple Silicon (macOS)**.

---

## 1. Immutability

Keep data unchanged whenever possible. Use registers consistently instead of overwriting values.

```asm
// Store a value in x0, never modify it directly
mov     x0, #42       // immutable input value
mov     x1, x0        // copy into another register for operations
add     x1, x1, #1    // safe: original x0 stays intact
```

---

## 2. Pure Functions

A function should give the same output for the same input and avoid side effects.

```asm
// Pure: adds two numbers passed in x0 and x1, returns in x0
.global add_two
add_two:
    add x0, x0, x1
    ret
```

---

## 3. Modularity

Write small, reusable routines instead of one big block.

```asm
// sum.s
.global sum
sum:
    add x0, x0, x1
    ret

// main.s
bl sum   // call reusable function
```

---

## 4. Declarative Style

State **what** you want, not **how** step by step. Use macros or data tables.

```asm
// Declare constants instead of magic numbers
.equ SYS_EXIT, 93   // Linux exit syscall
.equ SYS_WRITE, 64  // Linux write syscall
```

---

## 5. Testability

Write functions that can be tested independently.

```asm
// A small routine to double a number
.global double_val
double_val:
    lsl x0, x0, #1   // shift left by 1 = multiply by 2
    ret
```

Can be tested by calling with known inputs (e.g., `x0=4` → `x0=8`).

---

## 6. Refactorability

Keep code clear with meaningful labels.

```asm
// BAD: hard to read
mov x8, #64

// GOOD: named syscall
mov x8, SYS_WRITE
```

---

## 7. Error Handling

Always handle possible failure paths.

```asm
// Example: check if write returned error (negative value in x0)
cmp x0, #0
b.lt handle_error
```

---

## 8. Performance Conscious

Use efficient instructions (e.g., shifts instead of multiply when possible).

```asm
// Faster multiply by 8
lsl x0, x0, #3   // shift left 3 bits
```

---

## 9. Consistency

Stick to one style across files.

```asm
// Always put globals at top
.global main
main:
    ...
```

---

## 10. Documentation

Explain with comments so others can follow.

```asm
// Linux syscall to exit(0)
mov x8, SYS_EXIT
mov x0, #0
svc #0
```

---

✅ All code examples use **Linux syscall conventions** (x8 register):
- Exit: `mov x0, #exit_code; mov x8, #93; svc #0`
- Write: `mov x0, #1; mov x8, #64; svc #0`
- Read: `mov x0, #0; mov x8, #63; svc #0`

All programs include `halt_loop:` after exit syscalls to prevent illegal instructions.

---

## Reference Directories

### Fundamentals Reference

The `Fundamentals/` directory contains comprehensive, production-ready examples covering all core ARM64 assembly concepts. These files serve as both learning resources and reference implementations, demonstrating:

- Complete ARM64 instruction coverage
- Security best practices (no vulnerabilities, no segfaults, no illegal instructions)
- Clean code principles
- Proper error handling with halt_loop protection
- Linux syscall conventions
- Comprehensive input validation and bounds checking

All Fundamentals examples are compiled, tested, and ready for use as reference implementations. All 11 files compile and execute without errors. Binaries are located in `bin/fundamentals/`.

### Advanced Reference

The `Advanced/` directory contains advanced ARM64 assembly concepts for experienced developers, including:

- Atomic operations and synchronization (01_Atomic_Operations.s - Fixed CAS initialization)
- Memory barriers and ordering
- Advanced SIMD/NEON operations
- Advanced control flow optimization (04_Advanced_Control_Flow.s - Fixed validation logic)
- Variadic functions (05_Variadic_Functions.s - Fixed execution flow)
- Performance optimization techniques (06_Advanced_Optimization.s - Fixed alignment checks)
- Advanced floating point operations
- Advanced security features (08_Advanced_Security.s - Fixed execution flow, ASLR, CFI, PAC)
- Advanced Apple Silicon features
- Debugging techniques
- Memory management patterns

All Advanced examples are compiled, tested, and demonstrate production-ready advanced patterns. All 11 files compile and execute without errors. Binaries are located in `bin/advanced/`.

### Code Quality Standards

All code in both directories follows strict standards:
- ✅ STRICT CODE ONLY
- ✅ NO VULNERABILITIES ALLOWED
- ✅ NO SEGMENTATION FAULTS ALLOWED
- ✅ NO ILLEGAL INSTRUCTIONS ALLOWED
- ✅ CLEAN CODE PRINCIPLES
- ✅ SECURE CODE PRINCIPLES
- ✅ All files checked and refactored until they compile and execute without any errors or issues

---
