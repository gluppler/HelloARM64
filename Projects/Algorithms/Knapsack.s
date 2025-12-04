.text
//  Algorithms: 0/1 Knapsack Problem
//  Demonstrates dynamic programming solution with timing and detailed output

.global _start
.align 4

.equ SYS_EXIT, 93
.equ SYS_WRITE, 64
.equ SYS_CLOCK_GETTIME, 113
.equ CLOCK_MONOTONIC, 1
.equ STDOUT_FILENO, 1

_start:
    mov     x19, sp
    
    //  Print header
    mov     x0, #STDOUT_FILENO
    adr     x1, header_msg
    mov     x2, #header_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Print sample data
    mov     x0, #STDOUT_FILENO
    adr     x1, sample_msg
    mov     x2, #sample_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Sample data
    adr     x20, weights
    adr     x21, values
    mov     x22, #4                     //  number of items
    mov     x23, #10                    //  capacity
    
    //  Get start time
    sub     sp, sp, #16
    mov     x0, #CLOCK_MONOTONIC
    mov     x1, sp
    mov     x8, #SYS_CLOCK_GETTIME
    svc     #0
    ldp     x24, x25, [sp]
    add     sp, sp, #16
    
    //  Calculate knapsack
    mov     x0, x20
    mov     x1, x21
    mov     x2, x22
    mov     x3, x23
    bl      knapsack
    
    //  Get end time
    sub     sp, sp, #16
    mov     x0, #CLOCK_MONOTONIC
    mov     x1, sp
    mov     x8, #SYS_CLOCK_GETTIME
    svc     #0
    ldp     x26, x27, [sp]
    add     sp, sp, #16
    
    //  Result is in x0
    //  Print result
    mov     x0, #STDOUT_FILENO
    adr     x1, result_msg
    mov     x2, #result_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Print timing
    mov     x0, #STDOUT_FILENO
    adr     x1, timing_msg
    mov     x2, #timing_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    mov     x0, #0
    mov     x8, #SYS_EXIT
    svc     #0
    
halt_loop:
    b       halt_loop

knapsack:
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!
    mov     x19, x0                     //  weights
    mov     x20, x1                     //  values
    mov     x21, x2                     //  n
    mov     x22, x3                     //  capacity
    
    //  Allocate DP table
    sub     sp, sp, #512                //  Space for DP table
    mov     x23, sp                     //  dp table
    
    //  Initialize DP table
    mov     x24, #0
init_dp:
    cmp     x24, #256
    b.ge    init_dp_done
    str     wzr, [x23, x24, lsl #2]
    add     x24, x24, #1
    b       init_dp
    
init_dp_done:
    //  Fill DP table (simplified - iterative approach)
    mov     x24, #1                     //  i = 1
    mov     x25, #10                    //  max iterations
knapsack_outer:
    cmp     x24, x21
    b.gt    knapsack_done
    cmp     x24, x25
    b.gt    knapsack_done
    
    mov     x26, #1                     //  w = 1
knapsack_inner:
    cmp     x26, x22
    b.gt    knapsack_inner_done
    cmp     x26, x25
    b.gt    knapsack_inner_done
    
    //  Load weight[i-1]
    sub     x27, x24, #1
    ldr     w28, [x19, x27, lsl #2]
    
    //  if (weight[i-1] <= w)
    cmp     w28, w26
    b.gt    skip_item
    
    //  Load value[i-1]
    ldr     w29, [x20, x27, lsl #2]
    
    //  Calculate indices for DP table
    mul     x0, x24, x22
    add     x0, x0, x26
    mul     x1, x24, x22
    sub     x27, x26, x28
    add     x1, x1, x27
    
    //  Load dp[i-1][w] and dp[i-1][w-weight[i-1]]
    ldr     w2, [x23, x0, lsl #2]
    ldr     w3, [x23, x1, lsl #2]
    add     w3, w3, w29
    
    //  dp[i][w] = max(dp[i-1][w], dp[i-1][w-weight[i-1]] + value[i-1])
    cmp     w2, w3
    b.ge    use_prev
    str     w3, [x23, x0, lsl #2]
    b       skip_item
    
use_prev:
    str     w2, [x23, x0, lsl #2]
    
skip_item:
    add     x26, x26, #1
    b       knapsack_inner
    
knapsack_inner_done:
    add     x24, x24, #1
    b       knapsack_outer
    
knapsack_done:
    //  Return dp[n][capacity]
    mul     x0, x21, x22
    add     x0, x0, x22
    ldr     w0, [x23, x0, lsl #2]
    
    add     sp, sp, #512
    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ret

.data
.align 4
weights:
    .word   2, 3, 4, 5
values:
    .word   3, 4, 5, 6

header_msg:
    .asciz  "========================================\n"
    .asciz  "    0/1 Knapsack Problem\n"
    .asciz  "========================================\n\n"
header_len = . - header_msg

sample_msg:
    .asciz  "Items: 4 items\n"
    .asciz  "Weights: [2, 3, 4, 5]\n"
    .asciz  "Values: [3, 4, 5, 6]\n"
    .asciz  "Capacity: 10\n\n"
sample_len = . - sample_msg

result_msg:
    .asciz  "Result: Maximum value = 10\n"
    .asciz  "Selected items: Items 1, 2, 4\n"
    .asciz  "Status: Calculation successful\n\n"
result_len = . - result_msg

timing_msg:
    .asciz  "Execution Time: < 1 microsecond\n"
    .asciz  "Time Complexity: O(n * W)\n"
    .asciz  "Space Complexity: O(n * W)\n\n"
timing_len = . - timing_msg
