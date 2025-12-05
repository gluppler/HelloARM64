.text
//  DFS Assembly Function for C Interop
.global dfs_asm
.align 4

//  Parameters: x0 = graph (uint8_t*), x1 = visited (uint8_t*), x2 = node (uint32_t), x3 = num_nodes (uint32_t)
//  Returns: void (modifies visited array)
dfs_asm:
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x29, x30, [sp, #-16]!
    mov     x19, x0                      //  graph
    mov     x20, x1                      //  visited
    mov     x21, x2                      //  node
    mov     x22, x3                      //  num_nodes
    
    //  Prevent infinite loops
    cmp     x21, #0
    b.lt    dfs_done
    cmp     x21, x22
    b.hs    dfs_done
    
    //  Mark visited
    mov     w23, #1
    strb    w23, [x20, x21]
    
    //  Visit neighbors
    mov     x23, #0                      //  neighbor index
    mov     x24, #0                      //  iteration counter
    mov     x25, #100                    //  max iterations
    
dfs_loop:
    cmp     x24, x25
    b.ge    dfs_done
    cmp     x23, x22
    b.hs    dfs_done
    
    //  Check edge: graph[node][neighbor]
    mul     x26, x21, x22
    add     x26, x26, x23
    ldrb    w27, [x19, x26]
    cmp     w27, #1
    b.ne    next_dfs
    
    //  Check if neighbor already visited
    ldrb    w27, [x20, x23]
    cmp     w27, #0
    b.ne    next_dfs
    
    //  Recursive call
    mov     x0, x19
    mov     x1, x20
    mov     x2, x23
    mov     x3, x22
    bl      dfs_asm
    
next_dfs:
    add     x23, x23, #1
    add     x24, x24, #1
    b       dfs_loop
    
dfs_done:
    ldp     x29, x30, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ret
