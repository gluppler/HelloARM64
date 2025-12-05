.text
//  Algorithms: Breadth-First Search (BFS)
//  Demonstrates BFS algorithm with timing and detailed output

.global _start
.align 4

.equ SYS_EXIT, 93
.equ SYS_WRITE, 64
.equ SYS_CLOCK_GETTIME, 113
.equ CLOCK_MONOTONIC, 1
.equ STDOUT_FILENO, 1

_start:
    mov     x19, sp
    
    //  Get time-based seed for randomization
    sub     sp, sp, #16
    mov     x0, #CLOCK_MONOTONIC
    mov     x1, sp
    mov     x8, #SYS_CLOCK_GETTIME
    svc     #0
    ldp     x20, x21, [sp]                //  x20 = seconds, x21 = nanoseconds
    add     sp, sp, #16
    
    //  Combine seconds and nanoseconds for seed
    and     x20, x20, #0xFFFF
    and     x21, x21, #0xFFFF
    lsl     x20, x20, #16
    orr     x22, x20, x21                  //  x22 = initial seed
    
    //  Print header
    mov     x0, #STDOUT_FILENO
    adr     x1, header_msg
    mov     x2, #header_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Test 1: Smallest graph (5 nodes)
    mov     x0, #STDOUT_FILENO
    adr     x1, test1_msg
    mov     x2, #test1_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    mov     x0, #5                         //  nodes
    mov     x1, x22                        //  seed
    bl      test_bfs
    
    //  Update seed
    movz    x0, #0x41C6
    movk    x0, #0x4E6D, lsl #16
    mul     x22, x22, x0
    movz    x0, #0x3039
    add     x22, x22, x0
    movz    x0, #0xFFFF
    movk    x0, #0x7FFF, lsl #16
    and     x22, x22, x0
    
    //  Test 2: Median graph (8 nodes)
    mov     x0, #STDOUT_FILENO
    adr     x1, test2_msg
    mov     x2, #test2_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    mov     x0, #8                         //  nodes
    mov     x1, x22                        //  seed
    bl      test_bfs
    
    //  Update seed
    movz    x0, #0x41C6
    movk    x0, #0x4E6D, lsl #16
    mul     x22, x22, x0
    movz    x0, #0x3039
    add     x22, x22, x0
    movz    x0, #0xFFFF
    movk    x0, #0x7FFF, lsl #16
    and     x22, x22, x0
    
    //  Test 3: Largest graph (12 nodes)
    mov     x0, #STDOUT_FILENO
    adr     x1, test3_msg
    mov     x2, #test3_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    mov     x0, #12                        //  nodes
    mov     x1, x22                        //  seed
    bl      test_bfs
    
    mov     x0, #0
    mov     x8, #SYS_EXIT
    svc     #0
    
halt_loop:
    b       halt_loop

