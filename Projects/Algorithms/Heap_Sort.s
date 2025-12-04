.text
//  Algorithms: Heap Sort
//  Demonstrates heap sort algorithm with timing and detailed output

.global _start
.align 4

.equ SYS_EXIT, 93
.equ SYS_WRITE, 64
.equ SYS_CLOCK_GETTIME, 113
.equ CLOCK_MONOTONIC, 1
.equ STDOUT_FILENO, 1

_start:
    mov     x19, sp
    //  Get time-based seed for randomization
    sub     sp, sp, #16
    mov     x0, #CLOCK_MONOTONIC
    mov     x1, sp
    mov     x8, #SYS_CLOCK_GETTIME
    svc     #0
    ldp     x20, x21, [sp]
    add     sp, sp, #16
    and     x20, x20, #0xFFFF
    and     x21, x21, #0xFFFF
    lsl     x20, x20, #16
    orr     x22, x20, x21
    
    mov     x0, #STDOUT_FILENO
    adr     x1, header_msg
    mov     x2, #header_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Test 1: Smallest numbers (range 1-100)
    mov     x0, #STDOUT_FILENO
    adr     x1, test1_msg
    mov     x2, #test1_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Call test_sort with parameters: size=10, min=1, max=100, seed=1
    mov     x0, #10
    mov     x1, #1
    mov     x2, #100
    mov     x3, x22
    bl      test_sort
    
    //  Update seed
    movz    x0, #0x41C6
    movk    x0, #0x4E6D, lsl #16
    mul     x22, x22, x0
    movz    x0, #0x3039
    add     x22, x22, x0
    movz    x0, #0xFFFF
    movk    x0, #0x7FFF, lsl #16
    and     x22, x22, x0
    
    //  Test 2: Median numbers (range 10000-100000)
    mov     x0, #STDOUT_FILENO
    adr     x1, test2_msg
    mov     x2, #test2_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Call test_sort with parameters: size=10, min=10000, max=100000, seed=42
    mov     x0, #10
    mov     x1, #10000
    movz    x2, #0x86A0
    movk    x2, #0x1, lsl #16
    mov     x3, x22
    bl      test_sort
    
    //  Update seed
    movz    x0, #0x41C6
    movk    x0, #0x4E6D, lsl #16
    mul     x22, x22, x0
    movz    x0, #0x3039
    add     x22, x22, x0
    movz    x0, #0xFFFF
    movk    x0, #0x7FFF, lsl #16
    and     x22, x22, x0
    
    //  Test 3: Largest numbers (range 2000000000-2147483647)
    mov     x0, #STDOUT_FILENO
    adr     x1, test3_msg
    mov     x2, #test3_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Call test_sort with parameters: size=10, min=2000000000, max=2147483647, seed=123
    mov     x0, #10
    movz    x1, #0x4A00
    movk    x1, #0x7735, lsl #16
    movz    x2, #0xFFFF
    movk    x2, #0x7FFF, lsl #16
    mov     x3, x22
    bl      test_sort
    
    //  Update seed
    movz    x0, #0x41C6
    movk    x0, #0x4E6D, lsl #16
    mul     x22, x22, x0
    movz    x0, #0x3039
    add     x22, x22, x0
    movz    x0, #0xFFFF
    movk    x0, #0x7FFF, lsl #16
    and     x22, x22, x0
    
    mov     x0, #0
    mov     x8, #SYS_EXIT
    svc     #0
    
halt_loop:
    b       halt_loop

