.text
//  Algorithms: Prime Number Check
//  Demonstrates prime checking with timing and detailed output

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
    orr     x22, x20, x21                  //  x22 = initial seed
    
    //  Print header
    mov     x0, #STDOUT_FILENO
    adr     x1, header_msg
    mov     x2, #header_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Test 1: Smallest numbers (range 2-10, randomized)
    mov     x0, #STDOUT_FILENO
    adr     x1, test1_msg
    mov     x2, #test1_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    mov     x0, #2
    mov     x1, #10
    mov     x2, x22
    bl      random_in_range_simple
    mov     x22, x2                        //  Update seed
    mov     x0, x1
    bl      test_prime
    
    //  Test 2: Median numbers (range 50-100, randomized)
    mov     x0, #STDOUT_FILENO
    adr     x1, test2_msg
    mov     x2, #test2_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    mov     x0, #50
    mov     x1, #100
    mov     x2, x22
    bl      random_in_range_simple
    mov     x22, x2                        //  Update seed
    mov     x0, x1
    bl      test_prime
    
    //  Test 3: Largest numbers (range 1000-2000, randomized)
    mov     x0, #STDOUT_FILENO
    adr     x1, test3_msg
    mov     x2, #test3_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    mov     x0, #1000
    movz    x1, #0xD007
    movk    x1, #0x0000, lsl #16
    mov     x2, x22
    bl      random_in_range_simple
    mov     x0, x1
    bl      test_prime
    
    mov     x0, #0
    mov     x8, #SYS_EXIT
    svc     #0
    
halt_loop:
    b       halt_loop

test_prime:
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
    
    //  Check if prime
    mov     x0, x19
    bl      is_prime
    mov     x20, x0                      //  Save result (1 = prime, 0 = not prime)
    
    //  Get end time
    sub     sp, sp, #16
    mov     x0, #CLOCK_MONOTONIC
    mov     x1, sp
    mov     x8, #SYS_CLOCK_GETTIME
    svc     #0
    ldp     x26, x27, [sp]               //  end_sec, end_nsec
    add     sp, sp, #16
    
    //  Calculate elapsed time
    //  Validate: end >= start
    cmp     x26, x23
    b.lt    time_error_prime
    b.gt    calc_elapsed_prime
    //  Same second - compare nanoseconds
    cmp     x27, x24
    b.lt    time_error_prime
    mov     x28, #0
    sub     x27, x27, x24
    b       time_ok_prime
    
calc_elapsed_prime:
    sub     x28, x26, x23                //  elapsed_sec
    cmp     x27, x24
    b.ge    no_borrow_prime
    cmp     x28, #0
    b.le    time_error_prime
    sub     x28, x28, #1
    movz    x0, #0xCA00
    movk    x0, #0x3B9A, lsl #16
    add     x27, x27, x0
no_borrow_prime:
    sub     x27, x27, x24               //  elapsed_nsec
    //  Sanity check: elapsed time should be reasonable (< 10 seconds for prime check)
    cmp     x28, #10
    b.ge    time_error_prime
    b       time_ok_prime
    
time_error_prime:
    mov     x28, #0
    mov     x27, #1                      //  Default to 1 nanosecond on error
    
time_ok_prime:
    
    //  Print result header
    mov     x0, #STDOUT_FILENO
    adr     x1, result_msg
    mov     x2, #result_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Print result based on is_prime return value
    cmp     x20, #1
    b.eq    print_prime
    mov     x0, #STDOUT_FILENO
    adr     x1, not_prime_text
    mov     x2, #not_prime_text_len
    mov     x8, #SYS_WRITE
    svc     #0
    b       result_done
print_prime:
    mov     x0, #STDOUT_FILENO
    adr     x1, prime_text
    mov     x2, #prime_text_len
    mov     x8, #SYS_WRITE
    svc     #0
result_done:
    mov     x0, #STDOUT_FILENO
    adr     x1, closing_bracket
    mov     x2, #2
    mov     x8, #SYS_WRITE
    svc     #0
    
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

