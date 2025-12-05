.text
//  GCD Assembly Function for C Interop
.global gcd_asm
.align 4

//  Parameters: x0 = a (uint64_t), x1 = b (uint64_t)
//  Returns: x0 = GCD(a, b) (uint64_t)
gcd_asm:
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    mov     x19, x0
    mov     x20, x1
    
    mov     x21, #0                      //  iteration counter
    movz    x22, #0x4240                 //  max iterations = 1000000
    movk    x22, #0x000F, lsl #16
    
gcd_loop:
    cmp     x21, x22
    b.ge    gcd_done
    
    cmp     x20, #0
    b.eq    gcd_done
    
    mov     x23, x20
    udiv    x24, x19, x20
    mul     x24, x24, x20
    sub     x20, x19, x24
    mov     x19, x23
    
    add     x21, x21, #1
    b       gcd_loop
    
gcd_done:
    mov     x0, x19
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ret
