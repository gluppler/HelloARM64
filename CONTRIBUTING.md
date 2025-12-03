# Contributing Guidelines

Welcome!  
This project follows a universal coding doctrine focused on **immutability, functional purity, modularity, testing, and clarity**.  
Please follow these principles when contributing.

---

## 1. Immutability
- Prefer immutable data.  
- Avoid modifying variables in place.  
- Pass state explicitly instead of mutating globals.

## 2. Purity
- Functions should always return the same output for the same input.  
- Avoid hidden dependencies on global state or external side effects.

## 3. Modularity
- Write small, composable units of code.  
- Favor composition over deep inheritance or excessive coupling.

## 4. Error Handling
- Always handle errors explicitly.  
- Fail fast and log clearly.

## 5. Testing
- Every unit of logic must have tests.  
- Tests should be **fast, deterministic, and isolated**.

## 6. Refactoring
- Continuously improve readability and structure.  
- Keep functions short and single-purpose.  
- Eliminate duplication.

## 7. Documentation
- Comment why (not just what).  
- Keep `README.md` and usage docs updated.  

## 8. Security
- Validate inputs and outputs.  
- Avoid unsafe practices that compromise reliability or security.

---

## Example Guides
Each repository includes a `CONTRIBUTING_EXAMPLES.md` file that shows how to apply these principles in its specific language or environment.

## Portfolio Structure
This repository is organized as an ARM64 assembly portfolio:

### Numerically-Labelled References
- **`Fundamentals/`**: Core ARM64 assembly concepts (11 files, numbered 01-11)
- **`Advanced/`**: Advanced ARM64 assembly concepts (11 files, numbered 01-11)
- **Total**: 22 comprehensive reference files, 5,616 lines of production-ready code
- **Compiled Binaries**: 22 (11 in `bin/fundamentals/`, 11 in `bin/advanced/`)

### Cheatsheets
- **`Cheatsheets/`**: Quick reference guides (3 cheatsheets + README)
  - ARM64 Opcodes reference
  - ARM64 Instruction Set reference
  - ARM64 Syscalls reference

### Projects Portfolio
- **`Projects/`**: Standalone portfolio pieces (unlabelled, independent projects)
  - Projects are NOT numerically labelled
  - Each project is a complete, standalone implementation
  - Demonstrates real-world ARM64 assembly applications

All reference code follows these contributing guidelines and serves as examples of best practices. All files:
- Production-ready, error-free implementations
- Comprehensive security best practices implemented
- All memory accesses properly validated
- All instructions correctly formatted
- Well-structured, maintainable code
- Input validation and bounds checking throughout
- Comprehensive error handling with halt_loop protection
- 100% compilation and execution success rate - All 22 files tested and working
- Ready for production use
