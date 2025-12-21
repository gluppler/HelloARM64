// Bare metal boot code for ARM64
// Entry point and system initialization
//
// Reference: See ../../references/arm_architecture.md for boot process
// Reference: See ../../references/memory_management.md for stack setup

.section .rodata
msg_boot:
    .asciz "Bare Metal Firmware: Boot successful!\n"
msg_vectors:
    .asciz "Exception vectors initialized\n"
msg_ready:
    .asciz "System ready\n"

.section .text
.global _start
_start:
    // Set up stack pointer
    MOV  X0, #0x80000      // Stack at 0x80000
    MOV  SP, X0
    
    // Set up exception vectors (must be at 0x0 or VBAR_EL1)
    // For this example, assume vectors are linked at 0x0
    // Reference: See ../../references/arm_architecture.md for exception handling
    ADR  X0, exception_vectors
    MSR  VBAR_EL1, X0
    
    // Initialize MMU (optional, for this minimal example we skip)
    // BL   enable_mmu
    
    // Clear BSS section (if present)
    // ... BSS clearing code ...
    
    // Jump to main
    BL   main
    
    // If main returns, halt
halt:
    WFI                     // Wait for interrupt
    B    halt

.global main
main:
    // Save registers
    STP  X29, X30, [SP, #-16]!
    MOV  X29, SP
    
    // Initialize UART (optional, but good practice)
    BL   uart_init
    
    // Print boot message
    ADR  X0, msg_boot
    BL   uart_puts
    
    // Print exception vectors message
    ADR  X0, msg_vectors
    BL   uart_puts
    
    // Print ready message
    ADR  X0, msg_ready
    BL   uart_puts
    
    // Restore registers
    MOV  SP, X29
    LDP  X29, X30, [SP], #16
    
    // Exit QEMU using semihosting (if enabled)
    // Reference: QEMU semihosting interface for ARM64
    // X0 = 0x18 (SYS_EXIT), X1 = exit code
    // Note: Semihosting requires QEMU to be run with -semihosting flag
    MOV  X0, #0x18              // SYS_EXIT semihosting call
    MOV  X1, #0                 // Exit code: 0 (success)
    // HLT #0xF000 for semihosting (ARM64)
    // If semihosting is not enabled, this will cause an exception
    // and the exception handler will loop (which is fine for demo)
    HLT  #0xF000                // Trigger semihosting exit
    
    // If we reach here, semihosting didn't work - halt
halt_loop:
    WFI                         // Wait for interrupt
    B    halt_loop

// UART functions for QEMU virt machine
// QEMU virt machine uses PL011 UART at 0x09000000
// Reference: QEMU documentation - ARM virt machine

// UART base address (PL011 on QEMU virt)
.equ UART_BASE, 0x09000000

// UART registers
.equ UART_DR,   0x000  // Data register
.equ UART_FR,   0x018  // Flag register
.equ UART_IBRD, 0x024  // Integer baud rate divisor
.equ UART_FBRD, 0x028  // Fractional baud rate divisor
.equ UART_LCRH, 0x02C  // Line control register
.equ UART_CR,   0x030  // Control register

// Initialize UART (optional - QEMU may have it pre-initialized)
uart_init:
    MOV  X0, #UART_BASE
    // Enable UART (CR register: bit 0 = UARTEN)
    MOV  W1, #1
    STR  W1, [X0, #UART_CR]
    RET

// Write a single character to UART
// X0: character to write
uart_putc:
    MOV  X1, #UART_BASE
uart_putc_loop:
    // Wait for UART to be ready (check TXFF flag - bit 5)
    // If TXFF is set, FIFO is full, so wait
    LDR  W2, [X1, #UART_FR]
    TST  W2, #(1 << 5)        // TXFF (Transmit FIFO Full) bit
    B.NE uart_putc_loop        // Wait if FIFO is full
    
    // Write character (only lower 8 bits)
    AND  W0, W0, #0xFF        // Ensure only byte is written
    STR  W0, [X1, #UART_DR]
    RET

// Write a null-terminated string to UART
// X0: pointer to string
uart_puts:
    STP  X29, X30, [SP, #-16]!
    STP  X19, X20, [SP, #-16]!
    MOV  X29, SP
    MOV  X19, X0                // Save string pointer (callee-saved)
uart_puts_loop:
    LDRB W20, [X19], #1         // Load byte and increment pointer
    CBZ  W20, uart_puts_done    // Exit if null terminator
    MOV  W0, W20                // Move character to W0 (32-bit) for uart_putc
    BL   uart_putc
    B    uart_puts_loop
uart_puts_done:
    MOV  SP, X29
    LDP  X19, X20, [SP], #16
    LDP  X29, X30, [SP], #16
    RET
