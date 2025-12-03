# ARM64 Instruction Set Reference

Complete reference for ARM64 (AArch64) instruction set architecture.

## Instruction Categories

### 1. Data Processing - Immediate

| Instruction | Description | Example |
|------------|-------------|---------|
| `mov` | Move immediate or register | `mov x0, #42` |
| `movz` | Move with zero (16-bit immediate) | `movz x0, #0x1234` |
| `movk` | Move with keep (preserves other bits) | `movk x0, #0x5678, lsl #16` |
| `movn` | Move with NOT (bitwise complement) | `movn x0, #0` |

### 2. Data Processing - Register

| Instruction | Description | Example |
|------------|-------------|---------|
| `add` | Add | `add x0, x1, x2` |
| `sub` | Subtract | `sub x0, x1, x2` |
| `mul` | Multiply | `mul x0, x1, x2` |
| `madd` | Multiply and add | `madd x0, x1, x2, x3` |
| `msub` | Multiply and subtract | `msub x0, x1, x2, x3` |
| `udiv` | Unsigned divide | `udiv x0, x1, x2` |
| `sdiv` | Signed divide | `sdiv x0, x1, x2` |
| `and` | Bitwise AND | `and x0, x1, x2` |
| `orr` | Bitwise OR | `orr x0, x1, x2` |
| `eor` | Bitwise XOR | `eor x0, x1, x2` |
| `bic` | Bit clear (AND with NOT) | `bic x0, x1, x2` |
| `lsl` | Logical shift left | `lsl x0, x1, #3` |
| `lsr` | Logical shift right | `lsr x0, x1, #3` |
| `asr` | Arithmetic shift right | `asr x0, x1, #3` |
| `ror` | Rotate right | `ror x0, x1, #3` |

### 3. Data Processing - Extended Register

| Instruction | Description | Example |
|------------|-------------|---------|
| `sxtb` | Sign extend byte | `sxtb x0, w1` |
| `sxth` | Sign extend halfword | `sxth x0, w1` |
| `sxtw` | Sign extend word | `sxtw x0, w1` |
| `uxtb` | Zero extend byte | `uxtb x0, w1` |
| `uxth` | Zero extend halfword | `uxth x0, w1` |
| `uxtw` | Zero extend word | `uxtw x0, w1` |

### 4. Load/Store Instructions

| Instruction | Description | Example |
|------------|-------------|---------|
| `ldr` | Load register (64-bit) | `ldr x0, [x1]` |
| `ldr` | Load register (32-bit) | `ldr w0, [x1]` |
| `ldrh` | Load halfword (16-bit) | `ldrh w0, [x1]` |
| `ldrb` | Load byte (8-bit) | `ldrb w0, [x1]` |
| `ldp` | Load pair | `ldp x0, x1, [x2]` |
| `str` | Store register (64-bit) | `str x0, [x1]` |
| `str` | Store register (32-bit) | `str w0, [x1]` |
| `strh` | Store halfword | `strh w0, [x1]` |
| `strb` | Store byte | `strb w0, [x1]` |
| `stp` | Store pair | `stp x0, x1, [x2]` |

### 5. Branch Instructions

| Instruction | Description | Example |
|------------|-------------|---------|
| `b` | Branch (unconditional) | `b label` |
| `bl` | Branch with link (function call) | `bl function` |
| `br` | Branch to register (indirect) | `br x0` |
| `ret` | Return from function | `ret` |
| `b.eq` | Branch if equal | `b.eq label` |
| `b.ne` | Branch if not equal | `b.ne label` |
| `b.gt` | Branch if greater (signed) | `b.gt label` |
| `b.ge` | Branch if greater/equal (signed) | `b.ge label` |
| `b.lt` | Branch if less (signed) | `b.lt label` |
| `b.le` | Branch if less/equal (signed) | `b.le label` |
| `b.hi` | Branch if higher (unsigned) | `b.hi label` |
| `b.hs` | Branch if higher/same (unsigned) | `b.hs label` |
| `b.lo` | Branch if lower (unsigned) | `b.lo label` |
| `b.ls` | Branch if lower/same (unsigned) | `b.ls label` |

### 6. Comparison Instructions

