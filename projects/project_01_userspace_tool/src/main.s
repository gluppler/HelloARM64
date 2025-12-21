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
    .asciz "Error: Cannot open file\n"
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
    LDR  X1, [SP, #8]      // argv[0] (skip)
    LDR  X2, [SP, #16]     // argv[1] (source)
    LDR  X3, [SP, #24]     // argv[2] (dest)
    
    // Open source file (read-only)
    MOV  X8, #56           // sys_openat
    MOV  X0, #-100         // AT_FDCWD
    MOV  X1, X2            // source pathname
    MOV  X2, #0            // O_RDONLY
    MOV  X3, #0            // mode (not used)
    SVC  #0
    CMP  X0, #0
    B.LT open_failed
    MOV  X19, X0           // Save source fd in callee-saved register
    
    // Open destination file (create, write-only, truncate)
    MOV  X8, #56           // sys_openat
    MOV  X0, #-100         // AT_FDCWD
    MOV  X1, X3            // dest pathname
    MOV  X2, #0x241        // O_WRONLY | O_CREAT | O_TRUNC
    MOV  X3, #0644         // mode (rw-r--r--)
    SVC  #0
    CMP  X0, #0
    B.LT open_failed
    MOV  X20, X0           // Save dest fd
    
    // Copy loop
copy_loop:
    // Read from source
    MOV  X8, #63           // sys_read
    MOV  X0, X19           // source fd
    ADR  X1, buffer        // buffer
    MOV  X2, #4096         // buffer size
    SVC  #0
    CMP  X0, #0
    B.LE copy_done         // <= 0 means EOF or error
    
    // Write to destination
    MOV  X21, X0           // Save bytes read
    MOV  X8, #64           // sys_write
    MOV  X0, X20           // dest fd
    ADR  X1, buffer        // buffer
    MOV  X2, X21           // bytes to write
    SVC  #0
    CMP  X0, #0
    B.LT write_failed
    
    // Continue loop
    B    copy_loop

copy_done:
    // Close files
    MOV  X8, #57           // sys_close
    MOV  X0, X19           // source fd
    SVC  #0
    
    MOV  X8, #57           // sys_close
    MOV  X0, X20           // dest fd
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
