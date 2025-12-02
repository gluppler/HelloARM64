
.text
//  Advanced/10_Advanced_Debugging.s
//  Advanced Debugging: Breakpoints, Watchpoints, Debug Registers, Tracing
//  SECURITY: Debug code must not expose sensitive information

.global _start
.align 4

_start:
    //  ============================================
    //  DEBUGGING OVERVIEW
    //  ============================================
    //  Advanced debugging techniques for ARM64
    //  Includes breakpoints, watchpoints, and tracing
    
    //  ============================================
    //  SOFTWARE BREAKPOINTS
    //  ============================================
    //  BRK instruction triggers debugger breakpoint
    
    mov     x0, #10
    mov     x1, #20
    
    //  Software breakpoint (triggers debugger)
    //  brk     #0                      //  Breakpoint (commented for normal execution)
    
    add     x2, x0, x1               //  x2 = 30
    
    //  ============================================
    //  DEBUG REGISTERS (Conceptual)
    //  ============================================
    //  ARM64 has debug registers for hardware breakpoints
    //  Requires system-level access
    
    //  Note: Debug registers require special permissions
    //  This is conceptual
    
    //  Hardware breakpoint (conceptual)
    //  msr     dbgbvr0_el1, x0         //  Set breakpoint value register
    //  msr     dbgbcr0_el1, x1         //  Set breakpoint control register
    
    //  ============================================
    //  WATCHPOINTS (Conceptual)
    //  ============================================
    //  Watchpoints trigger on memory access
    
    adr     x3, watchpoint_var
    
    //  Set watchpoint (conceptual)
    //  msr     dbgwvr0_el0, x3         //  Watchpoint value (address)
    //  msr     dbgwcr0_el0, x4         //  Watchpoint control (enable, type)
    
    //  Access that would trigger watchpoint
    mov     x5, #42
    str     x5, [x3]                 //  This would trigger watchpoint if enabled
    
    //  ============================================
    //  DEBUGGING WITH FRAME POINTERS
    //  ============================================
    //  Frame pointers enable stack unwinding
    
