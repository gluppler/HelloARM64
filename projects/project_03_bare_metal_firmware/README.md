# Project 03: Bare Metal Firmware

> **References**: This project uses concepts from [`../../references/mmu_and_translation.md`](../../references/mmu_and_translation.md) for MMU setup and [`../../references/arm_architecture.md`](../../references/arm_architecture.md) for boot process.

## Overview

A minimal bare metal firmware for ARM64 that demonstrates:
- Boot sequence
- Exception vector setup
- MMU initialization
- Basic system initialization
- Real embedded system programming

## Goals

- Implement boot code
- Set up exception vectors
- Initialize MMU with identity mapping
- Provide minimal runtime environment
- Demonstrate low-level system control

## Architecture

### Memory Map
- **0x40000000**: Code/Data (configurable)
- **0x80000**: Stack
- **0x100000**: Page tables

### Components
- **boot.s**: Entry point and initialization
- **exception_vectors.s**: Exception handlers
- **mmu_enable.s**: MMU setup
- **linker.ld**: Memory layout

## Build Instructions

### Using Makefile (Recommended)

```bash
# Build and verify
make

# Run with QEMU system emulation
make run

# Debug with GDB
make debug

# Clean build artifacts
make clean

# Show help
make help
```

**Reference**: The Makefile handles assembly, linking, and binary creation. See [`../../references/mmu_and_translation.md`](../../references/mmu_and_translation.md) for MMU details.

### Manual Build

```bash
# Assemble
aarch64-linux-gnu-as -o boot.o boot.s
aarch64-linux-gnu-as -o exception_vectors.o exception_vectors.s
aarch64-linux-gnu-as -o mmu_enable.o mmu_enable.s

# Link
aarch64-linux-gnu-ld -T linker.ld -o firmware.elf boot.o exception_vectors.o mmu_enable.o

# Create binary
aarch64-linux-gnu-objcopy -O binary firmware.elf firmware.bin
```

## Execution

Requires ARM64 emulator or hardware:
- QEMU with -M virt
- Real ARM64 hardware
- ARM Development Studio

### Expected Output

When run with QEMU (`make run`), the firmware should output:

```
Bare Metal Firmware: Boot successful!
Exception vectors initialized
System ready
```

**Important**: QEMU will open a graphical window showing the bootloader. After printing the messages, the firmware enters a halt loop. To exit QEMU:

- **Close the QEMU window** (click the X button)
- Or press **Ctrl+Alt+G** to focus the QEMU monitor, then type `quit` and press Enter
- Or press **Ctrl+Alt+2** to switch to QEMU monitor, then type `quit`

**Note**: The firmware attempts to exit using semihosting, but if QEMU wasn't started with semihosting support, it will halt instead. This is normal behavior for bare metal firmware. The UART output appears in the QEMU window.

**Note**: The firmware uses UART (serial port) for output. In QEMU with `-nographic`, the UART output appears directly in your terminal. The firmware demonstrates:
- Boot sequence initialization
- Stack pointer setup
- Exception vector table setup
- UART communication for debugging/output

## References

All concepts used in this project are documented in:
- [`../../references/mmu_and_translation.md`](../../references/mmu_and_translation.md) - Complete MMU documentation
- [`../../references/arm_architecture.md`](../../references/arm_architecture.md) - Boot process and architecture
- [`../../references/memory_management.md`](../../references/memory_management.md) - Memory setup

Original sources:
- ARMv8-A Architecture Reference Manual - Boot process
- ARM Developer Documentation - MMU
- ARM Developer Documentation - Exception handling
