// ARM64 performance benchmarks
// Demonstrates optimization techniques and performance measurement
//
// References:
//   - ../../references/performance.md - Optimization strategies
//   - ../../references/instruction_set.md - Instruction details
//   - ../../references/syscalls.md - clock_gettime syscall (syscall 113)
//   - ../../references/arm_architecture.md - ARM64 architecture fundamentals

.section .data
msg_header:
    .asciz "=== ARM64 Performance Benchmarks ===\n"
msg_bench1_start:
    .asciz "\n[Benchmark 1] Scalar Addition Loop\n  Performing 100,000 iterations of ADD operations...\n"
msg_bench1_result:
    .asciz "  Results:\n"
msg_bench1_iterations:
    .asciz "    • Iterations: 100,000\n"
msg_bench1_instructions:
    .asciz "    • Instructions per iteration: 3 (ADD, SUBS, B.NE)\n"
msg_bench1_total:
    .asciz "    • Total instructions executed: ~300,000\n"
msg_bench1_time:
    .asciz "    • Execution time: "
msg_time_measured:
    .asciz "measured\n"
msg_time_very_fast:
    .asciz "< 1ms (very fast)\n"
msg_bench1_done:
    .asciz "  ✓ Scalar addition benchmark completed\n"
msg_bench2_start:
    .asciz "\n[Benchmark 2] Memory Access Pattern\n  Performing 100,000 memory load/store operations...\n"
msg_bench2_result:
    .asciz "  Results:\n"
msg_bench2_iterations:
    .asciz "    • Iterations: 100,000\n"
msg_bench2_instructions:
    .asciz "    • Instructions per iteration: 5 (LDR, ADD, STR, ADD, SUBS)\n"
msg_bench2_total:
    .asciz "    • Total instructions executed: ~500,000\n"
msg_bench2_memory:
    .asciz "    • Memory accesses: 200,000 (100,000 loads + 100,000 stores)\n"
msg_bench2_pattern:
    .asciz "    • Access pattern: Sequential (cache-friendly)\n"
msg_bench2_time:
    .asciz "    • Execution time: "
msg_bench2_done:
    .asciz "  ✓ Memory access benchmark completed\n"
msg_bench3_start:
    .asciz "\n[Benchmark 3] Conditional Execution (Branch Prediction)\n  Performing 100,000 conditional branches...\n"
msg_bench3_result:
    .asciz "  Results:\n"
msg_bench3_iterations:
    .asciz "    • Iterations: 100,000\n"
msg_bench3_instructions:
    .asciz "    • Instructions per iteration: 6 (CMP, B.GT, ADD/SUB, B, SUBS, B.NE)\n"
msg_bench3_total:
    .asciz "    • Total instructions executed: ~600,000\n"
msg_bench3_branches:
    .asciz "    • Conditional branches: 100,000\n"
msg_bench3_pattern:
    .asciz "    • Branch pattern: Predictable (first 500 taken, next 500 not taken)\n"
msg_bench3_time:
    .asciz "    • Execution time: "
msg_bench3_done:
    .asciz "  ✓ Branch prediction benchmark completed\n"
msg_summary_header:
    .asciz "\n=== Performance Summary ===\n"
msg_summary_total:
    .asciz "Total Instructions Executed: ~1,400,000\n"
msg_summary_breakdown1:
    .asciz "  • Scalar operations: ~300,000 instructions\n"
msg_summary_breakdown2:
    .asciz "  • Memory operations: ~500,000 instructions\n"
msg_summary_breakdown3:
    .asciz "  • Branch operations: ~600,000 instructions\n"
msg_summary_note1:
    .asciz "\nNote: Actual cycle counts depend on CPU microarchitecture.\n"
msg_summary_note2:
    .asciz "      These benchmarks demonstrate instruction-level performance characteristics.\n"
msg_footer1:
    .asciz "\n=== All Benchmarks Completed Successfully ===\n"
