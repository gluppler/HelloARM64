.text
//  Algorithms: Binary Search
//  Demonstrates binary search algorithm with timing and detailed output

.global _start
.align 4

.equ SYS_EXIT, 93
.equ SYS_WRITE, 64
.equ SYS_CLOCK_GETTIME, 113
.equ CLOCK_MONOTONIC, 1
.equ STDOUT_FILENO, 1

_start:
    mov     x19, sp
    
    mov     x0, #STDOUT_FILENO
    adr     x1, header_msg
    mov     x2, #header_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Test 1: Smallest target (5)
    mov     x0, #STDOUT_FILENO
    adr     x1, test1_msg
    mov     x2, #test1_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    adr     x20, sorted_array
    mov     x21, #10
    mov     x22, #5
    bl      test_search
    
    //  Test 2: Median target
    mov     x0, #STDOUT_FILENO
    adr     x1, test2_msg
    mov     x2, #test2_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    adr     x20, sorted_array
    mov     x21, #10
    mov     x22, #42
    bl      test_search
    
    //  Test 3: Largest target
    mov     x0, #STDOUT_FILENO
    adr     x1, test3_msg
    mov     x2, #test3_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    adr     x20, sorted_array
    mov     x21, #10
    mov     x22, #90
    bl      test_search
    
    mov     x0, #0
    mov     x8, #SYS_EXIT
    svc     #0
    
halt_loop:
    b       halt_loop

