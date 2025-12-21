# Lesson 00: Environment Setup

> **Reference**: This lesson is cross-referenced with [`references/external_links.md`](../references/external_links.md) for tool documentation and [`references/index.md`](../references/index.md) for overall ARM64 reference structure.

## Learning Objectives

By the end of this lesson, you will be able to:
- Set up a development environment for ARM64 assembly programming
- Install and configure necessary tools (assembler, linker, debugger)
- Compile and run your first ARM64 assembly program
- Understand the differences between native and cross-compilation environments

## Prerequisites

- Basic familiarity with command-line interfaces
- Understanding of basic programming concepts
- Access to a Linux or macOS system (or ability to use emulation)

## Required Tools

### Essential Tools

#### GNU Assembler (GAS)
- **Purpose**: Assembles ARM64 assembly source code into object files
- **Installation (Linux)**:
  ```bash
  sudo apt-get install binutils-aarch64-linux-gnu  # Debian/Ubuntu
  sudo yum install binutils-aarch64-linux-gnu      # RHEL/CentOS
  ```
- **Installation (macOS)**:
  ```bash
  # Already included with Xcode Command Line Tools
  xcode-select --install
  ```

**Reference**: GNU Assembler Manual - https://sourceware.org/binutils/docs/as/

#### GCC/Clang Compiler
- **Purpose**: Compiles and links assembly code
- **Installation (Linux)**:
  ```bash
  sudo apt-get install gcc-aarch64-linux-gnu       # Debian/Ubuntu
  ```
- **Installation (macOS)**:
  ```bash
  # Included with Xcode Command Line Tools
  ```

**Reference**: GCC ARM Options - https://gcc.gnu.org/onlinedocs/gcc/ARM-Options.html

#### GDB Debugger
- **Purpose**: Debug ARM64 assembly programs
- **Installation (Linux)**:
  ```bash
  sudo apt-get install gdb-multiarch              # Multi-architecture GDB
  ```
- **Installation (macOS)**:
  ```bash
  # Included with Xcode Command Line Tools
  ```

**Reference**: GDB Documentation - https://sourceware.org/gdb/documentation/

### Optional Tools

#### QEMU (for cross-platform development)
- **Purpose**: Emulates ARM64 systems on x86-64
- **Installation**:
  ```bash
  sudo apt-get install qemu-user-static           # Linux
  brew install qemu                                # macOS
  ```

#### Make
- **Purpose**: Build automation
- **Installation**: Usually pre-installed on Linux/macOS

## Development Environments

### Native ARM64 Development

#### Linux (AArch64)
- **Advantages**: Direct execution, no emulation overhead
- **Platforms**: Raspberry Pi 4, AWS Graviton, Apple Silicon (via Linux)
- **Toolchain**: Native `gcc`, `as`, `ld`

#### macOS (Apple Silicon)
- **Advantages**: Native ARM64 execution, excellent toolchain
- **Platforms**: M1, M2, M3 Macs
- **Toolchain**: `clang`, `as`, `ld` (Xcode tools)

**Reference**: Apple Developer - Apple Silicon - https://developer.apple.com/documentation/apple-silicon

### Cross-Compilation

#### x86-64 Linux → ARM64
- **Toolchain**: `aarch64-linux-gnu-gcc`, `aarch64-linux-gnu-as`
- **Execution**: Use QEMU user-mode emulation
- **Use case**: Development on x86-64 systems

#### x86-64 macOS → ARM64
- **Toolchain**: `clang -target arm64-apple-darwin`
- **Execution**: Native on Apple Silicon, Rosetta 2 on Intel Macs
- **Use case**: Universal binaries

## First Program

### Hello World in ARM64 Assembly

Create `hello.s`:

```assembly
.section .data
message:
    .asciz "Hello, ARM64!\n"
message_len = . - message - 1

.section .text
.global _start
_start:
    // Write message to stdout
    // sys_write: X8=64, X0=fd, X1=buf, X2=len
    MOV  X8, #64          // Linux sys_write
    MOV  X0, #1            // stdout
    ADR  X1, message       // message address
    MOV  X2, #message_len  // message length
    SVC  #0                // Make system call
    
    // Exit with status 0
    // sys_exit: X8=93, X0=status
    MOV  X8, #93           // Linux sys_exit
    MOV  X0, #0            // exit status
    SVC  #0                // Make system call
```

**Reference**: ARM A64 ISA (DDI0602) - MOV instruction, ARM Developer Documentation - System Calls

### Compilation

