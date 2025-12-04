.text
//  Algorithms: Bubble Sort
//  Demonstrates bubble sort algorithm with timing and detailed output

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
    ldp     x20, x21, [sp]                //  x20 = seconds, x21 = nanoseconds
    add     sp, sp, #16
    
    //  Combine seconds and nanoseconds for seed
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
    
    //  Test 1: Smallest numbers (range 1-100)
    mov     x0, #STDOUT_FILENO
    adr     x1, test1_msg
    mov     x2, #test1_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Call test_sort with parameters: size=10, min=1, max=100, seed=time-based
    mov     x0, #10
    mov     x1, #1
    mov     x2, #100
    mov     x3, x22                       //  Use time-based seed
    bl      test_sort
    
    //  Update seed for next test (use a simple LCG step)
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
    
    //  Call test_sort with parameters: size=10, min=10000, max=100000, seed=updated
    mov     x0, #10
    mov     x1, #10000
    movz    x2, #0x86A0
    movk    x2, #0x1, lsl #16
    mov     x3, x22                       //  Use updated seed
    bl      test_sort
    
    //  Update seed for next test
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
    
    //  Call test_sort with parameters: size=10, min=2000000000, max=2147483647, seed=updated
    mov     x0, #10
    movz    x1, #0x4A00
    movk    x1, #0x7735, lsl #16
    movz    x2, #0xFFFF
    movk    x2, #0x7FFF, lsl #16
    mov     x3, x22                       //  Use updated seed
    bl      test_sort
    
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
    //  x19-x24 are already saved at function start, fill_random_array will preserve them
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
    
    //  Print array values (use array pointer x20, size in x21)
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
    
    //  Copy array to working array
    mov     x23, #0
