# GDB Workflows

> **Reference**: Complete debugging documentation is available in [`../references/debugging.md`](../references/debugging.md) with detailed GDB usage and ARM64-specific debugging techniques.

## Basic Workflow

### Starting GDB
```bash
gdb ./program
```

### Setting Breakpoints
```
(gdb) break _start
(gdb) break function_name
(gdb) break *0x400000
```

### Running and Stepping
```
(gdb) run
(gdb) stepi              # Step one instruction
(gdb) nexti               # Step over calls
(gdb) continue            # Continue execution
```

### Inspecting State
```
(gdb) info registers      # All registers
(gdb) print $x0           # Specific register
(gdb) x/20g $sp           # Examine memory
(gdb) disassemble         # Current code
```

## Common Workflows

### Debugging Function Calls
1. Set breakpoint at function entry
2. Inspect arguments (X0-X7)
3. Step through function
4. Check return value (X0)

### Debugging Stack Issues
1. Check stack alignment: `print $sp % 16`
2. Examine stack: `x/20g $sp`
3. Check frame pointer: `print $fp`
4. Inspect frame record: `x/2g $fp`

### Debugging Memory Access
1. Check address: `print/x $x0`
2. Verify alignment: `print $x0 % 8`
3. Examine memory: `x/10x $x0`
4. Check for valid address

## GDB Scripts

### Useful Commands
```
define showregs
    info registers x0-x7
    info registers sp lr pc
end

define showstack
    x/20g $sp
end
```

## References

- GDB Documentation
- ARM Developer Documentation - Debugging
