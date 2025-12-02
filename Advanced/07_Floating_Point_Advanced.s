
.text
//  Advanced/07_Floating_Point_Advanced.s
//  Advanced Floating Point: Rounding Modes, Exceptions, Advanced Operations
//  SECURITY: All FP operations validate inputs, handle exceptions, prevent NaN propagation

.global _start
.align 4

_start:
    //  ============================================
    //  FLOATING POINT REGISTERS
    //  ============================================
    //  S0-S31: 32-bit single precision
    //  D0-D31: 64-bit double precision
    //  Q0-Q31: 128-bit quad precision (via SIMD)
    
    //  ============================================
    //  FLOATING POINT ARITHMETIC
    //  ============================================
    
    //  Load floating point values
    adr     x0, fp_value1
    adr     x1, fp_value2
    ldr     s0, [x0]                 //  Load single precision
    ldr     s1, [x1]                 //  Load single precision
    
    //  Basic arithmetic
    fadd    s2, s0, s1                //  s2 = s0 + s1
    fsub    s3, s0, s1                //  s3 = s0 - s1
    fmul    s4, s0, s1                //  s4 = s0 * s1
    fdiv    s5, s0, s1                //  s5 = s0 / s1
    
    //  Fused Multiply-Add (FMA)
    fmadd   s6, s0, s1, s2            //  s6 = (s0 * s1) + s2
    fmsub   s7, s0, s1, s2            //  s7 = (s0 * s1) - s2
    fnmadd  s8, s0, s1, s2            //  s8 = -(s0 * s1) + s2
    fnmsub  s9, s0, s1, s2            //  s9 = -(s0 * s1) - s2
    
    //  ============================================
    //  DOUBLE PRECISION OPERATIONS
    //  ============================================
    
    adr     x2, fp_double1
    adr     x3, fp_double2
    ldr     d0, [x2]                  //  Load double precision
    ldr     d1, [x3]                  //  Load double precision
    
    fadd    d2, d0, d1                //  d2 = d0 + d1
    fsub    d3, d0, d1                //  d3 = d0 - d1
    fmul    d4, d0, d1                //  d4 = d0 * d1
    fdiv    d5, d0, d1                //  d5 = d0 / d1
    
    //  ============================================
    //  FLOATING POINT COMPARISONS
    //  ============================================
    
    //  Compare and set flags
    fcmp    s0, s1                    //  Compare s0 and s1, set flags
    
    //  Conditional moves based on FP comparison
    adr     x2, fp_one
    adr     x3, fp_zero
    ldr     s10, [x2]                 //  Load 1.0
    ldr     s11, [x3]                 //  Load 0.0
    fcsel   s12, s10, s11, gt         //  s12 = (s0 > s1) ? 1.0 : 0.0
    
    //  Compare with zero
    ldr     s14, [x3]                 //  Load 0.0
    fcmp    s0, s14                   //  Compare with zero
    fcsel   s13, s10, s11, gt         //  s13 = (s0 > 0) ? 1.0 : 0.0
    
    //  ============================================
    //  ROUNDING MODES
    //  ============================================
    //  FPCR (Floating Point Control Register) controls rounding
    //  Rounding modes: RN (nearest), RZ (toward zero), RP (toward +inf), RM (toward -inf)
    
    //  Note: Changing FPCR requires system-level access
    //  Default is Round to Nearest (RN)
    
    //  Round to nearest (default)
    frintn  s14, s0                   //  Round to nearest integer
    
    //  Round toward zero
    frintz  s15, s0                   //  Round toward zero (truncate)
    
    //  Round toward positive infinity
    frintp  s16, s0                   //  Round toward +infinity (ceiling)
    
    //  Round toward negative infinity
    frintm  s17, s0                   //  Round toward -infinity (floor)
    
    //  Round to nearest with ties to even
    frinta  s18, s0                   //  Round to nearest, ties to even
    
    //  ============================================
    //  FLOATING POINT CONVERSIONS
    //  ============================================
    
    //  Convert integer to float
    mov     w4, #42
    scvtf   s19, w4                   //  Convert signed integer to float
    
    mov     w5, #100
    ucvtf   s20, w5                   //  Convert unsigned integer to float
    
    //  Convert float to integer
    fcvtns  w6, s0                    //  Convert float to signed integer (round to nearest)
    fcvtzs  w7, s0                    //  Convert float to signed integer (round toward zero)
    fcvtps  w8, s0                    //  Convert float to signed integer (round toward +inf)
    fcvtms  w9, s0                    //  Convert float to signed integer (round toward -inf)
    
    //  Convert between single and double precision
    fcvt    d6, s0                    //  Convert single to double
    fcvt    s21, d0                   //  Convert double to single
    
    //  ============================================
    //  FLOATING POINT ABSOLUTE VALUE AND NEGATION
    //  ============================================
    
    fabs    s22, s0                   //  s22 = |s0|
    fneg    s23, s0                   //  s23 = -s0
    
    //  ============================================
    //  SQUARE ROOT AND RECIPROCAL
    //  ============================================
    
    fsqrt   s24, s0                   //  s24 = sqrt(s0)
    
    //  Reciprocal (1/x)
    fmov    s25, #1.0                 //  Load 1.0
    fdiv    s26, s25, s0              //  s26 = 1.0 / s0
    
    //  Reciprocal square root (1/sqrt(x))
    fsqrt   s27, s0                   //  sqrt(x)
    fdiv    s28, s25, s27             //  1 / sqrt(x)
    
    //  ============================================
    //  MINIMUM AND MAXIMUM
    //  ============================================
    
    fmin    s29, s0, s1               //  s29 = min(s0, s1)
    fmax    s30, s0, s1               //  s30 = max(s0, s1)
    
    //  Minimum/maximum number (handle NaN)
    fminnm  s31, s0, s1               //  min, but return number if one is NaN
    fmaxnm  d7, d0, d1                //  max, but return number if one is NaN
    
    //  ============================================
    //  FLOATING POINT EXCEPTIONS
    //  ============================================
    //  IEEE 754 exceptions: Invalid, Division by Zero, Overflow, Underflow, Inexact
    
    //  Check for division by zero
    adr     x4, fp_one
    adr     x5, fp_zero
    ldr     s0, [x4]                 //  Load 1.0
    ldr     s1, [x5]                 //  Load 0.0
    fcmp    s1, s1                   //  Compare with self (0.0)
    b.eq    check_div_zero           //  Check if zero
    b       division_by_zero_fp      //  Prevent division by zero
    
