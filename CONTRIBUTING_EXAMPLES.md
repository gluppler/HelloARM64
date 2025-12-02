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

✅ These examples should run both on **Linux (AArch64)** and **Apple Silicon macOS** with minor adjustments (syscall numbers differ).
On macOS, replace Linux syscall numbers with **Mach-O system calls** when needed.

---

## Fundamentals Reference

The `Fundamentals/` directory contains comprehensive, production-ready examples covering all ARM64 assembly concepts. These files serve as both learning resources and reference implementations, demonstrating:

- Complete ARM64 instruction coverage
- Security best practices
- Clean code principles
- Proper error handling
- Cross-platform compatibility (Linux and macOS)

All Fundamentals examples are compiled and tested, ready for use as reference implementations.

---