msg_footer2:
    .asciz "These benchmarks demonstrate:\n"
msg_footer3:
    .asciz "  • Instruction-level performance (scalar operations)\n"
msg_footer4:
    .asciz "  • Memory access patterns (cache behavior)\n"
msg_footer5:
    .asciz "  • Branch prediction (conditional execution)\n"
msg_footer6:
    .asciz "\nFor detailed analysis, see analysis.md\n"

.section .text
.global _start
_start:
    // Print header
    ADR  X0, msg_header
    BL   print_string
    
    // Benchmark 1: Scalar addition
    // Reference: See ../../references/instruction_set.md for immediate value encoding
    ADR  X0, msg_bench1_start
    BL   print_string
    
    ADR  X0, msg_bench1_result
    BL   print_string
    ADR  X0, msg_bench1_iterations
    BL   print_string
    ADR  X0, msg_bench1_instructions
    BL   print_string
    ADR  X0, msg_bench1_total
    BL   print_string
    
    // Get start time
    ADR  X0, time_start
    BL   get_time
    
    MOV  X0, #0
    // Load 100000 using MOVZ/MOVK
    MOVZ X1, #0x86A0, LSL #0    // Lower 16 bits: 0x86A0 = 34464
    MOVK X1, #0x1, LSL #16      // Upper bits: 0x1 << 16 = 65536, total = 100000