#### Linux (Native or Cross-Compilation)
```bash
# Native ARM64 (static linking)
gcc -nostdlib -static -o hello hello.s

# Cross-compilation (static linking - recommended)
aarch64-linux-gnu-gcc -nostdlib -static -o hello hello.s

# Verify static linking
file hello
# Should show: "statically linked"

# Run (native)
./hello

# Run (cross-compilation with QEMU - static binary, no -L needed)
qemu-aarch64 ./hello

# If you need dynamic linking (not recommended for simple programs):
# 1. Compile without -static
# 2. Install ARM64 rootfs: sudo apt-get install qemu-user-binfmt
# 3. Or use: qemu-aarch64 -L /usr/aarch64-linux-gnu ./hello
```

#### macOS (Apple Silicon)
```bash
# Native compilation
clang -e _start -nostartfiles -o hello hello.s
./hello
```

**Reference**: GCC ARM Options, Clang ARM Support

### Understanding the Build Process

1. **Assembly**: `as hello.s -o hello.o`
   - Converts assembly source to object file
   - Resolves symbols and generates machine code

2. **Linking**: `ld hello.o -o hello` (or via gcc/clang)
   - Links object files into executable
   - Resolves external symbols
   - Sets up entry point

**Reference**: GNU Linker Manual - https://sourceware.org/binutils/docs/ld/

## Debugging Setup

### GDB Configuration

Create `~/.gdbinit`:
```
set disassembly-flavor intel
set print pretty on
set print elements 0
```

### Basic GDB Usage
```bash
# Start debugging
gdb ./hello

# Set breakpoint
(gdb) break _start

# Run
(gdb) run

# Step through instructions
(gdb) stepi

# Inspect registers
(gdb) info registers

# Examine memory
(gdb) x/10x $sp
```

**Reference**: GDB Documentation, ARM Developer Documentation - Using a debugger

## Project Structure

### Recommended Directory Layout
```
project/
├── src/
│   └── *.s              # Assembly source files
├── build/                # Build output
├── Makefile              # Build automation
└── README.md             # Project documentation
```

### Sample Makefile
```makefile
AS = aarch64-linux-gnu-as
LD = aarch64-linux-gnu-ld
CC = aarch64-linux-gnu-gcc

CFLAGS = -nostdlib
LDFLAGS = 

SRCDIR = src
BUILDDIR = build

SOURCES = $(wildcard $(SRCDIR)/*.s)
OBJECTS = $(SOURCES:$(SRCDIR)/%.s=$(BUILDDIR)/%.o)
TARGETS = $(SOURCES:$(SRCDIR)/%.s=$(BUILDDIR)/%)

all: $(TARGETS)

$(BUILDDIR)/%: $(BUILDDIR)/%.o
	$(CC) $(CFLAGS) -o $@ $<

$(BUILDDIR)/%.o: $(SRCDIR)/%.s
	$(AS) -o $@ $<

clean:
	rm -f $(BUILDDIR)/*

.PHONY: all clean
```

## Verification

### Verify Installation
```bash
# Check assembler
as --version              # or aarch64-linux-gnu-as

# Check compiler
gcc --version             # or aarch64-linux-gnu-gcc

# Check debugger
gdb --version             # or gdb-multiarch

# Check architecture
file hello                # Should show ARM64/aarch64
```

### Test Program
1. Compile the hello world program
2. Run it and verify output
3. Use GDB to step through execution
4. Inspect registers and memory

## Common Issues

### Issue: "Command not found"
- **Solution**: Install missing toolchain packages
- **Linux**: Use package manager (apt, yum, etc.)
- **macOS**: Install Xcode Command Line Tools

### Issue: "Wrong architecture"
- **Solution**: Ensure using correct toolchain
- **Cross-compilation**: Use `aarch64-linux-gnu-` prefix
- **Native**: Use system default tools

### Issue: "Permission denied"
- **Solution**: Make executable with `chmod +x hello`
- **Or**: Run with `./hello` (not just `hello`)

### Issue: "Segmentation fault"
- **Solution**: Use GDB to debug
- Check stack alignment (must be 16-byte aligned)
- Verify system call arguments

**Reference**: ARMv8-A Architecture Reference Manual - Stack alignment requirements

## Next Steps

After completing this lesson:
1. Verify all tools are installed and working
2. Compile and run the hello world program
3. Experiment with GDB debugging
4. Set up your preferred development environment
5. Proceed to Lesson 01: Registers and Data

## References

- [GNU Assembler Manual](https://sourceware.org/binutils/docs/as/)
- [GCC ARM Options](https://gcc.gnu.org/onlinedocs/gcc/ARM-Options.html)
- [GDB Documentation](https://sourceware.org/gdb/documentation/)
- [ARM Developer Documentation](https://developer.arm.com/documentation)
- [Apple Developer - Apple Silicon](https://developer.apple.com/documentation/apple-silicon)
