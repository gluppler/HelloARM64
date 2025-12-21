# ABI Notes

> **Reference**: Complete AAPCS64 documentation is available in [`../../references/calling_conventions.md`](../../references/calling_conventions.md). This document provides project-specific ABI notes.

## Calling Convention (AAPCS64)

### Argument Passing
- Integer arguments: X0-X7 (first 8)
- Floating-point: V0-V7 (first 8)
- Additional: Stack

### Return Values
- Integer: X0, X1 (up to 128 bits)
- Floating-point: V0, V1

### Register Preservation
- **Caller-saved**: X0-X7, X9-X15, X16-X17, X18, X30
- **Callee-saved**: X19-X28, X29 (FP)

### Stack Alignment
- Must be 16-byte aligned
- Function entry/exit maintains alignment

## Function Implementation

### memcpy
- Arguments: X0=dest, X1=src, X2=n
- Returns: X0=dest
- Preserves: X19-X28 (callee-saved)

### memset
- Arguments: X0=s, X1=c, X2=n
- Returns: X0=s
- Preserves: X19-X28

### strlen
- Arguments: X0=s
- Returns: X0=length
- Preserves: X19-X28

### strcmp
- Arguments: X0=s1, X1=s2
- Returns: X0=comparison result
- Preserves: X19-X28

## References

- AAPCS64 (IHI0055) - Procedure Call Standard
- ARMv8-A Architecture Reference Manual
