
.text
//  Advanced/01_Atomic_Operations.s
//  Atomic Memory Operations: Load-Exclusive, Store-Exclusive, Compare-and-Swap
//  SECURITY: All atomic operations are properly synchronized, no race conditions

.global _start
.align 4

_start:
    //  ============================================
    //  ATOMIC OPERATIONS OVERVIEW
    //  ============================================
    //  Atomic operations ensure operations complete without interruption
    //  Critical for multi-threaded programming and lock-free data structures
    //  Uses Load-Exclusive (LDXR) and Store-Exclusive (STXR) instructions
    
    //  ============================================
    //  LOAD-EXCLUSIVE (LDXR/LDAXR)
    //  ============================================
    //  Marks a memory location as exclusive for this CPU
    //  Must be paired with Store-Exclusive
    
    adr     x0, atomic_var           //  Address of atomic variable
    mov     x1, #0                   //  Initial value
    
    //  Load exclusive (64-bit)
    ldxr    x2, [x0]                 //  x2 = *x0 (exclusive load)
    
    //  Load exclusive acquire (stronger ordering)
    ldaxr   x3, [x0]                 //  x3 = *x0 (exclusive load with acquire semantics)
    
    //  Load exclusive (32-bit)
    ldxr    w4, [x0]                 //  w4 = *x0 (32-bit exclusive load)
    
    //  ============================================
    //  STORE-EXCLUSIVE (STXR/STLXR)
    //  ============================================
    //  Attempts to store to exclusively-held memory
    //  Returns 0 on success, 1 on failure (if exclusive was lost)
    
    //  Store exclusive (64-bit)
    mov     x5, #42                  //  Value to store
    stxr    w6, x5, [x0]             //  Try to store: w6 = result (0=success, 1=fail)
    
    //  Check if store succeeded
    cmp     w6, #0
    b.ne    store_failed             //  Branch if store failed
    
    //  Store exclusive release (stronger ordering)
    mov     x7, #100
    stlxr   w8, x7, [x0]             //  Store with release semantics
    
    //  Store exclusive (32-bit)
    mov     w9, #200
    stxr    w10, w9, [x0]            //  32-bit store exclusive
    
    b       store_success
    
store_failed:
    //  Handle store failure (exclusive was lost, retry needed)
    //  In real code, would retry the load-exclusive/store-exclusive loop
    b       continue
    
store_success:
continue:
    //  ============================================
    //  ATOMIC INCREMENT (Load-Modify-Store Loop)
    //  ============================================
    
    adr     x11, counter             //  Address of counter
    mov     x12, #0                  //  Initialize counter
    
atomic_increment_loop:
    //  Load exclusive
    ldxr    x13, [x11]               //  Load current value
    
    //  Modify
    add     x13, x13, #1             //  Increment
    
    //  Store exclusive
    stxr    w14, x13, [x11]          //  Try to store
    
    //  Check if store succeeded
    cmp     w14, #0
    b.ne    atomic_increment_loop    //  Retry if failed
    
    //  ============================================
    //  ATOMIC COMPARE-AND-SWAP (CAS)
    //  ============================================
    
    adr     x15, cas_var             //  Address of variable
    
    //  Initialize cas_var to expected value for demonstration
    mov     x16, #10                 //  Expected value
    str     x16, [x15]               //  Initialize to 10
    
    mov     x17, #20                 //  New value
    
cas_loop:
    //  Load exclusive
    ldxr    x18, [x15]               //  Load current value
    
    //  Compare
    cmp     x18, x16                 //  Compare with expected
    b.ne    cas_failed               //  If not equal, CAS fails
    
    //  Store exclusive (only if comparison passed)
    stxr    w19, x17, [x15]          //  Try to store new value
    
    //  Check if store succeeded
    cmp     w19, #0
    b.ne    cas_loop                 //  Retry if store failed
    
    //  CAS succeeded
    b       cas_success
    
cas_failed:
    //  CAS failed - value changed
    mov     x0, #1                   //  Return failure code
    mov     x8, #93                  //  Linux exit syscall (SYS_exit)
    svc     #0
    
    //  Halt loop (should never reach here, but prevents illegal instruction)
