# Memory Map

> **Reference**: For complete memory management documentation, see [`../../references/memory_management.md`](../../references/memory_management.md) and [`../../references/mmu_and_translation.md`](../../references/mmu_and_translation.md).

## Address Space Layout

### Code and Data
- **0x40000000**: Entry point and code
- **0x40001000**: Read-only data
- **0x40002000**: Read-write data

### System Memory
- **0x00080000**: Stack (grows downward)
- **0x00100000**: Page tables (if MMU enabled)
- **0x00200000**: Heap (if allocator implemented)

### Exception Vectors
- **0x00000000**: Exception vector table (or VBAR_EL1)

## Memory Attributes

### Normal Memory
- Cacheable
- Write-back
- Inner-shareable

### Device Memory
- Non-cacheable
- Strict ordering
- For memory-mapped I/O

## References

- ARMv8-A Architecture Reference Manual - Memory maps
- ARM Developer Documentation - Memory Management