| Instruction | Description | Example |
|------------|-------------|---------|
| `cmp` | Compare (subtract, set flags) | `cmp x0, x1` |
| `cmn` | Compare negative (add, set flags) | `cmn x0, x1` |
| `tst` | Test bits (AND, set flags) | `tst x0, x1` |

### 7. Conditional Instructions

| Instruction | Description | Example |
|------------|-------------|---------|
| `csel` | Conditional select | `csel x0, x1, x2, eq` |
| `csinc` | Conditional select increment | `csinc x0, x1, x2, ne` |
| `csinv` | Conditional select invert | `csinv x0, x1, x2, gt` |
| `cset` | Conditional set | `cset x0, gt` |
| `csetm` | Conditional set mask | `csetm x0, lt` |

### 8. Atomic Instructions

| Instruction | Description | Example |
|------------|-------------|---------|
| `ldxr` | Load exclusive | `ldxr x0, [x1]` |
| `ldaxr` | Load exclusive acquire | `ldaxr x0, [x1]` |
| `stxr` | Store exclusive | `stxr w0, x1, [x2]` |
| `stlxr` | Store exclusive release | `stlxr w0, x1, [x2]` |

### 9. Memory Barriers

| Instruction | Description | Example |
|------------|-------------|---------|
| `dmb` | Data Memory Barrier | `dmb ish` |
| `dsb` | Data Synchronization Barrier | `dsb ish` |
| `isb` | Instruction Synchronization Barrier | `isb` |

### 10. SIMD/NEON Instructions

#### Vector Load/Store
| Instruction | Description | Example |
|------------|-------------|---------|
| `ld1` | Load 1 vector | `ld1 {v0.4s}, [x0]` |
| `st1` | Store 1 vector | `st1 {v0.4s}, [x0]` |

#### Vector Arithmetic
| Instruction | Description | Example |
|------------|-------------|---------|
| `fadd` | Floating-point add | `fadd v0.4s, v1.4s, v2.4s` |
| `fsub` | Floating-point subtract | `fsub v0.4s, v1.4s, v2.4s` |
| `fmul` | Floating-point multiply | `fmul v0.4s, v1.4s, v2.4s` |
| `fdiv` | Floating-point divide | `fdiv v0.4s, v1.4s, v2.4s` |
| `fmla` | Fused multiply-add | `fmla v0.4s, v1.4s, v2.4s` |

#### Vector Comparisons
| Instruction | Description | Example |
|------------|-------------|---------|
| `cmeq` | Compare equal | `cmeq v0.4s, v1.4s, v2.4s` |
| `cmgt` | Compare greater than | `cmgt v0.4s, v1.4s, v2.4s` |
| `cmge` | Compare greater/equal | `cmge v0.4s, v1.4s, v2.4s` |

## Addressing Modes

### Immediate Offset
```asm
ldr     x0, [x1, #8]     // x0 = *(x1 + 8)
str     x0, [x1, #8]     // *(x1 + 8) = x0
```

### Register Offset
```asm
ldr     x0, [x1, x2]     // x0 = *(x1 + x2)
ldr     x0, [x1, x2, lsl #3]  // x0 = *(x1 + (x2 << 3))
```

### Pre-indexed
```asm
ldr     x0, [x1, #8]!    // x1 = x1 + 8, then x0 = *x1
str     x0, [x1, #8]!    // x1 = x1 + 8, then *x1 = x0
```

### Post-indexed
```asm
ldr     x0, [x1], #8     // x0 = *x1, then x1 = x1 + 8
str     x0, [x1], #8     // *x1 = x0, then x1 = x1 + 8
```

## Instruction Encoding Notes

- **Immediate values**: Limited range depending on instruction
  - 12-bit signed for most arithmetic/logical
  - 16-bit for movz/movk (can be shifted)
- **Register shifts**: LSL, LSR, ASR, ROR with shift amount 0-63
- **Condition codes**: 4-bit condition field for conditional instructions
- **Address offsets**: 12-bit signed for load/store (scaled by access size)

## Performance Tips

1. **Use load/store pairs** (`ldp`/`stp`) for better throughput
2. **Align data** to cache line boundaries (64 bytes)
3. **Minimize branches** - use conditional instructions when possible
4. **Prefer immediate values** over register loads when possible
5. **Use SIMD** for parallel operations on arrays
6. **Keep loops small** to fit in instruction cache
7. **Avoid data dependencies** - interleave independent operations
