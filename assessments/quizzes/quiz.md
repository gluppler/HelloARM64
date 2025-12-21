# ARM64 Assembly Quiz

> **Reference**: All quiz questions are based on concepts documented in [`../../references/`](../../references/). See [`../../references/index.md`](../../references/index.md) for the complete reference index.

## Quiz 1: Registers and Data

1. How many general-purpose 64-bit registers does ARM64 have?
   - [ ] 16
   - [ ] 31
   - [ ] 32
   - [ ] 64

2. What is the purpose of the zero register (XZR)?
   - [ ] Stores the value 1
   - [ ] Always reads as 0, discards writes
   - [ ] Used for floating-point operations
   - [ ] Holds the program counter

3. Which condition flag is set when a result is zero?
   - [ ] N (Negative)
   - [ ] Z (Zero)
   - [ ] C (Carry)
   - [ ] V (Overflow)

## Quiz 2: Instructions

1. What does the instruction `ADDS X0, X1, X2` do?
   - [ ] Adds X1 and X2, stores in X0, sets flags
   - [ ] Adds X0 and X1, stores in X2
   - [ ] Subtracts X2 from X1
   - [ ] Multiplies X1 and X2

2. Which instruction is used for unconditional branch?
   - [ ] B.cond
   - [ ] BL
   - [ ] B
   - [ ] RET

3. What is the difference between LDR and STR?
   - [ ] LDR loads, STR stores
   - [ ] LDR stores, STR loads
   - [ ] Both load data
   - [ ] Both store data

## Quiz 3: Memory and Stack

1. What alignment is required for the stack pointer?
   - [ ] 4-byte aligned
   - [ ] 8-byte aligned
   - [ ] 16-byte aligned
   - [ ] 32-byte aligned

2. What does LDP instruction do?
   - [ ] Loads a pair of registers
   - [ ] Stores a pair of registers
   - [ ] Loads and stores simultaneously
   - [ ] Performs arithmetic on pairs

## Quiz 4: Functions and ABI

1. Where are the first 8 integer function arguments passed?
   - [ ] X0-X7
   - [ ] X1-X8
   - [ ] Stack only
   - [ ] X19-X26

2. Which registers must be preserved by callee functions?
   - [ ] X0-X7
   - [ ] X19-X28
   - [ ] X9-X15
   - [ ] All registers

## Quiz 5: System Calls

1. Which register holds the system call number on Linux?
   - [ ] X0
   - [ ] X7
   - [ ] X8
   - [ ] X16

2. What instruction is used to make a system call?
   - [ ] B
   - [ ] BL
   - [ ] SVC
   - [ ] RET

## Answers

1. B (31 registers: X0-X30)
2. B (Always reads as 0)
3. B (Z flag)
4. A (Adds and sets flags)
5. C (B for unconditional branch)
6. A (LDR loads, STR stores)
7. C (16-byte aligned)
8. A (Loads pair of registers)
9. A (X0-X7)
10. B (X19-X28 are callee-saved)
11. C (X8 on Linux)
12. C (SVC instruction)
