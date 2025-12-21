// ARM64 assembly function called from C
// Function: int add(int a, int b)
// Arguments: X0 = a, X1 = b
// Returns: X0 = a + b
//
// Reference: See references/calling_conventions.md for AAPCS64 calling convention
// Reference: See references/instruction_set.md for ADD instruction documentation

.section .text
.global add
add:
    // Add arguments (X0 and X1) and return result in X0
    ADD  X0, X0, X1        // X0 = X0 + X1
    RET                    // Return (X0 contains result)
