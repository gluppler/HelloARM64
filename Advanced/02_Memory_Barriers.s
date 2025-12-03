
.text
//  Advanced/02_Memory_Barriers.s
//  Memory Barriers and Ordering: DMB, DSB, ISB
//  Demonstrates memory ordering with barriers to ensure correct execution order

.global _start
.align 4

_start:
    //  ============================================
    //  MEMORY ORDERING OVERVIEW
    //  ============================================
    //  ARM processors can reorder memory operations for performance
    //  Memory barriers enforce ordering constraints
    //  Critical for multi-threaded code and device drivers
    
    //  ============================================
    //  DATA MEMORY BARRIER (DMB)
    //  ============================================
    //  Ensures memory operations before the barrier
    //  complete before operations after the barrier
    //  Does not wait for completion, just enforces ordering
    
    //  Store some data
    adr     x0, data1
    mov     x1, #100
    str     x1, [x0]
    
    //  Data Memory Barrier - ensures previous stores complete
    //  before subsequent memory operations
    dmb     ish                      //  Inner Shareable domain
    
    //  Load data (guaranteed to see value written above)
    ldr     x2, [x0]
    
    //  ============================================
    //  DMB SYNC DOMAINS
    //  ============================================
    
    //  Full system barrier (all observers)
    dmb     sy                      //  Full system
    
    //  Outer shareable domain
    dmb     osh                     //  Outer Shareable
    
    //  Inner shareable domain (typical for SMP)
    dmb     ish                     //  Inner Shareable
    
    //  Non-shareable (single core)
    dmb     nsh                     //  Non-Shareable
    
    //  ============================================
    //  DATA SYNCHRONIZATION BARRIER (DSB)
    //  ============================================
    //  Stronger than DMB - waits for all memory operations
    //  to complete before continuing
    //  Use when you need to ensure completion, not just ordering
    
    adr     x3, data2
    mov     x4, #200
    str     x4, [x3]
    
    //  Data Synchronization Barrier - waits for store to complete
    dsb     ish                      //  Inner Shareable domain
    
    //  Now guaranteed that store has completed
    ldr     x5, [x3]
    
    //  ============================================
    //  DSB SYNC DOMAINS
    //  ============================================
    
    dsb     sy                      //  Full system
    dsb     osh                     //  Outer Shareable
    dsb     ish                     //  Inner Shareable
    dsb     nsh                     //  Non-Shareable
    
    //  ============================================
    //  INSTRUCTION SYNCHRONIZATION BARRIER (ISB)
    //  ============================================
    //  Ensures all previous instructions complete
    //  and flushes the instruction pipeline
    //  Critical after changing system registers or memory mappings
    
    //  Example: After modifying system register
    //  (In real code, would modify system register here)
    
    isb                              //  Flush pipeline
    
    //  Now safe to use new register values
    
    //  ============================================
    //  MEMORY ORDERING PATTERNS
    //  ============================================
    
    //  Pattern 1: Producer-Consumer with Release-Acquire
    adr     x6, flag
    adr     x7, data
    
    //  Producer: Write data, then set flag with release
    mov     x8, #42
    str     x8, [x7]                //  Write data
    dmb     ish                     //  Ensure data write completes
    mov     x9, #1
    str     x9, [x6]                //  Set flag (release)
    
    //  Consumer: Read flag with acquire, then read data
consumer_loop:
    ldr     x10, [x6]               //  Read flag
    cmp     x10, #0
    b.eq    consumer_loop           //  Wait for flag
    
    dmb     ish                     //  Acquire barrier
    ldr     x11, [x7]               //  Read data (guaranteed to see value)
    
    //  ============================================
    //  SEQUENTIAL CONSISTENCY
    //  ============================================
    //  Strongest ordering - all operations appear in program order
    
    adr     x12, var1
    adr     x13, var2
    
    mov     x14, #10
    str     x14, [x12]              //  Write var1
    dmb     sy                      //  Full system barrier
    mov     x15, #20
    str     x15, [x13]              //  Write var2
    
    //  All observers see var1=10 before var2=20
    
    //  ============================================
    //  MEMORY BARRIER WITH ATOMICS
    //  ============================================
    
    adr     x16, atomic_flag
    
    //  Store with release semantics (built-in barrier)
    mov     x17, #1
    stlxr   w18, x17, [x16]         //  Store-Release (has implicit barrier)
    
    //  Load with acquire semantics (built-in barrier)
    ldaxr   x19, [x16]              //  Load-Acquire (has implicit barrier)
    
    //  ============================================
    //  CACHE COHERENCY
    //  ============================================
    //  Memory barriers ensure cache coherency across cores
    
    adr     x20, shared_data
    
    //  Write to shared memory
    mov     x21, #1000
    str     x21, [x20]
    dmb     ish                     //  Ensure write is visible to other cores
    
    //  ============================================
    //  DEVICE MEMORY ORDERING
    //  ============================================
    //  Critical for device drivers - must ensure
    //  register writes complete in correct order
    
    //  Example: Configure device registers
    //  mov     x22, #DEVICE_BASE
    //  mov     x23, #CONFIG_VALUE1
    //  str     x23, [x22, #REG1_OFFSET]
    //  dsb     sy                      //  Wait for write to complete
    //  mov     x24, #CONFIG_VALUE2
    //  str     x24, [x22, #REG2_OFFSET]
    //  dsb     sy                      //  Wait for write to complete
    
    //  ============================================
    //  MEMORY BARRIER BEST PRACTICES
    //  ============================================
    //  Use appropriate barrier strength (DMB for ordering, DSB for completion)
    //  Use correct sync domain (ish for SMP systems)
    //  Place barriers correctly in critical sections to ensure ordering
    //  Use acquire/release semantics with atomics for efficient synchronization
    //  Ensure barriers are present in multi-threaded code where ordering matters
    
    //  Example: Secure flag update pattern
    adr     x25, secure_flag
    adr     x26, secure_data
    
    //  Write data securely
    movz    x27, #0x5678             //  Load 32-bit value
    movk    x27, #0x1234, lsl #16
    str     x27, [x26]
    dmb     ish                     //  Ensure data write completes
    
    //  Set flag (release)
    mov     x28, #1
    str     x28, [x25]
    dmb     ish                     //  Ensure flag write completes
    
    //  Clear sensitive data
    mov     x29, xzr
    str     x29, [x26]              //  Clear data
    dmb     ish                     //  Ensure clear completes
    
    //  Exit
    mov     x0, #0
    mov     x8, #93                  //  Linux exit syscall (SYS_exit)
    svc     #0
    
    //  Halt loop - defensive programming to stop execution after syscall
halt_loop:
    b       halt_loop

.data
.align 8
data1:
    .quad   0

data2:
    .quad   0

flag:
    .quad   0

data:
    .quad   0

var1:
    .quad   0

var2:
    .quad   0

atomic_flag:
    .quad   0

shared_data:
    .quad   0

secure_flag:
    .quad   0

secure_data:
    .quad   0
