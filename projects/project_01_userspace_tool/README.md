# Project 01: Userspace Tool

> **References**: This project uses concepts from [`../../references/syscalls.md`](../../references/syscalls.md) for system calls and [`../../references/calling_conventions.md`](../../references/calling_conventions.md) for stack layout.

## Overview

A complete ARM64 assembly implementation of a simple file copy utility (`cp`-like tool) that demonstrates:
- Command-line argument parsing
- File I/O system calls
- Error handling
- Memory management
- Real-world system programming

## Goals

- Parse command-line arguments from stack
- Open source and destination files
- Copy data efficiently using system calls
- Handle errors appropriately
- Exit with correct status codes

## Architecture

### System Calls Used
- **openat** (56): Open files
- **read** (63): Read from file
- **write** (64): Write to file
- **close** (57): Close file descriptors
- **exit** (93): Exit program

### Memory Layout
- Stack: Command-line arguments, local variables
- Heap: Not used (direct system calls)
- Data: Error messages, constants

## Build Instructions

```bash
# Compile
aarch64-linux-gnu-gcc -nostdlib -o cp_tool src/main.s

# Run (native ARM64)
./cp_tool source.txt dest.txt

# Run (cross-compilation with QEMU)
qemu-aarch64 ./cp_tool source.txt dest.txt
```

## Testing

1. Create test file: `echo "test" > test.txt`
2. Run: `./cp_tool test.txt copy.txt`
3. Verify: `cat copy.txt` should show "test"

## References

All concepts used in this project are documented in:
- [`../../references/syscalls.md`](../../references/syscalls.md) - System call documentation
- [`../../references/calling_conventions.md`](../../references/calling_conventions.md) - Stack layout and ABI
- [`../../references/instruction_set.md`](../../references/instruction_set.md) - Instruction details

Original sources:
- ARM A64 ISA (DDI0602) - System calls
- Linux System Call Table
- AAPCS64 (IHI0055) - Stack layout
