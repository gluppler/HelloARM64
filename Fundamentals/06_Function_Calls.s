//  Fundamentals/06_Function_Calls.s
//  Function Calls: calling conventions, parameter passing, return values
//  SECURITY: Follow ABI, preserve callee-saved registers, validate parameters

.global _start
.align 4

_start:
    //  ============================================
    //  CALLING CONVENTION OVERVIEW
    //  ============================================
    //  Arguments: x0-x7 (up to 8 integer/pointer arguments)
    //  Return value: x0 (or x0-x1 for 128-bit values)
    //  Caller-saved: x0-x18 (can be modified by callee)
    //  Callee-saved: x19-x28, x29 (FP), x30 (LR) (must be preserved)
    //  Stack: Must be 16-byte aligned
    
    //  ============================================
    //  CALLING A FUNCTION
    //  ============================================
    
    //  Prepare arguments
    mov     x0, #10                  //  First argument
    mov     x1, #20                  //  Second argument
    mov     x2, #30                  //  Third argument
    
    //  Call function (bl saves return address in LR)
    bl      add_three_numbers        //  Call function
    
    //  Return value is in x0
    //  x0 now contains the result (60)
    
    //  ============================================
    //  FUNCTION WITH MULTIPLE ARGUMENTS
    //  ============================================
    
    mov     x0, #1                   //  arg1
    mov     x1, #2                   //  arg2
    mov     x2, #3                   //  arg3
    mov     x3, #4                   //  arg4
    mov     x4, #5                   //  arg5
    mov     x5, #6                   //  arg6
    mov     x6, #7                   //  arg7
    mov     x7, #8                   //  arg8
    
    bl      function_with_8_args     //  Call with 8 arguments
    
    //  ============================================
    //  FUNCTION WITH MORE THAN 8 ARGUMENTS
    //  ============================================
    //  Arguments beyond x7 are passed on the stack
    
    sub     sp, sp, #16              //  Allocate space for extra args
    mov     x0, #1                   //  arg1
    mov     x1, #2                   //  arg2
    mov     x2, #3                   //  arg3
    mov     x3, #4                   //  arg4
    mov     x4, #5                   //  arg5
    mov     x5, #6                   //  arg6
    mov     x6, #7                   //  arg7
    mov     x7, #8                   //  arg8
    mov     x8, #9
    str     x8, [sp]                 //  arg9 on stack
    mov     x8, #10
    str     x8, [sp, #8]             //  arg10 on stack
    
    bl      function_with_10_args
    
    add     sp, sp, #16              //  Clean up stack
    
    //  ============================================
    //  FUNCTION RETURNING VALUE
    //  ============================================
    
    mov     x0, #100
    bl      double_value             //  x0 = double_value(100)
    //  x0 now contains 200
    
    //  ============================================
    //  FUNCTION RETURNING 128-BIT VALUE
    //  ============================================
    
    bl      return_128bit            //  Returns in x0 (low) and x1 (high)
    //  x0 = low 64 bits, x1 = high 64 bits
    
    //  ============================================
    //  PRESERVING CALLER-SAVED REGISTERS
    //  ============================================
    
    mov     x19, #100                //  Callee-saved register (preserved)
    mov     x20, #200                //  Callee-saved register (preserved)
    
    mov     x0, #5
    bl      some_function            //  Can modify x0-x18, but preserves x19-x28
    
    //  x19 and x20 are still 100 and 200 (preserved by callee)
    
    //  ============================================
    //  NESTED FUNCTION CALLS
    //  ============================================
    
    mov     x0, #5
    bl      outer_function           //  Calls inner_function
    
    //  ============================================
    //  TAIL CALL OPTIMIZATION
    //  ============================================
    
    mov     x0, #42
    b       tail_call_target         //  Use 'b' instead of 'bl' for tail calls
    
    //  Exit
    mov     x0, #0
    movz    x16, #0x0001
    movk    x16, #0x0200, lsl #16
    svc     #0

//  ============================================
//  EXAMPLE FUNCTIONS
//  ============================================

//  Simple function: add three numbers
add_three_numbers:
    //  Function prologue
    sub     sp, sp, #16              //  Allocate stack frame (aligned)
    str     x30, [sp]                //  Save link register
    
    //  Function body
    add     x0, x0, x1               //  x0 = x0 + x1
    add     x0, x0, x2               //  x0 = x0 + x2
    //  Result in x0
    
    //  Function epilogue
    ldr     x30, [sp]                //  Restore link register
    add     sp, sp, #16              //  Deallocate stack frame
    ret                              //  Return (branches to LR)

//  Function with 8 arguments
function_with_8_args:
    //  Prologue
    sub     sp, sp, #16
    str     x30, [sp]
    
    //  Use arguments (x0-x7)
    add     x0, x0, x1               //  x0 = arg1 + arg2
    add     x0, x0, x2               //  x0 += arg3
    add     x0, x0, x3               //  x0 += arg4
    add     x0, x0, x4               //  x0 += arg5
    add     x0, x0, x5               //  x0 += arg6
    add     x0, x0, x6               //  x0 += arg7
    add     x0, x0, x7               //  x0 += arg8
    
    //  Epilogue
    ldr     x30, [sp]
    add     sp, sp, #16
    ret

//  Function with 10 arguments
function_with_10_args:
    //  Prologue
    sub     sp, sp, #32
    stp     x29, x30, [sp, #16]      //  Save FP and LR
    add     x29, sp, #16             //  Set frame pointer
    
    //  Arguments x0-x7 in registers
    //  Arguments 9-10 on stack at [sp] and [sp, #8]
    ldr     x8, [x29, #16]           //  Load arg9 from stack
    ldr     x9, [x29, #24]           //  Load arg10 from stack
    
    add     x0, x0, x1
    add     x0, x0, x2
    add     x0, x0, x3
    add     x0, x0, x4
    add     x0, x0, x5
    add     x0, x0, x6
    add     x0, x0, x7
    add     x0, x0, x8
    add     x0, x0, x9
    
    //  Epilogue
    ldp     x29, x30, [sp, #16]
    add     sp, sp, #32
    ret

//  Function returning a value
double_value:
    //  Prologue
    sub     sp, sp, #16
    str     x30, [sp]
    
    //  Double the input value
    lsl     x0, x0, #1               //  x0 = x0 * 2 (shift left by 1)
    
    //  Epilogue
    ldr     x30, [sp]
    add     sp, sp, #16
    ret

//  Function returning 128-bit value
return_128bit:
    //  Prologue
    sub     sp, sp, #16
    str     x30, [sp]
    
    //  Return 128-bit value: x0 (low), x1 (high)
    movz    x0, #0xDEF0              //  Low 64 bits
    movk    x0, #0x9ABC, lsl #16
    movk    x0, #0x5678, lsl #32
    movk    x0, #0x1234, lsl #48
    movz    x1, #0x3210              //  High 64 bits
    movk    x1, #0x7654, lsl #16
    movk    x1, #0xBA98, lsl #32
    movk    x1, #0xFEDC, lsl #48
    
    //  Epilogue
    ldr     x30, [sp]
    add     sp, sp, #16
    ret

//  Function using callee-saved registers
some_function:
    //  Prologue
    sub     sp, sp, #32
    stp     x19, x20, [sp]           //  Save callee-saved registers we'll use
    str     x30, [sp, #16]
    
    //  Use callee-saved registers
    mov     x19, #1000
    mov     x20, #2000
    add     x0, x19, x20             //  x0 = 3000
    
    //  Epilogue - restore callee-saved registers
    ldp     x19, x20, [sp]
    ldr     x30, [sp, #16]
    add     sp, sp, #32
    ret

//  Outer function calling inner function
outer_function:
    //  Prologue
    sub     sp, sp, #16
    str     x30, [sp]
    
    //  Call inner function
    mov     x1, #10
    bl      inner_function           //  Call inner function
    
    //  Use result
    add     x0, x0, x1               //  x0 = result + 10
    
    //  Epilogue
    ldr     x30, [sp]
    add     sp, sp, #16
    ret

inner_function:
    //  Prologue
    sub     sp, sp, #16
    str     x30, [sp]
    
    //  Function body
    add     x0, x0, x1               //  x0 = x0 + x1
    
    //  Epilogue
    ldr     x30, [sp]
    add     sp, sp, #16
    ret

//  Tail call target
tail_call_target:
    //  No prologue needed for tail call
    add     x0, x0, #1
    ret                              //  Return to caller of original function
