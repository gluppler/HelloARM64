# ARM64 Linux Syscalls Cheatsheet

Quick reference for Linux system calls on ARM64 (AArch64).

## Syscall Convention (Linux)

```asm
// Syscall number in x8
// Arguments in x0-x7 (up to 8 arguments)
// Return value in x0
// Use 'svc #0' to invoke

mov     x0, #arg1        // First argument
mov     x1, #arg2        // Second argument
mov     x8, #syscall_num // Syscall number
svc     #0               // Invoke syscall
// Return value in x0
```

## Common Syscalls

### exit - Terminate Process
```asm
// int exit(int status);
mov     x0, #0           // status (exit code)
mov     x8, #93           // SYS_exit
svc     #0
halt_loop:
    b       halt_loop     // Prevent illegal instruction
```

### write - Write to File Descriptor
```asm
// ssize_t write(int fd, const void *buf, size_t count);
mov     x0, #1           // fd (1 = stdout)
adr     x1, message      // buf (address of message)
mov     x2, #14          // count (length of message)
mov     x8, #64          // SYS_write
svc     #0
// Returns: number of bytes written in x0, or -1 on error
```

### read - Read from File Descriptor
```asm
// ssize_t read(int fd, void *buf, size_t count);
mov     x0, #0           // fd (0 = stdin)
mov     x1, sp           // buf (stack buffer)
mov     x2, #16          // count (bytes to read)
mov     x8, #63          // SYS_read
svc     #0
// Returns: number of bytes read in x0, 0 on EOF, -1 on error
```

### open - Open File
```asm
// int open(const char *pathname, int flags, mode_t mode);
adr     x0, filename     // pathname
mov     x1, #0           // flags (O_RDONLY = 0)
mov     x2, #0           // mode (not used for O_RDONLY)
mov     x8, #56          // SYS_open
svc     #0
// Returns: file descriptor in x0, or -1 on error
```

### close - Close File Descriptor
```asm
// int close(int fd);
mov     x0, #3           // fd
mov     x8, #57          // SYS_close
svc     #0
// Returns: 0 on success, -1 on error
```

### lseek - Reposition File Offset
```asm
// off_t lseek(int fd, off_t offset, int whence);
mov     x0, #3           // fd
mov     x1, #0           // offset
mov     x2, #0           // whence (SEEK_SET = 0)
mov     x8, #62          // SYS_lseek
svc     #0
// Returns: new file offset in x0, or -1 on error
```

## Syscall Numbers Reference

| Syscall | Number | Description |
|---------|--------|-------------|
| `read` | 63 | Read from file descriptor |
| `write` | 64 | Write to file descriptor |
| `close` | 57 | Close file descriptor |
| `lseek` | 62 | Reposition file offset |
| `open` | 56 | Open file |
| `exit` | 93 | Terminate process |
| `exit_group` | 94 | Exit all threads |
| `brk` | 214 | Change data segment size |
| `mmap` | 222 | Map memory |
| `munmap` | 215 | Unmap memory |
| `mprotect` | 226 | Protect memory |
| `nanosleep` | 101 | Sleep for nanoseconds |
| `getpid` | 172 | Get process ID |
| `getuid` | 174 | Get user ID |
| `getgid` | 176 | Get group ID |

## File Descriptors

| FD | Description |
|----|-------------|
| 0 | stdin (standard input) |
| 1 | stdout (standard output) |
| 2 | stderr (standard error) |
| 3+ | Opened files |

## Open Flags

| Flag | Value | Description |
|------|-------|-------------|
| `O_RDONLY` | 0 | Read only |
| `O_WRONLY` | 1 | Write only |
| `O_RDWR` | 2 | Read and write |
| `O_CREAT` | 64 | Create if doesn't exist |
| `O_TRUNC` | 512 | Truncate to zero length |
| `O_APPEND` | 1024 | Append mode |

## Lseek Whence Values

| Value | Constant | Description |
|-------|----------|-------------|
| 0 | `SEEK_SET` | From beginning |
| 1 | `SEEK_CUR` | From current position |
| 2 | `SEEK_END` | From end |

## Error Handling Pattern

```asm
// Check syscall return value
mov     x0, #1           // fd = stdout
adr     x1, message      // buf
mov     x2, #14          // count
mov     x8, #64          // SYS_write
svc     #0

// Check for error (negative return value)
cmp     x0, #0
b.lt    handle_error     // Branch if error

// Check for partial write
cmp     x0, x2
b.ne    handle_partial   // Branch if partial write

// Success - continue
b       success

handle_error:
    // x0 contains negative error code
    // Handle error appropriately
    mov     x0, #1       // Exit with error
    mov     x8, #93
    svc     #0
    b       halt_loop

handle_partial:
    // Partial write occurred
    // May need to retry remaining data
    b       success

success:
    // Continue execution
```

## Complete Example: Write and Exit

```asm
.text
.global _start
.align 4

_start:
    // Write "Hello, World!\n" to stdout
    mov     x0, #1           // fd = stdout
    adr     x1, message      // buf = address of message
    mov     x2, #14          // count = length
    mov     x8, #64          // SYS_write
    svc     #0
    
    // Check for error
    cmp     x0, #0
    b.lt    error_exit
    
    // Exit with success
    mov     x0, #0           // exit code = 0
    mov     x8, #93          // SYS_exit
    svc     #0
    
halt_loop:
    b       halt_loop

error_exit:
    mov     x0, #1           // exit code = 1
    mov     x8, #93          // SYS_exit
    svc     #0
    b       halt_loop

.data
.align 4
message:
    .asciz  "Hello, World!\n"
```

## Notes

- **Always check return values** - syscalls can fail
- **Handle partial writes/reads** - may not transfer all requested bytes
- **Validate file descriptors** - ensure they're valid before use
- **Use halt_loop** after exit syscall to prevent illegal instructions
- **Error codes** are returned as negative values (e.g., -1 for error)
- **Syscall numbers** are architecture-specific (these are for Linux ARM64)
