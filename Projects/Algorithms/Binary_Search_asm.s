.text
//  Binary Search Assembly Function for C Interop
.global binary_search_asm
.align 4

//  Parameters: x0 = array (int32_t*), x1 = left (int32_t), x2 = right (int32_t), x3 = target (int32_t)
//  Returns: x0 = index if found, -1 if not found
binary_search_asm:
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    mov     x19, x0                      //  array
    mov     w20, w1                      //  left
    mov     w21, w2                      //  right
    mov     w22, w3                      //  target
    
binary_search_loop:
    //  Check if left > right
    cmp     w20, w21
    b.gt    binary_search_not_found
    
    //  Calculate mid = left + (right - left) / 2
    sub     w23, w21, w20
    lsr     w23, w23, #1
    add     w23, w20, w23                //  mid
    
    //  Load array[mid]
    sxtw    x23, w23
    ldr     w24, [x19, x23, lsl #2]      //  array[mid]
    
    //  Compare with target
    cmp     w24, w22
    b.eq    binary_search_found
    b.gt    binary_search_left
    
    //  array[mid] < target, search right
    add     w20, w23, #1
    b       binary_search_loop
    
binary_search_left:
    //  array[mid] > target, search left
    sub     w21, w23, #1
    b       binary_search_loop
    
binary_search_found:
    sxtw    x0, w23                      //  Return mid index
    b       binary_search_done
    
binary_search_not_found:
    mov     x0, #-1
    
binary_search_done:
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ret
