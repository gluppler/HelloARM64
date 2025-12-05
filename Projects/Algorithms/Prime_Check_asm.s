.text
//  Prime Check Assembly Function for C Interop
.global prime_check_asm
.align 4

//  Parameters: x0 = n (uint64_t)
//  Returns: x0 = 1 if prime, 0 if not prime
prime_check_asm:
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    mov     x19, x0
    
    //  Special cases
    cmp     x19, #1
    b.eq    is_prime_false
    cmp     x19, #2
    b.eq    is_prime_true
    
    //  Check if even
    and     x20, x19, #1
    cmp     x20, #0
    b.eq    is_prime_false
    
    //  Check odd divisors from 3 to sqrt(n)
    mov     x20, #3
    mov     x22, #0                      //  iteration counter
    movz    x23, #0x4240                 //  max iterations = 1000000
    movk    x23, #0x000F, lsl #16
    
prime_loop:
    cmp     x22, x23
    b.ge    is_prime_true
    
    //  Check if i * i > n
    mul     x24, x20, x20
    cmp     x24, x19
    b.gt    is_prime_true
    
    //  Check if n % i == 0
    udiv    x24, x19, x20
    mul     x24, x24, x20
    sub     x24, x19, x24
    cmp     x24, #0
    b.eq    is_prime_false
    
    add     x20, x20, #2
    add     x22, x22, #1
    b       prime_loop
    
is_prime_true:
    mov     x0, #1
    b       is_prime_done
    
is_prime_false:
    mov     x0, #0
    
is_prime_done:
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ret
