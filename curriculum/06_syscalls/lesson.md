# Lesson 06: System Calls

> **References**: This lesson is cross-referenced with [`references/syscalls.md`](../references/syscalls.md) for complete Linux and macOS system call documentation.

## Learning Objectives

By the end of this lesson, you will be able to:
- Understand system call mechanism
- Make Linux and macOS system calls
- Use common system calls (read, write, exit)
- Handle system call errors
- Understand syscall conventions

## System Call Overview

System calls provide interface between user-space and kernel.

### ARM64 Syscall Convention
- **System call number**: X8 (Linux) or X16 (macOS)
- **Arguments**: X0-X5 (up to 6)
- **Return value**: X0 (negative = error)
- **Instruction**: `SVC #0`

**Reference**: Linux kernel documentation, macOS system documentation

## Common System Calls

### exit (93 on Linux, 1 on macOS)
```assembly
MOV  X8, #93              // Linux sys_exit
MOV  X0, #0               // Exit status
SVC  #0
```

### write (64 on Linux, 4 on macOS)
```assembly
MOV  X8, #64              // Linux sys_write
MOV  X0, #1               // stdout
ADR  X1, message          // buffer
MOV  X2, #message_len     // length
SVC  #0
```

### read (63 on Linux, 3 on macOS)
```assembly
MOV  X8, #63              // Linux sys_read
MOV  X0, #0               // stdin
ADR  X1, buffer           // buffer
MOV  X2, #buffer_size     // size
SVC  #0                   // Returns bytes read in X0
```

## Error Handling

```assembly
MOV  X8, #64
// ... arguments ...
SVC  #0
CMP  X0, #0
B.LT error_handler        // Branch if error (negative)
```

## Practical Example

```assembly
.section .data
message:
    .asciz "Hello, World!\n"
message_len = . - message - 1

.section .text
.global _start
_start:
    MOV  X8, #64          // sys_write
    MOV  X0, #1           // stdout
    ADR  X1, message
    MOV  X2, #message_len
    SVC  #0
    
    MOV  X8, #93          // sys_exit
    MOV  X0, #0
    SVC  #0
```

## Exercises

1. Write a program that reads input and writes it back
2. Implement error handling for system calls
3. Use multiple system calls in sequence

## Key Takeaways

- System calls use SVC instruction
- Syscall number in X8 (Linux) or X16 (macOS)
- Arguments in X0-X5
- Return value in X0 (negative = error)
- Always check return values

## Next Steps

- Lesson 07: Debugging - Learn debugging techniques
- Practice with various system calls
- Understand error handling

## References

- Linux System Call Table
- macOS System Calls Documentation
- ARM64 ABI Documentation
