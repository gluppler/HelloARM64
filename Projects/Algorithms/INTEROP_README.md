# C/Assembly Interop for Algorithms

## Overview

Some algorithms have memory management issues when implemented purely in ARM64 assembly due to stack limitations and complex memory allocation patterns. The interop approach uses C for memory management while keeping the core algorithm logic in optimized ARM64 assembly.

## Architecture

- **C Wrapper**: Handles memory allocation/deallocation using `malloc()`/`free()`
- **Assembly Core**: Contains the optimized algorithm implementation
- **Interface**: C calls assembly functions with heap-allocated buffers

## Benefits

1. **No Stack Overflow**: Heap allocation avoids stack size limitations
2. **Memory Safety**: C runtime handles memory management safely
3. **Performance**: Core algorithm still runs in optimized assembly
4. **Debugging**: Easier to debug memory issues in C
5. **Portability**: Can use standard C libraries for I/O and utilities

## Current Interop Implementations

### BFS (Breadth-First Search)

**Files:**
- `BFS_interop.c` - C wrapper with memory management
- `BFS_asm.s` - ARM64 assembly BFS implementation

**Build:**
```bash
make BFS_interop
```

**Run:**
```bash
qemu-aarch64 -L /usr/aarch64-linux-gnu ./bin/BFS_interop
```

**Status:** ✅ Working - Correctly traverses graphs and shows visited nodes

## Adding New Interop Algorithms

1. Create `[ALGORITHM]_asm.s` with exported function:
   ```assembly
   .global algorithm_asm
   algorithm_asm:
       // Function implementation
       ret
   ```

2. Create `[ALGORITHM]_interop.c`:
   ```c
   extern void algorithm_asm(/* parameters */);
   
   int main() {
       // Allocate memory with malloc()
       // Call algorithm_asm()
       // Free memory with free()
   }
   ```

3. Add to Makefile:
   ```makefile
   INTEROP_TARGETS := BFS_interop [ALGORITHM]_interop
   
   [ALGORITHM]_interop: [ALGORITHM]_interop.c [ALGORITHM]_asm.s
       $(CC) -static -o "$(BIN_DIR)/$@" $^
   ```

## C Calling Convention (ARM64)

- **Parameters**: x0-x7 (first 8 integer/pointer arguments)
- **Return Value**: x0 (or x0-x1 for 128-bit values)
- **Caller-saved**: x0-x18 (can be modified by callee)
- **Callee-saved**: x19-x28, x29 (FP), x30 (LR) (must be preserved)
- **Stack**: Must be 16-byte aligned

## When to Use Interop

Use interop when:
- Algorithm requires large dynamic memory allocations
- Stack-based allocation causes overflow
- Complex memory management patterns
- Need for standard library functions (I/O, math, etc.)

Keep pure assembly when:
- Small, fixed-size allocations
- Maximum performance is critical
- Learning/educational purposes
- Minimal dependencies required
