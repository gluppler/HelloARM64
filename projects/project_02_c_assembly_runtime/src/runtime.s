// ARM64 runtime library functions
// ABI-compliant implementations for C interop
//
// Reference: See ../../references/calling_conventions.md for AAPCS64
// Reference: See ../../references/instruction_set.md for instruction details

.section .text

// void *memcpy(void *dest, const void *src, size_t n)
// X0 = dest, X1 = src, X2 = n
.global memcpy
memcpy:
    MOV  X3, X0            // Save dest pointer
    CMP  X2, #0
    B.EQ memcpy_done
    
memcpy_loop:
    LDRB W4, [X1], #1       // Load byte from src, increment
    STRB W4, [X0], #1       // Store byte to dest, increment
    SUBS X2, X2, #1         // Decrement count
    B.NE memcpy_loop
    
memcpy_done:
    MOV  X0, X3            // Return dest pointer
    RET

// void *memset(void *s, int c, size_t n)
// X0 = s, X1 = c, X2 = n
.global memset
memset:
    MOV  X3, X0            // Save pointer
    CMP  X2, #0
    B.EQ memset_done
    
memset_loop:
    STRB W1, [X0], #1      // Store byte, increment
    SUBS X2, X2, #1        // Decrement count
    B.NE memset_loop
    
memset_done:
    MOV  X0, X3            // Return pointer
    RET

// size_t strlen(const char *s)
// X0 = s
.global strlen
strlen:
    MOV  X1, X0            // Save start pointer
    
strlen_loop:
    LDRB W2, [X0], #1      // Load byte, increment
    CMP  W2, #0            // Check for null terminator
    B.NE strlen_loop
    
    SUB  X0, X0, X1        // Calculate length
    SUB  X0, X0, #1        // Subtract 1 (past null)
    RET

// int strcmp(const char *s1, const char *s2)
// X0 = s1, X1 = s2
// Returns: <0 if s1 < s2, 0 if equal, >0 if s1 > s2
.global strcmp
strcmp:
strcmp_loop:
    LDRB W2, [X0], #1      // Load byte from s1
    LDRB W3, [X1], #1      // Load byte from s2
    CMP  W2, W3            // Compare bytes
    B.NE strcmp_diff       // If different, exit
    CMP  W2, #0            // Check for null terminator
    B.NE strcmp_loop       // Continue if not null
    
    // Strings are equal
    MOV  X0, #0
    RET
    
strcmp_diff:
    SUB  X0, X2, X3        // Return difference
    SXTW X0, W0            // Sign-extend to 64-bit
    RET
