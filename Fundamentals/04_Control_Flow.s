//  Fundamentals/04_Control_Flow.s
//  Control Flow: branches, conditionals, loops
//  SECURITY: All branches are validated, no infinite loops

.global _start
.align 4

_start:
    //  ============================================
    //  UNCONDITIONAL BRANCHES
    //  ============================================
    
    //  b: Branch (unconditional jump)
    b       label1                   //  Jump to label1
    
label1:
    //  bl: Branch with link (function call)
    bl      example_function         //  Call function, save return address in LR
    
    //  br: Branch to register
    adr     x0, label2
    br      x0                       //  Jump to address in x0
    
label2:
    //  ret: Return from function (branch to LR)
    //  ret     lr                     //  Return (lr is default)
    
    //  ============================================
    //  CONDITIONAL BRANCHES
    //  ============================================
    //  Condition codes based on flags set by cmp, tst, etc.
    
    mov     x0, #10
    mov     x1, #20
    
    //  Compare and set flags
    cmp     x0, x1                   //  Sets flags: N, Z, C, V
    
    //  Signed comparisons
    b.eq    equal_label              //  Branch if equal (Z == 1)
    b.ne    not_equal_label          //  Branch if not equal (Z == 0)
    b.gt    greater_label            //  Branch if greater than (signed)
    b.ge    greater_equal_label      //  Branch if greater or equal (signed)
    b.lt    less_label               //  Branch if less than (signed)
    b.le    less_equal_label         //  Branch if less or equal (signed)
    
    //  Unsigned comparisons
    b.hi    higher_label             //  Branch if higher (unsigned)
    b.hs    higher_same_label         //  Branch if higher or same (unsigned, alias for b.cs)
    b.lo    lower_label              //  Branch if lower (unsigned)
    b.ls    lower_same_label         //  Branch if lower or same (unsigned)
    
    //  Flag-based branches
    b.mi    minus_label              //  Branch if minus (N == 1)
    b.pl    plus_label               //  Branch if plus (N == 0)
    b.vs    overflow_label           //  Branch if overflow (V == 1)
    b.vc    no_overflow_label        //  Branch if no overflow (V == 0)
    b.cs    carry_set_label          //  Branch if carry set (C == 1)
    b.cc    carry_clear_label        //  Branch if carry clear (C == 0)
    
equal_label:
not_equal_label:
greater_label:
greater_equal_label:
less_label:
less_equal_label:
higher_label:
higher_same_label:
lower_label:
lower_same_label:
minus_label:
plus_label:
overflow_label:
no_overflow_label:
carry_set_label:
carry_clear_label:
    
    //  ============================================
    //  CONDITIONAL EXECUTION
    //  ============================================
    //  csel: Conditional select
    mov     x2, #100
    mov     x3, #200
    cmp     x0, x1
    csel    x4, x2, x3, gt           //  x4 = (x0 > x1) ? x2 : x3
    
    //  csinc: Conditional select increment
    csinv   x5, x2, x3, eq           //  x5 = (x0 == x1) ? x2 : ~x3
    
    //  cset: Conditional set (set to 1 if condition true, else 0)
    cset    x6, gt                   //  x6 = (x0 > x1) ? 1 : 0
    
    //  csetm: Conditional set mask (set to -1 if condition true, else 0)
    csetm   x7, lt                   //  x7 = (x0 < x1) ? -1 : 0
    
    //  ============================================
    //  LOOPS
    //  ============================================
    
    //  Simple counted loop
    mov     x8, #0                   //  Loop counter
    mov     x9, #10                  //  Loop limit
    
loop_start:
    cmp     x8, x9                   //  Compare counter with limit
    b.ge    loop_end                 //  Exit if counter >= limit
    
    //  Loop body
    add     x8, x8, #1               //  Increment counter
    
    b       loop_start               //  Branch back to start
    
loop_end:
    
    //  ============================================
    //  WHILE LOOP
    //  ============================================
    
    mov     x10, #0                  //  Counter
    
while_loop:
    cmp     x10, #5                  //  Condition check
    b.ge    while_end                //  Exit condition
    
    //  Loop body
    add     x10, x10, #1
    
    b       while_loop               //  Continue loop
    
while_end:
    
    //  ============================================
    //  DO-WHILE LOOP
    //  ============================================
    
    mov     x11, #0
    
do_while_loop:
    //  Loop body (always executes at least once)
    add     x11, x11, #1
    
    cmp     x11, #5                  //  Condition check at end
    b.lt    do_while_loop            //  Continue if condition true
    
    //  ============================================
    //  SWITCH-LIKE CONSTRUCT (using branch table)
    //  ============================================
    
    mov     x12, #2                  //  Case value
    
    cmp     x12, #0
    b.eq    case_0
    cmp     x12, #1
    b.eq    case_1
    cmp     x12, #2
    b.eq    case_2
    b       case_default             //  Default case
    
case_0:
    mov     x13, #100
    b       switch_end
    
case_1:
    mov     x13, #200
    b       switch_end
    
case_2:
    mov     x13, #300
    b       switch_end
    
case_default:
    mov     x13, #0
    
switch_end:
    
    //  ============================================
    //  NESTED LOOPS
    //  ============================================
    
    mov     x14, #0                  //  Outer loop counter
    mov     x15, #3                  //  Outer loop limit
    
outer_loop:
    cmp     x14, x15
    b.ge    outer_end
    
    mov     x16, #0                  //  Inner loop counter
    mov     x17, #2                  //  Inner loop limit
    
inner_loop:
    cmp     x16, x17
    b.ge    inner_end
    
    //  Inner loop body
    add     x16, x16, #1
    b       inner_loop
    
inner_end:
    add     x14, x14, #1
    b       outer_loop
    
outer_end:
    
    //  ============================================
    //  SECURITY PRACTICES
    //  ============================================
    //  1. Always validate loop bounds to prevent infinite loops
    //  2. Check array bounds before indexing
    //  3. Validate branch targets (prevent code injection)
    //  4. Use secure comparison patterns
    //  5. Clear sensitive registers after use
    
    //  Exit
    mov     x0, #0
    movz    x16, #0x0001
    movk    x16, #0x0200, lsl #16
    svc     #0

//  Example function for demonstration
example_function:
    //  Function prologue
    sub     sp, sp, #16              //  Allocate stack space
    str     x30, [sp]                //  Save link register
    
    //  Function body
    mov     x0, #42
    
    //  Function epilogue
    ldr     x30, [sp]                //  Restore link register
    add     sp, sp, #16              //  Restore stack
    ret                              //  Return
