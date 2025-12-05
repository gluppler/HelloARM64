.text
//  Tree Traversal Assembly Function for C Interop
.global tree_traversal_asm
.align 4

//  Parameters: x0 = tree (int32_t*), x1 = root (uint32_t), x2 = size (uint32_t)
//  Returns: void (prints traversal)
//  Note: Simplified version - just marks visited nodes
tree_traversal_asm:
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x29, x30, [sp, #-16]!
    mov     x19, x0                      //  tree
    mov     x20, x1                      //  root
    mov     x21, x2                      //  size
    
    //  Validate
    cmp     x20, #0
    b.lt    traversal_done
    cmp     x20, x21
    b.hs    traversal_done
    
    //  Simplified traversal - visit nodes in order
    mov     x22, #0                      //  iteration counter
    mov     x23, #50                     //  max iterations
    
traversal_loop:
    cmp     x22, x23
    b.ge    traversal_done
    cmp     x20, x21
    b.hs    traversal_done
    
    //  Visit current node
    ldr     w24, [x19, x20, lsl #2]
    
    //  Calculate left child: 2*i + 1
    lsl     x25, x20, #1
    add     x25, x25, #1
    cmp     x25, x21
    b.hs    traversal_done
    
    //  Recursive call for left child
    mov     x0, x19
    mov     x1, x25
    mov     x2, x21
    bl      tree_traversal_asm
    
    //  Calculate right child: 2*i + 2
    lsl     x25, x20, #1
    add     x25, x25, #2
    cmp     x25, x21
    b.hs    traversal_done
    
    //  Recursive call for right child
    mov     x0, x19
    mov     x1, x25
    mov     x2, x21
    bl      tree_traversal_asm
    
    add     x22, x22, #1
    b       traversal_done
    
traversal_done:
    ldp     x29, x30, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ret
