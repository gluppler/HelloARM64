# ARM Assembly Fundamentals

This directory contains comprehensive examples of ARM assembly language concepts for both AArch64 and Apple Silicon architectures.

## Files Overview

### 01_Registers.s
- General Purpose Registers (x0-x30)
- Special Registers (SP, XZR, FP, LR)
- 32-bit Register Views (w0-w30)
- Register Usage Conventions
- Security Practices for Register Usage

### 02_Basic_Instructions.s
- Move Instructions (mov, movz, movk, movn)
- Arithmetic Instructions (add, sub, mul, madd, msub)
- Logical Instructions (and, orr, eor, bic)
- Shift Instructions (lsl, lsr, asr, ror)
- Comparison Instructions (cmp, cmn, tst)
- Extend Instructions (sxtb, sxth, sxtw, uxtb, uxth, uxtw)

### 03_Memory_Operations.s
- Load Instructions (ldr, ldrh, ldrb, ldp)
- Store Instructions (str, strh, strb, stp)
- Addressing Modes (immediate, register, pre-index, post-index)
- Literal Pool Access
- Security Practices for Memory Operations

### 04_Control_Flow.s
- Unconditional Branches (b, bl, br, ret)
- Conditional Branches (b.eq, b.ne, b.gt, b.lt, etc.)
- Conditional Execution (csel, csinc, cset, csetm)
- Loops (for, while, do-while)
- Switch-like Constructs
- Nested Loops

### 05_Stack_Operations.s
- Stack Pointer (SP)
- Stack Allocation and Deallocation
- Push/Pop Operations (using stp/ldp)
- Frame Pointer (x29/FP)
- Stack Alignment (16-byte requirement)
- Saving Registers on Stack
- Stack-based Local Variables
- Stack Overflow Prevention

### 06_Function_Calls.s
- Calling Conventions (AArch64 ABI)
- Parameter Passing (x0-x7, stack for >8 args)
- Return Values (x0, or x0-x1 for 128-bit)
- Caller-saved vs Callee-saved Registers
- Function Prologue and Epilogue
- Nested Function Calls
- Tail Call Optimization

### 07_System_Calls.s
- macOS System Calls (x16 register, 0x2000000 + BSD number)
- Linux System Calls (x8 register)
- Common Syscalls (write, read, exit, open, close, lseek)
- Error Handling
- Return Value Validation
- Security Practices for Syscalls

### 08_Arithmetic_Advanced.s
- Extended Arithmetic (umull, smull, umulh, smulh)
- Division (udiv, sdiv) with Zero Check
- Modulo Operations
- Bit Manipulation (clz, cls, rbit, rev)
- Bit Field Operations (bfm, sbfm, ubfm, bfi, bfxil)
- Population Count
- Overflow Detection
- Absolute Value, Min/Max Operations
- Rounding Operations

### 09_SIMD_NEON.s
- NEON Register Overview (V0-V31)
- Loading Vectors (ldr, ld1)
- Storing Vectors (str, st1)
- Vector Arithmetic (add, sub, mul, mla, mls)
- Vector Logical Operations (and, orr, eor, bic)
- Vector Shifts (shl, ushr, sshr)
- Vector Comparisons (cmgt, cmge, cmlt, cmle, cmeq)
- Vector Reduction (addv, smaxv, sminv)
- Floating Point Vectors (fadd, fsub, fmul, fdiv, fmax, fmin)
- Vector Initialization (movi, dup)

### 10_Apple_Silicon_Specific.s
- Apple Silicon Architecture Overview
- macOS System Call Conventions
- Page Addressing (adr for cross-platform compatibility)
- Register Restrictions (x18 reserved)
- Stack Alignment Requirements
- Apple Silicon Optimizations
- Memory Ordering (dmb, dsb, isb)
- Cache Operations
- Crypto Extensions (overview)
- Floating Point Support
- Performance Tips
- Debugging with Frame Pointers

### 11_Security_Practices.s
- Input Validation
- Buffer Overflow Prevention
- Division by Zero Prevention
- Integer Overflow Detection
- Sensitive Data Clearing
- Pointer Validation
- Stack Canaries
- Secure Memory Operations
- Secure System Calls
- Security Coding Checklist

## Building

To build any of these files:

```bash
# For macOS (Apple Silicon)
make bare file=Fundamentals/01_Registers.s target=macos

# For Linux
make bare file=Fundamentals/01_Registers.s target=linux
```

## Security Notes

All code examples follow security best practices:
- ✅ Input validation
- ✅ Bounds checking
- ✅ Overflow detection
- ✅ Division by zero prevention
- ✅ Pointer validation
- ✅ Sensitive data clearing
- ✅ Stack alignment maintenance
- ✅ Proper error handling

## Architecture Support

- **AArch64**: All examples work on standard AArch64 systems
- **Apple Silicon**: Special considerations documented in `10_Apple_Silicon_Specific.s`

## Code Quality

- ✅ Clean code principles
- ✅ No vulnerabilities
- ✅ No segment faults
- ✅ Proper error handling
- ✅ Comprehensive comments
- ✅ Secure coding patterns

## Notes

- Stack must always be 16-byte aligned
- x18 is reserved on Apple Silicon (do not use)
- macOS uses x16 for syscall numbers, Linux uses x8
- All memory accesses are bounds-checked
- Sensitive data is cleared after use