copy_loop:
    cmp     x23, x21
    b.ge    copy_done
    ldr     w24, [x20, x23, lsl #2]
    str     w24, [x22, x23, lsl #2]
    add     x23, x23, #1
    b       copy_loop
copy_done:
    //  Get start time (save x24 first since it's the array pointer)
    //  x20 = array pointer, x21 = size, x22 = working array, x24 = original array (saved)
    //  Use x23, x24 for time values temporarily
    sub     sp, sp, #16
    mov     x0, #CLOCK_MONOTONIC
    mov     x1, sp
    mov     x8, #SYS_CLOCK_GETTIME
    svc     #0
    ldp     x23, x24, [sp]               //  start_sec, start_nsec (use x23, x24)
    add     sp, sp, #16
    
    //  Sort
    mov     x0, x22
    mov     x1, x21
    bl      bubble_sort
    
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
    b.ge    no_borrow
    sub     x28, x28, #1
    //  Add 1000000000 (0x3B9ACA00)
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
    
    //  Allocate buffer for number conversion (x25 was overwritten by time values)
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
    
    //  Deallocate buffer
    add     sp, sp, #80
    
    //  Print result
    mov     x0, #STDOUT_FILENO
    adr     x1, result_msg
    mov     x2, #result_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Print timing
    mov     x0, x28
    mov     x1, x27
    bl      print_time
    
    add     sp, sp, #64
    //  Deallocate random array (size * 4, aligned to 16)
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

bubble_sort:
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!
    mov     x19, x0
    mov     x20, x1
    
    //  Validate inputs
    cmp     x20, #0
    b.le    bubble_sort_done
    cmp     x20, #1000
    b.gt    bubble_sort_done
    
    mov     x21, #0                     //  i
    sub     x25, x20, #1                //  size - 1
    mov     x26, #0                     //  iteration counter
    movz    x27, #0x4240                //  max iterations = 1000000
    movk    x27, #0x000F, lsl #16
    
outer_loop:
    cmp     x21, x25
    b.gt    bubble_sort_done
    cmp     x26, x27
    b.ge    bubble_sort_done
    
    mov     x22, #0                     //  j
    sub     x23, x25, x21               //  size - i - 1
    
inner_loop:
    cmp     x22, x23
    b.ge    inner_done
    cmp     x26, x27
    b.ge    bubble_sort_done
    
    ldr     w24, [x19, x22, lsl #2]
    add     x28, x22, #1
    ldr     w29, [x19, x28, lsl #2]
    
    cmp     w24, w29
    b.le    no_swap
    
    str     w29, [x19, x22, lsl #2]
    str     w24, [x19, x28, lsl #2]
    
no_swap:
    add     x22, x22, #1
    add     x26, x26, #1
    b       inner_loop
    
inner_done:
    add     x21, x21, #1
    b       outer_loop
    
bubble_sort_done:
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
    mov     x19, x0                     //  seconds
    mov     x20, x1                     //  nanoseconds
    
    //  Print "Execution Time: "
    mov     x0, #STDOUT_FILENO
    adr     x1, time_prefix
    mov     x2, #time_prefix_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Allocate buffers (aligned to 16 bytes)
    sub     sp, sp, #272                //  256 + 16 for alignment
    mov     x21, sp                     //  number buffer
    add     x25, sp, #128               //  temp buffer
    
    //  Convert and print time
    cmp     x19, #0
    b.ne    print_seconds
    cmp     x20, #1000
    b.lt    print_nanoseconds
    //  Compare with 1000000
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
    
    //  Copy to output
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
    
    //  Copy to output
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
    //  Format with 3 decimal places: X.XXX microseconds
    //  x20 = nanoseconds
    mov     x0, x20
    mov     x1, #1000
    udiv    x23, x0, x1                     //  whole microseconds
    mul     x1, x23, x1
    sub     x24, x20, x1                    //  remainder nanoseconds (0-999)
    
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
    
    //  Print 3 decimal digits (remainder in nanoseconds, 0-999)
    mov     x0, x24
    mov     x1, x25
    bl      uint64_to_string
    mov     x22, x0
    
    //  Pad to 3 digits if needed
    cmp     x22, #1
    b.eq    pad_2_digits_usec
    cmp     x22, #2
    b.eq    pad_1_digit_usec
    b       print_decimal_usec
    
pad_2_digits_usec:
    mov     x0, #STDOUT_FILENO
    adr     x1, zero_str
    mov     x2, #2
    mov     x8, #SYS_WRITE
    svc     #0
    b       print_decimal_usec
    
pad_1_digit_usec:
    mov     x0, #STDOUT_FILENO
    adr     x1, zero_str
    mov     x2, #1
    mov     x8, #SYS_WRITE
    svc     #0
    
print_decimal_usec:
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
    b       print_time_done
    
print_nanoseconds:
    //  Convert nanoseconds to microseconds with 3 decimal places
    //  Format: 0.XXX microseconds
    //  x20 = nanoseconds
    //  Calculate: nanoseconds / 1000 = microseconds (with remainder)
    mov     x0, x20
    mov     x1, #1000
    udiv    x23, x0, x1                     //  whole microseconds (should be 0 for < 1000 nsec)
    mul     x1, x23, x1
    sub     x24, x20, x1                    //  remainder nanoseconds (0-999)
    
    //  Print "0."
    mov     x0, #STDOUT_FILENO
    adr     x1, zero_dot
    mov     x2, #zero_dot_len
    mov     x8, #SYS_WRITE
    svc     #0
    
    //  Convert remainder to 3-digit decimal (0-999)
    //  x24 has remainder in nanoseconds (0-999), we want it as 3 digits
    mov     x0, x24
    mov     x1, x25
    bl      uint64_to_string
    mov     x22, x0
    
    //  Pad to 3 digits if needed
    cmp     x22, #1
    b.eq    pad_2_digits
    cmp     x22, #2
    b.eq    pad_1_digit
    b       print_decimal
    
pad_2_digits:
    mov     x0, #STDOUT_FILENO
    adr     x1, zero_str
    mov     x2, #2
    mov     x8, #SYS_WRITE
    svc     #0
    b       print_decimal
    
pad_1_digit:
    mov     x0, #STDOUT_FILENO
    adr     x1, zero_str
    mov     x2, #1
    mov     x8, #SYS_WRITE
    svc     #0
    
print_decimal:
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
    
    //  Handle zero
    cmp     x19, #0
    b.ne    convert_start
    
    mov     w21, #0x30
    strb    w21, [x20]
    mov     x0, #1
    b       uint64_to_string_done
    
convert_start:
    //  Build string in reverse (aligned to 16 bytes)
    sub     sp, sp, #80                 //  64 + 16 for alignment
    mov     x21, sp                     //  temp buffer
    mov     x22, x21
    add     x22, x22, #63               //  Start from end
    
    mov     x23, #0                     //  digit count
    
convert_digits:
    cmp     x19, #0
    b.eq    reverse_start
    
    //  Limit to prevent infinite loops
    cmp     x23, #20
    b.ge    reverse_start
    
    mov     x24, #10
    udiv    x25, x19, x24
    mul     x25, x25, x24
    sub     x25, x19, x25               //  digit = num % 10
    add     w25, w25, #0x30
    
    strb    w25, [x22]
    sub     x22, x22, #1
    add     x23, x23, #1
    
    udiv    x19, x19, x24
    b       convert_digits
    
reverse_start:
    add     x22, x22, #1                //  Point to first digit
    //  Calculate length
    add     x24, x21, #64               //  End of buffer
    sub     x24, x24, x22               //  Length
    mov     x0, x24                     //  Return length
    
    //  Validate length
    cmp     x24, #0
    b.le    uint64_to_string_error
    cmp     x24, #64
    b.gt    uint64_to_string_error
    
    //  Copy to output buffer
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

//  Random number generator using Linear Congruential Generator (LCG)
//  x0 = seed (input/output)
//  Returns: x0 = random number (0 to 2^31-1)
random_lcg:
    //  LCG: seed = (seed * 1103515245 + 12345) mod 2^31
    //  Constants: a = 1103515245, c = 12345
    movz    x1, #0x41C6
    movk    x1, #0x4E6D, lsl #16
    mul     x0, x0, x1
    movz    x1, #0x3039
    add     x0, x0, x1
    //  Modulo 2^31: mask upper bit
    movz    x1, #0xFFFF
    movk    x1, #0x7FFF, lsl #16
    and     x0, x0, x1
    ret

//  Generate random number in range [min, max]
//  x0 = seed (input/output)
//  x1 = min
//  x2 = max
//  Returns: x0 = random number in range, x1 = updated seed
random_in_range:
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    mov     x19, x0
    mov     x20, x1
    mov     x21, x2
    
    //  Generate random number
    mov     x0, x19
    bl      random_lcg
    mov     x22, x0
    
    //  Calculate range
    sub     x21, x21, x20
    add     x21, x21, #1
    
    //  random % range
    udiv    x0, x22, x21
    mul     x0, x0, x21
    sub     x0, x22, x0
    
    //  Add min
    add     x0, x0, x20
    
    //  Return updated seed in x1
    mov     x1, x22
    
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ret

//  Fill array with random numbers (array already allocated)
//  x0 = array pointer
//  x1 = size
//  x2 = min value
//  x3 = max value
//  x4 = seed
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
    .asciz  "    Bubble Sort Algorithm\n"
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
