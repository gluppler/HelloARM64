# Practical Tasks

> **Reference**: All tasks are based on concepts documented in [`../../references/`](../../references/). Implementation should follow reference-cited practices from the authoritative reference documentation.

## Task 1: Hello World Program

**Objective**: Write a complete ARM64 assembly program that prints "Hello, World!" to stdout.

**Requirements**:
- Use Linux system calls
- Properly exit with status 0
- Include error handling

**Deliverables**:
- Source file: `hello.s`
- Build instructions
- Test output

## Task 2: Function Implementation

**Objective**: Implement a function that calculates the factorial of a number.

**Requirements**:
- Function signature: `int factorial(int n)`
- Use recursion or iteration
- Follow AAPCS64 calling convention
- Handle edge cases (n=0, n=1)

**Deliverables**:
- Assembly function: `factorial.s`
- C test program: `test_factorial.c`
- Build and test instructions

## Task 3: Memory Operations

**Objective**: Implement a memory copy function using load/store pair instructions.

**Requirements**:
- Function: `void memcpy_pair(void *dest, const void *src, size_t n)`
- Use LDP/STP for efficiency
- Handle unaligned data
- Test with various sizes

**Deliverables**:
- Assembly function
- Test program
- Performance comparison with scalar version

## Task 4: Stack Frame Management

**Objective**: Write a function that uses local variables on the stack.

**Requirements**:
- Proper prologue and epilogue
- Allocate and use local variables
- Maintain stack alignment
- Save/restore callee-saved registers if needed

**Deliverables**:
- Complete function implementation
- Stack frame diagram
- GDB session showing stack layout

## Task 5: System Call Wrapper

**Objective**: Create a wrapper function for the write system call.

**Requirements**:
- Function: `ssize_t sys_write(int fd, const void *buf, size_t count)`
- Handle system call setup
- Return value and error handling
- Test with different file descriptors

**Deliverables**:
- Assembly wrapper function
- Test program
- Error handling demonstration

## Task 6: String Operations

**Objective**: Implement strlen and strcmp functions in assembly.

**Requirements**:
- strlen: Calculate string length
- strcmp: Compare two strings
- Follow AAPCS64
- Optimize for performance

**Deliverables**:
- Both functions in assembly
- C test program
- Performance analysis

## Task 7: Loop Optimization

**Objective**: Optimize a loop using various techniques.

**Requirements**:
- Original and optimized versions
- Use loop unrolling
- Minimize memory accesses
- Measure performance improvement

**Deliverables**:
- Both versions of code
- Performance measurements
- Analysis of improvements

## Task 8: Conditional Execution

**Objective**: Rewrite branch-heavy code using conditional select.

**Requirements**:
- Original version with branches
- Optimized version with CSEL
- Compare performance
- Explain trade-offs

**Deliverables**:
- Both code versions
- Performance comparison
- Analysis document

## Evaluation Criteria

- **Correctness**: Code compiles and runs correctly
- **ABI Compliance**: Follows AAPCS64 conventions
- **Code Quality**: Clean, readable, well-commented
- **Documentation**: Clear build and test instructions
- **Understanding**: Demonstrates comprehension of concepts
