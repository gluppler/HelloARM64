// ARM64 file copy utility
// Usage: ./cp_tool source dest
// Copies source file to destination file
//
// Reference: See ../../references/syscalls.md for system call documentation
// Reference: See ../../references/instruction_set.md for instruction details

.section .data
error_msg:
    .asciz "Error: Invalid arguments\nUsage: cp_tool source dest\n"
error_msg_len = . - error_msg - 1

open_error:
    .asciz "Error: Cannot open file (check if source file exists and is readable)\n"
open_error_len = . - open_error - 1

read_error:
    .asciz "Error: Cannot read file\n"
read_error_len = . - read_error - 1

write_error:
    .asciz "Error: Cannot write file\n"
write_error_len = . - write_error - 1

.section .bss
.lcomm buffer, 4096        // 4KB buffer for file operations

.section .text
.global _start
_start:
    // Get command-line arguments from stack
    // Stack layout: argc, argv[0], argv[1], argv[2], ...
    LDR  X0, [SP]          // argc
    CMP  X0, #3            // Need: program, source, dest
    B.EQ args_ok
    
    // Print error and exit
    MOV  X8, #64           // sys_write
    MOV  X0, #2            // stderr
    ADR  X1, error_msg
    MOV  X2, #error_msg_len
    SVC  #0
    MOV  X8, #93           // sys_exit
    MOV  X0, #1            // Exit with error
    SVC  #0

args_ok:
    // Get argv[1] (source file) and argv[2] (dest file)
    // Stack layout at _start: [SP] = argc, [SP+8] = argv[0], [SP+16] = argv[1], [SP+24] = argv[2]
    // Reference: See ../../references/calling_conventions.md for stack layout
    LDR  X1, [SP, #8]      // argv[0] (program name, skip)
    LDR  X2, [SP, #16]     // argv[1] (source file path - pointer to string)
    LDR  X3, [SP, #24]     // argv[2] (dest file path - pointer to string)
    
    // Save argv pointers in callee-saved registers before syscalls
    MOV  X19, X2           // Save argv[1] pointer (source) in X19
    MOV  X20, X3           // Save argv[2] pointer (dest) in X20
    
    // Open source file (read-only)
    // Reference: See ../../references/syscalls.md for sys_openat documentation
    MOV  X8, #56           // sys_openat
    MOV  X0, #-100         // AT_FDCWD (current working directory)
    MOV  X1, X19           // source pathname (pointer to string)
    MOV  X2, #0            // O_RDONLY
    MOV  X3, #0            // mode (not used for O_RDONLY)
    SVC  #0
    CMP  X0, #0
    B.LT open_failed
    MOV  X21, X0           // Save source fd in X21 (callee-saved)
    
    // Open destination file (create, write-only, truncate)
    MOV  X8, #56           // sys_openat
    MOV  X0, #-100         // AT_FDCWD
    MOV  X1, X20           // dest pathname (pointer to string)
    MOV  X2, #0x241        // O_WRONLY | O_CREAT | O_TRUNC
    MOV  X3, #0644         // mode (rw-r--r--)
    SVC  #0
    CMP  X0, #0
    B.LT open_failed
    MOV  X22, X0           // Save dest fd in X22 (callee-saved)
    
    // Copy loop
copy_loop:
    // Read from source
    // Reference: See ../../references/syscalls.md for sys_read documentation
    MOV  X8, #63           // sys_read
    MOV  X0, X21           // source fd (from X21)
    ADR  X1, buffer        // buffer address
    MOV  X2, #4096         // buffer size
    SVC  #0
    CMP  X0, #0
    B.LE copy_done         // <= 0 means EOF or error
    
    // Write to destination
    MOV  X23, X0           // Save bytes read in X23
    MOV  X8, #64           // sys_write
    MOV  X0, X22           // dest fd (from X22)
    ADR  X1, buffer        // buffer address
    MOV  X2, X23           // bytes to write
    SVC  #0
    CMP  X0, #0
    B.LT write_failed
    
    // Continue loop
    B    copy_loop

copy_done:
    // Close files
    MOV  X8, #57           // sys_close
    MOV  X0, X21           // source fd
    SVC  #0
    
    MOV  X8, #57           // sys_close
    MOV  X0, X22           // dest fd
    SVC  #0
    
    // Exit successfully
    MOV  X8, #93           // sys_exit
    MOV  X0, #0            // Success
    SVC  #0

open_failed:
    MOV  X8, #64           // sys_write
    MOV  X0, #2            // stderr
    ADR  X1, open_error
    MOV  X2, #open_error_len
    SVC  #0
    MOV  X8, #93           // sys_exit
    MOV  X0, #1            // Error
    SVC  #0

read_failed:
    MOV  X8, #64           // sys_write
    MOV  X0, #2            // stderr
    ADR  X1, read_error
    MOV  X2, #read_error_len
    SVC  #0
    MOV  X8, #93           // sys_exit
    MOV  X0, #1            // Error
    SVC  #0

write_failed:
    MOV  X8, #64           // sys_write
    MOV  X0, #2            // stderr
    ADR  X1, write_error
    MOV  X2, #write_error_len
    SVC  #0
    MOV  X8, #93           // sys_exit
    MOV  X0, #1            // Error
    SVC  #0