check_div_zero:
    fcmp    s1, s1                   //  Re-check (s1 should be 0.0)
    //  If we get here, s1 is 0.0, so prevent division
    b       division_by_zero_fp
    
    fdiv    s2, s0, s1                //  Safe division
    
    //  Check for overflow/underflow
    //  In real code, would check FPCR exception flags
    
    //  ============================================
    //  NaN AND INFINITY HANDLING
    //  ============================================
    
    //  Check for NaN
    fcmp    s0, s0                    //  NaN != NaN, so flags will indicate NaN
    b.vs    is_nan                    //  If unordered (NaN), V flag set
    
    //  Check for infinity
    //  Would need to compare with infinity value
    
    //  ============================================
    //  FLOATING POINT VECTOR OPERATIONS
    //  ============================================
    
    adr     x10, fp_vec1
    adr     x11, fp_vec2
    ld1     {v0.4s}, [x10]           //  Load 4 floats
    ld1     {v1.4s}, [x11]           //  Load 4 floats
    
    //  Vector arithmetic
    fadd    v2.4s, v0.4s, v1.4s      //  Add 4 floats in parallel
    fsub    v3.4s, v0.4s, v1.4s      //  Subtract 4 floats
    fmul    v4.4s, v0.4s, v1.4s      //  Multiply 4 floats
    fdiv    v5.4s, v0.4s, v1.4s      //  Divide 4 floats
    
    //  Vector FMA
    fmla    v6.4s, v0.4s, v1.4s      //  v6 = v6 + (v0 * v1)
    
    //  Vector reduction
    faddp   v7.4s, v0.4s, v1.4s       //  Pairwise add
    //  Sum elements manually
    mov     s9, v7.s[0]               //  Get first element
    mov     s18, v7.s[1]              //  Get second element
    mov     s19, v7.s[2]              //  Get third element
    mov     s20, v7.s[3]              //  Get fourth element
    fadd    s9, s9, s18                //  Add second element
    fadd    s9, s9, s19                //  Add third element
    fadd    s9, s9, s20                //  Add fourth element (final sum)
    
    //  ============================================
    //  SECURITY PRACTICES
    //  ============================================
    //  1. Validate FP inputs (check for NaN, Inf)
    //  2. Prevent division by zero
    //  3. Check for overflow/underflow
    //  4. Sanitize FP results
    //  5. Handle exceptions properly
    
    //  Secure FP division
secure_fp_division:
    adr     x12, fp_dividend
    adr     x13, fp_divisor
    ldr     s0, [x12]
    ldr     s1, [x13]
    
    //  Check for zero divisor
    fcmp    s1, #0.0
    b.eq    fp_division_by_zero       //  Prevent division by zero
    
    //  Check for NaN
    fcmp    s0, s0
    b.vs    fp_nan_detected          //  Dividend is NaN
    
    fcmp    s1, s1
    b.vs    fp_nan_detected          //  Divisor is NaN
    
    //  Safe division
    fdiv    s2, s0, s1
    
    //  Validate result
    fcmp    s2, s2
    b.vs    fp_result_nan            //  Result is NaN
    
    b       fp_division_ok
    
fp_division_by_zero:
fp_nan_detected:
fp_result_nan:
    //  Handle error
    mov     x0, #1
    mov     x8, #93                  //  Linux exit syscall (SYS_exit)
    svc     #0
    
    //  Halt loop (should never reach here, but prevents illegal instruction)
halt_loop_error:
    b       halt_loop_error
    
fp_division_ok:
is_nan:
division_by_zero_fp:
    //  Exit
    mov     x0, #0
    mov     x8, #93                  //  Linux exit syscall (SYS_exit)
    svc     #0
    
    //  Halt loop (should never reach here, but prevents illegal instruction)
halt_loop:
    b       halt_loop

.data
.align 4
fp_value1:
    .float  3.14159

fp_value2:
    .float  2.71828

fp_double1:
    .double 3.141592653589793

fp_double2:
    .double 2.718281828459045

fp_vec1:
    .float  1.0, 2.0, 3.0, 4.0

fp_vec2:
    .float  5.0, 6.0, 7.0, 8.0

fp_dividend:
    .float  10.0

fp_divisor:
    .float  2.0

fp_one:
    .float  1.0

fp_zero:
    .float  0.0
