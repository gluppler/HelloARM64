# Project 02: C/Assembly Runtime

> **References**: This project uses concepts from [`../../references/calling_conventions.md`](../../references/calling_conventions.md) for AAPCS64 and [`../../references/instruction_set.md`](../../references/instruction_set.md) for instructions.

## Overview

A runtime library written in ARM64 assembly that provides low-level functions for C programs, demonstrating:
- C/Assembly interoperation
- Runtime function implementation
- Memory management primitives
- String operations
- ABI compliance

## Goals

- Implement common runtime functions in assembly
- Demonstrate efficient C/Assembly interop
- Provide memory and string utilities
- Show ABI-compliant function interfaces

## Architecture

### Functions Implemented
- `memcpy`: Copy memory block
- `memset`: Set memory block
- `strlen`: Calculate string length
- `strcmp`: Compare strings

### ABI Compliance
- Arguments in X0-X7
- Return values in X0
- Callee-saved registers preserved
- Stack alignment maintained

## Build Instructions

```bash
# Compile assembly runtime
aarch64-linux-gnu-as -o runtime.o src/runtime.s

# Compile C program
aarch64-linux-gnu-gcc -c main.c

# Link together
aarch64-linux-gnu-gcc -o test_program main.o runtime.o
```

## Testing

```bash
./test_program
```

## References

All concepts used in this project are documented in:
- [`../../references/calling_conventions.md`](../../references/calling_conventions.md) - Complete AAPCS64 documentation
- [`../../references/instruction_set.md`](../../references/instruction_set.md) - Instruction details
- [`../../references/registers_and_flags.md`](../../references/registers_and_flags.md) - Register usage

Original sources:
- AAPCS64 (IHI0055) - Calling conventions
- ARM A64 ISA (DDI0602) - Instructions
