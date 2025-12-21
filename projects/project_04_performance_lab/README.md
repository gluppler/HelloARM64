# Project 04: Performance Lab

> **References**: This project uses concepts from:
> - [`../../references/performance.md`](../../references/performance.md) - Optimization strategies
> - [`../../references/instruction_set.md`](../../references/instruction_set.md) - Instruction details
> - [`../../references/syscalls.md`](../../references/syscalls.md) - clock_gettime syscall for timing
> - [`../../references/arm_architecture.md`](../../references/arm_architecture.md) - ARM64 architecture fundamentals

## Overview

A performance analysis laboratory demonstrating ARM64 optimization techniques:
- Instruction-level profiling
- Memory access optimization
- Branch prediction analysis
- SIMD/NEON vectorization
- Performance measurement

**What This Project Does**: The benchmarks run three performance tests that demonstrate different aspects of ARM64 CPU behavior:
1. **Scalar Addition Loop**: Tests basic arithmetic instruction performance
2. **Memory Access Pattern**: Tests memory load/store operations and cache behavior
3. **Conditional Execution**: Tests branch prediction and conditional execution performance

Each benchmark runs 100,000 iterations and measures execution time using high-resolution timing (clock_gettime syscall). The output shows detailed performance metrics including execution time in multiple units (seconds, milliseconds, microseconds, nanoseconds).

## Goals

- Measure instruction performance
- Optimize memory access patterns
- Analyze branch behavior
- Demonstrate vectorization benefits
- Provide benchmarking framework

## Architecture

### Benchmarks
- **Arithmetic**: Add, multiply, divide operations
- **Memory**: Load/store patterns, cache behavior
- **Branches**: Conditional execution, prediction
- **SIMD**: Vector operations vs scalar

### Measurement
- Cycle counting (if available)
- Instruction counting
- Cache miss analysis
- Performance comparison

## Build Instructions

### Using Makefile (Recommended)

```bash
# Build and verify
make

# Run benchmarks with QEMU
make run

# Run benchmarks natively (ARM64 only - for accurate measurements)
make run-native

# Run with performance profiling
make profile

# Run automated test
make test

# Debug with GDB
make debug

# Clean build artifacts
make clean

# Show help
make help
```

**Reference**: The Makefile uses static linking and optimization flags. See [`../../references/performance.md`](../../references/performance.md) for optimization strategies and [`../../tooling/qemu_execution.md`](../../tooling/qemu_execution.md) for QEMU execution.

### Manual Build

```bash
# Compile (static linking - no dynamic libraries)
aarch64-linux-gnu-gcc -nostdlib -static -O2 -o benchmarks benchmarks.s

# Run (native ARM64)
./benchmarks

# Run (cross-compilation with QEMU - static binary)
qemu-aarch64 ./benchmarks

# If dynamically linked, use:
# qemu-aarch64 -L /usr/aarch64-linux-gnu ./benchmarks
```

## Analysis

Compare optimized vs unoptimized versions:
- Instruction count
- Execution time
- Cache performance
- Branch prediction accuracy

## References

All concepts used in this project are documented in:
- [`../../references/performance.md`](../../references/performance.md) - Complete optimization strategies
- [`../../references/instruction_set.md`](../../references/instruction_set.md) - Instruction details
- [`../../references/syscalls.md`](../../references/syscalls.md) - clock_gettime syscall (syscall 113) for high-resolution timing
- [`../../references/memory_management.md`](../../references/memory_management.md) - Memory optimization
- [`../../references/arm_architecture.md`](../../references/arm_architecture.md) - ARM64 architecture fundamentals

Original sources:
- ARM Architecture Reference Manual - Performance
- ARM Optimization Guides
- ARM Performance Analysis Tools
