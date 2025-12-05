.text
//  BFS Assembly Function for C Interop
//  Exports bfs_asm function that can be called from C
//  Handles memory management via C wrapper to avoid stack issues

.global bfs_asm
.align 4

//  BFS (Breadth-First Search) - C-callable version
//  Parameters (C calling convention):
//    x0 = graph (uint8_t*)
//    x1 = num_nodes (uint32_t)
//    x2 = start (uint32_t)
//    x3 = visited (uint8_t*)
//    x4 = queue (uint64_t*)
//  Returns: void
//  Modifies: visited array (all reachable nodes marked as 1)
bfs_asm:
    //  Function prologue: Save callee-saved registers
    //  Following ARM64 ABI: x19-x28 are callee-saved
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    
    //  Save parameters to callee-saved registers
    mov     x19, x0                        //  x19 = graph (adjacency matrix pointer)
    mov     x20, x1                        //  x20 = num_nodes (|V|)
    mov     x21, x2                        //  x21 = start node (source s)
    mov     x24, x3                        //  x24 = visited array pointer
    mov     x23, x4                        //  x23 = queue array pointer
    
    //  Input validation
    cmp     x20, #0                        //  Check: num_nodes > 0
    b.le    bfs_asm_done
    cmp     x21, x20                       //  Check: 0 <= start < num_nodes
    b.hs    bfs_asm_done
    
    //  STEP 1: Initialize visited array to all false (0)
    //  Clear all entries: ∀v ∈ V: visited[v] = false
    mov     x0, #0                         //  x0 = loop counter i
bfs_clear_visited:
    cmp     x0, x20                        //  i < num_nodes?
    b.hs    bfs_clear_done
    strb    wzr, [x24, x0]                 //  visited[i] = 0 (false)
    add     x0, x0, #1
    b       bfs_clear_visited
bfs_clear_done:
    
    //  STEP 2: Initialize queue and mark start node
    //  Mark start node as visited and enqueue it
    mov     w0, #1
    strb    w0, [x24, x21]                 //  visited[start] = 1 (true)
    
    //  Initialize queue: front = 0, rear = 1, queue[0] = start
    mov     x0, #0                         //  x0 = front (queue front pointer)
    mov     x1, #1                         //  x1 = rear (queue rear pointer)
    str     x21, [x23]                     //  queue[0] = start (enqueue start node)
    
    //  STEP 3: BFS Main Loop
    //  Process nodes level by level until queue is empty
bfs_main_loop:
    //  Check termination: queue empty if front >= rear
    cmp     x0, x1                         //  front < rear?
    b.hs    bfs_asm_done                   //  If front >= rear, queue is empty, terminate
    
    //  Dequeue: Get current node u from queue[front]
    ldr     x2, [x23, x0, lsl #3]          //  x2 = current node u = queue[front]
    add     x0, x0, #1                     //  front++ (dequeue by incrementing front)
    
    //  Bounds check: Ensure current node is valid
    cmp     x2, x20                        //  current < num_nodes?
    b.hs    bfs_main_loop                  //  Skip if invalid (defensive check)
    
    //  STEP 4: Process all neighbors of current node u
    //  For each neighbor v: check edge, if unvisited, mark visited and enqueue
    mov     x3, #0                         //  x3 = neighbor index v (0 to num_nodes-1)
bfs_neighbor_loop:
    cmp     x3, x20                        //  v < num_nodes?
    b.hs    bfs_neighbor_done
    
    //  Check if edge exists: graph[u][v] == 1?
    //  Adjacency matrix indexing: graph[i][j] = graph[i * num_nodes + j]
    mul     x4, x2, x20                    //  x4 = u * num_nodes (row offset)
    add     x4, x4, x3                     //  x4 = u * num_nodes + v (matrix index)
    ldrb    w5, [x19, x4]                   //  w5 = graph[u][v]
    cmp     w5, #0
    b.eq    bfs_neighbor_next               //  No edge (graph[u][v] == 0), skip
    
    //  Check if neighbor v is already visited
    ldrb    w5, [x24, x3]                   //  w5 = visited[v]
    cmp     w5, #0
    b.ne    bfs_neighbor_next               //  Already visited, skip (prevents cycles)
    
    //  Neighbor v is unvisited and edge exists: mark visited and enqueue
    //  Critical: Mark visited BEFORE enqueueing to prevent duplicates
    mov     w5, #1
    strb    w5, [x24, x3]                   //  visited[v] = 1 (true)
    
    //  Enqueue neighbor v: queue[rear] = v, then rear++
    //  Bounds check: Ensure queue has capacity
    cmp     x1, x20                        //  rear < num_nodes?
    b.hs    bfs_neighbor_next               //  Queue full, skip (should not happen)
    str     x3, [x23, x1, lsl #3]          //  queue[rear] = v
    add     x1, x1, #1                     //  rear++ (enqueue by incrementing rear)
    
bfs_neighbor_next:
    add     x3, x3, #1                     //  v++ (next neighbor)
    b       bfs_neighbor_loop
    
bfs_neighbor_done:
    //  All neighbors of current node processed, continue with next node in queue
    b       bfs_main_loop
    
bfs_asm_done:
    //  Function epilogue: Restore callee-saved registers
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ret                                     //  Return to caller
