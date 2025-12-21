# ARM64 Instruction Set Reference

Complete reference for the A64 instruction set architecture used in ARM64 assembly programming.

**Source**: ARM A64 Instruction Set Architecture (DDI0602), ARMv8-A Architecture Reference Manual

## Instruction Format

### Fixed-Length Instructions
- All A64 instructions are 32 bits wide
- Instructions are naturally aligned (4-byte boundaries)
- PC-relative addressing for many operations

**Reference**: ARM A64 ISA (DDI0602), Section A1.1

## Data Processing Instructions

### Arithmetic Operations

#### ADD (Add)
```
ADD  Xd, Xn, Xm          // Xd = Xn + Xm
ADD  Xd, Xn, #imm         // Xd = Xn + immediate
ADDS Xd, Xn, Xm           // Add with flags set
```

**Reference**: DDI0602, C6.2.1

#### SUB (Subtract)
```
SUB  Xd, Xn, Xm          // Xd = Xn - Xm
SUB  Xd, Xn, #imm        // Xd = Xn - immediate
SUBS Xd, Xn, Xm          // Subtract with flags set
```

**Reference**: DDI0602, C6.2.2

#### MUL (Multiply)
```
MUL  Xd, Xn, Xm          // Xd = Xn * Xm (lower 64 bits)
UMULH Xd, Xn, Xm         // Unsigned multiply high
SMULH Xd, Xn, Xm         // Signed multiply high
```

**Reference**: DDI0602, C6.2.3

### Logical Operations

#### AND, ORR, EOR, BIC
```
AND  Xd, Xn, Xm          // Xd = Xn & Xm
ORR  Xd, Xn, Xm          // Xd = Xn | Xm
EOR  Xd, Xn, Xm          // Xd = Xn ^ Xm
BIC  Xd, Xn, Xm          // Xd = Xn & ~Xm
```

**Reference**: DDI0602, C6.2.4

#### Shift Operations
```
LSL  Xd, Xn, #imm        // Logical shift left
LSR  Xd, Xn, #imm        // Logical shift right
ASR  Xd, Xn, #imm        // Arithmetic shift right
ROR  Xd, Xn, #imm        // Rotate right
```

**Reference**: DDI0602, C6.2.5

### Comparison Operations

#### CMP, CMN, TST
```
CMP  Xn, Xm              // Compare (sets flags, Xn - Xm)
CMP  Xn, #imm            // Compare with immediate
CMN  Xn, Xm              // Compare negative (sets flags, Xn + Xm)
TST  Xn, Xm              // Test bits (sets flags, Xn & Xm)
```

**Reference**: DDI0602, C6.2.6

## Load/Store Instructions

### Basic Load/Store

#### LDR (Load Register)
```
LDR  Xd, [Xn]            // Load 64-bit from [Xn]
LDR  Wd, [Xn]            // Load 32-bit from [Xn]
LDR  Xd, [Xn, #offset]   // Load with offset
LDR  Xd, [Xn, Xm]        // Load with register offset
```

**Reference**: DDI0602, C6.3.1

#### STR (Store Register)
```
STR  Xd, [Xn]            // Store 64-bit to [Xn]
STR  Wd, [Xn]            // Store 32-bit to [Xn]
STR  Xd, [Xn, #offset]   // Store with offset
STR  Xd, [Xn, Xm]        // Store with register offset
```

**Reference**: DDI0602, C6.3.2

### Addressing Modes

#### Base Register
```
LDR  Xd, [Xn]            // Base register only
```

#### Offset Addressing
```
LDR  Xd, [Xn, #imm]      // Base + immediate offset
STR  Xd, [Xn, #imm]      // Base + immediate offset
```

#### Pre-indexed
```
LDR  Xd, [Xn, #imm]!     // Pre-index: Xn = Xn + imm, then load
```

#### Post-indexed
```
LDR  Xd, [Xn], #imm      // Post-index: load, then Xn = Xn + imm
```

#### Register Offset
```
LDR  Xd, [Xn, Xm]        // Base + register offset
LDR  Xd, [Xn, Xm, LSL #3] // Base + scaled register offset
```

**Reference**: DDI0602, C6.3.3

### Load/Store Multiple

#### LDP/STP (Load/Store Pair)
```
LDP  Xd1, Xd2, [Xn]      // Load pair
STP  Xd1, Xd2, [Xn]      // Store pair
LDP  Xd1, Xd2, [Xn, #imm]! // Pre-indexed pair
LDP  Xd1, Xd2, [Xn], #imm  // Post-indexed pair
```

**Reference**: DDI0602, C6.3.4

## Branch Instructions

### Unconditional Branch

#### B (Branch)
```
B   label                // Branch to label (PC-relative)
```

#### BR (Branch to Register)
```
BR   Xn                  // Branch to address in Xn
```

