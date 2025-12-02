
.text
//  Fundamentals/11_Security_Practices.s
//  Security Best Practices for ARM Assembly
//  SECURITY: This file demonstrates secure coding patterns

.global _start
.align 4

_start:
    //  ============================================
    //  INPUT VALIDATION
    //  ============================================
    //  Always validate inputs before use
    
    //  Example: Validate array index
    mov     x0, #5                   //  Array index (user input)
    mov     x1, #10                  //  Array size
    
    //  Bounds check
    cmp     x0, #0
    b.lt    invalid_index            //  Index < 0 is invalid
    cmp     x0, x1
    b.ge    invalid_index            //  Index >= size is invalid
    
    //  Index is valid, proceed
    b       index_valid
    
invalid_index:
    //  Handle error securely
    mov     x0, #1                   //  Error code
    mov     x8, #93                  //  Linux exit syscall (SYS_exit)
    svc     #0
    
index_valid:
    //  ============================================
    //  BUFFER OVERFLOW PREVENTION
    //  ============================================
    
    //  Allocate buffer with proper size
    mov     x2, #64                  //  Buffer size
    //  Ensure 16-byte alignment
    mov     x0, sp                   //  Copy SP to temporary register
    mov     x1, #15                  //  Load mask
    bic     x0, x0, x1               //  Clear lower 4 bits (ensure 16-byte alignment)
    sub     x0, x0, x2               //  Subtract buffer size from aligned SP
    mov     sp, x0                   //  Move aligned value back to SP
    
    mov     x3, sp                   //  Buffer pointer
    mov     x4, #32                  //  Data size to copy
    
    //  Check bounds before copy
    cmp     x4, x2
    b.gt    buffer_overflow          //  Data size > buffer size
    
    //  Safe copy (example - would use proper memcpy in real code)
    //  Copy operation here...
    
    //  Deallocate - restore SP properly (x2 still contains buffer size)
    mov     x0, sp                   //  Get current SP
    add     x0, x0, x2               //  Add buffer size back
    mov     sp, x0                   //  Restore SP
    b       buffer_ok
    
buffer_overflow:
    //  Handle overflow error
    //  Restore stack properly
    mov     x0, sp                   //  Get current SP
    add     x0, x0, x2               //  Add buffer size back
    mov     sp, x0                   //  Restore SP
    mov     x0, #1
    mov     x8, #93                  //  Linux exit syscall (SYS_exit)
    svc     #0
    
buffer_ok:
    //  ============================================
    //  DIVISION BY ZERO PREVENTION
    //  ============================================
    
    mov     x5, #100                 //  Dividend
    mov     x6, #0                   //  Divisor (potentially zero)
    
    //  Check for division by zero
    cmp     x6, #0
    b.eq    division_by_zero         //  Prevent division by zero
    
    udiv    x7, x5, x6               //  Safe division
    b       division_ok
    
division_by_zero:
        //  Linux syscall: x8 = 93 (SYS_exit), x0 = exit code
    //  Handle error
    mov     x0, #1
    mov     x8, #93                  //  Linux exit syscall (SYS_exit)
    svc     #0
    
division_ok:
    //  ============================================
    //  INTEGER OVERFLOW DETECTION
    //  ============================================
    
    mov     x8, #0x7FFFFFFFFFFFFFFF  //  Near maximum value
    mov     x9, #100
    
    //  Check for overflow before addition
    //  If x8 + x9 would exceed maximum, handle error
    mov     x10, #0x7FFFFFFFFFFFFFFF
    sub     x10, x10, x8             //  x10 = max - x8
    cmp     x9, x10
    b.gt    addition_overflow        //  x9 > (max - x8) means overflow
    
    adds    x11, x8, x9              //  Add with flags
    b.vs    addition_overflow        //  Check overflow flag
    
    b       addition_ok
    
addition_overflow:
        //  Linux syscall: x8 = 93 (SYS_exit), x0 = exit code
    //  Handle overflow
    mov     x0, #1
    mov     x8, #93                  //  Linux exit syscall (SYS_exit)
    svc     #0
    
