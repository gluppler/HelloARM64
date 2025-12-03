# ARM64 Opcodes Cheatsheet

Quick reference for ARM64 (AArch64) assembly opcodes and instruction formats.

## Data Processing Instructions

### Move Instructions
```asm
mov     x0, #42          // Move immediate to register
mov     x1, x0           // Move register to register
movz    x2, #0x1234      // Move with zero (16-bit immediate)
movk    x3, #0x5678, lsl #16  // Move with keep (preserves other bits)
movn    x4, #0           // Move with NOT (bitwise complement)
```

### Arithmetic Instructions
```asm
add     x0, x1, x2       // x0 = x1 + x2
add     x0, x1, #10      // x0 = x1 + 10 (immediate)
sub     x0, x1, x2       // x0 = x1 - x2
mul     x0, x1, x2       // x0 = x1 * x2
madd    x0, x1, x2, x3   // x0 = (x1 * x2) + x3
msub    x0, x1, x2, x3   // x0 = x3 - (x1 * x2)
udiv    x0, x1, x2       // Unsigned divide: x0 = x1 / x2
sdiv    x0, x1, x2       // Signed divide: x0 = x1 / x2
```

### Logical Instructions
```asm
and     x0, x1, x2       // x0 = x1 & x2 (bitwise AND)
orr     x0, x1, x2       // x0 = x1 | x2 (bitwise OR)
eor     x0, x1, x2       // x0 = x1 ^ x2 (bitwise XOR)
bic     x0, x1, x2       // x0 = x1 & ~x2 (bit clear)
orn     x0, x1, x2       // x0 = x1 | ~x2 (OR with NOT)
eon     x0, x1, x2       // x0 = x1 ^ ~x2 (XOR with NOT)
```

### Shift Instructions
```asm
lsl     x0, x1, #3       // Logical shift left: x0 = x1 << 3
lsr     x0, x1, #3       // Logical shift right: x0 = x1 >> 3
asr     x0, x1, #3       // Arithmetic shift right (sign-extending)
ror     x0, x1, #3       // Rotate right
```

### Comparison Instructions
```asm
cmp     x0, x1           // Compare x0 and x1 (sets flags)
cmn     x0, x1           // Compare negative: x0 + x1 (sets flags)
tst     x0, x1           // Test bits: x0 & x1 (sets flags)
```

### Conditional Instructions
```asm
csel    x0, x1, x2, eq   // x0 = (Z flag set) ? x1 : x2
csinc   x0, x1, x2, ne   // x0 = (Z flag clear) ? x1 : x2+1
csinv   x0, x1, x2, gt   // x0 = (N==V) ? x1 : ~x2
cset    x0, gt           // x0 = (N==V && Z==0) ? 1 : 0
csetm   x0, lt           // x0 = (N!=V) ? -1 : 0
```

## Memory Instructions

### Load Instructions
```asm
ldr     x0, [x1]         // Load 64-bit: x0 = *x1
ldr     w0, [x1]         // Load 32-bit: w0 = *x1
ldrh    w0, [x1]         // Load 16-bit halfword (zero-extended)
ldrb    w0, [x1]         // Load 8-bit byte (zero-extended)
ldp     x0, x1, [x2]     // Load pair: x0 = *x2, x1 = *(x2+8)
ldr     x0, [x1, #8]     // Load with offset: x0 = *(x1 + 8)
ldr     x0, [x1, #8]!    // Pre-index: x1 = x1 + 8, then load
ldr     x0, [x1], #8     // Post-index: load, then x1 = x1 + 8
```

### Store Instructions
```asm
str     x0, [x1]         // Store 64-bit: *x1 = x0
str     w0, [x1]         // Store 32-bit: *x1 = w0
strh    w0, [x1]         // Store 16-bit halfword
strb    w0, [x1]         // Store 8-bit byte
stp     x0, x1, [x2]     // Store pair: *x2 = x0, *(x2+8) = x1
str     x0, [x1, #8]     // Store with offset
str     x0, [x1, #8]!    // Pre-index store
str     x0, [x1], #8     // Post-index store
```

## Branch Instructions

### Unconditional Branches
```asm
b       label            // Branch to label (PC-relative)
bl      function         // Branch with link (call function, saves return address)
br      x0               // Branch to address in register (indirect)
ret                      // Return from function (uses x30/LR)
```

### Conditional Branches
```asm
b.eq    label            // Branch if equal (Z flag set)
b.ne    label            // Branch if not equal (Z flag clear)
b.gt    label            // Branch if greater than (signed)
b.ge    label            // Branch if greater or equal (signed)
b.lt    label            // Branch if less than (signed)
b.le    label            // Branch if less or equal (signed)
b.hi    label            // Branch if higher (unsigned)
b.hs    label            // Branch if higher or same (unsigned, carry set)
b.lo    label            // Branch if lower (unsigned, carry clear)
b.ls    label            // Branch if lower or same (unsigned)
```

## Atomic Instructions