//  Example function for debugging demonstration
//  Note: This function is not called from _start to avoid ret issues
//  In real code, would be called with: bl debuggable_function
debuggable_function:
    //  Prologue with frame pointer
    sub     sp, sp, #32
    stp     x29, x30, [sp, #16]      //  Save FP and LR
    add     x29, sp, #16             //  Set frame pointer
    
    //  Local variables (accessible via FP)
    mov     x6, #100
    str     x6, [x29, #-8]           //  local_var1 at FP-8
    
    mov     x7, #200
    str     x7, [x29, #-16]          //  local_var2 at FP-16
    
    //  Function body
    ldr     x8, [x29, #-8]           //  Load local_var1
    ldr     x9, [x29, #-16]          //  Load local_var2
    add     x10, x8, x9              //  x10 = local_var1 + local_var2
    
    //  Epilogue
    ldp     x29, x30, [sp, #16]      //  Restore FP and LR
    add     sp, sp, #32
    ret                              //  Return to caller (requires valid LR from bl)
    
    //  ============================================
    //  DEBUGGING WITH STACK TRACES
    //  ============================================
    //  Walk the stack using frame pointers
    
//  Example function for stack walking demonstration
//  Note: This function is not called from _start to avoid ret issues
//  In real code, would be called with: bl stack_walk_example
stack_walk_example:
    //  Prologue
    sub     sp, sp, #16
    stp     x29, x30, [sp]
    add     x29, sp, #0
    
    //  Walk stack (conceptual)
    mov     x11, x29                 //  Current frame pointer
    
stack_walk_loop:
    cmp     x11, #0
    b.eq    stack_walk_end           //  End of stack
    
    //  Get return address (LR saved in frame)
    ldr     x12, [x11, #8]           //  Load saved LR
    
    //  Get previous frame pointer
    ldr     x11, [x11]               //  Load saved FP
    
    //  In real debugger, would print return address
    b       stack_walk_loop
    
stack_walk_end:
    //  Epilogue
    ldp     x29, x30, [sp]
    add     sp, sp, #16
    ret                              //  Return to caller (requires valid LR from bl)
    
    //  ============================================
    //  DEBUGGING WITH LOGGING
    //  ============================================
    //  Add debug output to trace execution
    
debug_with_logging:
    //  Log entry
    adr     x13, debug_msg1
    //  In real code, would write to debug log
    
    //  Function operations
    mov     x14, #10
    mov     x15, #20
    add     x16, x14, x15
    
    //  Log intermediate value
    //  In real code, would log x16 value
    
    //  Log exit
    adr     x17, debug_msg2
    //  In real code, would write to debug log
    
    //  ============================================
    //  CONDITIONAL DEBUGGING
    //  ============================================
    //  Enable/disable debug code based on flags
    
    adr     x18, debug_flag
    ldr     x19, [x18]
    cmp     x19, #0
    b.eq    debug_disabled
    
    //  Debug code enabled
    //  brk     #0                      //  Breakpoint
    
debug_disabled:
    
    //  ============================================
    //  ASSERTIONS FOR DEBUGGING
    //  ============================================
    
debug_assert:
    mov     x20, #10
    mov     x21, #5
    
    //  Assert: x20 > x21
    cmp     x20, x21
    b.gt    assert_ok
    
    //  Assertion failed
    //  brk     #1                      //  Breakpoint with code
    
assert_ok:
    
    //  ============================================
    //  MEMORY DEBUGGING
    //  ============================================
    //  Check for memory corruption
    
debug_memory_check:
    adr     x22, debug_buffer
    movz    x23, #0xFABE             //  Sentinel value (64-bit)
    movk    x23, #0xCAFE, lsl #16
    movk    x23, #0xBEEF, lsl #32
    movk    x23, #0xDEAD, lsl #48
    str     x23, [x22, #24]          //  Store sentinel
    
    //  ... operations that might corrupt memory ...
    
    //  Check sentinel
    ldr     x24, [x22, #24]
    cmp     x23, x24
    b.ne    memory_corruption        //  Sentinel changed!
    
    b       memory_ok
    
memory_corruption:
    //  Memory corruption detected
    //  brk     #2                      //  Breakpoint
    
memory_ok:
    
    //  ============================================
    //  REGISTER INSPECTION
    //  ============================================
    //  Save registers for inspection
    
debug_save_registers:
    sub     sp, sp, #128             //  Allocate space for registers
    
    //  Save all general purpose registers
    stp     x0, x1, [sp]
    stp     x2, x3, [sp, #16]
    stp     x4, x5, [sp, #32]
    stp     x6, x7, [sp, #48]
    stp     x8, x9, [sp, #64]
    stp     x10, x11, [sp, #80]
    stp     x12, x13, [sp, #96]
    stp     x14, x15, [sp, #112]
    
    //  In debugger, can inspect saved registers
    
    //  Restore registers
    ldp     x0, x1, [sp]
    ldp     x2, x3, [sp, #16]
    ldp     x4, x5, [sp, #32]
    ldp     x6, x7, [sp, #48]
    ldp     x8, x9, [sp, #64]
    ldp     x10, x11, [sp, #80]
    ldp     x12, x13, [sp, #96]
    ldp     x14, x15, [sp, #112]
    
    add     sp, sp, #128
    
    //  ============================================
    //  SECURITY PRACTICES
    //  ============================================
    //  1. Remove debug code from production
    //  2. Don't expose sensitive data in debug output
    //  3. Disable debug features in release builds
    //  4. Validate debug inputs
    //  5. Secure debug interfaces
    
    //  Production-safe debugging (no sensitive data)
    adr     x25, safe_debug_data
    
    //  Don't log sensitive values
    //  Only log non-sensitive debug info
    
    //  Exit
    mov     x0, #0
    mov     x8, #93                  //  Linux exit syscall (SYS_exit)
    svc     #0
    
    //  Halt loop (should never reach here, but prevents illegal instruction)
halt_loop:
    b       halt_loop

.data
.align 8
watchpoint_var:
    .quad   0

debug_flag:
    .quad   0

debug_buffer:
    .quad   0, 0, 0, 0

debug_msg1:
    .asciz  "Function entry\n"

debug_msg2:
    .asciz  "Function exit\n"

safe_debug_data:
    .quad   0