addition_ok:
    //  ============================================
    //  SENSITIVE DATA CLEARING
    //  ============================================
    
    //  Store sensitive data
    sub     sp, sp, #16
    movz    x12, #0xDEF0             //  Sensitive value (64-bit)
    movk    x12, #0x9ABC, lsl #16
    movk    x12, #0x5678, lsl #32
    movk    x12, #0x1234, lsl #48
    str     x12, [sp]
    
    //  Use sensitive data
    ldr     x13, [sp]
    //  ... operations with x13 ...
    
    //  Clear sensitive data from memory
    mov     x14, xzr                 //  Zero register
    str     x14, [sp]                //  Overwrite sensitive data
    str     x14, [sp, #8]            //  Clear adjacent memory too
    
    //  Clear sensitive data from registers
    mov     x12, xzr                 //  Clear x12
    mov     x13, xzr                 //  Clear x13
    
    add     sp, sp, #16
    
    //  ============================================
    //  POINTER VALIDATION
    //  ============================================
    
    mov     x15, #0x1000             //  Pointer value (example)
    
    //  Validate pointer is not NULL
    cmp     x15, #0
    b.eq    null_pointer_error
    
    //  Validate pointer is in valid range (example)
    mov     x16, #0x1000000          //  Upper bound
    cmp     x15, x16
    b.ge    invalid_pointer_error
    
    //  Pointer is valid
    b       pointer_ok
    
null_pointer_error:
invalid_pointer_error:
    mov     x0, #1
    mov     x8, #93                  //  Linux exit syscall (SYS_exit)
    svc     #0
    
pointer_ok:
    //  ============================================
    //  STACK CANARY (Basic Example)
    //  ============================================
    //  Stack canaries help detect stack buffer overflows
    
    sub     sp, sp, #32
    movz    x17, #0xFABE             //  Canary value (64-bit)
    movk    x17, #0xCAFE, lsl #16
    movk    x17, #0xBEEF, lsl #32
    movk    x17, #0xDEAD, lsl #48
    str     x17, [sp, #24]           //  Store canary at end of frame
    
    //  ... function operations ...
    
    //  Check canary before return
    ldr     x18, [sp, #24]
    cmp     x17, x18
    b.ne    stack_corruption         //  Canary changed - stack corruption!
    
    add     sp, sp, #32
    b       stack_ok
    
stack_corruption:
    //  Stack corruption detected
    add     sp, sp, #32
    mov     x0, #1
    mov     x8, #93                  //  Linux exit syscall (SYS_exit)
    svc     #0
    
stack_ok:
    //  ============================================
    //  SECURE MEMORY OPERATIONS
    //  ============================================
    
    //  Always check alignment for vector operations
    sub     sp, sp, #32
    mov     x0, sp                   //  Copy SP to temporary register
    mov     x1, #15                  //  Load mask
    bic     x0, x0, x1               //  Clear lower 4 bits (align to 16 bytes)
    mov     sp, x0                   //  Move aligned value back to SP
    
    mov     x19, sp
    and     x19, x19, #0xF           //  Check alignment
    cmp     x19, #0
    b.ne    alignment_error          //  Not 16-byte aligned
    
    //  Safe to use aligned operations
    //  ldr     q0, [sp]              //  Safe aligned load
    
    add     sp, sp, #32
    b       alignment_ok
    
alignment_error:
    add     sp, sp, #32
    mov     x0, #1
    mov     x8, #93                  //  Linux exit syscall (SYS_exit)
    svc     #0
    
alignment_ok:
    //  ============================================
    //  SECURE SYSTEM CALLS
    //  ============================================
    
    //  Validate syscall parameters
    mov     x0, #1                   //  fd
    cmp     x0, #0
    b.lt    invalid_fd               //  fd < 0 is invalid
    
    //  Validate buffer pointer (example - skip validation for demo)
    //  adr     x1, secure_message       //  Load address of secure message
    //  cmp     x1, #0
    //  b.eq    invalid_buffer           //  NULL pointer
    //  Skip to exit (validation example is for demonstration only)
    b       syscall_ok
    
    //  Validate length (example)
    //  mov     x2, #20
    //  cmp     x2, #0
    //  b.le    invalid_length           //  length <= 0
    
    //  Safe syscall - commented out (example for demonstration only)
    //  mov     x8, #64                  //  Linux write syscall (SYS_write)
    //  svc     #0
    
    //  Skip to exit (syscall example is for demonstration only)
    b       syscall_ok
    
invalid_fd:
invalid_buffer:
invalid_length:
syscall_error:
    //  Linux syscall: x8 = 93 (SYS_exit), x0 = exit code
    mov     x0, #1
    mov     x8, #93                  //  Linux exit syscall (SYS_exit)
    svc     #0
    
    //  Halt loop (should never reach here, but prevents illegal instruction)
halt_loop_error:
    b       halt_loop_error
    
syscall_ok:
    //  ============================================
    //  SECURE CODING CHECKLIST
    //  ============================================
    //  ✓ Validate all inputs
    //  ✓ Check array bounds
    //  ✓ Prevent buffer overflows
    //  ✓ Check for division by zero
    //  ✓ Detect integer overflow
    //  ✓ Validate pointers (not NULL, in range)
    //  ✓ Clear sensitive data
    //  ✓ Maintain stack alignment
    //  ✓ Use stack canaries (where appropriate)
    //  ✓ Validate syscall parameters
    //  ✓ Check syscall return values
    //  ✓ Use secure memory operations
    //  ✓ Follow calling conventions
    //  ✓ Preserve callee-saved registers
    
    //  Exit
    mov     x0, #0
    mov     x8, #93                  //  Linux exit syscall (SYS_exit)
    svc     #0
    
    //  Halt loop (should never reach here, but prevents illegal instruction)
halt_loop:
    b       halt_loop

.data
.align 4
secure_message:
    .asciz  "Secure message\n"
