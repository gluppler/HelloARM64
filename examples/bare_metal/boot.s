// Bare metal boot code for ARM64
// Sets up minimal environment and jumps to main
//
// Reference: See references/arm_architecture.md for boot process
// Reference: See references/memory_management.md for stack setup

.section .text
.global _start
_start:
    // Set up stack pointer (assume stack at 0x80000)
    MOV  X0, #0x80000
    MOV  SP, X0
    
    // Clear BSS section (if needed)
    // ... BSS clearing code ...
    
    // Jump to main
    BL   main
    
    // If main returns, loop forever
halt:
    B    halt

.global main
main:
    // Main function (implement elsewhere or inline)
    MOV  X0, #0
    RET