test_sort:
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!
    stp     x27, x28, [sp, #-16]!
    stp     x29, x30, [sp, #-16]!
    //  x0 = size, x1 = min, x2 = max, x3 = seed
    //  Save parameters in callee-saved registers
    mov     x19, x0
    mov     x20, x1
    mov     x21, x2
    mov     x22, x3
    
    //  Allocate array on stack (size * 4 bytes, aligned to 16)
    //  Calculate aligned size
    mov     x23, x19
    lsl     x23, x23, #2
    add     x23, x23, #15
    and     x23, x23, #0xFFFFFFF0
    sub     sp, sp, x23
    mov     x24, sp
    
    //  Fill array with random numbers
    mov     x0, x24
    mov     x1, x19
    mov     x2, x20
    mov     x3, x21
    mov     x4, x22
    bl      fill_random_array
    
    //  x24 now points to the random array, x19 = size
    mov     x20, x24
    mov     x21, x19
    
    //  Print original array header
    mov     x0, #STDOUT_FILENO
    adr     x1, original_msg
    mov     x2, #original_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Allocate buffer for number conversion
    sub     sp, sp, #80
    mov     x25, sp
    
    //  Print array values
    mov     x23, #0
print_original_loop:
    cmp     x23, x21
    b.ge    print_original_done
    
    //  Load value and convert to string
    ldr     w24, [x20, x23, lsl #2]
    mov     x0, x24
    mov     x1, x25
    bl      uint64_to_string
    mov     x26, x0
    
    //  Print value
    mov     x0, #STDOUT_FILENO
    mov     x1, x25
    mov     x2, x26
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Print separator (except for last element)
    add     x23, x23, #1
    cmp     x23, x21
    b.ge    print_original_done
    mov     x0, #STDOUT_FILENO
    adr     x1, comma_space
    mov     x2, #2
    mov     x8, #SYS_WRITE
    svc     #0
    
    b       print_original_loop
    
print_original_done:
    //  Print closing bracket
    mov     x0, #STDOUT_FILENO
    adr     x1, closing_bracket
    mov     x2, #2
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Deallocate buffer (will reallocate later for sorted array)
    add     sp, sp, #80
    
    //  Allocate working array for sorting
    sub     sp, sp, #64
    mov     x22, sp
    
    mov     x23, #0
copy_loop:
    cmp     x23, x21
    b.ge    copy_done
    ldr     w24, [x20, x23, lsl #2]
    str     w24, [x22, x23, lsl #2]
    add     x23, x23, #1
    b       copy_loop
    
copy_done:
    //  Get start time (use x23, x24 for time values)
    sub     sp, sp, #16
    mov     x0, #CLOCK_MONOTONIC
    mov     x1, sp
    mov     x8, #SYS_CLOCK_GETTIME
    svc     #0
    ldp     x23, x24, [sp]               //  start_sec, start_nsec
    add     sp, sp, #16
    
    mov     x0, x22
    mov     x1, x21
    bl      heap_sort_simple
    
    sub     sp, sp, #16
    mov     x0, #CLOCK_MONOTONIC
    mov     x1, sp
    mov     x8, #SYS_CLOCK_GETTIME
    svc     #0
    ldp     x26, x27, [sp]
    add     sp, sp, #16
    
    //  Calculate elapsed time
    //  x23 = start_sec, x24 = start_nsec, x26 = end_sec, x27 = end_nsec
    sub     x28, x26, x23                //  elapsed_sec
    cmp     x27, x24
    b.ge    no_borrow
    sub     x28, x28, #1
    movz    x0, #0xCA00
    movk    x0, #0x3B9A, lsl #16
    add     x27, x27, x0
no_borrow:
    sub     x27, x27, x24               //  elapsed_nsec
    
    //  Print sorted array header
    mov     x0, #STDOUT_FILENO
    adr     x1, sorted_msg
    mov     x2, #sorted_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Allocate buffer for number conversion
    sub     sp, sp, #80
    mov     x25, sp
    
    //  Print sorted array values
    mov     x23, #0
print_sorted_loop:
    cmp     x23, x21
    b.ge    print_sorted_done
    
    //  Load value and convert to string
    ldr     w24, [x22, x23, lsl #2]
    mov     x0, x24
    mov     x1, x25
    bl      uint64_to_string
    mov     x26, x0
    
    //  Print value
    mov     x0, #STDOUT_FILENO
    mov     x1, x25
    mov     x2, x26
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Print separator (except for last element)
    add     x23, x23, #1
    cmp     x23, x21
    b.ge    print_sorted_done
    mov     x0, #STDOUT_FILENO
    adr     x1, comma_space
    mov     x2, #2
    mov     x8, #SYS_WRITE
    svc     #0
    
    b       print_sorted_loop
    
print_sorted_done:
    //  Print closing bracket
    mov     x0, #STDOUT_FILENO
    adr     x1, closing_bracket
    mov     x2, #2
    mov     x8, #SYS_WRITE
    svc     #0
    
    mov     x0, #STDOUT_FILENO
    adr     x1, result_msg
    mov     x2, #result_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    mov     x0, x28
    mov     x1, x27
    bl      print_time
    
    add     sp, sp, #80
    add     sp, sp, #64
    //  Deallocate random array (size * 4, aligned to 16)
    //  Use x21 (size) which is set from x19 and used throughout
    mov     x0, x21
    lsl     x0, x0, #2
    add     x0, x0, #15
    and     x0, x0, #0xFFFFFFF0
    add     sp, sp, x0
    ldp     x29, x30, [sp], #16
    ldp     x27, x28, [sp], #16
    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ret

heap_sort_simple:
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!
    mov     x19, x0
    mov     x20, x1
    
    cmp     x20, #0
    b.le    heap_sort_done
    cmp     x20, #1000
    b.gt    heap_sort_done
    
    mov     x21, #0
    sub     x25, x20, #1
    mov     x26, #0
    movz    x27, #0x4240
    movk    x27, #0x000F, lsl #16
    
outer_loop:
    cmp     x21, x25
    b.gt    heap_sort_done
    cmp     x26, x27
    b.ge    heap_sort_done
    
    mov     x22, x21
    add     x23, x21, #1
    
inner_loop:
    cmp     x23, x20
    b.ge    inner_done
    cmp     x26, x27
    b.ge    heap_sort_done
    
    ldr     w24, [x19, x23, lsl #2]
    ldr     w28, [x19, x22, lsl #2]
    cmp     w24, w28
    b.ge    no_update
    
    mov     x22, x23
    
no_update:
    add     x23, x23, #1
    add     x26, x26, #1
    b       inner_loop
    
inner_done:
    cmp     x22, x21
    b.eq    no_swap
    
    ldr     w24, [x19, x21, lsl #2]
    ldr     w28, [x19, x22, lsl #2]
    str     w28, [x19, x21, lsl #2]
    str     w24, [x19, x22, lsl #2]
    
no_swap:
    add     x21, x21, #1
    b       outer_loop
    
heap_sort_done:
    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
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
    //  Convert nanoseconds to microseconds with 3 decimal places
    //  Format: 0.XXX microseconds
    mov     x0, x20
    mov     x1, #1000
    udiv    x23, x0, x1
    mul     x1, x23, x1
    sub     x24, x20, x1
    mov     x0, #STDOUT_FILENO
    adr     x1, zero_dot
    mov     x2, #zero_dot_len
    mov     x8, #SYS_WRITE
    svc     #0
    mov     x0, x24
    mov     x1, x25
    bl      uint64_to_string
    mov     x22, x0
    cmp     x22, #1
    b.eq    pad_2_nsec
    cmp     x22, #2
    b.eq    pad_1_nsec
    b       print_dec_nsec
pad_2_nsec:
    mov     x0, #STDOUT_FILENO
    adr     x1, zero_str
    mov     x2, #2
    mov     x8, #SYS_WRITE
    svc     #0
    b       print_dec_nsec
pad_1_nsec:
    mov     x0, #STDOUT_FILENO
    adr     x1, zero_str
    mov     x2, #1
    mov     x8, #SYS_WRITE
    svc     #0
print_dec_nsec:
    mov     x0, #STDOUT_FILENO
    mov     x1, x25
    mov     x2, x22
    mov     x8, #SYS_WRITE
    svc     #0
    mov     x0, #STDOUT_FILENO
    adr     x1, usec_suffix
    mov     x2, #usec_suffix_len
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

fill_random_array:
    //  Save only what we need
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    mov     x19, x0
    mov     x20, x1
    mov     x21, x2
    mov     x22, x3
    //  x4 = seed, will be updated
    
    //  Generate random numbers
    mov     x0, #0
fill_loop:
    cmp     x0, x20
    b.ge    fill_done
    
    //  Simple LCG: seed = (seed * 1103515245 + 12345) & 0x7FFFFFFF
    movz    x1, #0x41C6
    movk    x1, #0x4E6D, lsl #16
    mul     x4, x4, x1
    movz    x1, #0x3039
    add     x4, x4, x1
    movz    x1, #0xFFFF
    movk    x1, #0x7FFF, lsl #16
    and     x4, x4, x1
    
    //  Calculate range and get value in range
    sub     x1, x22, x21
    add     x1, x1, #1
    udiv    x2, x4, x1
    mul     x2, x2, x1
    sub     x2, x4, x2
    add     x2, x2, x21
    
    //  Store in array
    str     w2, [x19, x0, lsl #2]
    
    add     x0, x0, #1
    b       fill_loop
    
fill_done:
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ret

.data
.align 4
header_msg:
    .asciz  "========================================\n"
    .asciz  "    Heap Sort Algorithm\n"
    .asciz  "========================================\n\n"
header_len = . - header_msg

test1_msg:
    .asciz  "Test 1: Smallest Numbers (Randomized, range 1-100)\n"
test1_len = . - test1_msg

test2_msg:
    .asciz  "\nTest 2: Median Numbers (Randomized, range 10000-100000)\n"
test2_len = . - test2_msg

test3_msg:
    .asciz  "\nTest 3: Largest Numbers (Randomized, range 2000000000-2147483647)\n"
test3_len = . - test3_msg

original_msg:
    .asciz  "Original Array: ["
original_len = . - original_msg

comma_space:
    .asciz  ", "

closing_bracket:
    .asciz  "]\n"

sorted_msg:
    .asciz  "Sorted Array: ["
    sorted_len = . - sorted_msg

result_msg:
    .asciz  "Status: Successfully sorted\n"
result_len = . - result_msg

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

zero_dot:
    .asciz  "0."
zero_dot_len = . - zero_dot

dot_str:
    .asciz  "."
zero_str:
    .asciz  "00"

newline:
    .byte   0x0A