### Load-Exclusive / Store-Exclusive
```asm
ldxr    x0, [x1]         // Load exclusive (marks memory as exclusive)
ldaxr   x0, [x1]         // Load exclusive acquire (stronger ordering)
stxr    w2, x0, [x1]     // Store exclusive: w2 = result (0=success, 1=fail)
stlxr   w2, x0, [x1]     // Store exclusive release (stronger ordering)
```

## System Instructions

### System Calls (Linux)
```asm
mov     x0, #0           // Argument 1 (exit code)
mov     x8, #93          // Syscall number (SYS_exit)
svc     #0               // Invoke system call
```

### Common Linux Syscall Numbers
- `93` - exit
- `64` - write
- `63` - read
- `56` - open
- `57` - close
- `62` - lseek

## Memory Barriers
```asm
dmb     ish              // Data Memory Barrier (Inner Shareable)
dsb     ish              // Data Synchronization Barrier
isb                      // Instruction Synchronization Barrier
```

## SIMD/NEON Instructions

### Vector Load/Store
```asm
ld1     {v0.4s}, [x0]    // Load 4 single-precision floats
st1     {v0.4s}, [x0]    // Store 4 single-precision floats
ld1     {v0.2d, v1.2d}, [x0]  // Load 2 double-precision floats
```

### Vector Arithmetic
```asm
fadd    v0.4s, v1.4s, v2.4s   // Floating-point add (4 floats)
fsub    v0.4s, v1.4s, v2.4s   // Floating-point subtract
fmul    v0.4s, v1.4s, v2.4s   // Floating-point multiply
fdiv    v0.4s, v1.4s, v2.4s   // Floating-point divide
fmla    v0.4s, v1.4s, v2.4s   // Fused multiply-add
```

### Vector Comparisons
```asm
cmeq    v0.4s, v1.4s, v2.4s   // Compare equal (mask result)
cmgt    v0.4s, v1.4s, v2.4s   // Compare greater than
cmge    v0.4s, v1.4s, v2.4s   // Compare greater or equal
```

## Register Conventions

### General Purpose Registers
- `x0-x7`: Argument/Result registers (caller-saved)
- `x8`: Indirect result location / Syscall number (Linux)
- `x9-x15`: Temporary registers (caller-saved)
- `x16-x17`: IP0/IP1 - Intra-procedure scratch (caller-saved)
- `x18`: Platform register (reserved on Apple Silicon)
- `x19-x28`: Callee-saved registers
- `x29`: Frame Pointer (FP) - Callee-saved
- `x30`: Link Register (LR) - Return address - Callee-saved
- `x31`: Stack Pointer (SP) or Zero Register (XZR)

### SIMD/NEON Registers
- `v0-v31`: 128-bit vector registers
- Can be accessed as:
  - `v0.16b` - 16 bytes
  - `v0.8h` - 8 halfwords
  - `v0.4s` - 4 single-precision floats
  - `v0.2d` - 2 double-precision floats

## Condition Codes

| Code | Meaning | Flags |
|------|---------|-------|
| `eq` | Equal | Z=1 |
| `ne` | Not equal | Z=0 |
| `cs/hs` | Carry set / Higher or same | C=1 |
| `cc/lo` | Carry clear / Lower | C=0 |
| `mi` | Negative | N=1 |
| `pl` | Positive or zero | N=0 |
| `vs` | Overflow | V=1 |
| `vc` | No overflow | V=0 |
| `hi` | Unsigned higher | C=1 && Z=0 |
| `ls` | Unsigned lower or same | C=0 \|\| Z=1 |
| `ge` | Signed greater or equal | N==V |
| `lt` | Signed less than | N!=V |
| `gt` | Signed greater than | Z=0 && N==V |
| `le` | Signed less or equal | Z=1 \|\| N!=V |
| `al` | Always (unconditional) | - |

## Quick Reference: Common Patterns

### Function Prologue
```asm
function:
    sub     sp, sp, #16      // Allocate stack space
    stp     x29, x30, [sp]   // Save FP and LR
    add     x29, sp, #0      // Set frame pointer
```

### Function Epilogue
```asm
    ldp     x29, x30, [sp]   // Restore FP and LR
    add     sp, sp, #16      // Deallocate stack space
    ret                      // Return
```

### Exit with Code
```asm
    mov     x0, #0           // Exit code
    mov     x8, #93          // Linux exit syscall
    svc     #0
halt_loop:
    b       halt_loop        // Prevent illegal instruction
```

### Loop Pattern
```asm
    mov     x0, #0           // i = 0
loop:
    cmp     x0, #10          // i < 10?
    b.ge    loop_end
    // Loop body
    add     x0, x0, #1       // i++
    b       loop
loop_end:
```

### Atomic Increment
```asm
atomic_inc:
    ldxr    x1, [x0]         // Load exclusive
    add     x1, x1, #1       // Increment
    stxr    w2, x1, [x0]     // Store exclusive
    cmp     w2, #0           // Check if succeeded
    b.ne    atomic_inc       // Retry if failed
```
