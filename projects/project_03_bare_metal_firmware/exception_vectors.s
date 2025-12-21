// Exception vector table for ARM64
// Must be aligned to 2KB boundary
//
// Reference: See ../../references/arm_architecture.md for exception handling
// Reference: See ../../references/mmu_and_translation.md for exception vectors

.section .text
.align 11                  // 2KB alignment
.global exception_vectors
exception_vectors:
    // Current EL with SP0
    B    sync_handler_sp0
    .align 7
    B    irq_handler_sp0
    .align 7
    B    fiq_handler_sp0
    .align 7
    B    serror_handler_sp0
    .align 7
    
    // Current EL with SPx
    B    sync_handler_spx
    .align 7
    B    irq_handler_spx
    .align 7
    B    fiq_handler_spx
    .align 7
    B    serror_handler_spx
    .align 7
    
    // Lower EL using AArch64
    B    sync_handler_lower64
    .align 7
    B    irq_handler_lower64
    .align 7
    B    fiq_handler_lower64
    .align 7
    B    serror_handler_lower64
    .align 7
    
    // Lower EL using AArch32
    B    sync_handler_lower32
    .align 7
    B    irq_handler_lower32
    .align 7
    B    fiq_handler_lower32
    .align 7
    B    serror_handler_lower32

// Exception handlers (stub implementations)
sync_handler_sp0:
    B    sync_handler_sp0  // Loop on sync exception

irq_handler_sp0:
    B    irq_handler_sp0

fiq_handler_sp0:
    B    fiq_handler_sp0

serror_handler_sp0:
    B    serror_handler_sp0

sync_handler_spx:
    B    sync_handler_spx

irq_handler_spx:
    B    irq_handler_spx

fiq_handler_spx:
    B    fiq_handler_spx

serror_handler_spx:
    B    serror_handler_spx

sync_handler_lower64:
    B    sync_handler_lower64

irq_handler_lower64:
    B    irq_handler_lower64

fiq_handler_lower64:
    B    fiq_handler_lower64

serror_handler_lower64:
    B    serror_handler_lower64

sync_handler_lower32:
    B    sync_handler_lower32

irq_handler_lower32:
    B    irq_handler_lower32

fiq_handler_lower32:
    B    fiq_handler_lower32

serror_handler_lower32:
    B    serror_handler_lower32
