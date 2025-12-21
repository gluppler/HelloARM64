# MMU and Address Translation Reference

Complete reference for ARM64 Memory Management Unit (MMU) and address translation.

**Source**: ARM Developer Documentation - Memory Management, ARMv8-A Architecture Reference Manual

## MMU Overview

### Purpose
The Memory Management Unit (MMU) translates virtual addresses to physical addresses, provides memory protection, and controls memory attributes.

**Reference**: ARM Developer Documentation - The Memory Management Unit (MMU)

### Translation Granule
- **4KB**: Most common, 4-level page tables
- **16KB**: 4-level page tables
- **64KB**: 3-level page tables
- Controlled by TCR_EL1.TG0/TG1

**Reference**: ARM Developer Documentation - Translation granule

## Address Translation

### Translation Levels

#### 4KB Granule (4 levels)
- **Level 0 (L0)**: 512GB blocks (optional)
- **Level 1 (L1)**: 1GB blocks
- **Level 2 (L2)**: 2MB blocks
- **Level 3 (L3)**: 4KB pages

#### 16KB Granule (4 levels)
- **Level 0 (L0)**: 512GB blocks
- **Level 1 (L1)**: 32MB blocks
- **Level 2 (L2)**: 64KB blocks
- **Level 3 (L3)**: 16KB pages

#### 64KB Granule (3 levels)
- **Level 0 (L0)**: 512GB blocks
- **Level 1 (L1)**: 512MB blocks
- **Level 2 (L2)**: 64KB pages

**Reference**: ARM Developer Documentation - Multilevel translation

### Translation Table Base Registers

#### TTBR0_EL1
- Translation table base for lower address space (user space)
- Typically: 0x0000_0000_0000_0000 to implementation-defined boundary
- Contains ASID (Address Space Identifier)

#### TTBR1_EL1
- Translation table base for upper address space (kernel space)
- Typically: implementation-defined boundary to 0x0000_FFFF_FFFF_FFFF

**Reference**: ARM Developer Documentation - Registers that control address translation

### Translation Control Register (TCR_EL1)

#### Key Fields
- **T0SZ/T1SZ**: Size offset for TTBR0/TTBR1 address spaces
- **TG0/TG1**: Translation granule size
- **IPS**: Intermediate Physical Address Size
- **AS**: ASID size

**Reference**: ARMv8-A Architecture Reference Manual, Section D13.2.50

## Page Table Entries

### Table Entry Format

#### Valid Bit
- **Bit 0**: Valid (1) or Invalid (0)
- Invalid entries cause translation faults

#### Block/Page Descriptor
- **Bits [1:0]**: Entry type
  - 00: Invalid
  - 01: Block/Page (depends on level)
  - 11: Table (points to next level)

#### Access Permissions
- **AP[2:1]**: Access permissions
  - 00: Read-only at EL0, Read-write at EL1
  - 01: Read-only at all levels
  - 10: Read-write at EL0, Read-only at EL1
  - 11: Read-write at all levels
- **AP[0]**: User/Privileged (0=EL0, 1=EL1+)

#### Memory Attributes
- **AttrIndx[2:0]**: Index into MAIR_EL1 (Memory Attribute Indirection Register)
- **SH[1:0]**: Shareability (00=Non-shareable, 01=Unpredictable, 10=Outer-shareable, 11=Inner-shareable)
- **AF**: Access flag (must be set on first access)

**Reference**: ARM Developer Documentation - Table entry

### Memory Attribute Indirection Register (MAIR_EL1)
- Defines memory type attributes
- 8 attribute fields (Attr0-Attr7)
- Each field defines Normal/Device memory type and cacheability

**Reference**: ARMv8-A Architecture Reference Manual, Section D13.2.45

## Translation Lookaside Buffer (TLB)

### TLB Purpose
- Caches recent translations
- Reduces page table walk overhead
- Separate instruction and data TLBs

**Reference**: ARM Developer Documentation - TLBs and Changing translations

