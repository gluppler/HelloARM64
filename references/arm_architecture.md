# ARM Architecture Reference

## ARMv8-A Architecture Overview

ARMv8-A is the 64-bit architecture that introduced AArch64, the 64-bit execution state. This document covers the fundamental architectural concepts for ARM64 assembly programming.

**Source**: ARMv8-A Architecture Reference Manual (DDI0487), ARM Developer Documentation

## Execution States

### AArch64 State
- 64-bit execution state
- 64-bit general-purpose registers (X0-X30)
- 64-bit program counter (PC)
- 64-bit stack pointer (SP)
- 32-bit instruction set (A64)

### AArch32 State (Legacy)
- 32-bit execution state
- ARM and Thumb instruction sets
- Not covered in this repository (ARM64 focus)

## Register Architecture

### General-Purpose Registers
- **X0-X30**: 64-bit general-purpose registers
- **W0-W30**: Lower 32 bits of X0-X30 (32-bit access)
- **XZR/WZR**: Zero register (always reads as 0, writes ignored)
- **SP**: Stack pointer (64-bit)
- **X30 (LR)**: Link register (return address)

**Reference**: ARMv8-A Architecture Reference Manual, Section B1.1

### Special Registers
- **PC**: Program counter (not directly accessible as register)
- **PSTATE**: Processor state (NZCV flags, exception level, etc.)
- **System registers**: Control registers, MMU registers, etc.

## Exception Levels

ARMv8-A defines four exception levels (EL0-EL3):

- **EL0**: User/Application level (lowest privilege)
- **EL1**: OS/Kernel level
- **EL2**: Hypervisor level
- **EL3**: Secure monitor level (highest privilege)

**Reference**: ARMv8-A Architecture Reference Manual, Section D1.1

## Memory Model

### Address Spaces
- **Virtual Address Space**: 48-bit (implementation-defined, typically 48-bit)
- **Physical Address Space**: Up to 48-bit (implementation-defined)
- **Address Size**: Controlled by TCR_EL1 register

**Reference**: ARMv8-A Architecture Reference Manual, Section D5.1

### Memory Attributes
- **Normal vs Device memory**: Different access semantics
- **Cacheability**: Write-back, write-through, non-cacheable
- **Shareability**: Inner-shareable, outer-shareable, non-shareable

**Reference**: ARMv8-A Architecture Reference Manual, Section D5.2

## Instruction Set Architecture

### A64 Instruction Set
- Fixed-length 32-bit instructions
- Load/store architecture (no memory-to-memory operations)
- Predicated execution removed (replaced with conditional branches)
- SIMD/NEON instructions for vector operations

**Reference**: ARM A64 Instruction Set Architecture (DDI0602)

### Instruction Categories
1. **Data Processing**: Arithmetic, logical, bit manipulation
2. **Load/Store**: Memory access instructions
3. **Branch**: Conditional and unconditional branches
4. **System**: System register access, barriers, exceptions
5. **SIMD/NEON**: Vector and floating-point operations

## Endianness

ARMv8-A supports both:
- **Little-endian**: Default for AArch64
- **Big-endian**: Can be configured per page

**Reference**: ARMv8-A Architecture Reference Manual, Section A3.4

## Alignment

### Natural Alignment
- 64-bit values must be 8-byte aligned
- 32-bit values must be 4-byte aligned
- 16-bit values must be 2-byte aligned
- Unaligned accesses may cause alignment faults (configurable)

**Reference**: ARMv8-A Architecture Reference Manual, Section B2.5

## Architectural Features

### Security Features
- **Pointer Authentication (PAC)**: Available on Apple Silicon
- **Memory Tagging Extension (MTE)**: Optional feature
- **Privileged Access Never (PAN)**: Prevents kernel access to user memory

### Performance Features
- **Out-of-order execution**: Modern ARM cores
- **Branch prediction**: Hardware branch predictors
- **Cache hierarchy**: L1, L2, L3 caches

## References

- ARMv8-A Architecture Reference Manual (DDI0487): https://developer.arm.com/documentation/ddi0487/latest
- ARM Developer Documentation: https://developer.arm.com/documentation
- ARM Architecture Learning: https://www.arm.com/architecture/learn-the-architecture
