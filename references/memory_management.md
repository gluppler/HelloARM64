# Memory Management Reference

Complete reference for ARM64 memory models, addressing modes, and memory operations.

**Source**: ARMv8-A Architecture Reference Manual (DDI0487), ARM Developer Documentation

## Address Spaces

### Virtual Address Space
- **Size**: 48-bit virtual addresses (typical implementation)
- **Range**: 0x0000_0000_0000_0000 to 0x0000_FFFF_FFFF_FFFF
- **Implementation-defined**: Actual size controlled by TCR_EL1.T0SZ/T1SZ

**Reference**: ARM Developer Documentation - Memory Management, Virtual and Physical Addresses

### Physical Address Space
- **Size**: Up to 48-bit physical addresses (implementation-defined)
- **Range**: Implementation-specific
- **Controlled by**: System registers and MMU configuration

**Reference**: ARM Developer Documentation - Memory Management, Physical Addresses

### Address Space Identifiers (ASID)
- Tags translations with owning process
- Enables TLB sharing across processes
- Stored in TTBR0_EL1.ASID field

**Reference**: ARM Developer Documentation - Address Space Identifiers

## Memory Attributes

### Memory Types

#### Normal Memory
- Cacheable
- Supports write-back, write-through, write-allocate policies
- Used for RAM, code, data

#### Device Memory
- Non-cacheable
- Strict ordering requirements
- Used for memory-mapped I/O
- Types: Device-nGnRnE, Device-nGnRE, Device-nGRE, Device-GRE

**Reference**: ARMv8-A Architecture Reference Manual, Section D5.2.1

### Cacheability Attributes
- **Write-Back (WB)**: Writes go to cache, flushed later
- **Write-Through (WT)**: Writes go to cache and memory
- **Non-Cacheable (NC)**: No caching

**Reference**: ARMv8-A Architecture Reference Manual, Section D5.2.2

### Shareability Attributes
- **Non-Shareable (NSH)**: Not shared between cores
- **Inner-Shareable (ISH)**: Shared within inner domain
- **Outer-Shareable (OSH)**: Shared within outer domain

**Reference**: ARMv8-A Architecture Reference Manual, Section D5.2.3

## Alignment Requirements

### Natural Alignment
- **64-bit values**: 8-byte aligned
- **32-bit values**: 4-byte aligned
- **16-bit values**: 2-byte aligned
- **8-bit values**: 1-byte aligned (no alignment required)

**Reference**: ARMv8-A Architecture Reference Manual, Section B2.5.1

### Unaligned Access
- **Configurable**: Can be enabled/disabled via SCTLR_EL1.A
- **Performance**: Unaligned accesses may be slower
- **Atomicity**: Unaligned accesses are not atomic

**Reference**: ARMv8-A Architecture Reference Manual, Section B2.5.2

## Memory Access Instructions

### Load Instructions

#### LDR (Load Register)
```
LDR  Xd, [Xn]            // Load 64-bit
LDR  Wd, [Xn]            // Load 32-bit
LDR  Hd, [Xn]            // Load 16-bit (halfword)
LDR  Bd, [Xn]            // Load 8-bit (byte)
```

#### LDRB, LDRH (Load with Sign Extension)
```
LDRSB Xd, [Xn]           // Load signed byte, sign-extend to 64-bit
LDRSH Xd, [Xn]           // Load signed halfword, sign-extend to 64-bit
LDRSW Xd, [Xn]           // Load signed word, sign-extend to 64-bit
```

**Reference**: ARM A64 ISA (DDI0602), Section C6.3.1

### Store Instructions

#### STR (Store Register)
```
STR  Xd, [Xn]            // Store 64-bit
STR  Wd, [Xn]            // Store 32-bit
STR  Hd, [Xn]            // Store 16-bit
STR  Bd, [Xn]            // Store 8-bit
```

**Reference**: ARM A64 ISA (DDI0602), Section C6.3.2

### Addressing Modes

#### Base Register
```
LDR  Xd, [Xn]            // Address = Xn
```

#### Immediate Offset
```
LDR  Xd, [Xn, #imm]      // Address = Xn + imm
STR  Xd, [Xn, #imm]      // Address = Xn + imm
```

