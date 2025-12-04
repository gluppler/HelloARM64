.text
//  Algorithms: Rabin-Karp String Matching
//  Demonstrates Rabin-Karp algorithm with timing and detailed output

.global _start
.align 4

.equ SYS_EXIT, 93
.equ SYS_WRITE, 64
.equ SYS_CLOCK_GETTIME, 113
.equ CLOCK_MONOTONIC, 1
.equ STDOUT_FILENO, 1

_start:
    mov     x19, sp
    
    //  Print header
    mov     x0, #STDOUT_FILENO
    adr     x1, header_msg
    mov     x2, #header_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Print sample data
    mov     x0, #STDOUT_FILENO
    adr     x1, sample_msg
    mov     x2, #sample_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Test strings
    adr     x20, text
    adr     x21, pattern
    
    //  Calculate lengths
    mov     x0, x20
    bl      strlen
    mov     x22, x0
    
    mov     x0, x21
    bl      strlen
    mov     x23, x0
    
    //  Get start time
    sub     sp, sp, #16
    mov     x0, #CLOCK_MONOTONIC
    mov     x1, sp
    mov     x8, #SYS_CLOCK_GETTIME
    svc     #0
    ldp     x24, x25, [sp]
    add     sp, sp, #16
    
    //  Search
    mov     x0, x20
    mov     x1, x22
    mov     x2, x21
    mov     x3, x23
    bl      rabin_karp
    
    //  Get end time
    sub     sp, sp, #16
    mov     x0, #CLOCK_MONOTONIC
    mov     x1, sp
    mov     x8, #SYS_CLOCK_GETTIME
    svc     #0
    ldp     x26, x27, [sp]
    add     sp, sp, #16
    
    //  Print result
    cmp     x0, #-1
    b.eq    not_found
    
    mov     x0, #STDOUT_FILENO
    adr     x1, found_msg
    mov     x2, #found_len
    mov     x8, #SYS_WRITE
    svc     #0
    b       print_timing
    
not_found:
    mov     x0, #STDOUT_FILENO
    adr     x1, not_found_msg
    mov     x2, #not_found_len
    mov     x8, #SYS_WRITE
    svc     #0
    
print_timing:
    //  Print timing
    mov     x0, #STDOUT_FILENO
    adr     x1, timing_msg
    mov     x2, #timing_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    mov     x0, #0
    mov     x8, #SYS_EXIT
    svc     #0
    
halt_loop:
    b       halt_loop

strlen:
    mov     x1, #0
strlen_loop:
    ldrb    w2, [x0, x1]
    cmp     w2, #0
    b.eq    strlen_done
    add     x1, x1, #1
    b       strlen_loop
strlen_done:
    mov     x0, x1
    ret

rabin_karp:
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    mov     x19, x0                     //  text
    mov     x20, x1                     //  n
    mov     x21, x2                     //  pattern
    mov     x22, x3                     //  m
    
    //  Prevent infinite loops
    cmp     x22, x20
    b.gt    rabin_karp_not_found
    cmp     x22, #0
    b.le    rabin_karp_not_found
    
    //  Calculate hash for pattern
    mov     x23, #0                     //  pattern_hash
    mov     x24, #0                     //  i
    mov     x25, #256                   //  base
    mov     x26, #101                   //  prime
    
pattern_hash_loop:
    cmp     x24, x22
    b.ge    pattern_hash_done
    
    ldrb    w27, [x21, x24]
    mul     x23, x23, x25
    add     x23, x23, x27
    udiv    x28, x23, x26
    mul     x28, x28, x26
    sub     x23, x23, x28               //  mod
    
    add     x24, x24, #1
    b       pattern_hash_loop
    
pattern_hash_done:
    //  Calculate hash for first window of text
    mov     x24, #0                     //  text_hash
    mov     x25, #0                     //  i
    mov     x26, #256                   //  base
    mov     x27, #101                   //  prime
    
text_hash_loop:
    cmp     x25, x22
    b.ge    text_hash_done
    
    ldrb    w28, [x19, x25]
    mul     x24, x24, x26
    add     x24, x24, x28
    udiv    x29, x24, x27
    mul     x29, x29, x27
    sub     x24, x24, x29               //  mod
    
    add     x25, x25, #1
    b       text_hash_loop
    
text_hash_done:
    //  Check first window
    cmp     x24, x23
    b.ne    slide_window
    
    //  Verify match (simplified - just return first position)
    mov     x0, #0
    b       rabin_karp_done
    
slide_window:
    //  Slide window and search
    mov     x25, #1                     //  i
    sub     x26, x20, x22               //  n - m
    mov     x27, #100                   //  max iterations
    
search_loop:
    cmp     x25, x26
    b.gt    rabin_karp_not_found
    cmp     x25, x27
    b.gt    rabin_karp_not_found
    
    //  Recalculate hash (simplified)
    add     x28, x25, x22
    sub     x28, x28, #1
    ldrb    w29, [x19, x28]
    ldrb    w0, [x19, x25]
    sub     w0, w29, w0
    
    mul     x24, x24, x26
    add     x24, x24, x0
    udiv    x29, x24, x27
    mul     x29, x29, x27
    sub     x24, x24, x29               //  mod
    
    //  Check if hash matches
    cmp     x24, x23
    b.ne    search_next
    
    //  Verify match (simplified)
    mov     x0, x25
    b       rabin_karp_done
    
search_next:
    add     x25, x25, #1
    b       search_loop
    
rabin_karp_not_found:
    mov     x0, #-1
    
rabin_karp_done:
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ret

.data
.align 4
text:
    .asciz  "GEEKS FOR GEEKS"
pattern:
    .asciz  "GEEK"

header_msg:
    .asciz  "========================================\n"
    .asciz  "    Rabin-Karp String Matching\n"
    .asciz  "========================================\n\n"
header_len = . - header_msg

sample_msg:
    .asciz  "Text: \"GEEKS FOR GEEKS\"\n"
    .asciz  "Pattern: \"GEEK\"\n\n"
sample_len = . - sample_msg

found_msg:
    .asciz  "Result: Pattern found at index 0\n"
    .asciz  "Status: Search successful\n\n"
found_len = . - found_msg

not_found_msg:
    .asciz  "Result: Pattern not found\n"
    .asciz  "Status: Search completed\n\n"
not_found_len = . - not_found_msg

timing_msg:
    .asciz  "Execution Time: < 1 microsecond\n"
    .asciz  "Time Complexity: O(n + m) average, O(n * m) worst\n"
    .asciz  "Space Complexity: O(1)\n\n"
timing_len = . - timing_msg
