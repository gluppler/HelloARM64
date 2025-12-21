// ARM64 performance benchmarks
// Demonstrates optimization techniques
//
// Reference: See ../../references/performance.md for optimization strategies
// Reference: See ../../references/instruction_set.md for instruction details

.section .data
result_msg:
    .asciz "Benchmark completed\n"

.section .text
.global _start
_start:
    // Benchmark 1: Scalar addition
    MOV  X0, #0
    MOV  X1, #1000000      // Iteration count
scalar_add_loop:
    ADD  X0, X0, #1
    SUBS X1, X1, #1
    B.NE scalar_add_loop
    
    // Benchmark 2: Memory access pattern
    MOV  X0, #0
    MOV  X1, #100000
    ADR  X2, buffer
memory_loop:
    LDR  X3, [X2]
    ADD  X3, X3, #1
    STR  X3, [X2]
    ADD  X2, X2, #8
    SUBS X1, X1, #1
    B.NE memory_loop
    
    // Benchmark 3: Conditional execution
    MOV  X0, #0
    MOV  X1, #1000000
branch_loop:
    CMP  X0, #500000
    B.GT branch_taken
    ADD  X0, X0, #1
    B    branch_continue
branch_taken:
    SUB  X0, X0, #1
branch_continue:
    SUBS X1, X1, #1
    B.NE branch_loop
    
    // Print completion message
    MOV  X8, #64
    MOV  X0, #1
    ADR  X1, result_msg
    MOV  X2, #20
    SVC  #0
    
    // Exit
    MOV  X8, #93
    MOV  X0, #0
    SVC  #0

.section .bss
.lcomm buffer, 8192
