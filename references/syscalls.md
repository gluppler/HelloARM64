# System Calls Reference

Complete reference for ARM64 system calls on Linux and macOS.

**Source**: Linux kernel documentation, macOS system documentation, ARM64 ABI documentation

## System Call Overview

### Purpose
System calls provide the interface between user-space applications and the kernel. They allow programs to request services from the operating system.

### ARM64 System Call Convention
- **System call number**: X8 register
- **Arguments**: X0-X5 (up to 6 arguments)
- **Return value**: X0 (negative values indicate errors)
- **Instruction**: `SVC #0` (Supervisor Call)

**Reference**: Linux kernel documentation, ARM64 ABI

## Linux System Calls

### System Call Numbers
Common Linux system calls for ARM64:

- **0**: io_setup
- **1**: io_destroy
- **2**: io_submit
- **3**: io_cancel
- **4**: io_getevents
- **56**: openat
- **57**: close
- **58**: newfstatat
- **59**: fchmodat
- **60**: fchownat
- **61**: openat
- **62**: newfstatat
- **63**: readlinkat
- **64**: newfstatat
- **80**: read
- **81**: write
- **82**: openat
- **83**: close
- **93**: exit
- **94**: exit_group
- **103**: nanosleep
- **113**: clock_gettime
- **160**: uname
- **169**: gettimeofday
- **220**: clone
- **221**: execve

**Reference**: Linux kernel source, arch/arm64/include/uapi/asm/unistd.h

### Common Linux System Calls

#### exit (93)
```assembly
// Exit program with status code
MOV  X8, #93             // sys_exit
MOV  X0, #0               // exit status (0 = success)
SVC  #0                   // Make system call
```

#### write (64)
```assembly
// Write to file descriptor
// X0 = file descriptor (1 = stdout)
// X1 = buffer address
// X2 = buffer length
MOV  X8, #64              // sys_write
MOV  X0, #1                // stdout
ADR  X1, message           // buffer address
MOV  X2, #message_len      // buffer length
SVC  #0                    // Make system call
```

#### read (63)
```assembly
// Read from file descriptor
// X0 = file descriptor (0 = stdin)
// X1 = buffer address
// X2 = buffer length
MOV  X8, #63              // sys_read
MOV  X0, #0                // stdin
ADR  X1, buffer            // buffer address
MOV  X2, #buffer_size      // buffer size
SVC  #0                    // Make system call
// X0 = number of bytes read (or error if negative)
```

#### openat (56)
```assembly
// Open file
// X0 = directory file descriptor (AT_FDCWD = -100)
// X1 = pathname address
// X2 = flags
// X3 = mode (if O_CREAT)
MOV  X8, #56              // sys_openat
MOV  X0, #-100             // AT_FDCWD
ADR  X1, filename          // pathname
MOV  X2, #0                // O_RDONLY
MOV  X3, #0                // mode (not used)
SVC  #0                    // Make system call
// X0 = file descriptor (or error if negative)
```

#### close (57)
```assembly
// Close file descriptor
MOV  X8, #57              // sys_close
MOV  X0, #fd               // file descriptor
SVC  #0                    // Make system call
```

#### brk (214)
```assembly
// Change data segment size (heap allocation)
MOV  X8, #214             // sys_brk
MOV  X0, #new_brk          // new break address (0 to get current)
SVC  #0                    // Make system call
// X0 = new break address
```

#### clock_gettime (113)
```assembly
// Get current time with high resolution
// X0 = clock_id (1 = CLOCK_MONOTONIC, 0 = CLOCK_REALTIME)
// X1 = pointer to timespec structure (16 bytes: 8 bytes tv_sec, 8 bytes tv_nsec)
MOV  X8, #113             // sys_clock_gettime
MOV  X0, #1                // CLOCK_MONOTONIC (monotonic time, not affected by system clock changes)
ADR  X1, timespec          // Address of timespec structure
SVC  #0                    // Make system call
// Result stored in timespec structure at X1
// X0 = 0 on success, negative on error
```

**Reference**: Linux kernel documentation, POSIX clock_gettime(2)

### Error Handling

#### Error Return Values
- Negative values indicate errors
- Error code is -errno (e.g., -1 = EPERM, -2 = ENOENT)
- Use `NEG` instruction or compare with 0

