.text
//  Algorithms: Linear Search
//  Demonstrates linear search algorithm with timing and detailed output

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
    
    //  Test 1: Smallest numbers (range 1-10, size 5, randomized)
    mov     x0, #STDOUT_FILENO
    adr     x1, test1_msg
    mov     x2, #test1_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    mov     x0, #5
    mov     x1, #1
    mov     x2, #10
    mov     x3, #1
    bl      test_search
    
    //  Test 2: Median numbers (range 50-100, size 8, randomized)
    mov     x0, #STDOUT_FILENO
    adr     x1, test2_msg
    mov     x2, #test2_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    mov     x0, #8
    mov     x1, #50
    mov     x2, #100
    mov     x3, #42
    bl      test_search
    
    //  Test 3: Largest numbers (range 1000-2000, size 10, randomized)
    mov     x0, #STDOUT_FILENO
    adr     x1, test3_msg
    mov     x2, #test3_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    mov     x0, #10
    mov     x1, #1000
    movz    x2, #0xD007
    movk    x2, #0x0000, lsl #16
    mov     x3, #123
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
    //  x0 = size, x1 = min, x2 = max, x3 = seed
    mov     x19, x0
    mov     x20, x1
    mov     x21, x2
    mov     x22, x3
    
    //  Allocate array on stack
    mov     x23, x19
    lsl     x23, x23, #2
    add     x23, x23, #15
    and     x23, x23, #0xFFFFFFF0
    sub     sp, sp, x23
    mov     x24, sp
    
    //  Fill array with random numbers
    mov     x0, x24                     //  array pointer
    mov     x1, x19                     //  size
    mov     x2, x20                     //  min
    mov     x3, x21                     //  max
    mov     x4, x22                     //  seed
    bl      fill_random_array
    
    //  Generate random target value (use updated seed from x22)
    mov     x0, x20                     //  min
    mov     x1, x21                     //  max
    mov     x2, x22                     //  seed
    bl      random_in_range_simple
    mov     x25, x1                     //  target value
    
    mov     x20, x24                    //  array pointer
    mov     x21, x19                    //  size
    
    //  Print original array header
    mov     x0, #STDOUT_FILENO
    adr     x1, original_msg
    mov     x2, #original_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Allocate buffer
    sub     sp, sp, #80
    mov     x26, sp
    
    //  Print array values
    mov     x23, #0
