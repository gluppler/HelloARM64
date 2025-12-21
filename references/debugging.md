# Debugging Reference

Complete reference for debugging ARM64 assembly code using GDB and Arm Development Studio.

**Source**: GDB Documentation, Arm Development Studio Documentation, ARM Developer Documentation

## Debugging Tools

### GDB (GNU Debugger)
- Primary debugger for Linux ARM64 development
- Supports assembly-level debugging
- Can inspect registers, memory, and execution flow

**Reference**: GDB Documentation, ARM Developer Documentation - Using a debugger

### Arm Development Studio
- Professional IDE for ARM development
- Integrated debugger with advanced features
- Supports hardware and software debugging

**Reference**: Arm Development Studio Documentation

## GDB Basics

### Starting GDB
```bash
# Debug executable
gdb ./program

# Debug with core dump
gdb ./program core

# Attach to running process
gdb -p <pid>
```

### Basic GDB Commands

#### Running Programs
```
run [args]                # Start program
continue [n]              # Continue execution (optionally n times)
step [n]                  # Step into (n instructions)
next [n]                  # Step over (n instructions)
finish                    # Continue until current function returns
```

#### Breakpoints
```
break *address            # Set breakpoint at address
break function            # Set breakpoint at function
break file.s:line         # Set breakpoint at line
info breakpoints          # List breakpoints
delete [n]                # Delete breakpoint n
disable [n]               # Disable breakpoint n
enable [n]                # Enable breakpoint n
```

#### Inspecting Registers
```
info registers            # Show all registers
info registers x0 x1      # Show specific registers
print $x0                 # Print value of X0
print/x $x0               # Print X0 in hexadecimal
print/d $x0               # Print X0 in decimal
print/t $x0               # Print X0 in binary
```

#### Inspecting Memory
```
x/10x $sp                 # Examine 10 words at SP (hex)
x/10i $pc                 # Examine 10 instructions at PC
x/s address               # Examine as string
x/10g address             # Examine 10 giant words (64-bit)
print *address            # Print value at address
```

#### Disassembly
```
disassemble               # Disassemble current function
disassemble function      # Disassemble function
disassemble start,end     # Disassemble address range
```

## ARM64-Specific GDB Features

### Register Inspection
```
# General-purpose registers
info registers x0-x30
print $x0
print $sp
print $lr                 # Link register (X30)
print $pc                 # Program counter

# Condition flags
print $cpsr               # Current Program Status Register
print $nzcv               # Condition flags (if supported)

# SIMD/NEON registers
info registers v0-v31
print $v0
```

### Assembly-Level Stepping
```
stepi [n]                 # Step one instruction (n times)
nexti [n]                 # Step one instruction, skip calls
```

### Memory Inspection
```
# Stack inspection
x/20g $sp                 # Examine 20 64-bit values on stack
x/20x $sp                 # Examine 20 words in hex

# Code inspection
x/10i $pc                 # Next 10 instructions
x/10i function            # First 10 instructions of function
```

## Debugging Techniques

### Register State Inspection
```gdb
# Check all registers at breakpoint
(gdb) break main
(gdb) run
(gdb) info registers

# Check specific register values
(gdb) print $x0
(gdb) print $x1
(gdb) print $sp
```

### Stack Frame Inspection
```gdb
# Examine stack frame
(gdb) x/20g $sp           # 20 64-bit values
(gdb) x/20x $sp           # 20 words in hex
(gdb) print $fp            # Frame pointer
(gdb) x/2g $fp             # Frame record (FP, LR)
```

### Instruction-Level Debugging
```gdb
# Step through instructions
(gdb) stepi                # Step one instruction
(gdb) nexti                # Step one instruction, skip calls
(gdb) disassemble          # See current instructions
```

### Memory Content Inspection
```gdb
# Examine memory at address
(gdb) x/10x 0x1000        # 10 words at address 0x1000
(gdb) x/s 0x1000          # As string
(gdb) x/10i 0x1000        # As instructions
```

## Common Debugging Scenarios

### Debugging Function Calls
```gdb
# Set breakpoint at function
(gdb) break my_function
(gdb) run

# Check arguments (X0-X7)
(gdb) print $x0
(gdb) print $x1

# Step through function
(gdb) stepi
(gdb) info registers

# Check return value (X0)
(gdb) finish
(gdb) print $x0
```

### Debugging Stack Issues
```gdb
# Check stack alignment
(gdb) print $sp
(gdb) print $sp % 16       # Should be 0 (16-byte aligned)

# Examine stack contents
(gdb) x/20g $sp
(gdb) x/20x $sp

# Check frame pointer
(gdb) print $fp
(gdb) x/2g $fp             # Frame record
```

### Debugging Memory Access
```gdb
# Check memory address
(gdb) print/x $x0          # Address in register
(gdb) x/10x $x0            # Examine memory at address

# Check for alignment
(gdb) print $x0 % 8        # Should be 0 for 64-bit access
```

### Debugging Condition Flags
```gdb
# Check condition flags (if supported)
(gdb) print $cpsr
(gdb) print $nzcv

# Or check individual flags
(gdb) print $z             # Zero flag
(gdb) print $c             # Carry flag
```

## GDB Scripts

### Useful GDB Initialization
Create `~/.gdbinit`:
```
set disassembly-flavor intel
set print pretty on
set print elements 0
```

### Custom GDB Commands
```gdb
# Define command to show registers
define showregs
    info registers x0-x7
    info registers sp lr pc
end

# Define command to show stack
define showstack
    x/20g $sp
end
```

## Arm Development Studio

### Features
- Integrated development environment
- Advanced debugging capabilities
- Hardware debugging support
- Performance profiling

### Debugging with Arm Development Studio
1. Create project
2. Set breakpoints
3. Run debug session
4. Inspect registers and memory
5. Step through code

**Reference**: Arm Development Studio Documentation

## Debugging Best Practices

### Use Breakpoints Strategically
- Set breakpoints at function entry/exit
- Set breakpoints before problematic code
- Use conditional breakpoints when needed

### Inspect Register State
- Check argument registers (X0-X7) at function entry
- Verify return values in X0
- Check stack pointer alignment

### Verify Memory Access
- Check addresses before load/store
- Verify alignment requirements
- Inspect memory contents

### Trace Execution Flow
- Use stepi to trace instruction-by-instruction
- Use disassemble to see current code
- Check branch targets

## Common Issues and Solutions

### Segmentation Fault
```gdb
# Run with GDB to catch fault
(gdb) run
# GDB will stop at fault
(gdb) info registers
(gdb) x/10i $pc           # See faulting instruction
(gdb) print $x0            # Check address register
```

### Incorrect Register Values
```gdb
# Check all registers
(gdb) info registers
# Compare with expected values
# Check for register corruption
```

### Stack Corruption
```gdb
# Check stack pointer
(gdb) print $sp
(gdb) x/20g $sp
# Verify stack alignment
(gdb) print $sp % 16
```

## References

- GDB Documentation: https://sourceware.org/gdb/documentation/
- ARM Developer Documentation - Using a debugger: https://developer.arm.com/documentation/107829/0201/Using-a-debugger-to-investigate-registers
- Arm Development Studio: https://developer.arm.com/Tools%20and%20Software/Arm%20Development%20Studio
- GDB on AArch64 Linux: https://developer.arm.com/documentation/107829/0201/Using-a-debugger-to-investigate-registers/Debugging-with-GDB-on-AArch64-Linux
