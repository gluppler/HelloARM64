.text
//  Linear Search Assembly Function for C Interop
.global linear_search_asm
.align 4

//  Parameters: x0 = array (int32_t*), x1 = size (uint32_t), x2 = target (int32_t)
//  Returns: x0 = index if found, -1 if not found
linear_search_asm:
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    mov     x19, x0                      //  array
    mov     x20, x1                      //  size
    mov     w21, w2                      //  target
    
    mov     x22, #0                      //  i = 0
    movz    x23, #0x4240                 //  max iterations
    movk    x23, #0x000F, lsl #16
    
search_loop:
    cmp     x22, x23
    b.ge    search_not_found
    
    cmp     x22, x20
    b.hs    search_not_found
    
    //  Load array[i]
    ldr     w24, [x19, x22, lsl #2]      //  array[i]
    
    //  Compare with target
    cmp     w24, w21
    b.eq    search_found
    
    add     x22, x22, #1
    b       search_loop
    
search_found:
    mov     x0, x22                      //  Return index
    b       search_done
    
search_not_found:
    mov     x0, #-1
    
search_done:
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ret