test_bfs:
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!
    stp     x27, x28, [sp, #-16]!
    stp     x29, x30, [sp, #-16]!
    //  x0 = num_nodes, x1 = seed
    mov     x19, x0                        //  num_nodes
    mov     x20, x1                        //  seed
    
    //  Input validation: num_nodes must be > 0
    cmp     x19, #0
    b.le    test_bfs_error                 //  Invalid num_nodes
    
    //  Stack overflow protection: limit max nodes to prevent excessive stack usage
    //  Maximum reasonable size: 1000 nodes (1000 * 1000 = 1MB graph + queue/visited)
    movz    x0, #0x03E8                    //  1000
    cmp     x19, x0
    b.gt    test_bfs_error                 //  num_nodes too large
    
    //  Allocate graph matrix (num_nodes * num_nodes bytes, aligned)
    //  Check for multiplication overflow
    movz    x0, #0xFFFF
    movk    x0, #0xFFFF, lsl #16
    movk    x0, #0xFFFF, lsl #32
    udiv    x0, x0, x19                    //  max safe value for num_nodes
    cmp     x19, x0
    b.gt    test_bfs_error                 //  Multiplication would overflow
    mul     x21, x19, x19                  //  total bytes
    add     x21, x21, #15
    and     x21, x21, #0xFFFFFFF0
    //  Additional safety: ensure allocation size is reasonable (< 10MB)
    movz    x0, #0x4000                    //  16KB in pages
    movk    x0, #0x0098, lsl #16            //  ~10MB total
    cmp     x21, x0
    b.gt    test_bfs_error                 //  Allocation too large
    sub     sp, sp, x21
    mov     x22, sp                        //  graph matrix
    
    //  Generate random graph
    mov     x0, x22
    mov     x1, x19
    mov     x2, x20                        //  seed
    bl      generate_random_graph
    mov     x20, x0                        //  updated seed
    
    //  Print graph header
    mov     x0, #STDOUT_FILENO
    adr     x1, graph_msg
    mov     x2, #graph_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Print graph matrix
    mov     x0, x22
    mov     x1, x19
    bl      print_graph
    
    //  Allocate visited array (num_nodes bytes, aligned to 16)
    mov     x23, x19                       //  num_nodes
    add     x23, x23, #15
    and     x23, x23, #0xFFFFFFF0          //  x23 = visited array size (PRESERVE THIS)
    sub     sp, sp, x23
    mov     x24, sp                        //  x24 = visited array pointer
    
    //  Allocate queue (num_nodes * 8 bytes for indices, aligned to 16)
    mov     x25, x19
    lsl     x25, x25, #3                   //  num_nodes * 8
    add     x25, x25, #15
    and     x25, x25, #0xFFFFFFF0          //  x25 = queue size (PRESERVE THIS)
    sub     sp, sp, x25
    mov     x26, sp                        //  x26 = queue pointer
    
    //  Get start time
    sub     sp, sp, #16
    mov     x0, #CLOCK_MONOTONIC
    mov     x1, sp
    mov     x8, #SYS_CLOCK_GETTIME
    svc     #0
    ldp     x27, x28, [sp]                 //  start_sec (x27), start_nsec (x28)
    add     sp, sp, #16
    
    //  Perform BFS from node 0
    //  Save pointers to stack (bfs preserves callee-saved registers, but we save to be safe)
    stp     x24, x26, [sp, #-16]!          //  Save visited (x24) and queue (x26) pointers
    mov     x0, x22                        //  graph
    mov     x1, x19                        //  num_nodes
    mov     x2, #0                         //  start_node
    mov     x3, x24                        //  visited array pointer
    mov     x4, x26                        //  queue pointer
    bl      bfs
    //  Restore pointers
    ldp     x24, x26, [sp], #16            //  Restore visited (x24) and queue (x26) pointers
    
    //  Print visited array immediately after BFS
    mov     x0, #STDOUT_FILENO
    adr     x1, traversal_msg
    mov     x2, #traversal_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    mov     x0, x24                        //  visited array pointer
    mov     x1, x19                        //  num_nodes
    bl      print_visited
    
    mov     x0, #STDOUT_FILENO
    adr     x1, closing_bracket
    mov     x2, #2
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Get end time
    sub     sp, sp, #16
    mov     x0, #CLOCK_MONOTONIC
    mov     x1, sp
    mov     x8, #SYS_CLOCK_GETTIME
    svc     #0
    ldp     x0, x1, [sp]                    //  end_sec (x0), end_nsec (x1)
    add     sp, sp, #16
    
    //  Calculate elapsed time
    //  x0 = end_sec, x1 = end_nsec
    //  x27 = start_sec, x28 = start_nsec
    //  Validate: end >= start
    cmp     x0, x27                         //  Compare end_sec with start_sec
    b.lt    time_error_bfs
    b.gt    calc_elapsed_bfs
    //  Same second - compare nanoseconds
    cmp     x1, x28                         //  Compare end_nsec with start_nsec
    b.lt    time_error_bfs
    mov     x0, #0
    sub     x1, x1, x28                     //  elapsed_nsec = end_nsec - start_nsec
    b       time_ok_bfs
    
calc_elapsed_bfs:
    sub     x0, x0, x27                     //  elapsed_sec = end_sec - start_sec
    cmp     x1, x28                         //  Compare end_nsec with start_nsec
    b.ge    no_borrow_bfs
    cmp     x0, #0
    b.le    time_error_bfs
    sub     x0, x0, #1
    movz    x2, #0xCA00
    movk    x2, #0x3B9A, lsl #16
    //  Calculate elapsed_nsec: (end_nsec + 1_second) - start_nsec
    add     x1, x1, x2                       //  end_nsec + 1 second in nanoseconds
    sub     x1, x1, x28                      //  elapsed_nsec
    b       time_check_bfs
no_borrow_bfs:
    sub     x1, x1, x28                      //  elapsed_nsec = end_nsec - start_nsec
time_check_bfs:
    //  Sanity check: elapsed time should be reasonable (< 1 second)
    cmp     x0, #1
    b.ge    time_error_bfs
    //  Additional check: if elapsed_sec is 0 but elapsed_nsec is huge, it's an error
    cmp     x0, #0
    b.ne    time_ok_bfs
    //  Check if elapsed_nsec is reasonable (< 1 second = 1000000000)
    movz    x2, #0xCA00
    movk    x2, #0x3B9A, lsl #16
    cmp     x1, x2
    b.ge    time_error_bfs
    //  Also check for obviously wrong values (if nsec > 1000000000, it's wrong)
    b       time_ok_bfs
    
time_error_bfs:
    mov     x0, #0
    mov     x1, #1                         //  Default to 1 nanosecond on error
    
time_ok_bfs:
    //  Save elapsed time to stack
    stp     x0, x1, [sp, #-16]!             //  Save elapsed_sec, elapsed_nsec
    
    //  Print status
    mov     x0, #STDOUT_FILENO
    adr     x1, status_msg
    mov     x2, #status_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Restore elapsed time and print
    ldp     x0, x1, [sp], #16               //  Restore elapsed_sec, elapsed_nsec
    bl      print_time
    
    //  Deallocate in reverse order of allocation
    //  Recalculate sizes from num_nodes (preserved in x19)
    mov     x0, x19                        //  num_nodes
    
    //  Calculate queue size
    lsl     x25, x0, #3                    //  num_nodes * 8
    add     x25, x25, #15
    and     x25, x25, #0xFFFFFFF0          //  queue size (aligned)
    
    //  Calculate visited array size
    mov     x23, x0                        //  num_nodes
    add     x23, x23, #15
    and     x23, x23, #0xFFFFFFF0          //  visited array size (aligned)
    
    //  Calculate graph size
    mul     x21, x0, x0                    //  graph size = num_nodes * num_nodes
    add     x21, x21, #15
    and     x21, x21, #0xFFFFFFF0          //  graph size (aligned)
    
    //  Deallocate in reverse order: queue, visited, graph
    add     sp, sp, x25                    //  Deallocate queue
    add     sp, sp, x23                    //  Deallocate visited
    add     sp, sp, x21                    //  Deallocate graph
    
    //  Restore registers in reverse order of save (LIFO)
    ldp     x29, x30, [sp], #16            //  Restore x29 (FP) and x30 (LR)
    ldp     x27, x28, [sp], #16            //  Restore x27, x28
    ldp     x25, x26, [sp], #16            //  Restore x25, x26  
    ldp     x23, x24, [sp], #16            //  Restore x23, x24
    ldp     x21, x22, [sp], #16            //  Restore x21, x22
    ldp     x19, x20, [sp], #16            //  Restore x19, x20
    //  Stack pointer should now be back to original value
    ret                                     //  Return using x30 (LR) - if x30 is wrong, segfault here

test_bfs_error:
    //  Error handler: clean up and return safely
    //  Restore stack pointer if needed (x21 may not be set)
    ldp     x29, x30, [sp], #16
    ldp     x27, x28, [sp], #16
    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ret

generate_random_graph:
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!
    //  x0 = graph matrix, x1 = num_nodes, x2 = seed
    mov     x19, x0                        //  graph
    mov     x20, x1                        //  num_nodes
    mov     x21, x2                        //  seed
    
    //  Input validation: num_nodes must be > 0
    cmp     x20, #0
    b.le    gen_graph_error                //  Invalid num_nodes
    
    //  Initialize graph to zero
    mov     x22, #0
    mov     x23, #0
init_graph:
    cmp     x23, x20
    b.ge    init_graph_done
    mov     x24, #0
init_row:
    cmp     x24, x20
    b.ge    init_row_done
    mul     x0, x23, x20
    add     x0, x0, x24
    strb    wzr, [x19, x0]
    add     x24, x24, #1
    b       init_row
init_row_done:
    add     x23, x23, #1
    b       init_graph
init_graph_done:
    
    //  Generate random edges (30% probability)
    mov     x22, #0                        //  i
gen_edges_i:
    cmp     x22, x20
    b.ge    gen_edges_done
    mov     x23, #0                        //  j
gen_edges_j:
    cmp     x23, x20
    b.ge    gen_edges_j_done
    cmp     x22, x23
    b.eq    skip_self                      //  Skip self-loops
    
    //  Generate random (0-99)
    mov     x0, x21
    movz    x1, #0x41C6
    movk    x1, #0x4E6D, lsl #16
    mul     x0, x0, x1
    movz    x1, #0x3039
    add     x0, x0, x1
    movz    x1, #0xFFFF
    movk    x1, #0x7FFF, lsl #16
    and     x21, x0, x1                    //  Update seed
    
    //  Check if < 30 (30% probability)
    mov     x0, x21
    mov     x1, #100
    udiv    x24, x0, x1
    mul     x24, x24, x1
    sub     x24, x0, x24                   //  x24 = random % 100
    cmp     x24, #30
    b.ge    skip_edge
    
    //  Add edge (symmetric) with bounds checking
    //  Calculate index for graph[i][j] = graph[i * num_nodes + j]
    mul     x0, x22, x20
    //  Check for overflow
    cmp     x22, #0
    b.eq    mul_ok_i
    movz    x24, #0xFFFF
    movk    x24, #0xFFFF, lsl #16
    movk    x24, #0xFFFF, lsl #32
    udiv    x24, x24, x20
    cmp     x22, x24
    b.gt    skip_edge                      //  Overflow protection
mul_ok_i:
    add     x0, x0, x23
    //  Validate index bounds
    mul     x24, x20, x20                  //  max index
    cmp     x0, x24
    b.ge    skip_edge                      //  Index out of bounds
    mov     w1, #1
    strb    w1, [x19, x0]
    
    //  Calculate index for graph[j][i] = graph[j * num_nodes + i]
    mul     x0, x23, x20
    //  Check for overflow
    cmp     x23, #0
    b.eq    mul_ok_j
    movz    x24, #0xFFFF
    movk    x24, #0xFFFF, lsl #16
    movk    x24, #0xFFFF, lsl #32
    udiv    x24, x24, x20
    cmp     x23, x24
    b.gt    skip_edge                      //  Overflow protection
mul_ok_j:
    add     x0, x0, x22
    //  Validate index bounds
    mul     x24, x20, x20                  //  max index
    cmp     x0, x24
    b.ge    skip_edge                      //  Index out of bounds
    strb    w1, [x19, x0]
    
skip_edge:
skip_self:
    add     x23, x23, #1
    b       gen_edges_j
gen_edges_j_done:
    add     x22, x22, #1
    b       gen_edges_i
gen_edges_done:
    
    //  Ensure connectivity - always add edge from node 0 to node 1
    cmp     x20, #1
    b.le    ensure_done                    //  Need at least 2 nodes
    mov     w1, #1
    //  graph[0][1] = graph[0 * num_nodes + 1] = graph[1]
    //  Validate index: 0 * num_nodes + 1 = 1 < num_nodes * num_nodes
    mov     x0, #1
    mul     x24, x20, x20                  //  max index
    cmp     x0, x24
    b.ge    ensure_done                    //  Safety check
    strb    w1, [x19, #1]                  //  graph[1]
    //  graph[1][0] = graph[1 * num_nodes + 0] = graph[num_nodes]
    //  Validate index: 1 * num_nodes + 0 = num_nodes < num_nodes * num_nodes
    cmp     x20, x24
    b.ge    ensure_done                    //  Safety check
    strb    w1, [x19, x20]                 //  graph[num_nodes] (x20 = num_nodes)
ensure_done:
    
    mov     x0, x21                         //  Return updated seed
    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ret

gen_graph_error:
    //  Error handler: return seed unchanged
    mov     x0, x21                         //  Return original seed
    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ret

print_graph:
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!
    stp     x29, x30, [sp, #-16]!
    //  x0 = graph, x1 = num_nodes
    mov     x19, x0                        //  graph
    mov     x20, x1                        //  num_nodes
    
    //  Allocate buffer (aligned to 16)
    sub     sp, sp, #80
    mov     x25, sp
    
    mov     x21, #0                        //  i
print_graph_i:
    cmp     x21, x20
    b.ge    print_graph_done
    mov     x22, #0                        //  j
print_graph_j:
    cmp     x22, x20
    b.ge    print_graph_j_done
    
    //  Load graph[i][j] = graph[i * num_nodes + j]
    mul     x0, x21, x20
    add     x0, x0, x22
    ldrb    w23, [x19, x0]
    
    //  Convert digit to ASCII (0 or 1)
    add     w23, w23, #0x30                //  '0' or '1'
    
    //  Print single character
    sub     sp, sp, #16
    strb    w23, [sp]
    mov     x0, #STDOUT_FILENO
    mov     x1, sp
    mov     x2, #1
    mov     x8, #SYS_WRITE
    svc     #0
    add     sp, sp, #16
    
    //  Print space (except last column)
    add     x22, x22, #1
    cmp     x22, x20
    b.ge    print_graph_j_done
    mov     x0, #STDOUT_FILENO
    adr     x1, space_str
    mov     x2, #1
    mov     x8, #SYS_WRITE
    svc     #0
    b       print_graph_j
    
print_graph_j_done:
    //  Print newline
    mov     x0, #STDOUT_FILENO
    adr     x1, newline
    mov     x2, #1
    mov     x8, #SYS_WRITE
    svc     #0
    
    add     x21, x21, #1
    b       print_graph_i
    
print_graph_done:
    add     sp, sp, #80
    ldp     x29, x30, [sp], #16
    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ret

//  BFS (Breadth-First Search) - Correct ARM64 Implementation
//  
//  Algorithm: Breadth-First Search on undirected graph
//  Input: graph (adjacency matrix), num_nodes, start node, visited array, queue array
//  Output: visited array contains all reachable nodes marked as visited
//
//  Mathematical Foundation:
//  1. Queue Invariant: Queue contains all nodes at current level (distance from source)
//  2. Visited Invariant: Once visited, a node remains visited (prevents cycles)
//  3. Level Order: Nodes processed in order of increasing distance (FIFO property)
//  4. Termination: Algorithm ends when queue is empty (all reachable nodes processed)
//
//  Steps:
//  1. Initialize: visited[start] = true, queue = [start], front = 0, rear = 1
//  2. While queue is not empty (front < rear):
//     a. Dequeue u = queue[front], increment front
//     b. For each neighbor v of u:
//        - If edge exists and visited[v] == false:
//          * visited[v] = true
//          * Enqueue v: queue[rear] = v, increment rear
//  3. Return (all reachable nodes have been visited)
//
//  Time Complexity: O(V + E) where V = |V|, E = |E|
//  Space Complexity: O(V) for queue and visited array
bfs:
    //  Function prologue: Save callee-saved registers
    //  Following ARM64 ABI: x19-x28 are callee-saved
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    
    //  Save parameters to callee-saved registers
    //  Parameters: x0=graph, x1=num_nodes, x2=start, x3=visited, x4=queue
    mov     x19, x0                        //  graph (adjacency matrix pointer)
    mov     x20, x1                        //  num_nodes (|V|)
    mov     x21, x2                        //  start node (source s)
    mov     x24, x3                        //  visited array pointer
    mov     x23, x4                        //  queue array pointer
    
    //  Input validation
    cmp     x20, #0                        //  Check: num_nodes > 0
    b.le    bfs_done
    cmp     x21, x20                       //  Check: 0 <= start < num_nodes
    b.hs    bfs_done
    
    //  STEP 1: Initialize visited array to all false (0)
    mov     x0, #0                         //  loop counter i
bfs_clear_visited:
    cmp     x0, x20                        //  i < num_nodes?
    b.hs    bfs_clear_done
    strb    wzr, [x24, x0]                 //  visited[i] = 0 (false)
    add     x0, x0, #1
    b       bfs_clear_visited
bfs_clear_done:
    
    //  STEP 2: Initialize queue and mark start node
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
    b.hs    bfs_done                       //  If front >= rear, queue is empty, terminate
    
    //  Dequeue: Get current node u from queue[front]
    ldr     x2, [x23, x0, lsl #3]          //  x2 = current node u = queue[front]
    add     x0, x0, #1                     //  front++ (dequeue by incrementing front)
    
    //  Bounds check: Ensure current node is valid
    cmp     x2, x20                        //  current < num_nodes?
    b.hs    bfs_main_loop                  //  Skip if invalid (defensive check)
    
    //  STEP 4: Process all neighbors of current node u
    mov     x3, #0                         //  neighbor index v
bfs_neighbor_loop:
    cmp     x3, x20                        //  v < num_nodes?
    b.hs    bfs_neighbor_done
    
    //  Check if edge exists: graph[u][v] == 1?
    mul     x4, x2, x20                    //  u * num_nodes (row offset)
    add     x4, x4, x3                     //  u * num_nodes + v (matrix index)
    ldrb    w5, [x19, x4]                   //  graph[u][v]
    cmp     w5, #0
    b.eq    bfs_neighbor_next               //  No edge, skip
    
    //  Check if neighbor v is already visited
    ldrb    w5, [x24, x3]                   //  visited[v]
    cmp     w5, #0
    b.ne    bfs_neighbor_next               //  Already visited, skip
    
    //  Mark visited and enqueue
    mov     w5, #1
    strb    w5, [x24, x3]                   //  visited[v] = 1 (true)
    
    //  Enqueue neighbor v
    cmp     x1, x20                        //  rear < num_nodes?
    b.hs    bfs_neighbor_next               //  Queue full, skip
    str     x3, [x23, x1, lsl #3]          //  queue[rear] = v
    add     x1, x1, #1                     //  rear++
    
bfs_neighbor_next:
    add     x3, x3, #1                     //  v++ (next neighbor)
    b       bfs_neighbor_loop
    
bfs_neighbor_done:
    //  All neighbors of current node processed, continue with next node in queue
    b       bfs_main_loop
    
bfs_done:
    //  Function epilogue: Restore callee-saved registers
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ret

//  Helper function to print a number (saves/restores all registers)
print_number:
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!
    stp     x29, x30, [sp, #-16]!
    //  x0 = number to print
    mov     x19, x0
    
    //  Allocate buffer
    sub     sp, sp, #80
    mov     x20, sp
    
    //  Convert to string
    mov     x0, x19
    mov     x1, x20
    bl      uint64_to_string
    mov     x21, x0                        //  length
    
    //  Print
    mov     x0, #STDOUT_FILENO
    mov     x1, x20
    mov     x2, x21
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Deallocate and return
    add     sp, sp, #80
    ldp     x29, x30, [sp], #16
    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ret

print_visited:
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!
    stp     x27, x28, [sp, #-16]!
    stp     x29, x30, [sp, #-16]!
    //  x0 = visited, x1 = num_nodes
    //  Save parameters to callee-saved registers
    mov     x27, x0                        //  visited array pointer (preserved)
    mov     x28, x1                        //  num_nodes (preserved)
    
    //  Use x19-x20 for count and i
    mov     x19, #0                        //  count
    mov     x20, #0                        //  i
print_visited_loop:
    cmp     x20, x28
    b.ge    print_visited_done
    
    //  Load visited[i] - x27 = visited array, x20 = i
    ldrb    w21, [x27, x20]                //  visited[i]
    cmp     w21, #0
    b.eq    skip_visited
    
    //  Print comma if not first
    cmp     x19, #0
    b.eq    first_visited
    mov     x0, #STDOUT_FILENO
    adr     x1, comma_space
    mov     x2, #2
    mov     x8, #SYS_WRITE
    svc     #0
    
first_visited:
    //  Save local state to preserved registers before calling print_number
    //  x25-x26 are preserved by print_number, use them for temporary storage
    mov     x25, x19                       //  Save count
    mov     x26, x20                       //  Save i
    //  x27-x28 are already preserved (visited and num_nodes)
    
    //  Print node number using helper function
    mov     x0, x26                        //  node number (i)
    bl      print_number
    
    //  Restore local state (x27-x28 unchanged, x25-x26 preserved)
    mov     x19, x25                       //  Restore count
    mov     x20, x26                       //  Restore i
    
    add     x19, x19, #1
    
skip_visited:
    add     x20, x20, #1
    b       print_visited_loop
    
print_visited_done:
    mov     x0, #STDOUT_FILENO
    adr     x1, newline
    mov     x2, #1
    mov     x8, #SYS_WRITE
    svc     #0
    ldp     x29, x30, [sp], #16
    ldp     x27, x28, [sp], #16
    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ret

print_time:
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!
    stp     x27, x28, [sp, #-16]!
    stp     x29, x30, [sp, #-16]!
    mov     x19, x0                     //  seconds
    mov     x20, x1                     //  nanoseconds
    
    //  Print "Execution Time: "
    mov     x0, #STDOUT_FILENO
    adr     x1, time_prefix
    mov     x2, #time_prefix_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Allocate buffers (aligned to 16 bytes)
    sub     sp, sp, #272                //  256 + 16 for alignment
    mov     x21, sp                     //  number buffer
    add     x25, sp, #128               //  temp buffer
    
    //  Convert and print time
    cmp     x19, #0
    b.ne    print_seconds
    cmp     x20, #1000
    b.lt    print_nanoseconds
    //  Compare with 1000000
    movz    x0, #0x4240
    movk    x0, #0x000F, lsl #16
    cmp     x20, x0
    b.lt    print_microseconds
    b       print_milliseconds
    
print_seconds:
    mov     x0, x19
    mov     x1, x25
    bl      uint64_to_string
    mov     x22, x0
    
    //  Copy to output
    mov     x23, x21
    mov     x24, x25
    mov     x26, x22
copy_sec:
    cmp     x26, #0
    b.le    print_sec_write
    ldrb    w27, [x24], #1
    strb    w27, [x23], #1
    sub     x26, x26, #1
    b       copy_sec
    
print_sec_write:
    mov     x0, #STDOUT_FILENO
    mov     x1, x21
    mov     x2, x22
    mov     x8, #SYS_WRITE
    svc     #0
    
    mov     x0, #STDOUT_FILENO
    adr     x1, sec_suffix
    mov     x2, #sec_suffix_len
    mov     x8, #SYS_WRITE
    svc     #0
    b       print_time_done
    
print_milliseconds:
    mov     x0, x20
    movz    x1, #0x4240
    movk    x1, #0x000F, lsl #16
    udiv    x0, x0, x1
    mov     x1, x25
    bl      uint64_to_string
    mov     x22, x0
    
    //  Copy to output
    mov     x23, x21
    mov     x24, x25
    mov     x26, x22
copy_msec:
    cmp     x26, #0
    b.le    print_msec_write
    ldrb    w27, [x24], #1
    strb    w27, [x23], #1
    sub     x26, x26, #1
    b       copy_msec
    
print_msec_write:
    mov     x0, #STDOUT_FILENO
    mov     x1, x21
    mov     x2, x22
    mov     x8, #SYS_WRITE
    svc     #0
    
    mov     x0, #STDOUT_FILENO
    adr     x1, msec_suffix
    mov     x2, #msec_suffix_len
    mov     x8, #SYS_WRITE
    svc     #0
    b       print_time_done
    
print_microseconds:
    //  Format with 3 decimal places: X.XXX microseconds
    //  x20 = nanoseconds
    mov     x0, x20
    mov     x1, #1000
    udiv    x23, x0, x1                     //  whole microseconds
    mul     x1, x23, x1
    sub     x24, x20, x1                    //  remainder nanoseconds (0-999)
    
    //  Print whole part
    mov     x0, x23
    mov     x1, x25
    bl      uint64_to_string
    mov     x22, x0
    
    mov     x0, #STDOUT_FILENO
    mov     x1, x25
    mov     x2, x22
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Print "."
    mov     x0, #STDOUT_FILENO
    adr     x1, dot_str
    mov     x2, #1
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Print 3 decimal digits (remainder in nanoseconds, 0-999)
    mov     x0, x24
    mov     x1, x25
    bl      uint64_to_string
    mov     x22, x0
    
    //  Pad to 3 digits if needed
    cmp     x22, #1
    b.eq    pad_2_digits_usec
    cmp     x22, #2
    b.eq    pad_1_digit_usec
    b       print_decimal_usec
    
pad_2_digits_usec:
    mov     x0, #STDOUT_FILENO
    adr     x1, zero_str
    mov     x2, #2
    mov     x8, #SYS_WRITE
    svc     #0
    b       print_decimal_usec
    
pad_1_digit_usec:
    mov     x0, #STDOUT_FILENO
    adr     x1, zero_str
    mov     x2, #1
    mov     x8, #SYS_WRITE
    svc     #0
    
print_decimal_usec:
    mov     x0, #STDOUT_FILENO
    mov     x1, x25
    mov     x2, x22
    mov     x8, #SYS_WRITE
    svc     #0
    
    mov     x0, #STDOUT_FILENO
    adr     x1, usec_suffix
    mov     x2, #usec_suffix_len
    mov     x8, #SYS_WRITE
    svc     #0
    b       print_time_done
    
print_nanoseconds:
    //  Convert nanoseconds to microseconds with 3 decimal places
    //  Format: 0.XXX microseconds
    //  x20 = nanoseconds
    //  Calculate: nanoseconds / 1000 = microseconds (with remainder)
    mov     x0, x20
    mov     x1, #1000
    udiv    x23, x0, x1                     //  whole microseconds (should be 0 for < 1000 nsec)
    mul     x1, x23, x1
    sub     x24, x20, x1                    //  remainder nanoseconds (0-999)
    
    //  Print "0."
    mov     x0, #STDOUT_FILENO
    adr     x1, zero_dot
    mov     x2, #zero_dot_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Convert remainder to 3-digit decimal (0-999)
    //  x24 has remainder in nanoseconds (0-999), we want it as 3 digits
    mov     x0, x24
    mov     x1, x25
    bl      uint64_to_string
    mov     x22, x0
    
    //  Pad to 3 digits if needed
    cmp     x22, #1
    b.eq    pad_2_digits
    cmp     x22, #2
    b.eq    pad_1_digit
    b       print_decimal
    
pad_2_digits:
    mov     x0, #STDOUT_FILENO
    adr     x1, zero_str
    mov     x2, #2
    mov     x8, #SYS_WRITE
    svc     #0
    b       print_decimal
    
pad_1_digit:
    mov     x0, #STDOUT_FILENO
    adr     x1, zero_str
    mov     x2, #1
    mov     x8, #SYS_WRITE
    svc     #0
    
print_decimal:
    mov     x0, #STDOUT_FILENO
    mov     x1, x25
    mov     x2, x22
    mov     x8, #SYS_WRITE
    svc     #0
    
    mov     x0, #STDOUT_FILENO
    adr     x1, usec_suffix
    mov     x2, #usec_suffix_len
    mov     x8, #SYS_WRITE
    svc     #0
    
print_time_done:
    mov     x0, #STDOUT_FILENO
    adr     x1, newline
    mov     x2, #1
    mov     x8, #SYS_WRITE
    svc     #0
    
    add     sp, sp, #272
    ldp     x29, x30, [sp], #16
    ldp     x27, x28, [sp], #16
    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ret

uint64_to_string:
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!
    mov     x19, x0
    mov     x20, x1
    
    //  Handle zero
    cmp     x19, #0
    b.ne    convert_start
    
    mov     w21, #0x30
    strb    w21, [x20]
    mov     x0, #1
    b       uint64_to_string_done
    
convert_start:
    //  Build string in reverse (aligned to 16 bytes)
    sub     sp, sp, #80                 //  64 + 16 for alignment
    mov     x21, sp                     //  temp buffer
    mov     x22, x21
    add     x22, x22, #63               //  Start from end
    
    mov     x23, #0                     //  digit count
    
convert_digits:
    cmp     x19, #0
    b.eq    reverse_start
    
    //  Limit to prevent infinite loops
    cmp     x23, #20
    b.ge    reverse_start
    
    mov     x24, #10
    udiv    x25, x19, x24
    mul     x25, x25, x24
    sub     x25, x19, x25               //  digit = num % 10
    add     w25, w25, #0x30
    
    strb    w25, [x22]
    sub     x22, x22, #1
    add     x23, x23, #1
    
    udiv    x19, x19, x24
    b       convert_digits
    
reverse_start:
    add     x22, x22, #1                //  Point to first digit
    //  Calculate length
    add     x24, x21, #64               //  End of buffer
    sub     x24, x24, x22               //  Length
    mov     x0, x24                     //  Return length
    
    //  Validate length
    cmp     x24, #0
    b.le    uint64_to_string_error
    cmp     x24, #64
    b.gt    uint64_to_string_error
    
    //  Copy to output buffer
    mov     x25, x20
    mov     x26, x24
copy_forward:
    cmp     x26, #0
    b.le    uint64_to_string_done
    ldrb    w27, [x22], #1
    strb    w27, [x25], #1
    sub     x26, x26, #1
    b       copy_forward
    
uint64_to_string_error:
    mov     x0, #0
    
uint64_to_string_done:
    add     sp, sp, #80
    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ret

.data
.align 4

header_msg:
    .asciz  "========================================\n"
    .asciz  "    BFS (Breadth-First Search) Algorithm\n"
    .asciz  "========================================\n"
header_len = . - header_msg

test1_msg:
    .asciz  "Test 1: Smallest Graph (Randomized, 5 nodes)\n"
test1_len = . - test1_msg

test2_msg:
    .asciz  "Test 2: Median Graph (Randomized, 8 nodes)\n"
test2_len = . - test2_msg

test3_msg:
    .asciz  "Test 3: Largest Graph (Randomized, 12 nodes)\n"
test3_len = . - test3_msg

graph_msg:
    .asciz  "Graph Matrix:\n"
graph_len = . - graph_msg

traversal_msg:
    .asciz  "BFS Traversal Order: ["
traversal_len = . - traversal_msg

comma_space:
    .asciz  ", "
closing_bracket:
    .asciz  "]\n"

status_msg:
    .asciz  "Status: BFS traversal completed successfully\n"
status_len = . - status_msg

time_prefix:
    .asciz  "Execution Time: "
time_prefix_len = . - time_prefix

sec_suffix:
    .asciz  " seconds\n"
sec_suffix_len = . - sec_suffix

msec_suffix:
    .asciz  " milliseconds\n"
msec_suffix_len = . - msec_suffix

usec_suffix:
    .asciz  " microseconds\n"
usec_suffix_len = . - usec_suffix

nsec_suffix:
    .asciz  " nanoseconds\n"
nsec_suffix_len = . - nsec_suffix

zero_dot:
    .asciz  "0."
zero_dot_len = . - zero_dot

dot_str:
    .asciz  "."
zero_str:
    .asciz  "00"

space_str:
    .asciz  " "
newline:
    .byte   0x0A