print_original_loop:
    cmp     x23, x21
    b.ge    print_original_done
    
    ldr     w24, [x20, x23, lsl #2]
    mov     x0, x24
    mov     x1, x26
    bl      uint64_to_string
    mov     x27, x0
    
    mov     x0, #STDOUT_FILENO
    mov     x1, x26
    mov     x2, x27
    mov     x8, #SYS_WRITE
    svc     #0
    
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
    mov     x0, #STDOUT_FILENO
    adr     x1, closing_bracket
    mov     x2, #2
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Print target
    mov     x0, #STDOUT_FILENO
    adr     x1, target_msg
    mov     x2, #target_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    mov     x0, x25
    mov     x1, x26
    bl      uint64_to_string
    mov     x27, x0
    
    mov     x0, #STDOUT_FILENO
    mov     x1, x26
    mov     x2, x27
    mov     x8, #SYS_WRITE
    svc     #0
    
    mov     x0, #STDOUT_FILENO
    adr     x1, closing_bracket
    mov     x2, #2
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Deallocate buffer
    add     sp, sp, #80
    
    //  Get start time
    sub     sp, sp, #16
    mov     x0, #CLOCK_MONOTONIC
    mov     x1, sp
    mov     x8, #SYS_CLOCK_GETTIME
    svc     #0
    ldp     x23, x24, [sp]               //  start_sec, start_nsec
    add     sp, sp, #16
    
    //  Search
    mov     x0, x20
    mov     x1, x21
    mov     x2, x25
    bl      linear_search
    mov     x26, x0                      //  result index (-1 if not found)
    
    //  Get end time
    sub     sp, sp, #16
    mov     x0, #CLOCK_MONOTONIC
    mov     x1, sp
    mov     x8, #SYS_CLOCK_GETTIME
    svc     #0
    ldp     x27, x28, [sp]               //  end_sec, end_nsec
    add     sp, sp, #16
    
    //  Calculate elapsed time
    sub     x29, x27, x23                //  elapsed_sec
    cmp     x28, x24
    b.ge    no_borrow_search
    sub     x29, x29, #1
    movz    x0, #0xCA00
    movk    x0, #0x3B9A, lsl #16
    add     x28, x28, x0
no_borrow_search:
    sub     x28, x28, x24               //  elapsed_nsec
    
    //  Print result header
    mov     x0, #STDOUT_FILENO
    adr     x1, result_msg
    mov     x2, #result_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Allocate buffer
    sub     sp, sp, #80
    mov     x30, sp
    
    //  Print result index
    cmp     x26, #0
    b.lt    print_not_found
    mov     x0, x26
    mov     x1, x30
    bl      uint64_to_string
    mov     x27, x0
    
    mov     x0, #STDOUT_FILENO
    mov     x1, x30
    mov     x2, x27
    mov     x8, #SYS_WRITE
    svc     #0
    b       result_done_search
print_not_found:
    mov     x0, #STDOUT_FILENO
    adr     x1, not_found_text
    mov     x2, #not_found_text_len
    mov     x8, #SYS_WRITE
    svc     #0
result_done_search:
    mov     x0, #STDOUT_FILENO
    adr     x1, closing_bracket
    mov     x2, #2
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Deallocate buffer
    add     sp, sp, #80
    
    //  Print status
    mov     x0, #STDOUT_FILENO
    adr     x1, status_msg
    mov     x2, #status_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Print timing
    mov     x0, x29
    mov     x1, x28
    bl      print_time
    
    //  Deallocate array (x19 still holds size)
    mov     x0, x19
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

linear_search:
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    mov     x19, x0                      //  array
    mov     x20, x1                      //  size
    mov     x21, x2                      //  target
    
    mov     x22, #0                      //  i = 0
    movz    x23, #0x4240                 //  max iterations
    movk    x23, #0x000F, lsl #16
    
search_loop:
    cmp     x22, x20
    b.ge    search_not_found
    cmp     x22, x23
    b.ge    search_not_found
    
    ldr     w24, [x19, x22, lsl #2]
    cmp     w24, w21
    b.eq    search_found
    
    add     x22, x22, #1
    b       search_loop
    
search_found:
    mov     x0, x22
    b       search_done
    
search_not_found:
    mov     x0, #-1
    
search_done:
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ret

fill_random_array:
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    mov     x19, x0                      //  array
    mov     x20, x1                      //  size
    mov     x21, x2                      //  min
    mov     x22, x3                      //  max
    mov     x23, x4                      //  seed (will be updated)
    mov     x24, #0                      //  i = 0
    
fill_loop:
    cmp     x24, x20
    b.ge    fill_done
    
    //  LCG: seed = (seed * 1103515245 + 12345) & 0x7FFFFFFF
    movz    x0, #0x41C6
    movk    x0, #0x4E6D, lsl #16
    mul     x23, x23, x0
    movz    x0, #0x3039
    add     x23, x23, x0
    movz    x0, #0xFFFF
    movk    x0, #0x7FFF, lsl #16
    and     x23, x23, x0
    
    //  Calculate range and get value in range
    sub     x0, x22, x21
    add     x0, x0, #1
    udiv    x1, x23, x0
    mul     x1, x1, x0
    sub     x1, x23, x1
    add     x1, x1, x21
    
    //  Store in array
    str     w1, [x19, x24, lsl #2]
    
    add     x24, x24, #1
    b       fill_loop
    
fill_done:
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ret

random_in_range_simple:
    stp     x19, x20, [sp, #-16]!
    mov     x19, x0
    mov     x20, x1
    mov     x0, x2
    
    movz    x1, #0x41C6
    movk    x1, #0x4E6D, lsl #16
    mul     x0, x0, x1
    movz    x1, #0x3039
    add     x0, x0, x1
    movz    x1, #0xFFFF
    movk    x1, #0x7FFF, lsl #16
    and     x0, x0, x1
    
    sub     x1, x20, x19
    add     x1, x1, #1
    udiv    x2, x0, x1
    mul     x2, x2, x1
    sub     x2, x0, x2
    add     x1, x2, x19
    
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
header_msg:
    .asciz  "========================================\n"
    .asciz  "    Linear Search Algorithm\n"
    .asciz  "========================================\n"
header_len = . - header_msg

test1_msg:
    .asciz  "Test 1: Smallest Numbers (Randomized, range 1-10, size 5)\n"
test1_len = . - test1_msg

test2_msg:
    .asciz  "Test 2: Median Numbers (Randomized, range 50-100, size 8)\n"
test2_len = . - test2_msg

test3_msg:
    .asciz  "Test 3: Largest Numbers (Randomized, range 1000-2000, size 10)\n"
test3_len = . - test3_msg

original_msg:
    .asciz  "Original Array: ["
original_len = . - original_msg

target_msg:
    .asciz  "Target: ["
target_len = . - target_msg

result_msg:
    .asciz  "Result: Index = ["
result_len = . - result_msg

not_found_text:
    .asciz  "Not Found"
not_found_text_len = . - not_found_text

status_msg:
    .asciz  "Status: Successfully searched\n"
status_len = . - status_msg

closing_bracket:
    .asciz  "]\n"
comma_space:
    .asciz  ", "
newline:
    .asciz  "\n"

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