**Reference**: DDI0602, C6.4.1

### Conditional Branch

#### B.cond (Conditional Branch)
```
B.EQ  label              // Branch if equal (Z=1)
B.NE  label              // Branch if not equal (Z=0)
B.GT  label              // Branch if greater than (signed)
B.LT  label              // Branch if less than (signed)
B.GE  label              // Branch if greater or equal
B.LE  label              // Branch if less or equal
B.HI  label              // Branch if higher (unsigned)
B.LO  label              // Branch if lower (unsigned)
```

**Condition Codes**:
- EQ: Equal (Z=1)
- NE: Not equal (Z=0)
- CS/HS: Carry set / Higher or same (C=1)
- CC/LO: Carry clear / Lower (C=0)
- MI: Negative (N=1)
- PL: Positive or zero (N=0)
- VS: Overflow (V=1)
- VC: No overflow (V=0)
- HI: Higher (unsigned, C=1 and Z=0)
- LS: Lower or same (unsigned, C=0 or Z=1)
- GE: Greater or equal (signed, N=V)
- LT: Less than (signed, N≠V)
- GT: Greater than (signed, Z=0 and N=V)
- LE: Less or equal (signed, Z=1 or N≠V)

**Reference**: DDI0602, C6.4.2

### Function Call Branches

#### BL (Branch with Link)
```
BL   label               // Branch and link (save return address in LR)
BLR  Xn                  // Branch with link to register
```

**Reference**: DDI0602, C6.4.3

#### RET (Return)
```
RET  Xn                  // Return (branch to Xn, default Xn=LR)
RET                      // Return (branch to LR)
```

**Reference**: DDI0602, C6.4.4

## System Instructions

### Memory Barriers

#### DMB, DSB, ISB
```
DMB  SY                  // Data Memory Barrier
DSB  SY                  // Data Synchronization Barrier
ISB                      // Instruction Synchronization Barrier
```

**Reference**: DDI0602, C6.5.1

### System Register Access

#### MRS, MSR
```
MRS  Xd, S3_0_C0_C0_0    // Move from system register
MSR  S3_0_C0_C0_0, Xn    // Move to system register
```

**Reference**: DDI0602, C6.5.2

## SIMD/NEON Instructions

### Vector Operations

#### ADD (Vector)
```
ADD  Vd.8B, Vn.8B, Vm.8B  // Add 8 bytes
ADD  Vd.4H, Vn.4H, Vm.4H  // Add 4 halfwords
ADD  Vd.2S, Vn.2S, Vm.2S  // Add 2 words
ADD  Vd.2D, Vn.2D, Vm.2D  // Add 2 doublewords
```

**Reference**: DDI0602, C7.2.1

### Load/Store Vector

#### LD1, ST1 (Load/Store 1 element)
```
LD1  {Vt.8B}, [Xn]       // Load 1 register, 8 bytes
ST1  {Vt.8B}, [Xn]       // Store 1 register, 8 bytes
```

**Reference**: DDI0602, C7.2.2

## Floating-Point Instructions

### FP Arithmetic

#### FADD, FSUB, FMUL, FDIV
```
FADD  Sd, Sn, Sm         // Single-precision add
FADD  Dd, Dn, Dm         // Double-precision add
FSUB  Sd, Sn, Sm         // Single-precision subtract
FMUL  Sd, Sn, Sm         // Single-precision multiply
FDIV  Sd, Sn, Sm         // Single-precision divide
```

**Reference**: DDI0602, C7.3.1

### FP Load/Store

#### LDR, STR (Floating-Point)
```
LDR  Sd, [Xn]            // Load single-precision
LDR  Dd, [Xn]            // Load double-precision
STR  Sd, [Xn]            // Store single-precision
STR  Dd, [Xn]            // Store double-precision
```

**Reference**: DDI0602, C7.3.2

## Immediate Encoding

### Arithmetic Immediate
- 12-bit immediate with optional 12-bit left shift
- Range: 0 to 4095, or 0 to 16777215 (with shift)

### Logical Immediate
- Complex encoding for bitmasks
- Not all values representable

### Load/Store Offset
- 9-bit signed immediate for unscaled
- 12-bit unsigned immediate for scaled

**Reference**: DDI0602, C1.2

## Instruction Aliases

Many instructions have aliases for readability:
```
MOV  Xd, Xn              // Alias for ORR Xd, XZR, Xn
MVN  Xd, Xn              // Alias for ORN Xd, XZR, Xn
NOP                      // Alias for HINT #0
```

**Reference**: DDI0602, C1.3

## References

- ARM A64 Instruction Set Architecture (DDI0602): https://developer.arm.com/documentation/ddi0602/latest
- ARMv8-A Architecture Reference Manual (DDI0487): https://developer.arm.com/documentation/ddi0487/latest
- ARM Developer Documentation: https://developer.arm.com/documentation
