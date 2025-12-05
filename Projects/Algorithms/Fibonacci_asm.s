.text
//  Fibonacci Assembly Function for C Interop
.global fibonacci_asm
.align 4

//  Parameters: x0 = n (uint64_t)
//  Returns: x0 = fib(n) (uint64_t, 0 on error)
fibonacci_asm:
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    mov     x19, x0
    
    //  Validate input
    cmp     x19, #0
    b.lt    fibonacci_error
    cmp     x19, #100
    b.gt    fibonacci_error
    
    //  Base cases
    cmp     x19, #0
    b.eq    fibonacci_zero
    cmp     x19, #1
    b.eq    fibonacci_one
    
    //  Iterative calculation
    mov     x20, #0                      //  fib(0)
    mov     x21, #1                      //  fib(1)
    mov     x22, #2                      //  i = 2
    
fibonacci_iter:
    cmp     x22, x19
    b.gt    fibonacci_done_loop
    
    add     x23, x20, x21                //  fib(i) = fib(i-2) + fib(i-1)
    mov     x20, x21
    mov     x21, x23
    
    add     x22, x22, #1
    b       fibonacci_iter
    
fibonacci_done_loop:
    mov     x0, x21
    b       fibonacci_done
    
fibonacci_zero:
    mov     x0, #0
    b       fibonacci_done
    
fibonacci_one:
    mov     x0, #1
    b       fibonacci_done
    
fibonacci_error:
    mov     x0, #0
    
fibonacci_done:
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ret
