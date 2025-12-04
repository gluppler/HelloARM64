.text
//  Algorithms: Fibonacci Sequence
//  Demonstrates Fibonacci calculation with timing and detailed output

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
    
    //  Test 1: Smallest number (n = 5)
    mov     x0, #STDOUT_FILENO
    adr     x1, test1_msg
    mov     x2, #test1_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    mov     x0, #5
    bl      test_fibonacci
    
    //  Test 2: Median number (n = 20)
    mov     x0, #STDOUT_FILENO
    adr     x1, test2_msg
    mov     x2, #test2_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    mov     x0, #20
    bl      test_fibonacci
    
    //  Test 3: Largest number (n = 40)
    mov     x0, #STDOUT_FILENO
    adr     x1, test3_msg
    mov     x2, #test3_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    mov     x0, #40
    bl      test_fibonacci
    
    mov     x0, #0
    mov     x8, #SYS_EXIT
    svc     #0
    
halt_loop:
    b       halt_loop

test_fibonacci:
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!
    stp     x27, x28, [sp, #-16]!
    stp     x29, x30, [sp, #-16]!
    mov     x19, x0                     //  n
    
    //  Print input header
    mov     x0, #STDOUT_FILENO
    adr     x1, input_msg
    mov     x2, #input_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Allocate buffer for number conversion
    sub     sp, sp, #80
    mov     x25, sp
    
    //  Print n value
    mov     x0, x19
    mov     x1, x25
    bl      uint64_to_string
    mov     x26, x0
    
    mov     x0, #STDOUT_FILENO
    mov     x1, x25
    mov     x2, x26
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
    
    //  Calculate Fibonacci
    mov     x0, x19
    bl      fibonacci
    mov     x20, x0                      //  Save result
    
    //  Get end time
    sub     sp, sp, #16
    mov     x0, #CLOCK_MONOTONIC
    mov     x1, sp
    mov     x8, #SYS_CLOCK_GETTIME
    svc     #0
    ldp     x26, x27, [sp]               //  end_sec, end_nsec
    add     sp, sp, #16
    
    //  Calculate elapsed time
    //  x23 = start_sec, x24 = start_nsec, x26 = end_sec, x27 = end_nsec
    sub     x28, x26, x23                //  elapsed_sec
    cmp     x27, x24
    b.ge    no_borrow_fib
    sub     x28, x28, #1
    //  Add 1000000000 (0x3B9ACA00)
    movz    x0, #0xCA00
    movk    x0, #0x3B9A, lsl #16
    add     x27, x27, x0
no_borrow_fib:
    sub     x27, x27, x24               //  elapsed_nsec
    
    //  Print result header
    mov     x0, #STDOUT_FILENO
    adr     x1, result_msg
    mov     x2, #result_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Allocate buffer for number conversion
    sub     sp, sp, #80
    mov     x25, sp
    
    //  Print result value
    mov     x0, x20
    mov     x1, x25
    bl      uint64_to_string
    mov     x26, x0
    
    mov     x0, #STDOUT_FILENO
    mov     x1, x25
    mov     x2, x26
    mov     x8, #SYS_WRITE
    svc     #0
    
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

fibonacci:
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    mov     x19, x0
    
    //  Validate input
    cmp     x19, #0
    b.lt    fibonacci_error
    cmp     x19, #100
    b.gt    fibonacci_error
    
    //  Base cases
    cmp     x19, #0
    b.eq    fibonacci_zero
    cmp     x19, #1
    b.eq    fibonacci_one
    
    //  Iterative calculation
    mov     x20, #0                      //  fib(0)
    mov     x21, #1                      //  fib(1)
    mov     x22, #2                      //  i = 2
    
fibonacci_iter:
    cmp     x22, x19
    b.gt    fibonacci_done_loop
    
    add     x23, x20, x21                //  fib(i) = fib(i-2) + fib(i-1)
    mov     x20, x21
    mov     x21, x23
    
    add     x22, x22, #1
    b       fibonacci_iter
    
fibonacci_done_loop:
    mov     x0, x21
    b       fibonacci_done
    
fibonacci_zero:
    mov     x0, #0
    b       fibonacci_done
    
fibonacci_one:
    mov     x0, #1
    b       fibonacci_done
    
fibonacci_error:
    mov     x0, #0
    
fibonacci_done:
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
header_msg:
    .asciz  "========================================\n"
    .asciz  "    Fibonacci Sequence Algorithm\n"
    .asciz  "========================================\n"
header_len = . - header_msg

test1_msg:
    .asciz  "Test 1: Smallest Number (n = 5)\n"
test1_len = . - test1_msg

test2_msg:
    .asciz  "Test 2: Median Number (n = 20)\n"
test2_len = . - test2_msg

test3_msg:
    .asciz  "Test 3: Largest Number (n = 40)\n"
test3_len = . - test3_msg

input_msg:
    .asciz  "Input: n = ["
input_len = . - input_msg

result_msg:
    .asciz  "Result: Fibonacci(n) = ["
result_len = . - result_msg

status_msg:
    .asciz  "Status: Successfully calculated\n"
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
