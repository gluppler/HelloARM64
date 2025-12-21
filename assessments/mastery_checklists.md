# Mastery Checklists

> **Reference**: All mastery criteria are aligned with concepts documented in [`../references/`](../references/). See [`../references/index.md`](../references/index.md) for the complete reference index.

## Level 1: Fundamentals

### Registers and Data
- [ ] Understand 64-bit and 32-bit register access
- [ ] Use zero register effectively
- [ ] Understand condition flags (NZCV)
- [ ] Load immediate values correctly

### Basic Instructions
- [ ] Use arithmetic instructions (ADD, SUB, MUL)
- [ ] Use logical instructions (AND, ORR, EOR)
- [ ] Perform shift operations
- [ ] Use comparison instructions

### Control Flow
- [ ] Implement unconditional branches
- [ ] Use conditional branches
- [ ] Write loops (for, while, do-while)
- [ ] Implement if-else structures

## Level 2: Intermediate

### Memory Operations
- [ ] Load and store data from/to memory
- [ ] Use different addressing modes
- [ ] Understand alignment requirements
- [ ] Use load/store pair instructions

### Functions
- [ ] Write functions with proper prologue/epilogue
- [ ] Pass arguments correctly (X0-X7)
- [ ] Return values correctly
- [ ] Manage caller-saved and callee-saved registers
- [ ] Implement leaf function optimizations

### Stack Management
- [ ] Allocate and deallocate stack frames
- [ ] Maintain 16-byte alignment
- [ ] Save and restore registers
- [ ] Use frame pointer correctly

## Level 3: Advanced

### System Programming
- [ ] Make system calls correctly
- [ ] Handle system call errors
- [ ] Use common system calls (read, write, open, close)
- [ ] Parse command-line arguments

### Optimization
- [ ] Select efficient instructions
- [ ] Optimize memory access patterns
- [ ] Minimize branch mispredictions
- [ ] Use conditional select (CSEL)
- [ ] Apply loop optimization techniques

### Debugging
- [ ] Use GDB effectively
- [ ] Set breakpoints and step through code
- [ ] Inspect registers and memory
- [ ] Debug common issues (segfaults, alignment)

## Level 4: Expert

### Advanced Topics
- [ ] Understand MMU and address translation
- [ ] Implement bare metal code
- [ ] Set up exception vectors
- [ ] Configure MMU
- [ ] Use SIMD/NEON instructions

### Real-World Applications
- [ ] Implement complete utilities
- [ ] Write runtime library functions
- [ ] Create C/Assembly interop code
- [ ] Optimize performance-critical code

### Architecture Deep Dive
- [ ] Understand pipeline effects
- [ ] Analyze cache behavior
- [ ] Optimize for specific ARM cores
- [ ] Understand memory ordering

## Mastery Validation

To achieve mastery at each level:
1. Complete all checklist items
2. Successfully implement practical tasks
3. Pass quizzes with 90%+ accuracy
4. Demonstrate understanding through projects
5. Explain concepts clearly in documentation

## Progression Path

- **Beginner**: Complete Level 1
- **Intermediate**: Complete Level 2
- **Advanced**: Complete Level 3
- **Expert**: Complete Level 4

Each level builds on previous knowledge and requires practical application through projects and assessments.
