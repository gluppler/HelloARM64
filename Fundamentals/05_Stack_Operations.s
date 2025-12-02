//  Fundamentals/05_Stack_Operations.s
//  Stack Operations: stack pointer, push/pop, frame pointers
//  SECURITY: Stack must be 16-byte aligned, prevent stack overflow

.global _start
.align 4

_start:
    //  ============================================
    //  STACK POINTER (SP)
    //  ============================================
    //  SP (x31) points to the top of the stack
    //  Stack grows downward (toward lower addresses)
    //  MUST be 16-byte aligned at all times
    
    //  Read stack pointer
    mov     x0, sp                   //  x0 = current stack pointer value
    
    //  ============================================
    //  STACK ALLOCATION
    //  ============================================
    
    //  Allocate stack space (must be multiple of 16)
    sub     sp, sp, #32              //  Allocate 32 bytes (aligned)
    //  Always subtract (stack grows down)
    
    //  Allocate larger stack frame
    sub     sp, sp, #256             //  Allocate 256 bytes
    
    //  ============================================
    //  STACK DEALLOCATION
    //  ============================================
    
    //  Deallocate stack space
    add     sp, sp, #256             //  Deallocate 256 bytes
    add     sp, sp, #32              //  Deallocate 32 bytes
    
    //  ============================================
    //  PUSH OPERATIONS (manual)
    //  ============================================
    //  AArch64 doesn't have push/pop instructions
    //  Use stp/ldp or str/ldr with pre/post indexing
    
    sub     sp, sp, #16              //  Allocate space for 2 registers
    
    //  Push x0, x1 onto stack
    stp     x0, x1, [sp]             //  Store pair at stack top
    
    //  Push x2, x3
    stp     x2, x3, [sp, #-16]!      //  Pre-index: allocate and store
    
    //  Push single register
    str     x4, [sp, #-8]!           //  Push x4
    
    //  ============================================
    //  POP OPERATIONS (manual)
    //  ============================================
    
    //  Pop single register
    ldr     x5, [sp], #8             //  Pop x5, deallocate 8 bytes
    
    //  Pop pair
    ldp     x2, x3, [sp], #16        //  Pop x2, x3, deallocate 16 bytes
    
    //  Pop another pair
    ldp     x0, x1, [sp], #16        //  Pop x0, x1, deallocate 16 bytes
    
    //  ============================================
    //  FRAME POINTER (x29/FP)
    //  ============================================
    //  Frame pointer points to the base of current stack frame
    //  Useful for debugging and stack unwinding
    
    //  Function with frame pointer
    sub     sp, sp, #32              //  Allocate stack frame
    stp     x29, x30, [sp, #16]      //  Save old FP and LR
    add     x29, sp, #16             //  Set new frame pointer
    
    //  Access local variables relative to FP
    str     x0, [x29, #-8]           //  Store local variable at FP-8
    ldr     x1, [x29, #-8]           //  Load local variable from FP-8
    
    //  Restore frame pointer
    ldp     x29, x30, [sp, #16]      //  Restore old FP and LR
    add     sp, sp, #32              //  Deallocate stack frame
    
    //  ============================================
    //  STACK ALIGNMENT
    //  ============================================
    //  Critical: Stack must be 16-byte aligned
    
    //  Correct: Allocate multiple of 16
    sub     sp, sp, #16              //  16 bytes - aligned ✓
    sub     sp, sp, #32              //  32 bytes - aligned ✓
    sub     sp, sp, #48              //  48 bytes - aligned ✓
    
    //  Incorrect: Would cause alignment fault
    //  sub     sp, sp, #15            //  15 bytes - NOT aligned ✗
    //  sub     sp, sp, #17            //  17 bytes - NOT aligned ✗
    
    //  Align stack manually if needed
    mov     x0, sp                   //  Copy SP to temporary register
    mov     x1, #15                  //  Load mask
    bic     x0, x0, x1               //  Clear lower 4 bits (align to 16-byte boundary)
    mov     sp, x0                   //  Move aligned value back to SP
    
    //  ============================================
    //  SAVING REGISTERS ON STACK
    //  ============================================
    
    //  Save callee-saved registers
    sub     sp, sp, #64              //  Allocate space for 8 registers
    stp     x19, x20, [sp]           //  Save x19, x20
    stp     x21, x22, [sp, #16]      //  Save x21, x22
    stp     x23, x24, [sp, #32]      //  Save x23, x24
    stp     x25, x26, [sp, #48]      //  Save x25, x26
    
    //  ... use registers ...
    
    //  Restore callee-saved registers
    ldp     x25, x26, [sp, #48]      //  Restore x25, x26
    ldp     x23, x24, [sp, #32]      //  Restore x23, x24
    ldp     x21, x22, [sp, #16]      //  Restore x21, x22
    ldp     x19, x20, [sp]           //  Restore x19, x20
    add     sp, sp, #64              //  Deallocate space
    
    //  ============================================
    //  STACK-BASED LOCAL VARIABLES
    //  ============================================
    
    sub     sp, sp, #32              //  Allocate space for locals
    
    //  Local variable at [sp]
    mov     x0, #100
    str     x0, [sp]                 //  local_var1 = 100
    
    //  Local variable at [sp, #8]
    mov     x1, #200
    str     x1, [sp, #8]             //  local_var2 = 200
    
    //  Local variable at [sp, #16]
    mov     x2, #300
    str     x2, [sp, #16]            //  local_var3 = 300
    
    //  Use local variables
    ldr     x3, [sp]                 //  x3 = local_var1
    ldr     x4, [sp, #8]             //  x4 = local_var2
    add     x5, x3, x4               //  x5 = local_var1 + local_var2
    
    add     sp, sp, #32              //  Deallocate locals
    
    //  ============================================
    //  STACK OVERFLOW PREVENTION
    //  ============================================
    
    //  Check stack bounds before large allocation
    mov     x6, sp                   //  Current stack pointer
    mov     x7, #0x100000            //  Stack limit (example)
    cmp     x6, x7
    b.lo    stack_overflow_error     //  Branch if stack too low
    
    //  Safe allocation
    sub     sp, sp, #1024            //  Allocate 1KB
    
    //  ... use stack ...
    
    add     sp, sp, #1024            //  Deallocate
    
    b       stack_ok
    
stack_overflow_error:
    //  Handle error (exit with error code)
    mov     x0, #1                   //  Error code
    movz    x16, #0x0001
    movk    x16, #0x0200, lsl #16
    svc     #0
    
stack_ok:
    
    //  ============================================
    //  SECURITY PRACTICES
    //  ============================================
    //  1. Always maintain 16-byte stack alignment
    //  2. Check stack bounds before large allocations
    //  3. Clear sensitive data from stack before deallocation
    //  4. Validate stack pointer before dereferencing
    //  5. Use frame pointers for debugging in production
    
    //  Clear sensitive stack data
    sub     sp, sp, #16
    mov     x0, xzr
    stp     x0, x0, [sp]             //  Zero out stack location
    add     sp, sp, #16
    
    //  Exit
    mov     x0, #0
    movz    x16, #0x0001
    movk    x16, #0x0200, lsl #16
    svc     #0
