# ARM64 vs x86-64 Calling Convention Comparison

> **Reference**: ARM64 calling conventions are documented in [`../references/calling_conventions.md`](../references/calling_conventions.md) (AAPCS64).

## Register Usage

### Argument Passing

**ARM64 (AAPCS64)**:
- Integer arguments: X0-X7 (first 8)
- Floating-point: V0-V7 (first 8)
- Additional: Stack

**x86-64 (System V ABI)**:
- Integer arguments: RDI, RSI, RDX, RCX, R8, R9 (first 6)
- Floating-point: XMM0-XMM7 (first 8)
- Additional: Stack

## Return Values

**ARM64**:
- Integer: X0, X1 (up to 128 bits)
- Floating-point: V0, V1

**x86-64**:
- Integer: RAX, RDX (up to 128 bits)
- Floating-point: XMM0, XMM1

## Callee-Saved Registers

**ARM64**:
- X19-X28, X29 (FP), V8-V15

**x86-64**:
- RBX, RBP, R12-R15, XMM6-XMM15

## Stack Alignment

**ARM64**: 16-byte aligned
**x86-64**: 16-byte aligned

## Function Prologue Comparison

### ARM64
```assembly
function:
    STP  X29, X30, [SP, #-16]!
    MOV  X29, SP
```

### x86-64
```assembly
function:
    push rbp
    mov  rbp, rsp
```

## Key Differences

1. **More argument registers on ARM64** (8 vs 6)
2. **Different register names** (X0-X30 vs RAX-R15)
3. **Similar stack alignment** (both 16-byte)
4. **Similar calling patterns** (frame pointer, return address)