#### Register Offset
```
LDR  Xd, [Xn, Xm]        // Address = Xn + Xm
LDR  Xd, [Xn, Xm, LSL #3] // Address = Xn + (Xm << 3)
```

#### Pre-indexed
```
LDR  Xd, [Xn, #imm]!     // Xn = Xn + imm, then load from [Xn]
```

#### Post-indexed
```
LDR  Xd, [Xn], #imm      // Load from [Xn], then Xn = Xn + imm
```

**Reference**: ARM A64 ISA (DDI0602), Section C6.3.3

### Load/Store Pair

#### LDP/STP (Load/Store Pair)
```
LDP  Xd1, Xd2, [Xn]      // Load pair from [Xn] and [Xn+8]
STP  Xd1, Xd2, [Xn]      // Store pair to [Xn] and [Xn+8]
LDP  Xd1, Xd2, [Xn, #imm]! // Pre-indexed pair
LDP  Xd1, Xd2, [Xn], #imm  // Post-indexed pair
```

**Reference**: ARM A64 ISA (DDI0602), Section C6.3.4

## Stack Operations

### Stack Pointer (SP)
- Must be 16-byte aligned
- Grows downward (decrements on push)
- Modified by load/store with SP as base

**Reference**: AAPCS64 (IHI0055), Section 5.2.3

### Stack Frame Layout
```
High Address
    ...
    [Local variables]
    [Saved registers]
    [Frame record]      <- X29 (FP) points here
    [Outgoing arguments]
    ...
Low Address             <- SP points here
```

**Reference**: AAPCS64 (IHI0055), Section 5.2.2

### Stack Operations
```
SUB  SP, SP, #16         // Allocate stack frame
ADD  SP, SP, #16         // Deallocate stack frame
STP  X29, X30, [SP, #-16]! // Save frame pointer and link register
LDP  X29, X30, [SP], #16   // Restore frame pointer and link register
```

## Memory Ordering

### Memory Barriers

#### DMB (Data Memory Barrier)
```
DMB  SY                  // Ensure memory accesses complete in order
DMB  ISH                 // Inner-shareable domain barrier
DMB  OSH                 // Outer-shareable domain barrier
```

#### DSB (Data Synchronization Barrier)
```
DSB  SY                  // Stronger than DMB, waits for completion
```

#### ISB (Instruction Synchronization Barrier)
```
ISB                      // Flush pipeline, ensure instruction fetch
```

**Reference**: ARMv8-A Architecture Reference Manual, Section B2.3

### Atomic Operations

#### LDXR/STXR (Load-Exclusive/Store-Exclusive)
```
LDXR  Xd, [Xn]           // Load exclusive
STXR  Ws, Xt, [Xn]       // Store exclusive (Ws = 0 if success)
```

**Reference**: ARMv8-A Architecture Reference Manual, Section B2.10

#### Atomic Instructions
```
LDADD  Xd, Xs, [Xn]      // Atomic add: [Xn] += Xs, Xd = old [Xn]
LDCLR  Xd, Xs, [Xn]      // Atomic clear: [Xn] &= ~Xs
LDEOR  Xd, Xs, [Xn]      // Atomic exclusive-or
LDSET  Xd, Xs, [Xn]      // Atomic set: [Xn] |= Xs
```

**Reference**: ARM A64 ISA (DDI0602), Section C6.2.7

## Memory Protection

### Access Permissions
- **Read**: R bit in page table entry
- **Write**: W bit in page table entry
- **Execute**: X bit in page table entry
- **User/Kernel**: U bit in page table entry

**Reference**: ARM Developer Documentation - MMU, Table entry

### Memory Tagging Extension (MTE)
- Optional feature for memory safety
- Tags memory with metadata
- Detects use-after-free and buffer overflows

**Reference**: ARMv8-A Architecture Reference Manual, Section D5.7

## References

- ARMv8-A Architecture Reference Manual (DDI0487): https://developer.arm.com/documentation/ddi0487/latest
- ARM Developer Documentation - Memory Management: https://developer.arm.com/documentation/101811/0105
- ARM A64 Instruction Set Architecture (DDI0602): https://developer.arm.com/documentation/ddi0602/latest
