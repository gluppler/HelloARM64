
.text
//  Fundamentals/07_System_Calls.s
//  System Calls: macOS and Linux syscalls
//  SECURITY: Validate all syscall parameters, check return values

.global _start
.align 4

_start:
    //  ============================================
    //  SYSTEM CALL OVERVIEW
    //  ============================================
    //  Syscall number in x8 (Linux) or x16 (macOS)
    //  Arguments in x0-x7
    //  Return value in x0
    //  Use 'svc #0' to invoke syscall

    //  Halt loop (should never reach here, but prevents illegal instruction)
    
    //  ============================================
    //  macOS SYSTEM CALLS
    //  ============================================
    //  macOS uses x16 for syscall number
    //  Syscall numbers: 0x2000000 + BSD syscall number
    
    //  --- write(fd, buf, count) ---
    //  Syscall number: 0x2000004 (write = 4)
    mov     x0, #1                   //  fd = stdout
    adr     x1, message              //  Load address of message (works on both Linux and macOS)
    mov     x2, #14                  //  count = length of "Hello, World!\n"
    mov     x8, #64                  //  Linux write syscall (SYS_write)
    svc     #0                       //  Invoke syscall

    //  Halt loop (should never reach here, but prevents illegal instruction)
    //  Return value in x0: number of bytes written, or -1 on error
    
    //  Check for error
    cmp     x0, #0
    b.lt    syscall_error            //  Branch if error (negative return)
    
    //  --- read(fd, buf, count) ---
    //  Syscall number: 0x2000003 (read = 3)
    //  NOTE: Commented out to prevent blocking in non-interactive environments
    //  This is a demonstration - in production, use non-blocking I/O or handle blocking appropriately
    //  sub     sp, sp, #16              //  Allocate buffer on stack
    //  mov     x0, #0                   //  fd = stdin
    //  mov     x1, sp                   //  buf = stack buffer
    //  mov     x2, #16                  //  count = 16 bytes
    //  mov     x8, #63                  //  Linux read syscall (SYS_read)
    //  svc     #0
    //  add     sp, sp, #16              //  Deallocate buffer
    
    //  --- exit(status) ---
    //  Syscall number: 0x2000001 (exit = 1)
    mov     x0, #0                   //  status = 0 (success)
    mov     x8, #93                  //  Linux exit syscall (SYS_exit)
    svc     #0

    //  Halt loop (should never reach here, but prevents illegal instruction)
    b       halt_loop
    //  Does not return
    
    //  ============================================
    //  LINUX SYSTEM CALLS
    //  ============================================
    //  Linux uses x8 for syscall number
    //  Syscall numbers: See /usr/include/asm/unistd.h
    
linux_syscalls:
    //  --- write(fd, buf, count) ---
    //  Syscall number: 64 (SYS_write)
    mov     x0, #1                   //  fd = stdout
    adr     x1, message              //  Load address of message
    mov     x2, #14                  //  count
    mov     x8, #64                  //  Linux write syscall
    svc     #0
    
    //  --- read(fd, buf, count) ---
    //  Syscall number: 63 (SYS_read)
    sub     sp, sp, #16
    mov     x0, #0                   //  fd = stdin
    mov     x1, sp                   //  buf
    mov     x2, #16                  //  count
    mov     x8, #63                  //  Linux read syscall
    svc     #0
    
    add     sp, sp, #16
    
    //  --- exit(status) ---
    //  Syscall number: 93 (SYS_exit)
    mov     x0, #0                   //  status
    mov     x8, #93                  //  Linux exit syscall
    svc     #0
    
    //  ============================================
    //  COMMON SYSTEM CALLS
    //  ============================================
    
    //  --- open(pathname, flags, mode) ---
    //  macOS: 0x2000005, Linux: 56
    adr     x0, filename             //  pathname
    mov     x1, #0                   //  flags: O_RDONLY
    mov     x2, #0                   //  mode (not used for O_RDONLY)
    //  Set syscall number based on platform
    //  movz    x16, #0x0005            //  macOS
    //  mov     x8, #56                //  Linux
    //  svc     #0
    //  Return: file descriptor in x0, or -1 on error
    
    //  --- close(fd) ---
    //  macOS: 0x2000006, Linux: 57
    mov     x0, #3                   //  fd
    //  movz    x16, #0x0006            //  macOS
    //  mov     x8, #57                //  Linux
    //  svc     #0
    //  Return: 0 on success, -1 on error
    
    //  --- lseek(fd, offset, whence) ---
    //  macOS: 0x20000C7, Linux: 62
    mov     x0, #3                   //  fd
    mov     x1, #0                   //  offset
    mov     x2, #0                   //  whence: SEEK_SET
    //  Set syscall number
    //  svc     #0
    //  Return: new file offset, or -1 on error
    
    //  ============================================
    //  ERROR HANDLING
    //  ============================================
    
    //  Check syscall return value
    mov     x0, #1
    adr     x1, message              //  Load address of message
    mov     x2, #14
    mov     x8, #64                  //  Linux write syscall (SYS_write)
    svc     #0
    
    //  Validate return value
    cmp     x0, #0
    b.lt    handle_error             //  Error if negative
    cmp     x0, x2
    b.ne    handle_partial_write     //  Partial write if less than requested
    
    b       syscall_success
    
handle_error:
    //  Error occurred, x0 contains error code (negative)
    //  Invert to get positive error number
    neg     x0, x0
    //  Handle error appropriately
    b       exit_with_error
    
handle_partial_write:
    //  Partial write occurred
    //  May need to retry writing remaining data
    b       syscall_success
    
syscall_error:
    //  Generic syscall error handler
    mov     x0, #1                   //  Exit with error code
    mov     x8, #93                  //  Linux exit syscall (SYS_exit)
    svc     #0
    
syscall_success:
exit_with_error:
    //  ============================================
    //  SECURITY PRACTICES
    //  ============================================
    //  1. Always validate syscall parameters
    //  2. Check return values for errors
    //  3. Validate file descriptors before use
    //  4. Check buffer bounds before read/write
    //  5. Use appropriate file permissions
    //  6. Handle partial writes/reads
    //  7. Clear sensitive data from buffers
    
    //  Clear sensitive buffer
    sub     sp, sp, #16
    mov     x0, xzr
    stp     x0, x0, [sp]             //  Zero buffer
    add     sp, sp, #16
    
    //  Exit
    mov     x0, #0
    mov     x8, #93                  //  Linux exit syscall (SYS_exit)
    svc     #0
    
    //  Halt loop (should never reach here, but prevents illegal instruction)
halt_loop:
    b       halt_loop

.data
.align 4
message:
    .asciz  "Hello, World!\n"
filename:
    .asciz  "test.txt"
