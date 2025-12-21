// Hello World program for Linux ARM64
// Demonstrates basic system calls (write, exit)
//
// Reference: See references/syscalls.md for complete system call documentation
// Reference: See references/instruction_set.md for instruction documentation

.section .data
message:
    .asciz "Hello, ARM64 World!\n"
message_len = . - message - 1

.section .text
.global _start
_start:
    // Write message to stdout
    // Linux sys_write: X8=64, X0=fd, X1=buf, X2=len
    MOV  X8, #64          // sys_write system call number
    MOV  X0, #1            // File descriptor: stdout
    ADR  X1, message       // Buffer address (PC-relative)
    MOV  X2, #message_len  // Buffer length
    SVC  #0                // Make system call
    
    // Exit with status 0
    // Linux sys_exit: X8=93, X0=status
    MOV  X8, #93           // sys_exit system call number
    MOV  X0, #0            // Exit status: 0 (success)
    SVC  #0                // Make system call