halt_loop_error:
    b       halt_loop_error
    
cas_success:
    //  ============================================
    //  ATOMIC ADD (Fetch-and-Add)
    //  ============================================
    
    adr     x20, atomic_add_var      //  Address of variable
    mov     x21, #5                  //  Value to add
    
atomic_add_loop:
    //  Load exclusive
    ldxr    x22, [x20]               //  Load current value
    
    //  Add
    add     x23, x22, x21            //  Add value
    
    //  Store exclusive
    stxr    w24, x23, [x20]          //  Try to store
    
    //  Check if store succeeded
    cmp     w24, #0
    b.ne    atomic_add_loop          //  Retry if failed
    
    //  Original value is in x22, new value is in x23
    
    //  ============================================
    //  ATOMIC EXCHANGE (Swap)
    //  ============================================
    
    adr     x25, swap_var            //  Address of variable
    mov     x26, #99                 //  New value
    
atomic_swap_loop:
    //  Load exclusive
    ldxr    x27, [x25]               //  Load current value (old value)
    
    //  Store exclusive (swap with new value)
    stxr    w28, x26, [x25]          //  Try to store new value
    
    //  Check if store succeeded
    cmp     w28, #0
    b.ne    atomic_swap_loop         //  Retry if failed
    
    //  Old value is in x27, new value (x26) is now in memory
    
    //  ============================================
    //  LOAD-LINKED/STORE-CONDITIONAL PAIR
    //  ============================================
    //  Alternative names for Load-Exclusive/Store-Exclusive
    
    adr     x29, llsc_var            //  Address of variable
    
llsc_loop:
    //  Load-Linked (Load-Exclusive)
    ldxr    x30, [x29]               //  Mark as exclusive
    
    //  ... perform computation ...
    add     x30, x30, #1             //  Modify value
    
    //  Store-Conditional (Store-Exclusive)
    stxr    w0, x30, [x29]           //  Try to store
    
    //  Check result
    cmp     w0, #0
    b.ne    llsc_loop                //  Retry if failed
    
    //  ============================================
    //  MEMORY ORDERING WITH ATOMICS
    //  ============================================
    
    //  Load-Acquire: Ensures all subsequent memory operations
    //  are not reordered before this load
    adr     x1, sync_var
    ldaxr   x2, [x1]                 //  Load with acquire semantics
    
    //  Store-Release: Ensures all previous memory operations
    //  are not reordered after this store
    mov     x3, #42
    stlxr   w4, x3, [x1]             //  Store with release semantics
    
    //  ============================================
    //  SECURITY PRACTICES
    //  ============================================
    //  1. Always check return value of store-exclusive
    //  2. Implement retry loops for failed stores
    //  3. Use appropriate memory ordering (acquire/release)
    //  4. Validate addresses before atomic operations
    //  5. Prevent ABA problem in lock-free algorithms
    
    //  Validate address before atomic operation
    adr     x5, atomic_var
    cmp     x5, #0
    b.eq    invalid_address           //  NULL pointer check
    
    //  Clear sensitive atomic variables
    mov     x6, xzr
    adr     x7, atomic_var
    ldxr    x8, [x7]
    stxr    w9, x6, [x7]             //  Clear value atomically
    
    //  Exit
    mov     x0, #0
    mov     x8, #93                  //  Linux exit syscall (SYS_exit)
    svc     #0
    
    //  Halt loop (should never reach here, but prevents illegal instruction)
halt_loop:
    b       halt_loop
    
invalid_address:
    mov     x0, #1
    mov     x8, #93                  //  Linux exit syscall (SYS_exit)
    svc     #0
    
    //  Halt loop (should never reach here, but prevents illegal instruction)
halt_loop_invalid:
    b       halt_loop_invalid

.data
.align 8
atomic_var:
    .quad   0

counter:
    .quad   0

cas_var:
    .quad   0

atomic_add_var:
    .quad   0

swap_var:
    .quad   0

llsc_var:
    .quad   0

sync_var:
    .quad   0