```assembly
MOV  X8, #64              // sys_write
// ... set up arguments ...
SVC  #0                    // Make system call
CMP  X0, #0                // Check return value
B.LT error_handler         // Branch if error (negative)
```

## macOS System Calls

### macOS System Call Convention
- **System call number**: X16 register (not X8!)
- **Arguments**: X0-X7 (up to 8 arguments)
- **Return value**: X0
- **Instruction**: `SVC #0x80` (or `SVC #0`)

**Reference**: Apple Developer Documentation, macOS System Calls

### Common macOS System Calls

#### exit (1)
```assembly
// Exit program
MOV  X16, #1               // sys_exit (macOS uses X16)
MOV  X0, #0                // exit status
SVC  #0x80                 // Make system call (or SVC #0)
```

#### write (4)
```assembly
// Write to file descriptor
MOV  X16, #4               // sys_write
MOV  X0, #1                // stdout
ADR  X1, message           // buffer
MOV  X2, #message_len      // length
SVC  #0x80                 // Make system call
```

#### read (3)
```assembly
// Read from file descriptor
MOV  X16, #3               // sys_read
MOV  X0, #0                // stdin
ADR  X1, buffer            // buffer
MOV  X2, #buffer_size      // size
SVC  #0x80                 // Make system call
```

## System Call Wrapper Example

### Linux Hello World
```assembly
.section .data
message:
    .asciz "Hello, World!\n"
message_len = . - message - 1

.section .text
.global _start
_start:
    // Write message to stdout
    MOV  X8, #64           // sys_write
    MOV  X0, #1            // stdout
    ADR  X1, message       // message address
    MOV  X2, #message_len  // message length
    SVC  #0                // Make system call
    
    // Exit with status 0
    MOV  X8, #93           // sys_exit
    MOV  X0, #0            // exit status
    SVC  #0                // Make system call
```

### macOS Hello World
```assembly
.section __DATA,__data
message:
    .asciz "Hello, World!\n"
message_len = . - message - 1

.section __TEXT,__text
.global _start
_start:
    // Write message to stdout
    MOV  X16, #4           // sys_write (macOS uses X16)
    MOV  X0, #1            // stdout
    ADR  X1, message       // message address
    MOV  X2, #message_len  // message length
    SVC  #0x80             // Make system call
    
    // Exit with status 0
    MOV  X16, #1           // sys_exit
    MOV  X0, #0            // exit status
    SVC  #0x80             // Make system call
```

## System Call Table Lookup

### Finding System Call Numbers

#### Linux
- Check `/usr/include/asm-generic/unistd.h`
- Check kernel source: `arch/arm64/include/uapi/asm/unistd.h`
- Use `ausyscall` command: `ausyscall --dump`

#### macOS
- Check `/usr/include/sys/syscall.h`
- Use `syscall(2)` man page
- Check XNU kernel source

## Advanced System Calls

### File Operations
- **openat**: Open file (with directory file descriptor)
- **read**: Read from file
- **write**: Write to file
- **close**: Close file descriptor
- **lseek**: Seek in file
- **fstat**: Get file status

### Process Operations
- **fork**: Create child process
- **execve**: Execute program
- **wait4**: Wait for process
- **exit**: Terminate process
- **getpid**: Get process ID

### Memory Operations
- **mmap**: Map memory
- **munmap**: Unmap memory
- **mprotect**: Change memory protection
- **brk**: Change data segment size

### Socket Operations
- **socket**: Create socket
- **bind**: Bind socket
- **listen**: Listen on socket
- **accept**: Accept connection
- **connect**: Connect to socket
- **sendto**: Send data
- **recvfrom**: Receive data

## System Call Best Practices

### Error Checking
Always check return values for errors:
```assembly
MOV  X8, #64              // sys_write
// ... arguments ...
SVC  #0
CMP  X0, #0
B.LT handle_error          // Handle error if negative
```

### Register Preservation
System calls may modify registers. Save important values:
```assembly
STP  X0, X1, [SP, #-16]!  // Save registers
// ... make system call ...
LDP  X0, X1, [SP], #16    // Restore registers
```

## References

- Linux System Call Table: https://chromium.googlesource.com/chromiumos/docs/+/master/constants/syscalls.md
- Linux kernel source: arch/arm64/include/uapi/asm/unistd.h
- macOS System Calls: https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/syscall.2.html
- ARM64 ABI Documentation
