
.text
//  Fundamentals/09_SIMD_NEON.s
//  SIMD/NEON Operations: Vector operations for parallel processing
//  Demonstrates vector operations with proper size validation and alignment

.global _start
.align 4

_start:
    //  ============================================
    //  NEON REGISTERS OVERVIEW
    //  ============================================
    //  V0-V31: 128-bit vector registers
    //  Can be viewed as:
    //    - 16 x 8-bit (int8x16_t)
    //    - 8 x 16-bit (int16x8_t)
    //    - 4 x 32-bit (int32x4_t)
    //    - 2 x 64-bit (int64x2_t)
    //    - 4 x float (float32x4_t)
    //    - 2 x double (float64x2_t)
    
    //  ============================================
    //  LOADING VECTORS
    //  ============================================
    
    //  Load vector from memory (aligned, 16-byte boundary)
    adr     x0, vector_data          //  Load address of vector data
    
    //  ldr: Load 128-bit vector
    ldr     q0, [x0]                 //  Load 128 bits into v0
    ldr     q1, [x0, #16]            //  Load next 128 bits into v1
    
    //  ld1: Load 1 element structure (flexible)
    ld1     {v2.16b}, [x0]           //  Load 16 bytes into v2
    ld1     {v3.8h}, [x0]            //  Load 8 halfwords into v3
    ld1     {v4.4s}, [x0]            //  Load 4 words into v4
    ld1     {v5.2d}, [x0]            //  Load 2 doublewords into v5
    
    //  ld1 with multiple registers
    ld1     {v6.16b, v7.16b}, [x0]   //  Load 2 vectors
    
    //  ld1 with post-index
    ld1     {v8.4s}, [x0], #16       //  Load and increment pointer by 16
    
    //  ============================================
    //  STORING VECTORS
    //  ============================================
    
    sub     sp, sp, #32              //  Allocate aligned buffer
    mov     x1, sp
    
    //  str: Store 128-bit vector
    str     q0, [x1]                 //  Store v0 to memory
    
    //  st1: Store 1 element structure
    st1     {v2.16b}, [x1]           //  Store 16 bytes
    st1     {v3.4s}, [x1]            //  Store 4 words
    st1     {v4.2d}, [x1]            //  Store 2 doublewords
    
    //  st1 with post-index
    st1     {v5.4s}, [x1], #16       //  Store and increment pointer
    
    add     sp, sp, #32
    
    //  ============================================
    //  VECTOR ARITHMETIC
    //  ============================================
    
    //  Load test data
    adr     x0, vec_a               //  Load address of vec_a
    adr     x1, vec_b               //  Load address of vec_b
    
    ld1     {v0.4s}, [x0]            //  Load 4 32-bit integers
    ld1     {v1.4s}, [x1]            //  Load 4 32-bit integers
    
    //  add: Vector addition
    add     v2.4s, v0.4s, v1.4s      //  v2 = v0 + v1 (4 elements in parallel)
    
    //  sub: Vector subtraction
    sub     v3.4s, v0.4s, v1.4s      //  v3 = v0 - v1
    
    //  mul: Vector multiplication
    mul     v4.4s, v0.4s, v1.4s      //  v4 = v0 * v1
    
    //  mla: Multiply and add
    mul     v5.4s, v0.4s, v1.4s     //  v5 = v0 * v1
    add     v5.4s, v5.4s, v2.4s     //  v5 = v5 + v2 (v5 = (v0 * v1) + v2)
    
    //  mls: Multiply and subtract
    mul     v6.4s, v0.4s, v1.4s     //  v6 = v0 * v1
    sub     v6.4s, v2.4s, v6.4s     //  v6 = v2 - v6 (v6 = v2 - (v0 * v1))
    
    //  ============================================
    //  VECTOR LOGICAL OPERATIONS
    //  ============================================
    
    //  and: Bitwise AND
    and     v7.16b, v0.16b, v1.16b   //  v7 = v0 & v1
    
    //  orr: Bitwise OR
    orr     v8.16b, v0.16b, v1.16b   //  v8 = v0 | v1
    
    //  eor: Bitwise XOR
    eor     v9.16b, v0.16b, v1.16b   //  v9 = v0 ^ v1
    
    //  bic: Bit clear
    bic     v10.16b, v0.16b, v1.16b  //  v10 = v0 & ~v1
    
    //  ============================================
    //  VECTOR SHIFTS
    //  ============================================
    
    //  shl: Shift left
    shl     v11.4s, v0.4s, #2        //  v11 = v0 << 2 (each element)
    
    //  ushr: Unsigned shift right
    ushr    v12.4s, v0.4s, #2        //  v12 = v0 >> 2 (unsigned)
    
    //  sshr: Signed shift right
    sshr    v13.4s, v0.4s, #2        //  v13 = v0 >> 2 (signed, arithmetic)
    
    //  ============================================
    //  VECTOR COMPARISONS
    //  ============================================
    
    //  cmgt: Compare greater than (signed)
    cmgt    v14.4s, v0.4s, v1.4s     //  v14 = (v0 > v1) ? -1 : 0
    
    //  cmge: Compare greater or equal (signed)
    cmge    v15.4s, v0.4s, v1.4s     //  v15 = (v0 >= v1) ? -1 : 0
    
    //  cmlt: Compare less than (signed) - use cmgt with swapped operands
    cmgt    v16.4s, v1.4s, v0.4s     //  v16 = (v1 > v0) ? -1 : 0 (equivalent to v0 < v1)
    
    //  cmle: Compare less or equal (signed) - use cmge with swapped operands
    cmge    v17.4s, v1.4s, v0.4s     //  v17 = (v1 >= v0) ? -1 : 0 (equivalent to v0 <= v1)
    
    //  cmeq: Compare equal
    cmeq    v18.4s, v0.4s, v1.4s     //  v18 = (v0 == v1) ? -1 : 0
    
    //  ============================================
    //  VECTOR REDUCTION
    //  ============================================
    
    //  addv: Add across vector
    addv    s19, v0.4s               //  s19 = sum of all elements in v0.4s
    
    //  smaxv: Signed maximum across vector
    smaxv   s20, v0.4s               //  s20 = maximum element in v0.4s
    
    //  sminv: Signed minimum across vector
    sminv   s21, v0.4s               //  s21 = minimum element in v0.4s
    
    //  ============================================
    //  FLOATING POINT VECTORS
    //  ============================================
    
    adr     x0, float_vec_a         //  Load address of float_vec_a
    adr     x1, float_vec_b         //  Load address of float_vec_b
    
    ld1     {v22.4s}, [x0]           //  Load 4 floats
    ld1     {v23.4s}, [x1]           //  Load 4 floats
    
    //  fadd: Floating point add
    fadd    v24.4s, v22.4s, v23.4s   //  v24 = v22 + v23
    
    //  fsub: Floating point subtract
    fsub    v25.4s, v22.4s, v23.4s   //  v25 = v22 - v23
    
    //  fmul: Floating point multiply
    fmul    v26.4s, v22.4s, v23.4s   //  v26 = v22 * v23
    
    //  fdiv: Floating point divide
    fdiv    v27.4s, v22.4s, v23.4s   //  v27 = v22 / v23
    
    //  fmax: Floating point maximum
    fmax    v28.4s, v22.4s, v23.4s   //  v28 = max(v22, v23)
    
    //  fmin: Floating point minimum
    fmin    v29.4s, v22.4s, v23.4s   //  v28 = min(v22, v23)
    
    //  ============================================
    //  VECTOR INITIALIZATION
    //  ============================================
    
    //  movi: Move immediate (broadcast constant)
    movi    v30.4s, #10              //  v30 = {10, 10, 10, 10}
    movi    v31.16b, #0xFF           //  v31 = all 0xFF bytes
    
    //  dup: Duplicate scalar to vector
    mov     x2, #42
    dup     v0.4s, w2                //  v0 = {42, 42, 42, 42}
    
    //  ============================================
    //  VECTOR OPERATION BEST PRACTICES
    //  ============================================
    //  Ensure 16-byte alignment for vector loads/stores (required for performance)
    //  Validate vector sizes before operations to prevent out-of-bounds access
    //  Check buffer bounds for vector operations
    //  Clear sensitive vector data after use
    //  Use appropriate data types (signed/unsigned) based on data semantics
    
    //  Clear sensitive vector data
    movi    v0.16b, #0               //  Zero vector
    movi    v1.16b, #0
    
    //  Exit
    //  Linux syscall: x8 = 93 (SYS_exit), x0 = exit code
    mov     x0, #0
    mov     x8, #93                  //  Linux exit syscall (SYS_exit)
    svc     #0

    //  Halt loop - defensive programming to stop execution after syscall
halt_loop:
    b       halt_loop

.data
.align 16                              //  16-byte alignment for vectors
vector_data:
    .quad   0x0123456789ABCDEF
    .quad   0xFEDCBA9876543210

vec_a:
    .word   1, 2, 3, 4

vec_b:
    .word   5, 6, 7, 8

float_vec_a:
    .float  1.0, 2.0, 3.0, 4.0

float_vec_b:
    .float  5.0, 6.0, 7.0, 8.0
