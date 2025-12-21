# Lesson 09: Virtual Memory and MMU

> **References**: This lesson is cross-referenced with [`references/mmu_and_translation.md`](../references/mmu_and_translation.md) for MMU documentation and [`references/memory_management.md`](../references/memory_management.md) for virtual memory concepts.

## Learning Objectives

By the end of this lesson, you will be able to:
- Understand virtual memory concepts
- Understand MMU operation
- Understand address translation
- Understand page tables
- Understand memory protection

## Virtual Memory

### Address Spaces
- **Virtual**: 48-bit addresses (user perspective)
- **Physical**: Up to 48-bit addresses (hardware)
- **Translation**: MMU converts virtual to physical

**Reference**: ARM Developer Documentation - Memory Management

## MMU Overview

### Purpose
- Address translation
- Memory protection
- Memory attributes

**Reference**: ARM Developer Documentation - MMU

## Address Translation

### Translation Levels
- **4KB granule**: 4 levels (L0-L3)
- **16KB granule**: 4 levels
- **64KB granule**: 3 levels

**Reference**: ARM Developer Documentation - Translation Granule

### Page Table Entries
- Valid bit
- Access permissions
- Memory attributes
- Physical address

**Reference**: ARM Developer Documentation - Table Entry

## Memory Protection

### Access Permissions
- Read, Write, Execute
- User/Kernel access
- Controlled by page table entries

**Reference**: ARM Developer Documentation - MMU

## Practical Understanding

### User-Space Perspective
- Programs use virtual addresses
- MMU handles translation transparently
- Protection prevents unauthorized access

### Kernel Perspective
- Sets up page tables
- Configures MMU
- Manages memory mappings

## Exercises

1. Understand address translation process
2. Learn about page table structure
3. Understand memory protection mechanisms

## Key Takeaways

- Virtual memory provides abstraction
- MMU translates addresses
- Page tables define mappings
- Memory protection enforces security
- Translation is transparent to user programs

## Next Steps

- Review all lessons
- Complete projects
- Master ARM64 assembly

## References

- ARM Developer Documentation - Memory Management
- ARMv8-A Architecture Reference Manual
- ARM Developer Documentation - MMU
