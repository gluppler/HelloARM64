.text
//  LCM Assembly Function for C Interop
.global lcm_asm
.global gcd_helper_asm
.align 4

//  Helper function for GCD (used by LCM)
//  Parameters: x0 = a, x1 = b
//  Returns: x0 = GCD(a, b)
gcd_helper_asm:
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    mov     x19, x0
    mov     x20, x1
    
    mov     x21, #0
    movz    x22, #0x4240
    movk    x22, #0x000F, lsl #16
    
gcd_helper_loop:
    cmp     x21, x22
    b.ge    gcd_helper_done
    cmp     x20, #0
    b.eq    gcd_helper_done
    
    mov     x23, x20
    udiv    x24, x19, x20
    mul     x24, x24, x20
    sub     x20, x19, x24
    mov     x19, x23
    
    add     x21, x21, #1
    b       gcd_helper_loop
    
gcd_helper_done:
    mov     x0, x19
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ret

//  Parameters: x0 = a (uint64_t), x1 = b (uint64_t)
//  Returns: x0 = LCM(a, b) (uint64_t, 0 on error)
lcm_asm:
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x29, x30, [sp, #-16]!
    mov     x19, x0
    mov     x20, x1
    
    //  Validate inputs
    cmp     x19, #0
    b.eq    lcm_error
    cmp     x20, #0
    b.eq    lcm_error
    
    //  Calculate product first
    mul     x21, x19, x20
    
    //  Calculate GCD
    mov     x0, x19
    mov     x1, x20
    bl      gcd_helper_asm
    mov     x22, x0
    
    //  Check for division by zero
    cmp     x22, #0
    b.eq    lcm_error
    
    //  Calculate LCM = (a * b) / GCD(a, b)
    udiv    x0, x21, x22
    
    b       lcm_done
    
lcm_error:
    mov     x0, #0
    
lcm_done:
    ldp     x29, x30, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ret