is_prime:
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    mov     x19, x0
    
    //  Validate input
    cmp     x19, #0
    b.le    is_prime_false
    movz    x24, #0x86A0
    movk    x24, #0x0000, lsl #16
    cmp     x19, x24
    b.gt    is_prime_false
    
    //  Special cases
    cmp     x19, #1
    b.eq    is_prime_false
    cmp     x19, #2
    b.eq    is_prime_true
    
    //  Check if even
    and     x20, x19, #1
    cmp     x20, #0
    b.eq    is_prime_false
    
    //  Check odd divisors from 3 to sqrt(n)
    mov     x20, #3
    mov     x22, #0                      //  iteration counter
    movz    x23, #0x4240                 //  max iterations = 1000000
    movk    x23, #0x000F, lsl #16
    
prime_loop:
    cmp     x22, x23
    b.ge    is_prime_true
    
    //  Check if i * i > n
    mul     x24, x20, x20
    cmp     x24, x19
    b.gt    is_prime_true
    
    //  Check if n % i == 0
    udiv    x24, x19, x20
    mul     x24, x24, x20
    sub     x24, x19, x24
    cmp     x24, #0
    b.eq    is_prime_false
    
    add     x20, x20, #2
    add     x22, x22, #1
    b       prime_loop
    
is_prime_true:
    mov     x0, #1
    b       is_prime_done
    
is_prime_false:
    mov     x0, #0
    
is_prime_done:
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
    and     x0, x0, x1                   //  x0 = new seed
    
    sub     x1, x20, x19
    add     x1, x1, #1
    udiv    x2, x0, x1
    mul     x2, x2, x1
    sub     x2, x0, x2
    add     x1, x2, x19                  //  x1 = result
    mov     x2, x0                      //  x2 = updated seed
    
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
    //  Format with 3 decimal places: X.XXX milliseconds
    //  x20 = nanoseconds
    mov     x0, x20
    movz    x1, #0x4240
    movk    x1, #0x000F, lsl #16              //  1000000
    udiv    x23, x0, x1                       //  whole milliseconds
    mul     x1, x23, x1
    sub     x24, x20, x1                      //  remainder nanoseconds (0-999999)
    mov     x1, #1000
    udiv    x24, x24, x1                      //  convert to microseconds (0-999)
    
    //  Print whole part
    mov     x0, x23
    mov     x1, x25
    bl      uint64_to_string
    mov     x22, x0
    
    mov     x0, #STDOUT_FILENO
    mov     x1, x25
    mov     x2, x22
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Print "."
    mov     x0, #STDOUT_FILENO
    adr     x1, dot_str
    mov     x2, #1
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Print 3 decimal digits
    mov     x0, x24
    mov     x1, x25
    bl      uint64_to_string
    mov     x22, x0
    
    //  Pad to 3 digits if needed
    cmp     x22, #1
    b.eq    pad_2_digits_msec_pc
    cmp     x22, #2
    b.eq    pad_1_digit_msec_pc
    b       print_decimal_msec_pc
    
pad_2_digits_msec_pc:
    mov     x0, #STDOUT_FILENO
    adr     x1, zero_str
    mov     x2, #2
    mov     x8, #SYS_WRITE
    svc     #0
    b       print_decimal_msec_pc
    
pad_1_digit_msec_pc:
    mov     x0, #STDOUT_FILENO
    adr     x1, zero_str
    mov     x2, #1
    mov     x8, #SYS_WRITE
    svc     #0
    
print_decimal_msec_pc:
    mov     x0, #STDOUT_FILENO
    mov     x1, x25
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
    .asciz  "    Prime Number Check Algorithm\n"
    .asciz  "========================================\n"
header_len = . - header_msg

test1_msg:
    .asciz  "Test 1: Smallest Numbers (Randomized, range 2-10)\n"
test1_len = . - test1_msg

test2_msg:
    .asciz  "Test 2: Median Numbers (Randomized, range 50-100)\n"
test2_len = . - test2_msg

test3_msg:
    .asciz  "Test 3: Largest Numbers (Randomized, range 1000-2000)\n"
test3_len = . - test3_msg

input_msg:
    .asciz  "Input: n = ["
input_len = . - input_msg

result_msg:
    .asciz  "Result: ["
result_len = . - result_msg

prime_text:
    .asciz  "Prime"
prime_text_len = . - prime_text

not_prime_text:
    .asciz  "Not Prime"
not_prime_text_len = . - not_prime_text

status_msg:
    .asciz  "Status: Successfully checked\n"
status_len = . - status_msg

closing_bracket:
    .asciz  "]\n"
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

zero_dot:
    .asciz  "0."
zero_dot_len = . - zero_dot

dot_str:
    .asciz  "."
zero_str:
    .asciz  "00"
