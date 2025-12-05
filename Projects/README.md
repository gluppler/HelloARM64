# Projects Portfolio

This directory contains standalone ARM64 assembly projects demonstrating real-world applications and advanced implementations.

## Portfolio Projects

Each project in this directory is a complete, standalone implementation showcasing ARM64 assembly expertise. **Projects are NOT numerically labelled** and represent independent portfolio pieces that demonstrate real-world problem-solving and implementation skills.

## Current Projects

### Algorithms
A comprehensive collection of algorithms implemented in ARM64 assembly with C/Assembly interop support.

**Location**: `Projects/Algorithms/`  
**Status**: ✅ Complete - 20 pure assembly + 14 interop implementations

**Contents**:
- **20 Pure Assembly Algorithms**: Graph algorithms (BFS, DFS), search algorithms (Binary Search, Linear Search), mathematical algorithms (Factorial, Fibonacci, GCD, LCM, Prime Check), string matching (KMP, Rabin-Karp), dynamic programming (Knapsack, LCS), tree algorithms (Tree Traversal), and all 6 sorting algorithms (Bubble, Heap, Insertion, Merge, Quick, Selection)
- **14 C/Assembly Interop Versions**: For algorithms requiring complex memory management, using heap allocation via C wrappers
- **34 Total Binaries**: All algorithms build and run successfully

**Documentation**: See `Projects/Algorithms/README.md` for complete details.

### Binutils
ARM64 implementations of standard binary utilities.

**Location**: `Projects/Binutils/`  
**Status**: ✅ Complete - 13 utility implementations

**Contents**: addr2line, ar, c++filt, elfedit, gprof, ld, nm, objcopy, objdump, ranlib, readelf, size, strings, strip

**Documentation**: See `Projects/Binutils/README.md` for details.

## Project Structure

Projects should be organized by category or functionality, with each project containing:
- Source code (`.s` files)
- Documentation (README.md)
- Build instructions
- Example usage
- Clear demonstration of ARM64 assembly concepts

## Portfolio Organization

Projects are organized as standalone pieces, not as part of a numbered sequence. Each project should:
- Have a descriptive, meaningful name (no numerical prefixes)
- Be self-contained and independently buildable
- Demonstrate specific ARM64 assembly techniques or solve real problems
- Include comprehensive documentation
- Follow industry best practices and quality standards

## Adding Projects

When adding a new project to the portfolio:

1. **Create a descriptive directory name** (no numerical prefixes)
   - Good: `Matrix_Multiplier`, `String_Processor`, `Cryptographic_Hash`
   - Avoid: `01_Project`, `02_Project`, etc.

2. **Include comprehensive documentation**
   - README.md explaining the project
   - What problem it solves
   - What ARM64 techniques it demonstrates
   - Build and usage instructions

3. **Ensure code follows industry best practices**
   - Production-ready, error-free implementations
   - Comprehensive security best practices
   - All memory accesses properly validated
   - All instructions correctly formatted
   - Well-structured, maintainable code
   - Input validation and bounds checking throughout
   - All code must compile and execute without errors

4. **Provide clear build and usage instructions**
   - How to compile
   - How to run
   - Expected output
   - Dependencies (if any)

## Project Categories

Projects can be organized by:
- **Application Domain**: System utilities, algorithms, data processing
- **Technique Focus**: Optimization, security, performance
- **Complexity Level**: Beginner-friendly, intermediate, advanced
- **Platform**: Linux-specific, Apple Silicon-specific, cross-platform

## Portfolio Showcase

Each project in this directory serves as a portfolio piece demonstrating:
- **Technical Skills**: ARM64 assembly proficiency
- **Problem-Solving**: Real-world application development
- **Code Quality**: Production-ready implementations
- **Documentation**: Clear, comprehensive project documentation

## Example Project Structure

```
Projects/
├── Matrix_Multiplier/
│   ├── matrix_mult.s
│   ├── README.md
│   └── Makefile
├── String_Processor/
│   ├── string_ops.s
│   ├── README.md
│   └── Makefile
└── README.md (this file)
```

## Building Projects

Each project has its own build system. See individual project README files for build instructions.

### Algorithms
```bash
cd Projects/Algorithms
make          # Build all pure assembly algorithms
make interop  # Build all interop versions
make clean    # Clean binaries
```

### Binutils
```bash
cd Projects/Binutils
make          # Build all utilities
make clean    # Clean binaries
```

## Status

✅ **Algorithms**: Complete - 20 pure assembly + 14 interop implementations (34 binaries)  
✅ **Binutils**: Complete - 13 utility implementations  
📝 **Ready for more projects**: Add your standalone ARM64 assembly implementations here to showcase your expertise.
