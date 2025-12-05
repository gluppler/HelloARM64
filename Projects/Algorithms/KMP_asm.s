.text
//  KMP Assembly Function for C Interop
.global kmp_search_asm
.global compute_lps_asm
.align 4

//  Helper: Compute LPS array
//  Parameters: x0 = pattern, x1 = pattern_len, x2 = lps array
compute_lps_asm:
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    mov     x19, x0
    mov     x20, x1
    mov     x21, x2
    
    str     wzr, [x21]
    mov     x22, #0                      //  len
    mov     x23, #1                      //  i
    
lps_loop:
    cmp     x23, x20
    b.hs    lps_done
    
    ldrb    w24, [x19, x23]
    ldrb    w25, [x19, x22]
    cmp     w24, w25
    b.ne    lps_mismatch
    
    add     x22, x22, #1
    str     w22, [x21, x23, lsl #2]
    add     x23, x23, #1
    b       lps_loop
    
lps_mismatch:
    cmp     x22, #0
    b.eq    lps_zero
    
    sub     x22, x22, #1
    ldr     w22, [x21, x22, lsl #2]
    b       lps_loop
    
lps_zero:
    str     wzr, [x21, x23, lsl #2]
    add     x23, x23, #1
    b       lps_loop
    
lps_done:
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ret

//  Parameters: x0 = text, x1 = text_len, x2 = pattern, x3 = pattern_len, x4 = lps
//  Returns: x0 = index if found, -1 if not found
kmp_search_asm:
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    mov     x19, x0                      //  text
    mov     x20, x1                      //  text_len
    mov     x21, x2                      //  pattern
    mov     x22, x3                      //  pattern_len
    mov     x23, x4                      //  lps
    
    mov     x24, #0                      //  i (text index)
    mov     x25, #0                      //  j (pattern index)
    sub     x26, x20, x22                 //  max_i
    
kmp_loop:
    cmp     x24, x26
    b.gt    kmp_not_found
    
    //  Compare characters
    add     x27, x24, x25
    ldrb    w28, [x19, x27]
    ldrb    w29, [x21, x25]
    cmp     w28, w29
    b.eq    kmp_match
    
    //  Mismatch - use LPS
    cmp     x25, #0
    b.eq    kmp_next_i
    sub     x25, x25, #1
    ldr     w25, [x23, x25, lsl #2]
    b       kmp_loop
    
kmp_match:
    add     x25, x25, #1
    cmp     x25, x22
    b.eq    kmp_found
    b       kmp_loop
    
kmp_next_i:
    add     x24, x24, #1
    b       kmp_loop
    
kmp_found:
    mov     x0, x24
    b       kmp_done
    
kmp_not_found:
    mov     x0, #-1
    
kmp_done:
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ret
