.text
//  Knapsack Assembly Function for C Interop
.global knapsack_asm
.align 4

//  Parameters: x0 = weights (int32_t*), x1 = values (int32_t*), x2 = n (uint32_t), x3 = capacity (uint32_t)
//  Returns: x0 = maximum value
knapsack_asm:
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!
    mov     x19, x0                      //  weights
    mov     x20, x1                      //  values
    mov     x21, x2                      //  n
    mov     x22, x3                      //  capacity
    
    //  Allocate DP table on stack (simplified - use caller's buffer)
    //  Note: Caller should allocate (n+1) * (capacity+1) * sizeof(int32_t)
    //  For this version, we'll use a simplified approach with limited size
    sub     sp, sp, #1024                 //  Fixed size buffer
    mov     x23, sp                      //  dp table
    
    //  Initialize DP table
    mov     x24, #0
init_dp:
    cmp     x24, #256
    b.hs    init_dp_done
    str     wzr, [x23, x24, lsl #2]
    add     x24, x24, #1
    b       init_dp
    
init_dp_done:
    //  Fill DP table
    mov     x24, #1                      //  i = 1
    mov     x25, #10                     //  max iterations
knapsack_outer:
    cmp     x24, x21
    b.gt    knapsack_done
    cmp     x24, x25
    b.gt    knapsack_done
    
    mov     x26, #1                      //  w = 1
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
    
    //  Calculate indices
    mul     x0, x24, x22
    add     x0, x0, x26
    mul     x1, x24, x22
    sub     x27, x26, x28
    add     x1, x1, x27
    
    //  Load dp values
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
    
    add     sp, sp, #1024
    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ret
