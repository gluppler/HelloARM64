# Lesson 03: Control Flow

> **References**: This lesson is cross-referenced with [`references/instruction_set.md`](../references/instruction_set.md) for branch instructions and conditional execution documentation.

## Learning Objectives

By the end of this lesson, you will be able to:
- Use unconditional and conditional branches
- Implement loops and conditional execution
- Understand branch prediction implications
- Use conditional select instructions
- Implement switch-like structures

## Branch Instructions

### Unconditional Branch

#### B (Branch)
```assembly
B   label                 // Branch to label (PC-relative)
```

**Architectural reasoning**: PC-relative addressing allows position-independent code. Branch target must be within ±128MB of current PC.

**Reference**: ARM A64 ISA (DDI0602), Section C6.4.1

#### BR (Branch to Register)
```assembly
BR   Xn                   // Branch to address in Xn
```

**Use cases**: Function pointers, jump tables, return from function

**Reference**: ARM A64 ISA (DDI0602), Section C6.4.1

### Conditional Branch

#### B.cond (Conditional Branch)
```assembly
B.EQ  label               // Branch if equal (Z=1)
B.NE  label               // Branch if not equal (Z=0)
B.GT  label               // Branch if greater than (signed)
B.LT  label               // Branch if less than (signed)
B.GE  label               // Branch if greater or equal
B.LE  label               // Branch if less or equal
B.HI  label               // Branch if higher (unsigned)
B.LO  label               // Branch if lower (unsigned)
```

**Condition Codes**:
- **EQ/NE**: Equal/Not equal (Z flag)
- **CS/HS**: Carry set / Higher or same (C flag, unsigned)
- **CC/LO**: Carry clear / Lower (C flag, unsigned)
- **MI/PL**: Negative/Positive (N flag)
- **VS/VC**: Overflow/No overflow (V flag)
- **HI**: Higher (unsigned, C=1 and Z=0)
- **LS**: Lower or same (unsigned, C=0 or Z=1)
- **GE**: Greater or equal (signed, N=V)
- **LT**: Less than (signed, N≠V)
- **GT**: Greater than (signed, Z=0 and N=V)
- **LE**: Less or equal (signed, Z=1 or N≠V)

**Reference**: ARM A64 ISA (DDI0602), Section C6.4.2

### Function Call Branches

#### BL (Branch with Link)
```assembly
BL   label                // Branch and link (save return address in LR)
BLR  Xn                   // Branch with link to register
```

**Architectural reasoning**: BL saves return address (PC+4) in X30 (LR), enabling function returns.

**Reference**: ARM A64 ISA (DDI0602), Section C6.4.3

#### RET (Return)
```assembly
RET  Xn                   // Return (branch to Xn, default Xn=LR)
RET                       // Return (branch to LR)
```

**Reference**: ARM A64 ISA (DDI0602), Section C6.4.4

## Loops

### Simple Loop
```assembly
    MOV  X0, #10           // Loop counter
loop:
    // Loop body
    SUBS X0, X0, #1        // Decrement and set flags
    B.NE loop              // Branch if not zero
```

### Counted Loop
```assembly
    MOV  X0, #0            // Counter
    MOV  X1, #10           // Limit
loop:
    // Loop body
    ADD  X0, X0, #1
    CMP  X0, X1
    B.LT loop              // Continue if X0 < X1
```

### Do-While Loop
```assembly
loop:
    // Loop body
    SUBS X0, X0, #1
    B.NE loop              // Always executes at least once
```

## Conditional Execution

### If-Then-Else
```assembly
    CMP  X0, X1
    B.GT greater
    // Else branch
    MOV  X2, #0
    B    end
greater:
    // Then branch
    MOV  X2, #1
end:
```

### Conditional Select
```assembly
CMP  X0, X1
CSEL X2, X3, X4, GT        // X2 = (X0 > X1) ? X3 : X4
```

**Architectural reasoning**: CSEL avoids branch misprediction penalty by using conditional execution instead of branching.

**Reference**: ARM A64 ISA (DDI0602), Section C6.2.9

## Switch-Like Structures

### Jump Table
```assembly
    CMP  X0, #3            // Check range
    B.HI default
    ADR  X1, jump_table
    LDR  X2, [X1, X0, LSL #3]  // Load address from table
    BR   X2                // Jump to address
jump_table:
    .quad case0
    .quad case1
    .quad case2
    .quad case3
case0:
    // Case 0 code
    B    end
case1:
    // Case 1 code
    B    end
default:
    // Default case
end:
```

## Practical Examples

### Example 1: Simple Loop
```assembly
.section .text
.global _start
_start:
    MOV  X0, #5            // Counter
    MOV  X1, #0            // Sum
loop:
    ADD  X1, X1, X0        // Add counter to sum
    SUBS X0, X0, #1        // Decrement counter
    B.NE loop              // Continue if not zero
    // X1 now contains 5+4+3+2+1 = 15
    
    MOV  X8, #93
    MOV  X0, #0
    SVC  #0
```

### Example 2: Conditional Execution
```assembly
.section .text
.global _start
_start:
    MOV  X0, #10
    MOV  X1, #20
    
    // If X0 > X1, set X2 = 1, else X2 = 0
    CMP  X0, X1
    B.GT set_one
    MOV  X2, #0
    B    end
set_one:
    MOV  X2, #1
end:
    
    MOV  X8, #93
    MOV  X0, #0
    SVC  #0
```

### Example 3: Maximum Value
```assembly
.section .text
.global _start
_start:
    MOV  X0, #10
    MOV  X1, #20
    
    // X2 = max(X0, X1) using conditional select
    CMP  X0, X1
    CSEL X2, X0, X1, GT    // X2 = (X0 > X1) ? X0 : X1
    
    MOV  X8, #93
    MOV  X0, #0
    SVC  #0
```

## Branch Prediction

### Forward vs Backward Branches
- **Forward branches**: Typically not taken (if statements)
- **Backward branches**: Typically taken (loops)
- Hardware branch predictor learns patterns

### Minimizing Mispredictions
- Use conditional select (CSEL) for simple conditionals
- Structure code to favor predicted paths
- Avoid unpredictable branches in tight loops

**Reference**: ARM Architecture Reference Manual - Branch Prediction

## Exercises

1. **Loop Sum**: Write a program that sums numbers from 1 to N
2. **Conditional Logic**: Implement if-else and switch-like structures
3. **Optimization**: Rewrite branch-heavy code using conditional select

## Key Takeaways

- Branches change program flow based on conditions
- Conditional branches use NZCV flags
- Loops use backward branches (typically predicted taken)
- Conditional select (CSEL) avoids branch penalties
- Function calls use BL (saves return address in LR)
- Returns use RET (branches to LR)

## Next Steps

- Lesson 04: Memory and Stack - Learn memory operations
- Practice implementing various control flow patterns
- Experiment with branch prediction in performance-critical code

## References

- ARM A64 Instruction Set Architecture (DDI0602), Section C6.4
- ARMv8-A Architecture Reference Manual (DDI0487)
- ARM Developer Documentation - Control Flow