### TLB Invalidation

#### TLBI Instructions
```
TLBI  VMALLE1            // Invalidate all entries, current VMID
TLBI  VAE1, Xt           // Invalidate by virtual address
TLBI  ASIDE1, Xt         // Invalidate by ASID
TLBI  VAAE1, Xt          // Invalidate by virtual address, all ASIDs
```

**Reference**: ARM Developer Documentation - Format of a TLB operation

### TLB Maintenance
- Required after page table modifications
- Must be followed by DSB and ISB
- Context switches may require TLB invalidation

**Reference**: ARM Developer Documentation - Updating translations

## Address Translation Process

### Translation Walk

1. **Extract address bits**: Based on T0SZ/T1SZ, determine which TTBR to use
2. **Level 0 lookup**: Use bits [47:39] to index into L0 table
3. **Level 1 lookup**: Use bits [38:30] to index into L1 table
4. **Level 2 lookup**: Use bits [29:21] to index into L2 table
5. **Level 3 lookup**: Use bits [20:12] to index into L3 table
6. **Page offset**: Bits [11:0] used as byte offset within page

**Reference**: ARM Developer Documentation - Table lookup

### Translation Faults

#### Translation Fault
- Page table entry is invalid
- Access permission violation
- Address not in range (T0SZ/T1SZ violation)

#### Alignment Fault
- Unaligned access to device memory
- Controlled by SCTLR_EL1.A

**Reference**: ARMv8-A Architecture Reference Manual, Section D5.3

## MMU Control

### System Control Register (SCTLR_EL1)

#### Key Bits
- **M (bit 0)**: MMU enable (1=enabled, 0=disabled)
- **A (bit 1)**: Alignment check enable
- **C (bit 2)**: Cache enable
- **I (bit 12)**: Instruction cache enable

**Reference**: ARMv8-A Architecture Reference Manual, Section D13.2.1

### Enabling MMU

#### Steps
1. Configure MAIR_EL1 with memory attributes
2. Configure TCR_EL1 with translation parameters
3. Set TTBR0_EL1 (and TTBR1_EL1 if needed) with page table base
4. Create initial page tables
5. Invalidate TLBs
6. Set SCTLR_EL1.M to enable MMU
7. Execute ISB to ensure MMU enable takes effect

**Reference**: ARM Developer Documentation - MMU disabled

## Page Table Creation

### Example: Identity Mapping

```assembly
// Create identity mapping for first 2MB (4KB pages)
// Page table base at 0x80000

// Level 2 table entry (points to L3 table)
// Bits [47:39] = 0, [38:30] = 0, [29:21] = 0
// Entry at offset 0 in L2 table
MOV  X0, #0x80000        // L3 table base (must be 4KB aligned)
ORR  X0, X0, #0x3        // Type=Table, Valid
STR  X0, [X1]            // Store to L2 table entry

// Level 3 table entries (512 x 4KB pages = 2MB)
// Each entry maps 4KB page
MOV  X2, #0x0            // Physical address (identity map)
ORR  X2, X2, #(0x3 << 8) // AF=1, SH=Inner-shareable
ORR  X2, X2, #(0x1 << 2) // AttrIndx=0 (Normal memory)
ORR  X2, X2, #0x3        // Type=Page, Valid
// Store 512 entries...
```

**Reference**: ARMv8-A Architecture Reference Manual, Section D5.4

## Virtual Machine Identifiers (VMID)

### Purpose
- Tags translations with owning virtual machine
- Enables TLB sharing across VMs
- Used in virtualization scenarios

**Reference**: ARM Developer Documentation - Virtual Machine Identifiers

## References

- ARM Developer Documentation - Memory Management: https://developer.arm.com/documentation/101811/0105
- ARMv8-A Architecture Reference Manual (DDI0487): https://developer.arm.com/documentation/ddi0487/latest
- ARM Developer Documentation - MMU: https://developer.arm.com/documentation/101811/0105/The-Memory-Management-Unit--MMU-