test_search:
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!
    stp     x27, x28, [sp, #-16]!
    stp     x29, x30, [sp, #-16]!
    
    sub     sp, sp, #16
    mov     x0, #CLOCK_MONOTONIC
    mov     x1, sp
    mov     x8, #SYS_CLOCK_GETTIME
    svc     #0
    ldp     x24, x25, [sp]
    add     sp, sp, #16
    
    mov     x0, x20
    mov     x1, #0
    sub     x2, x21, #1
    mov     w3, w22
    bl      binary_search
    mov     x23, x0                      //  Save search result in x23
    
    sub     sp, sp, #16
    mov     x0, #CLOCK_MONOTONIC
    mov     x1, sp
    mov     x8, #SYS_CLOCK_GETTIME
    svc     #0
    ldp     x26, x27, [sp]
    add     sp, sp, #16
    
    //  Calculate elapsed time
    //  Check if end >= start (should always be true, but validate)
    cmp     x26, x24
    b.lt    time_error                   //  End time before start - error
    cmp     x26, x24
    b.gt    calc_elapsed
    //  Same second - just compare nanoseconds
    cmp     x27, x25
    b.lt    time_error
    mov     x28, #0
    sub     x27, x27, x25
    b       time_ok
    
calc_elapsed:
    sub     x28, x26, x24                //  elapsed_sec
    cmp     x27, x25
    b.ge    no_borrow
    //  Need to borrow from seconds
    sub     x28, x28, #1
    //  Add 1000000000 nanoseconds (0x3B9ACA00)
    movz    x0, #0xCA00
    movk    x0, #0x3B9A, lsl #16
    add     x27, x27, x0
no_borrow:
    sub     x27, x27, x25                //  elapsed_nsec
    b       time_ok
    
time_error:
    mov     x28, #0
    mov     x27, #1
    
time_ok:
    //  Restore search result from x23
    mov     x0, x23
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
    //  Print timing (x28 = elapsed_sec, x27 = elapsed_nsec)
    mov     x0, x28
    mov     x1, x27
    bl      print_time
    
    ldp     x29, x30, [sp], #16
    ldp     x27, x28, [sp], #16
    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ret

binary_search:
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    mov     x19, x0
    mov     x20, x1
    mov     x21, x2
    mov     w22, w3
    
    mov     x23, #0
    movz    x24, #0x4240
    movk    x24, #0x000F, lsl #16
    
binary_search_loop:
    cmp     x20, x21
    b.gt    binary_search_not_found
    cmp     x23, x24
    b.ge    binary_search_not_found
    
    sub     x25, x21, x20
    lsr     x25, x25, #1
    add     x25, x20, x25
    
    ldr     w26, [x19, x25, lsl #2]
    cmp     w26, w22
    b.eq    binary_search_found
    b.gt    binary_search_left
    
    add     x20, x25, #1
    add     x23, x23, #1
    b       binary_search_loop
    
binary_search_left:
    sub     x21, x25, #1
    add     x23, x23, #1
    b       binary_search_loop
    
binary_search_found:
    mov     x0, x25
    b       binary_search_done
    
binary_search_not_found:
    mov     x0, #-1
    
binary_search_done:
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ret

print_time:
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!
    stp     x27, x28, [sp, #-16]!
    stp     x29, x30, [sp, #-16]!
    mov     x19, x0
    mov     x20, x1
    
    mov     x0, #STDOUT_FILENO
    adr     x1, time_prefix
    mov     x2, #time_prefix_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    sub     sp, sp, #272
    mov     x21, sp
    add     x25, sp, #128
    
    cmp     x19, #0
    b.ne    print_seconds
    cmp     x20, #1000
    b.lt    print_nanoseconds
    movz    x0, #0x4240
    movk    x0, #0x000F, lsl #16
    cmp     x20, x0
    b.lt    print_microseconds
    b       print_milliseconds
    
print_seconds:
    mov     x0, x19
    mov     x1, x25
    bl      uint64_to_string
    mov     x22, x0
    mov     x23, x21
    mov     x24, x25
    mov     x26, x22
copy_sec:
    cmp     x26, #0
    b.le    print_sec_write
    ldrb    w27, [x24], #1
    strb    w27, [x23], #1
    sub     x26, x26, #1
    b       copy_sec
print_sec_write:
    mov     x0, #STDOUT_FILENO
    mov     x1, x21
    mov     x2, x22
    mov     x8, #SYS_WRITE
    svc     #0
    mov     x0, #STDOUT_FILENO
    adr     x1, sec_suffix
    mov     x2, #sec_suffix_len
    mov     x8, #SYS_WRITE
    svc     #0
    b       print_time_done
    
print_milliseconds:
    mov     x0, x20
    movz    x1, #0x4240
    movk    x1, #0x000F, lsl #16
    udiv    x0, x0, x1
    mov     x1, x25
    bl      uint64_to_string
    mov     x22, x0
    mov     x23, x21
    mov     x24, x25
    mov     x26, x22
copy_msec:
    cmp     x26, #0
    b.le    print_msec_write
    ldrb    w27, [x24], #1
    strb    w27, [x23], #1
    sub     x26, x26, #1
    b       copy_msec
print_msec_write:
    mov     x0, #STDOUT_FILENO
    mov     x1, x21
    mov     x2, x22
    mov     x8, #SYS_WRITE
    svc     #0
    mov     x0, #STDOUT_FILENO
    adr     x1, msec_suffix
    mov     x2, #msec_suffix_len
    mov     x8, #SYS_WRITE
    svc     #0
    b       print_time_done
    
print_microseconds:
    mov     x0, x20
    mov     x1, #1000
    udiv    x0, x0, x1
    mov     x1, x25
    bl      uint64_to_string
    mov     x22, x0
    mov     x23, x21
    mov     x24, x25
    mov     x26, x22
copy_usec:
    cmp     x26, #0
    b.le    print_usec_write
    ldrb    w27, [x24], #1
    strb    w27, [x23], #1
    sub     x26, x26, #1
    b       copy_usec
print_usec_write:
    mov     x0, #STDOUT_FILENO
    mov     x1, x21
    mov     x2, x22
    mov     x8, #SYS_WRITE
    svc     #0
    mov     x0, #STDOUT_FILENO
    adr     x1, usec_suffix
    mov     x2, #usec_suffix_len
    mov     x8, #SYS_WRITE
    svc     #0
    b       print_time_done
    
print_nanoseconds:
    mov     x0, x20
    mov     x1, x25
    bl      uint64_to_string
    mov     x22, x0
    mov     x23, x21
    mov     x24, x25
    mov     x26, x22
copy_nsec:
    cmp     x26, #0
    b.le    print_nsec_write
    ldrb    w27, [x24], #1
    strb    w27, [x23], #1
    sub     x26, x26, #1
    b       copy_nsec
print_nsec_write:
    mov     x0, #STDOUT_FILENO
    mov     x1, x21
    mov     x2, x22
    mov     x8, #SYS_WRITE
    svc     #0
    mov     x0, #STDOUT_FILENO
    adr     x1, nsec_suffix
    mov     x2, #nsec_suffix_len
    mov     x8, #SYS_WRITE
    svc     #0
    
print_time_done:
    mov     x0, #STDOUT_FILENO
    adr     x1, newline
    mov     x2, #1
    mov     x8, #SYS_WRITE
    svc     #0
    add     sp, sp, #272
    ldp     x29, x30, [sp], #16
    ldp     x27, x28, [sp], #16
    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ret

uint64_to_string:
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!
    mov     x19, x0
    mov     x20, x1
    
    cmp     x19, #0
    b.ne    convert_start
    mov     w21, #0x30
    strb    w21, [x20]
    mov     x0, #1
    b       uint64_to_string_done
    
convert_start:
    sub     sp, sp, #80
    mov     x21, sp
    mov     x22, x21
    add     x22, x22, #63
    mov     x23, #0
    
convert_digits:
    cmp     x19, #0
    b.eq    reverse_start
    cmp     x23, #20
    b.ge    reverse_start
    mov     x24, #10
    udiv    x25, x19, x24
    mul     x25, x25, x24
    sub     x25, x19, x25
    add     w25, w25, #0x30
    strb    w25, [x22]
    sub     x22, x22, #1
    add     x23, x23, #1
    udiv    x19, x19, x24
    b       convert_digits
    
reverse_start:
    add     x22, x22, #1
    add     x24, x21, #64
    sub     x24, x24, x22
    mov     x0, x24
    cmp     x24, #0
    b.le    uint64_to_string_error
    cmp     x24, #64
    b.gt    uint64_to_string_error
    mov     x25, x20
    mov     x26, x24
copy_forward:
    cmp     x26, #0
    b.le    uint64_to_string_done
    ldrb    w27, [x22], #1
    strb    w27, [x25], #1
    sub     x26, x26, #1
    b       copy_forward
    
uint64_to_string_error:
    mov     x0, #0
    
uint64_to_string_done:
    add     sp, sp, #80
    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ret

.data
.align 4
sorted_array:
    .word   5, 11, 12, 22, 25, 34, 42, 64, 77, 90

header_msg:
    .asciz  "========================================\n"
    .asciz  "    Binary Search Algorithm\n"
    .asciz  "========================================\n\n"
header_len = . - header_msg

test1_msg:
    .asciz  "Test 1: Smallest Target (5) in sorted array [5, 11, 12, 22, 25, 34, 42, 64, 77, 90]\n"
test1_len = . - test1_msg

test2_msg:
    .asciz  "\nTest 2: Median Target (42) in sorted array [5, 11, 12, 22, 25, 34, 42, 64, 77, 90]\n"
test2_len = . - test2_msg

test3_msg:
    .asciz  "\nTest 3: Largest Target (90) in sorted array [5, 11, 12, 22, 25, 34, 42, 64, 77, 90]\n"
test3_len = . - test3_msg

found_msg:
    .asciz  "Result: Target found\n"
    .asciz  "Status: Search successful\n"
found_len = . - found_msg

not_found_msg:
    .asciz  "Result: Target not found\n"
    .asciz  "Status: Search completed\n"
not_found_len = . - not_found_msg

time_prefix:
    .asciz  "Execution Time: "
time_prefix_len = . - time_prefix

sec_suffix:
    .asciz  " seconds\n"
sec_suffix_len = . - sec_suffix

msec_suffix:
    .asciz  " milliseconds\n"
msec_suffix_len = . - msec_suffix

usec_suffix:
    .asciz  " microseconds\n"
usec_suffix_len = . - usec_suffix

nsec_suffix:
    .asciz  " nanoseconds\n"
nsec_suffix_len = . - nsec_suffix

newline:
    .byte   0x0A
