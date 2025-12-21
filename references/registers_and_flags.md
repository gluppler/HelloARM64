# Registers and Flags Reference

Complete reference for ARM64 register architecture and condition flags.

**Source**: ARMv8-A Architecture Reference Manual (DDI0487), AAPCS64 (IHI0055)

## General-Purpose Registers

### 64-bit Registers (X0-X30)
- **X0-X7**: Argument/result registers (caller-saved)
- **X8**: Indirect result location register (caller-saved)
- **X9-X15**: Temporary registers (caller-saved)
- **X16-X17**: IP0/IP1 (intra-procedure-call scratch registers, caller-saved)
- **X18**: Platform register (platform-specific use, caller-saved)
- **X19-X28**: Callee-saved registers
- **X29 (FP)**: Frame pointer (callee-saved)
- **X30 (LR)**: Link register (return address, caller-saved)

**Reference**: AAPCS64 (IHI0055), Section 5.1.1

### 32-bit Registers (W0-W30)
- Lower 32 bits of X0-X30
- Writing to Wn zero-extends to Xn
- Reading Wn reads lower 32 bits of Xn

**Reference**: ARMv8-A Architecture Reference Manual, Section B1.1.1

### Zero Register
- **XZR/WZR**: Zero register
- Always reads as 0
- Writes are ignored
- Useful for comparisons and clearing registers

**Reference**: ARMv8-A Architecture Reference Manual, Section B1.1.2

## Stack Pointer

### SP Register
- **SP**: 64-bit stack pointer
- Must be 16-byte aligned at all times
- Modified by load/store instructions with SP as base
- Cannot be used as general-purpose register in most contexts

**Reference**: AAPCS64 (IHI0055), Section 5.2.3

### Stack Alignment
- Stack must be 16-byte aligned
- Function entry/exit must maintain alignment
- Violations cause alignment faults

**Reference**: AAPCS64 (IHI0055), Section 5.2.3

## Program Counter

### PC Register
- **PC**: 64-bit program counter
- Not directly accessible as register
- Can be read via `ADR` or `ADRP` instructions
- Modified by branch instructions

**Reference**: ARMv8-A Architecture Reference Manual, Section B1.1.3

## Processor State (PSTATE)

### Condition Flags (NZCV)

#### N (Negative)
- Set when result is negative (MSB = 1)
- Cleared when result is non-negative

#### Z (Zero)
- Set when result is zero
- Cleared when result is non-zero

#### C (Carry)
- Set when unsigned addition overflows
- Set when unsigned subtraction underflows
- Used for unsigned comparisons

#### V (Overflow)
- Set when signed addition/subtraction overflows
- Used for signed comparisons

**Reference**: ARMv8-A Architecture Reference Manual, Section B1.2.1

### Accessing Condition Flags
- Flags are part of PSTATE
- Modified by instructions with 'S' suffix (e.g., ADDS, SUBS)
- Tested by conditional branch instructions (B.cond)

**Reference**: ARMv8-A Architecture Reference Manual, Section B1.2.2

## SIMD/NEON Registers

### Vector Registers (V0-V31)
- **V0-V7**: Argument/result registers (caller-saved)
- **V8-V15**: Callee-saved registers
- **V16-V31**: Temporary registers (caller-saved)
- 128 bits wide
- Can be accessed as:
  - 8B, 16B: 8/16 bytes
  - 4H, 8H: 4/8 halfwords (16-bit)
  - 2S, 4S: 2/4 words (32-bit)
  - 1D, 2D: 1/2 doublewords (64-bit)

**Reference**: AAPCS64 (IHI0055), Section 5.1.2

### Scalar Floating-Point Registers
- Same registers as vector registers (V0-V31)
- Accessed as S0-S31 (32-bit single-precision)
- Accessed as D0-D31 (64-bit double-precision)

**Reference**: AAPCS64 (IHI0055), Section 5.1.2

## Register Usage Conventions (AAPCS64)

### Function Arguments
- **X0-X7**: Integer/pointer arguments (first 8)
- **V0-V7**: Floating-point/vector arguments (first 8)
- **Stack**: Additional arguments passed on stack

**Reference**: AAPCS64 (IHI0055), Section 5.4

### Return Values
- **X0/X1**: Integer/pointer return values (up to 2 registers)
- **V0/V1**: Floating-point/vector return values (up to 2 registers)
- **Stack**: Large return values via hidden pointer in X8

**Reference**: AAPCS64 (IHI0055), Section 5.5

### Caller-Saved Registers
Must be preserved by caller if needed after call:
- X0-X7, X9-X15, X16-X17, X18, X30 (LR)
- V0-V7, V16-V31

**Reference**: AAPCS64 (IHI0055), Section 5.1.1

### Callee-Saved Registers
Must be preserved by callee:
- X19-X28, X29 (FP)
- V8-V15

**Reference**: AAPCS64 (IHI0055), Section 5.1.1

## Special-Purpose Registers

### Frame Pointer (X29/FP)
- Points to current stack frame
- Optional but recommended for debugging
- Must be preserved by callee

**Reference**: AAPCS64 (IHI0055), Section 5.2.2

### Link Register (X30/LR)
- Holds return address after BL/BLR
- Must be saved if function makes calls
- Typically saved to stack at function entry

**Reference**: AAPCS64 (IHI0055), Section 5.3

### Platform Register (X18)
- Reserved for platform-specific use
- On some platforms: thread-local storage pointer
- Should not be used without platform documentation

**Reference**: AAPCS64 (IHI0055), Section 5.1.1.1

## System Registers

### Control Registers
- **SCTLR_EL1**: System Control Register
- **TCR_EL1**: Translation Control Register
- **TTBR0_EL1, TTBR1_EL1**: Translation Table Base Registers
- Accessed via MRS/MSR instructions

**Reference**: ARMv8-A Architecture Reference Manual, Section D13.2

## Register Access Patterns

### Reading Registers
```
MOV  X0, X1              // Copy X1 to X0
LDR  X0, [SP]            // Load from stack
ADD  X0, X1, X2          // Read X1 and X2
```

### Writing Registers
```
MOV  X0, #42             // Write immediate
STR  X0, [SP]            // Store to stack
ADD  X0, X1, X2          // Write result to X0
```

### Zero Extension
```
MOV  W0, #100            // Write to W0 (zero-extends to X0)
LDR  W0, [SP]            // Load 32-bit (zero-extends to X0)
```

## Condition Code Usage

### Setting Flags
```
ADDS X0, X1, X2          // Add and set flags
SUBS X0, X1, X2          // Subtract and set flags
CMP  X1, X2              // Compare (sets flags, X1 - X2)
TST  X1, X2              // Test bits (sets flags, X1 & X2)
```

### Using Flags
```
B.EQ  label              // Branch if equal (Z=1)
B.NE  label              // Branch if not equal (Z=0)
B.GT  label              // Branch if greater (signed)
B.HI  label              // Branch if higher (unsigned)
CSEL X0, X1, X2, EQ      // Conditional select
```

**Reference**: ARM A64 ISA (DDI0602), Section C6.4.2

## References

- ARMv8-A Architecture Reference Manual (DDI0487): https://developer.arm.com/documentation/ddi0487/latest
- Procedure Call Standard for ARM 64-bit Architecture (AAPCS64, IHI0055): https://developer.arm.com/documentation/ihi0055/latest
- ARM A64 Instruction Set Architecture (DDI0602): https://developer.arm.com/documentation/ddi0602/latest
