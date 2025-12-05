# ARM64 Assembly Algorithms

Complete collection of algorithms implemented in ARM64 assembly with C/Assembly interop support.

## Overview

This directory contains production-ready implementations of common algorithms in ARM64 assembly. Algorithms with memory management issues have C/Assembly interop versions that use heap allocation for reliability.

## Algorithms

### Graph Algorithms
- **BFS** (Breadth-First Search) - ✅ Interop version recommended
- **DFS** (Depth-First Search) - ✅ Interop version recommended

### Search Algorithms
- **Binary_Search** - ✅ Both versions available
- **Linear_Search** - ✅ Interop version recommended

### Mathematical Algorithms
- **Factorial** - ✅ Both versions available
- **Fibonacci** - ✅ Both versions available
- **GCD** (Greatest Common Divisor) - ✅ Both versions available
- **LCM** (Least Common Multiple) - ✅ Both versions available
- **Prime_Check** - ✅ Both versions available

### String Matching Algorithms
- **KMP** (Knuth-Morris-Pratt) - ✅ Interop version recommended
- **Rabin_Karp** - ✅ Interop version recommended

### Dynamic Programming
- **Knapsack** (0/1 Knapsack) - ✅ Interop version recommended
- **LCS** (Longest Common Subsequence) - ✅ Interop version recommended

### Tree Algorithms
- **Tree_Traversal** - ✅ Interop version recommended

### Sorting Algorithms (Pure Assembly)
- **Bubble_Sort** - ✅ Pure assembly
- **Heap_Sort** - ✅ Pure assembly
- **Insertion_Sort** - ✅ Pure assembly
- **Merge_Sort** - ✅ Pure assembly
- **Quick_Sort** - ✅ Pure assembly
- **Selection_Sort** - ✅ Pure assembly

## Building

### Build All Pure Assembly Algorithms
```bash
make
```

### Build All Interop Versions
```bash
make interop
```

### Build Specific Algorithm
```bash
make BFS              # Pure assembly
make BFS_interop      # Interop version
```

### Clean Build Artifacts
```bash
make clean
```

## Running

### Pure Assembly Versions
```bash
qemu-aarch64 -L /usr/aarch64-linux-gnu ./bin/BFS
```

### Interop Versions (Recommended for algorithms with memory issues)
```bash
qemu-aarch64 -L /usr/aarch64-linux-gnu ./bin/BFS_interop
```

## Which Version to Use?

### Use Interop Version When:
- Algorithm requires large dynamic memory allocations
- Stack-based allocation causes overflow
- Complex memory management patterns
- Need for standard library functions

**Algorithms with interop versions:**
- BFS, DFS (graph algorithms)
- KMP, Rabin_Karp (string matching)
- Knapsack, LCS (dynamic programming)
- Tree_Traversal (tree algorithms)
- Binary_Search, Linear_Search (search algorithms)
- Factorial, Fibonacci, GCD, LCM, Prime_Check (mathematical)

### Use Pure Assembly When:
- Small, fixed-size allocations
- Maximum performance is critical
- Learning/educational purposes
- Minimal dependencies required

**Pure assembly only:**
- All sorting algorithms (Bubble_Sort, Heap_Sort, Insertion_Sort, Merge_Sort, Quick_Sort, Selection_Sort)

## File Structure

Each algorithm may have:
- `[ALGORITHM].s` - Pure ARM64 assembly implementation
- `[ALGORITHM]_asm.s` - Assembly function for C interop
- `[ALGORITHM]_interop.c` - C wrapper with memory management

## Code Quality

All implementations follow:
- ARM64 ABI calling conventions
- Proper register preservation (callee-saved x19-x28)
- 16-byte stack alignment
- Input validation and bounds checking
- Error handling
- Clean, maintainable code structure

## Notes

- **Dijkstra** algorithm was removed (requires priority queue, too complex for pure assembly)
- All `.core` files have been cleaned up
- Interop versions use heap allocation to avoid stack issues
- Pure assembly versions are optimized for performance
