.text
//  LCS Assembly Function for C Interop
.global lcs_asm
.align 4

//  Parameters: x0 = str1 (char*), x1 = str2 (char*), x2 = m (uint32_t), x3 = n (uint32_t)
//  Returns: x0 = LCS length
lcs_asm:
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!
    mov     x19, x0                      //  str1
    mov     x20, x1                      //  str2
    mov     x21, x2                      //  m
    mov     x22, x3                      //  n
    
    //  Allocate DP table
    sub     sp, sp, #1024
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
    mov     x25, #0                      //  max LCS
    mov     x26, #100                    //  max iterations
    
lcs_outer:
    cmp     x24, x21
    b.gt    lcs_done
    cmp     x26, #0
    b.le    lcs_done
    
    mov     x27, #1                      //  j = 1
lcs_inner:
    cmp     x27, x22
    b.gt    lcs_inner_done
    cmp     x26, #0
    b.le    lcs_done
    
    //  Load characters
    sub     x28, x24, #1
    sub     x29, x27, #1
    ldrb    w0, [x19, x28]
    ldrb    w1, [x20, x29]
    
    //  if (str1[i-1] == str2[j-1])
    cmp     w0, w1
    b.ne    lcs_else
    
    //  dp[i][j] = dp[i-1][j-1] + 1
    mul     x2, x24, x22
    add     x2, x2, x27
    sub     x3, x24, #1
    mul     x3, x3, x22
    add     x3, x3, x27
    sub     x3, x3, #1
    ldr     w4, [x23, x3, lsl #2]
    add     w4, w4, #1
    str     w4, [x23, x2, lsl #2]
    cmp     w4, w25
    csel    x25, x25, x4, ge
    b       lcs_next_j
    
lcs_else:
    //  dp[i][j] = max(dp[i-1][j], dp[i][j-1])
    mul     x2, x24, x22
    add     x2, x2, x27
    sub     x3, x24, #1
    mul     x3, x3, x22
    add     x3, x3, x27
    ldr     w4, [x23, x3, lsl #2]
    mul     x3, x24, x22
    add     x3, x3, x27
    sub     x3, x3, #1
    ldr     w5, [x23, x3, lsl #2]
    cmp     w4, w5
    csel    w4, w4, w5, ge
    str     w4, [x23, x2, lsl #2]
    
lcs_next_j:
    add     x27, x27, #1
    sub     x26, x26, #1
    b       lcs_inner
    
lcs_inner_done:
    add     x24, x24, #1
    sub     x26, x26, #1
    b       lcs_outer
    
lcs_done:
    mov     x0, x25
    add     sp, sp, #1024
    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ret
