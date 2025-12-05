.text
//  Rabin-Karp Assembly Function for C Interop
.global rabin_karp_asm
.align 4

//  Parameters: x0 = text (char*), x1 = text_len (uint32_t), x2 = pattern (char*), x3 = pattern_len (uint32_t)
//  Returns: x0 = index if found, -1 if not found
rabin_karp_asm:
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    mov     x19, x0                      //  text
    mov     x20, x1                      //  text_len
    mov     x21, x2                      //  pattern
    mov     x22, x3                      //  pattern_len
    
    //  Validate
    cmp     x22, x20
    b.gt    rabin_karp_not_found
    cmp     x22, #0
    b.le    rabin_karp_not_found
    
    //  Calculate hash for pattern
    mov     x23, #0                      //  pattern_hash
    mov     x24, #0                      //  i
    mov     x25, #256                    //  base
    mov     x26, #101                    //  prime
    
pattern_hash_loop:
    cmp     x24, x22
    b.hs    pattern_hash_done
    
    ldrb    w27, [x21, x24]
    mul     x23, x23, x25
    add     x23, x23, x27
    udiv    x28, x23, x26
    mul     x28, x28, x26
    sub     x23, x23, x28                //  mod
    
    add     x24, x24, #1
    b       pattern_hash_loop
    
pattern_hash_done:
    //  Calculate hash for first window
    mov     x24, #0                      //  text_hash
    mov     x25, #0                      //  i
    mov     x26, #256                    //  base
    mov     x27, #101                    //  prime
    
text_hash_loop:
    cmp     x25, x22
    b.hs    text_hash_done
    
    ldrb    w28, [x19, x25]
    mul     x24, x24, x26
    add     x24, x24, x28
    udiv    x29, x24, x27
    mul     x29, x29, x27
    sub     x24, x24, x29                //  mod
    
    add     x25, x25, #1
    b       text_hash_loop
    
text_hash_done:
    //  Check first window
    cmp     x24, x23
    b.ne    rabin_karp_rolling
    
    //  Verify match
    mov     x25, #0
verify_first:
    cmp     x25, x22
    b.hs    rabin_karp_found
    
    ldrb    w28, [x19, x25]
    ldrb    w29, [x21, x25]
    cmp     w28, w29
    b.ne    rabin_karp_rolling
    
    add     x25, x25, #1
    b       verify_first
    
rabin_karp_rolling:
    //  Rolling hash for remaining windows
    mov     x25, x22                     //  i = pattern_len
    mov     x26, #256                    //  base
    mov     x27, #101                    //  prime
    mov     x28, #1                      //  h = base^(pattern_len-1) mod prime
    mov     x29, #1
    
calc_h:
    cmp     x29, x22
    b.hs    calc_h_done
    mul     x28, x28, x26
    udiv    x0, x28, x27
    mul     x0, x0, x27
    sub     x28, x28, x0
    add     x29, x29, #1
    b       calc_h
    
calc_h_done:
rabin_karp_loop:
    cmp     x25, x20
    b.hs    rabin_karp_not_found
    
    //  Remove leading character, add trailing character
    sub     x29, x25, x22
    ldrb    w0, [x19, x29]
    mul     x0, x0, x28
    udiv    x1, x0, x27
    mul     x1, x1, x27
    sub     x24, x24, x1
    udiv    x1, x24, x27
    mul     x1, x1, x27
    sub     x24, x24, x1
    
    ldrb    w0, [x19, x25]
    mul     x24, x24, x26
    add     x24, x24, x0
    udiv    x1, x24, x27
    mul     x1, x1, x27
    sub     x24, x24, x1
    
    //  Check hash match
    cmp     x24, x23
    b.ne    rabin_karp_next
    
    //  Verify match
    mov     x29, #0
verify_loop:
    cmp     x29, x22
    b.hs    rabin_karp_found
    
    sub     x0, x25, x22
    add     x0, x0, x29
    add     x1, x29, #1
    ldrb    w2, [x19, x0]
    ldrb    w3, [x21, x29]
    cmp     w2, w3
    b.ne    rabin_karp_next
    
    add     x29, x29, #1
    b       verify_loop
    
rabin_karp_next:
    add     x25, x25, #1
    b       rabin_karp_loop
    
rabin_karp_found:
    sub     x0, x25, x22
    b       rabin_karp_done
    
rabin_karp_not_found:
    mov     x0, #-1
    
rabin_karp_done:
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ret
