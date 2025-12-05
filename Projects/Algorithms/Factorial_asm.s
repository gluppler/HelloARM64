.text
//  Factorial Assembly Function for C Interop
.global factorial_asm
.align 4

//  Parameters: x0 = n (uint64_t)
//  Returns: x0 = n! (uint64_t, 0 on error)
factorial_asm:
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    mov     x19, x0
    
    //  Validate input
    cmp     x19, #0
    b.lt    factorial_error
    cmp     x19, #20
    b.gt    factorial_error
    
    //  Base case
    cmp     x19, #0
    b.eq    factorial_zero
    cmp     x19, #1
    b.le    factorial_one
    
    //  Iterative calculation
    mov     x20, #1                      //  result = 1
    mov     x21, #2                      //  i = 2
    
factorial_iter:
    cmp     x21, x19
    b.gt    factorial_done_loop
    
    mul     x20, x20, x21                //  result *= i
    
    add     x21, x21, #1
    b       factorial_iter
    
factorial_done_loop:
    mov     x0, x20
    b       factorial_done
    
factorial_zero:
factorial_one:
    mov     x0, #1
    b       factorial_done
    
factorial_error:
    mov     x0, #0
    
factorial_done:
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ret
