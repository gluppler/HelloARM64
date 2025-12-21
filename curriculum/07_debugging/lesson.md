# Lesson 07: Debugging

> **References**: This lesson is cross-referenced with [`references/debugging.md`](../references/debugging.md) for complete debugging techniques and GDB workflows documentation.

## Learning Objectives

By the end of this lesson, you will be able to:
- Use GDB for ARM64 debugging
- Set breakpoints and step through code
- Inspect registers and memory
- Debug common issues (segfaults, alignment)
- Use debugging best practices

## GDB Basics

### Starting GDB
```bash
gdb ./program
```

### Basic Commands
```
break *address            # Set breakpoint
run                       # Start program
stepi                     # Step one instruction
info registers            # Show registers
x/10x $sp                 # Examine memory
disassemble               # Disassemble code
```

**Reference**: GDB Documentation

## Debugging Techniques

### Register Inspection
```gdb
(gdb) info registers
(gdb) print $x0
(gdb) print $sp
```

### Memory Inspection
```gdb
(gdb) x/20g $sp           # 20 64-bit values
(gdb) x/20x $sp           # 20 words in hex
```

### Stack Inspection
```gdb
(gdb) print $fp
(gdb) x/2g $fp             # Frame record
```

## Common Issues

### Segmentation Fault
- Use GDB to catch fault
- Check address registers
- Verify alignment
- Check stack pointer

### Alignment Issues
```gdb
(gdb) print $sp % 16      # Should be 0
```

## Exercises

1. Debug a program with intentional bugs
2. Use GDB to trace execution flow
3. Inspect registers and memory at breakpoints

## Key Takeaways

- GDB is essential for assembly debugging
- Breakpoints stop execution for inspection
- Register and memory inspection reveals state
- Stack alignment is critical
- Step through code instruction-by-instruction

## Next Steps

- Lesson 08: Performance and Optimization
- Practice debugging various issues
- Master GDB workflows

## References

- GDB Documentation
- ARM Developer Documentation - Debugging