scalar_add_loop:
    ADD  X0, X0, #1
    SUBS X1, X1, #1
    B.NE scalar_add_loop
    
    // Get end time
    ADR  X0, time_end
    BL   get_time
    
    // Calculate duration
    ADR  X0, time_start
    ADR  X1, time_end
    BL   calculate_duration_ns
    // X0 now contains nanoseconds - save it
    STP  X0, XZR, [SP, #-16]!   // Save nanoseconds on stack
    
    ADR  X0, msg_bench1_time
    BL   print_string
    // Restore nanoseconds and print duration
    LDP  X0, XZR, [SP], #16     // Restore nanoseconds
    BL   print_duration_ns
    ADR  X0, msg_bench1_done
    BL   print_string
    
    // Benchmark 2: Memory access pattern
    ADR  X0, msg_bench2_start
    BL   print_string
    
    ADR  X0, msg_bench2_result
    BL   print_string
    ADR  X0, msg_bench2_iterations
    BL   print_string
    ADR  X0, msg_bench2_instructions
    BL   print_string
    ADR  X0, msg_bench2_total
    BL   print_string
    ADR  X0, msg_bench2_memory
    BL   print_string
    ADR  X0, msg_bench2_pattern
    BL   print_string
    // Get start time
    ADR  X0, time_start
    BL   get_time
    
    MOV  X0, #0
    // Load 100000 using MOVZ/MOVK
    MOVZ X1, #0x86A0, LSL #0    // Lower 16 bits: 0x86A0 = 34464
    MOVK X1, #0x1, LSL #16      // Upper bits: 0x1 << 16 = 65536, total = 100000
    ADR  X2, buffer
memory_loop:
    LDR  X3, [X2]
    ADD  X3, X3, #1
    STR  X3, [X2]
    ADD  X2, X2, #8
    SUBS X1, X1, #1
    B.NE memory_loop
    
    // Get end time
    ADR  X0, time_end
    BL   get_time
    
    // Get end time
    ADR  X0, time_end
    BL   get_time
    
    // Calculate duration
    ADR  X0, time_start
    ADR  X1, time_end
    BL   calculate_duration_ns
    // X0 now contains nanoseconds - save it
    STP  X0, XZR, [SP, #-16]!   // Save nanoseconds on stack
    
    ADR  X0, msg_bench2_time
    BL   print_string
    // Restore nanoseconds and print duration
    LDP  X0, XZR, [SP], #16     // Restore nanoseconds
    BL   print_duration_ns
    ADR  X0, msg_bench2_done
    BL   print_string
    
    // Benchmark 3: Conditional execution
    ADR  X0, msg_bench3_start
    BL   print_string
    
    ADR  X0, msg_bench3_result
    BL   print_string
    ADR  X0, msg_bench3_iterations
    BL   print_string
    ADR  X0, msg_bench3_instructions
    BL   print_string
    ADR  X0, msg_bench3_total
    BL   print_string
    ADR  X0, msg_bench3_branches
    BL   print_string
    ADR  X0, msg_bench3_pattern
    BL   print_string
    // Get start time
    ADR  X0, time_start
    BL   get_time
    
    MOV  X0, #0
    // Load 100000 using MOVZ/MOVK
    MOVZ X1, #0x86A0, LSL #0    // Lower 16 bits: 0x86A0 = 34464
    MOVK X1, #0x1, LSL #16      // Upper bits: 0x1 << 16 = 65536, total = 100000
branch_loop:
    CMP  X0, #500
    B.GT branch_taken
    ADD  X0, X0, #1
    B    branch_continue
branch_taken:
    SUB  X0, X0, #1
branch_continue:
    SUBS X1, X1, #1
    B.NE branch_loop
    
    // Get end time
    ADR  X0, time_end
    BL   get_time
    
    // Get end time
    ADR  X0, time_end
    BL   get_time
    
    // Calculate duration
    ADR  X0, time_start
    ADR  X1, time_end
    BL   calculate_duration_ns
    // X0 now contains nanoseconds - save it
    STP  X0, XZR, [SP, #-16]!   // Save nanoseconds on stack
    
    ADR  X0, msg_bench3_time
    BL   print_string
    // Restore nanoseconds and print duration
    LDP  X0, XZR, [SP], #16     // Restore nanoseconds
    BL   print_duration_ns
    ADR  X0, msg_bench3_done
    BL   print_string
    
    // Print performance summary
    ADR  X0, msg_summary_header
    BL   print_string
    ADR  X0, msg_summary_total
    BL   print_string
    ADR  X0, msg_summary_breakdown1
    BL   print_string
    ADR  X0, msg_summary_breakdown2
    BL   print_string
    ADR  X0, msg_summary_breakdown3
    BL   print_string
    ADR  X0, msg_summary_note1
    BL   print_string
    ADR  X0, msg_summary_note2
    BL   print_string
    
    // Print footer
    ADR  X0, msg_footer1
    BL   print_string
    ADR  X0, msg_footer2
    BL   print_string
    ADR  X0, msg_footer3
    BL   print_string
    ADR  X0, msg_footer4
    BL   print_string
    ADR  X0, msg_footer5
    BL   print_string
    ADR  X0, msg_footer6
    BL   print_string
    
    // Exit
    MOV  X8, #93
    MOV  X0, #0
    SVC  #0

// Helper function: Print null-terminated string
// X0: pointer to string
print_string:
    STP  X29, X30, [SP, #-16]!
    STP  X19, X20, [SP, #-16]!
    MOV  X29, SP
    MOV  X19, X0                // Save string pointer
    
    // Calculate string length
    MOV  X20, #0                // Length counter
    MOV  X1, X19                // Current pointer
length_loop:
    LDRB W2, [X1], #1          // Load byte and increment
    CBZ  W2, length_done         // Exit if null terminator
    ADD  X20, X20, #1           // Increment length
    B    length_loop
length_done:
    
    // Write string to stdout
    MOV  X8, #64                // sys_write
    MOV  X0, #1                 // stdout
    MOV  X1, X19                // buffer address
    MOV  X2, X20                // length
    SVC  #0
    
    // Restore registers
    MOV  SP, X29
    LDP  X19, X20, [SP], #16
    LDP  X29, X30, [SP], #16
    RET

// Get current time using clock_gettime
// X0 = address of timespec structure to fill
// Uses CLOCK_MONOTONIC (clock ID 1) for high-resolution timing
// Reference: ../../references/syscalls.md - clock_gettime (syscall 113)
get_time:
    STP  X29, X30, [SP, #-16]!
    STP  X19, X20, [SP, #-16]!
    MOV  X29, SP
    
    // Save timespec address (callee-saved register)
    MOV  X19, X0
    
    // clock_gettime(CLOCK_MONOTONIC, &timespec)
    // syscall 113 = clock_gettime
    MOV  X8, #113               // sys_clock_gettime
    MOV  X0, #1                 // CLOCK_MONOTONIC
    MOV  X1, X19                // timespec structure address
    SVC  #0
    
    // Result is stored in the timespec structure at X19
    // X0 contains return value (0 = success, negative = error)
    
    MOV  SP, X29
    LDP  X19, X20, [SP], #16
    LDP  X29, X30, [SP], #16
    RET

// Calculate duration in nanoseconds
// X0 = address of time_start (timespec)
// X1 = address of time_end (timespec)
// Returns: X0 = duration in nanoseconds
calculate_duration_ns:
    STP  X29, X30, [SP, #-16]!
    STP  X19, X20, [SP, #-16]!
    MOV  X29, SP
    
    // Load start time
    LDP  X2, X3, [X0]           // X2 = start_sec, X3 = start_nsec
    
    // Load end time
    LDP  X4, X5, [X1]           // X4 = end_sec, X5 = end_nsec
    
    // Calculate: (end_sec - start_sec) * 1e9 + (end_nsec - start_nsec)
    SUB  X6, X4, X2             // X6 = seconds difference
    SUB  X7, X5, X3             // X7 = nanoseconds difference
    
    // Handle negative nanoseconds (borrow from seconds)
    CMP  X7, #0
    B.GE no_borrow2
    SUB  X6, X6, #1             // Borrow 1 second
    // Add 1 billion nanoseconds: 1000 * 1000 * 1000
    MOV  X8, #1000
    MUL  X9, X8, X8             // X9 = 1,000,000
    MUL  X8, X9, X8             // X8 = 1,000,000,000
    ADD  X7, X7, X8             // Add 1 billion nanoseconds
no_borrow2:
    
    // Convert seconds to nanoseconds: X6 * 1,000,000,000
    MOV  X8, #1000
    MUL  X6, X6, X8             // X6 = seconds * 1000
    MUL  X6, X6, X8             // X6 = seconds * 1,000,000
    MUL  X6, X6, X8             // X6 = seconds * 1,000,000,000
    ADD  X0, X6, X7             // X0 = total nanoseconds
    
    MOV  SP, X29
    LDP  X19, X20, [SP], #16
    LDP  X29, X30, [SP], #16
    RET

// Print duration in human-readable format
// X0 = nanoseconds
// Format: "X.XXXs (XXXms, XXXus, XXXns)\n"
print_duration_ns:
    STP  X29, X30, [SP, #-16]!
    STP  X19, X20, [SP, #-16]!
    STP  X21, X22, [SP, #-16]!
    STP  X23, X24, [SP, #-16]!
    MOV  X29, SP
    
    MOV  X19, X0                // X19 = nanoseconds
    
    // Allocate buffer on stack (64 bytes, 16-byte aligned)
    // 80 bytes is already 16-byte aligned if stack was aligned
    SUB  SP, SP, #80            // Allocate 80 bytes
    MOV  X20, SP                // X20 = buffer address
    
    // Calculate units: divide by 1000 repeatedly
    MOV  X21, #1000
    UDIV X22, X19, X21          // X22 = microseconds
    UDIV X23, X22, X21          // X23 = milliseconds
    UDIV X24, X23, X21          // X24 = seconds
    
    // Calculate fractional milliseconds for seconds display
    MUL  X25, X24, X21          // X25 = seconds * 1000
    MUL  X25, X25, X21          // X25 = seconds * 1,000,000
    MUL  X25, X25, X21          // X25 = seconds * 1,000,000,000
    SUB  X25, X19, X25          // X25 = fractional nanoseconds
    UDIV X25, X25, X21          // X25 = fractional microseconds
    UDIV X25, X25, X21          // X25 = fractional milliseconds (0-999)
    
    // Print seconds.X.X.X
    MOV  X0, X24
    MOV  X1, X20
    BL   uint64_to_string
    MOV  X0, X20
    BL   print_string
    
    // Print "."
    ADR  X0, msg_dot
    BL   print_string
    
    // Print fractional milliseconds (3 digits)
    MOV  X0, X25
    MOV  X1, X20
    BL   uint64_to_string_3digits
    MOV  X0, X20
    BL   print_string
    
    // Print "s ("
    ADR  X0, msg_sec_open
    BL   print_string
    
    // Print milliseconds
    MOV  X0, X23
    MOV  X1, X20
    BL   uint64_to_string
    MOV  X0, X20
    BL   print_string
    
    // Print "ms, "
    ADR  X0, msg_ms
    BL   print_string
    
    // Print microseconds
    MOV  X0, X22
    MOV  X1, X20
    BL   uint64_to_string
    MOV  X0, X20
    BL   print_string
    
    // Print "us, "
    ADR  X0, msg_us
    BL   print_string
    
    // Print nanoseconds
    MOV  X0, X19
    MOV  X1, X20
    BL   uint64_to_string
    MOV  X0, X20
    BL   print_string
    
    // Print "ns)\n"
    ADR  X0, msg_ns_close
    BL   print_string
    
    // Restore stack
    ADD  SP, SP, #80
    
    MOV  SP, X29
    LDP  X23, X24, [SP], #16
    LDP  X21, X22, [SP], #16
    LDP  X19, X20, [SP], #16
    LDP  X29, X30, [SP], #16
    RET

// OLD calculate_duration - removed, using calculate_duration_ns instead
// calculate_duration_old:
    STP  X29, X30, [SP, #-16]!
    MOV  X29, SP
    
    // Load start time
    ADR  X0, time_start
    LDP  X1, X2, [X0]           // X1 = start_sec, X2 = start_nsec
    
    // Load end time
    ADR  X0, time_end
    LDP  X3, X4, [X0]           // X3 = end_sec, X4 = end_nsec
    
    // Calculate: (end_sec - start_sec) * 1e9 + (end_nsec - start_nsec)
    SUB  X5, X3, X1             // X5 = seconds difference
    SUB  X6, X4, X2             // X6 = nanoseconds difference
    
    // Handle negative nanoseconds (borrow from seconds)
    CMP  X6, #0
    B.GE no_borrow1
    SUB  X5, X5, #1             // Borrow 1 second
    // Add 1 billion nanoseconds: multiply 1000 three times
    MOV  X7, #1000
    MOV  X8, X7
    MUL  X8, X8, X7             // X8 = 1,000,000
    MUL  X8, X8, X7             // X8 = 1,000,000,000
    ADD  X6, X6, X8             // Add 1 billion nanoseconds
no_borrow1:
    
    // Convert seconds to nanoseconds: X5 * 1,000,000,000
    // Use multiplication by 1000 three times (safer than loading large constant)
    MOV  X7, #1000              // 1000
    MUL  X5, X5, X7             // X5 = seconds * 1000
    MUL  X5, X5, X7             // X5 = seconds * 1,000,000
    MUL  X5, X5, X7             // X5 = seconds * 1,000,000,000
    ADD  X5, X5, X6             // Add nanoseconds
    
    // Store result
    ADR  X0, time_diff
    STR  X5, [X0]
    
    MOV  SP, X29
    LDP  X29, X30, [SP], #16
    RET

// OLD print_duration - removed, using print_duration_ns instead
// print_duration_old:
    STP  X29, X30, [SP, #-16]!
    STP  X19, X20, [SP, #-16]!
    STP  X21, X22, [SP, #-16]!
    STP  X23, X24, [SP, #-16]!
    MOV  X29, SP
    
    ADR  X0, time_diff
    LDR  X19, [X0]              // X19 = nanoseconds
    
    // Calculate seconds and fractional part
    // 1 billion = 1000 * 1000 * 1000
    MOV  X20, #1000             // 1000
    UDIV X21, X19, X20          // X21 = nanoseconds / 1000 (microseconds)
    UDIV X21, X21, X20          // X21 = microseconds / 1000 (milliseconds)
    UDIV X21, X21, X20          // X21 = milliseconds / 1000 (seconds)
    
    // Calculate fractional part: X19 % 1,000,000,000
    // X22 = full seconds in nanoseconds
    MUL  X22, X21, X20          // X22 = seconds * 1000
    MUL  X22, X22, X20          // X22 = seconds * 1,000,000
    MUL  X22, X22, X20          // X22 = seconds * 1,000,000,000
    SUB  X22, X19, X22          // X22 = fractional nanoseconds
    
    // Convert fractional nanoseconds to milliseconds (for display)
    MOV  X20, #1000
    UDIV X22, X22, X20          // X22 = fractional microseconds
    UDIV X22, X22, X20          // X22 = fractional milliseconds (0-999)
    
    // Calculate microseconds and milliseconds for display
    MOV  X20, #1000
    UDIV X23, X19, X20          // X23 = microseconds
    UDIV X24, X23, X20          // X24 = milliseconds
    
    // Print seconds with decimal: "X.XXX"
    // Allocate buffer on stack
    SUB  SP, SP, #64            // Allocate 64 bytes on stack
    MOV  X0, X21
    MOV  X1, SP                // Use stack as buffer
    BL   uint64_to_string
    MOV  X0, SP                // Use stack buffer
    BL   print_string
    ADD  SP, SP, #64            // Restore stack
    
    // Print "."
    ADR  X0, msg_dot
    BL   print_string
    
    // Print fractional milliseconds (3 digits, zero-padded)
    SUB  SP, SP, #64
    MOV  X0, X22
    MOV  X1, SP
    BL   uint64_to_string_3digits
    MOV  X0, SP
    BL   print_string
    ADD  SP, SP, #64
    
    // Print "s ("
    ADR  X0, msg_sec_open
    BL   print_string
    
    // Print milliseconds
    SUB  SP, SP, #64
    MOV  X0, X24
    MOV  X1, SP
    BL   uint64_to_string
    MOV  X0, SP
    BL   print_string
    ADD  SP, SP, #64
    
    // Print "ms, "
    ADR  X0, msg_ms
    BL   print_string
    
    // Print microseconds
    SUB  SP, SP, #64
    MOV  X0, X23
    MOV  X1, SP
    BL   uint64_to_string
    MOV  X0, SP
    BL   print_string
    ADD  SP, SP, #64
    
    // Print "us, "
    ADR  X0, msg_us
    BL   print_string
    
    // Print nanoseconds
    SUB  SP, SP, #64
    MOV  X0, X19
    MOV  X1, SP
    BL   uint64_to_string
    MOV  X0, SP
    BL   print_string
    ADD  SP, SP, #64
    
    // Print "ns)\n"
    ADR  X0, msg_ns_close
    BL   print_string
    
    MOV  SP, X29
    LDP  X23, X24, [SP], #16
    LDP  X21, X22, [SP], #16
    LDP  X19, X20, [SP], #16
    LDP  X29, X30, [SP], #16
    RET

// Convert uint64 to string (simple version)
// X0 = number, X1 = buffer address
uint64_to_string:
    STP  X29, X30, [SP, #-16]!
    STP  X19, X20, [SP, #-16]!
    STP  X21, X22, [SP, #-16]!
    STP  X23, X24, [SP, #-16]!
    MOV  X29, SP
    
    MOV  X19, X0                // Number
    MOV  X20, X1                // Buffer
    MOV  X21, #0                // Digit count
    
    // Handle zero case
    CBZ  X19, handle_zero
    
    // Convert to string (reverse order)
    MOV  X22, #10               // Base 10
convert_loop:
    UDIV X23, X19, X22          // X23 = quotient
    MSUB X24, X23, X22, X19     // X24 = remainder (digit)
    ADD  X24, X24, #48          // Convert to ASCII
    STRB W24, [X20, X21]        // Store digit
    ADD  X21, X21, #1           // Increment counter
    MOV  X19, X23               // Update number
    CBNZ X19, convert_loop      // Continue if not zero
    
    // Reverse string
    MOV  X23, #0                // Start index
    SUB  X24, X21, #1           // End index
reverse_loop:
    CMP  X23, X24
    B.GE reverse_done
    LDRB W25, [X20, X23]        // Load from start
    LDRB W26, [X20, X24]        // Load from end
    STRB W26, [X20, X23]        // Swap
    STRB W25, [X20, X24]        // Swap
    ADD  X23, X23, #1
    SUB  X24, X24, #1
    B    reverse_loop
reverse_done:
    B    string_done
    
handle_zero:
    MOV  W24, #48               // '0'
    STRB W24, [X20]
    MOV  X21, #1
    
string_done:
    // Null terminate
    MOV  W24, #0
    STRB W24, [X20, X21]
    
    MOV  SP, X29
    LDP  X23, X24, [SP], #16
    LDP  X21, X22, [SP], #16
    LDP  X19, X20, [SP], #16
    LDP  X29, X30, [SP], #16
    RET

// Convert uint64 to 3-digit string (for fractional seconds, zero-padded)
// X0 = number (0-999), X1 = buffer address
uint64_to_string_3digits:
    STP  X29, X30, [SP, #-16]!
    MOV  X29, SP
    
    MOV  X2, X0                 // Number
    MOV  X3, X1                 // Buffer
    
    // Extract hundreds
    MOV  X4, #100
    UDIV X5, X2, X4             // Hundreds digit
    ADD  X5, X5, #48            // Convert to ASCII
    STRB W5, [X3]
    
    // Calculate remainder for tens
    MUL  X6, X5, X4             // X6 = hundreds * 100
    SUB  X6, X2, X6              // X6 = remainder (0-99)
    
    // Extract tens
    MOV  X4, #10
    UDIV X5, X6, X4             // Tens digit
    ADD  X5, X5, #48            // Convert to ASCII
    STRB W5, [X3, #1]
    
    // Extract ones (remainder after tens)
    MUL  X7, X5, X4             // X7 = tens * 10
    SUB  X5, X6, X7              // X5 = ones digit
    ADD  X5, X5, #48            // Convert to ASCII
    STRB W5, [X3, #2]
    
    // Null terminate
    MOV  W5, #0
    STRB W5, [X3, #3]
    
    MOV  SP, X29
    LDP  X29, X30, [SP], #16
    RET

// Message strings for duration printing
msg_dot:
    .asciz "."
msg_sec_open:
    .asciz "s ("
msg_ms:
    .asciz "ms, "
msg_us:
    .asciz "us, "
msg_ns_close:
    .asciz "ns)\n"

// Time structures (timespec: {tv_sec, tv_nsec})
// Must be 16-byte aligned for proper timespec structure
.align 4
time_start:
    .quad 0    // tv_sec
    .quad 0    // tv_nsec
time_end:
    .quad 0    // tv_sec
    .quad 0    // tv_nsec
time_diff:
    .quad 0    // nanoseconds

.section .bss
.lcomm buffer, 1000000          // 1MB buffer for 100,000 iterations (8 bytes each = 800KB)
