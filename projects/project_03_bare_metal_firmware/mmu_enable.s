// MMU enable code for ARM64
// Sets up identity mapping and enables MMU
//
// Reference: See ../../references/mmu_and_translation.md for complete MMU documentation
// Reference: See ../../references/arm_architecture.md for system registers

.section .text
.global enable_mmu
enable_mmu:
    // Save registers
    STP  X29, X30, [SP, #-16]!
    MOV  X29, SP
    
    // Configure MAIR_EL1 (Memory Attribute Indirection Register)
    // Attr0: Normal, Inner/Outer Write-Back, Read-Allocate, Write-Allocate
    MOV  X0, #0xFF
    MSR  MAIR_EL1, X0
    
    // Configure TCR_EL1 (Translation Control Register)
    // T0SZ=25 (48-bit address space), TG0=0 (4KB granule)
    MOV  X0, #25           // T0SZ (bits 5:0)
    // TG0 is already 0 (4KB granule), no need to set it
    MSR  TCR_EL1, X0
    
    // Set TTBR0_EL1 (Translation Table Base Register 0)
    // Assume page table at 0x100000 (must be 4KB aligned)
    MOV  X0, #0x100000
    MSR  TTBR0_EL1, X0
    
    // Invalidate TLBs
    TLBI VMALLE1
    DSB  SY
    ISB
    
    // Enable MMU (SCTLR_EL1.M = 1)
    MRS  X0, SCTLR_EL1
    ORR  X0, X0, #(1 << 0)  // M bit
    MSR  SCTLR_EL1, X0
    ISB                      // Ensure MMU enable takes effect
    
    // Restore registers
    MOV  SP, X29
    LDP  X29, X30, [SP], #16
    RET
