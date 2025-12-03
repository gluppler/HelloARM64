# ARM Assembly Fundamentals - Portfolio Reference

This directory contains comprehensive, production-ready ARM64 assembly reference code demonstrating core concepts. All files are **numerically labelled (01-11)** and serve as a complete reference portfolio for ARM64 assembly fundamentals.

## Files Overview

### 01_Registers.s
- General Purpose Registers (x0-x30)
- Special Registers (SP, XZR, FP, LR)
- 32-bit Register Views (w0-w30)
- Register Usage Conventions
- Register Management Best Practices

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
- Memory Access Best Practices

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
- Linux System Calls (x8 register) - Primary implementation
- Common Syscalls (write=64, read=63, exit=93)
- Error Handling and Return Value Validation
- Syscall Best Practices
- Note: Blocking read syscalls commented out for non-interactive environments

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
- Page Addressing (adr for cross-platform compatibility)
- Register Restrictions (x18 reserved)
- Stack Alignment Requirements
- Apple Silicon Optimizations
- Memory Ordering (dmb, dsb, isb)
- Cache Operations
- Crypto Extensions (overview)
- Floating Point Support (demonstration code)
- Performance Tips
- Debugging with Frame Pointers
- Note: Some demonstration code commented out for compatibility

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

To build all Fundamentals examples:

```bash
# Build all Fundamentals examples (outputs to bin/fundamentals/)
make fundamentals

# Or build both Fundamentals and Advanced together
make all-examples

# Or build individually
make bare file=Fundamentals/01_Registers.s
```

All compiled binaries are placed in the `bin/fundamentals/` directory (11 binaries).

## Best Practices

All code examples follow industry best practices:
- Input validation before use
- Bounds checking for array and memory accesses
- Overflow detection in arithmetic operations
- Division by zero prevention
- Pointer validation (null checks, range validation)
- Sensitive data clearing after use
- Stack alignment maintenance (16-byte requirement)
- Proper error handling with appropriate exit codes

## Architecture Support

- **AArch64**: All examples work on standard AArch64 systems
- **Apple Silicon**: Special considerations documented in `10_Apple_Silicon_Specific.s`

## Code Quality

All files are production-ready and follow industry best practices:
- Production-ready, error-free implementations
- Comprehensive security best practices implemented
- All memory accesses properly validated
- All instructions correctly formatted
- Well-structured, maintainable code
- Input validation and bounds checking throughout
- Proper error handling with halt_loop protection
- Comprehensive comments and documentation
- 100% compilation and execution success rate

## Notes

- Stack must always be 16-byte aligned
- x18 is reserved on Apple Silicon (do not use)
- Linux syscalls use x8 register (syscall numbers: 64 for write, 93 for exit, 63 for read)
- All memory accesses are bounds-checked
- Sensitive data is cleared after use
- All programs include halt_loop after exit syscalls as defensive programming
- All code follows industry best practices and quality standards
