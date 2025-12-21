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

### Using Makefile (Recommended)

```bash
# Build and verify
make

# Run with QEMU
make run

# Run natively (ARM64 only)
make run-native

# Run automated test
make test

# Debug with GDB
make debug

# Clean build artifacts
make clean

# Show help
make help
```

**Reference**: The Makefile handles assembly and C compilation, linking with static libraries for QEMU compatibility. See [`../../tooling/qemu_execution.md`](../../tooling/qemu_execution.md) for details.

### Manual Build

```bash
# Compile assembly runtime
aarch64-linux-gnu-as -o runtime.o src/runtime.s

# Compile C program
aarch64-linux-gnu-gcc -c src/main.c -o main.o

# Link together (static linking recommended)
aarch64-linux-gnu-gcc -static -o test_program main.o runtime.o

# Run with QEMU (static binary, no -L needed)
qemu-aarch64 ./test_program

# If dynamically linked, use:
# qemu-aarch64 -L /usr/aarch64-linux-gnu ./test_program
```

## Testing

```bash
# Run (native ARM64)
./test_program

# Run (cross-compilation with QEMU - static binary)
qemu-aarch64 ./test_program

# If dynamically linked, use:
# qemu-aarch64 -L /usr/aarch64-linux-gnu ./test_program
```

## References

All concepts used in this project are documented in:
- [`../../references/calling_conventions.md`](../../references/calling_conventions.md) - Complete AAPCS64 documentation
- [`../../references/instruction_set.md`](../../references/instruction_set.md) - Instruction details
- [`../../references/registers_and_flags.md`](../../references/registers_and_flags.md) - Register usage

Original sources:
- AAPCS64 (IHI0055) - Calling conventions
- ARM A64 ISA (DDI0602) - Instructions
