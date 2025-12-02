# HelloARM64: A Curriculum for ARM64 Assembly

Welcome! This repository provides a structured, curriculum-based approach to learning ARM64 (AArch64) assembly. It is designed to run on **any native ARM64 hardware**, including Linux servers, desktops, and Apple Silicon Macs.

This project contains comprehensive ARM64 assembly learning resources:

-   **`Fundamentals` Folder**: Complete reference covering all ARM assembly concepts for AArch64 and Apple Silicon.
-   **`sample` Folder**: Use this first to ensure your toolchain is working correctly.
-   **`baremetal` Track**: Learn pure assembly by interacting directly with the OS kernel.
-   **`systems` Track**: Learn to integrate assembly with C++ for real-world applications.

---

## 🧪 Quick Test: Verify Your Setup

Before starting the curriculum, use the `sample` folder to make sure everything is configured correctly.

#### 1. Test Bare-Metal Compilation
```bash
make bare file=sample/baremetal-test/hello-bare.s
./bin/hello-bare
````

You should see "Hello Bare-Metal\!" printed to your console.

#### 2\. Test Systems (C++) Compilation

```bash
make build file=sample/systems-test/hello-sys.s
./bin/hello-sys
```

You should see "Hello Systems\!" printed to your console.

If both of these work, you are ready to start the curriculum\!

-----

## 📂 Project Structure

The repository is organized like a course, with numbered folders that build upon each other. Start with `01_` in each track and work your way up.

```
HelloARM64/
├── Fundamentals/          # Complete ARM assembly reference
│   ├── 01_Registers.s
│   ├── 02_Basic_Instructions.s
│   ├── 03_Memory_Operations.s
│   ├── 04_Control_Flow.s
│   ├── 05_Stack_Operations.s
│   ├── 06_Function_Calls.s
│   ├── 07_System_Calls.s
│   ├── 08_Arithmetic_Advanced.s
│   ├── 09_SIMD_NEON.s
│   ├── 10_Apple_Silicon_Specific.s
│   ├── 11_Security_Practices.s
│   └── README.md
├── sample/                # <-- Use this to test your setup
│   ├── baremetal-test/
│   └── systems-test/
├── baremetal/             # The bare-metal curriculum
│   ├── 01_Registers_and_Syscalls/
│   ├── 02_Memory_and_Data/
│   ├── 03_Arithmetic_and_Logic/
│   ├── 04_Control_Flow/
│   ├── 05_The_Stack_and_Functions/
│   ├── 06_Advanced_Memory_Addressing/
│   └── projects/
├── systems/               # The C++ interop curriculum
│   ├── 01_Basic_Interop/
│   ├── 02_Passing_Arguments/
│   ├── 03_Returning_Values/
│   ├── 04_Data_Structures/
│   ├── 05_Strings_and_Pointers/
│   ├── 06_Calling_Cpp_from_Asm/
│   └── projects/
├── bin/                   # Compiled binaries
│   └── fundamentals/      # Compiled Fundamentals examples
└── Makefile
```

-----

## ▶️ Building Examples

### Building Fundamentals Examples

The `Fundamentals` folder contains comprehensive ARM assembly reference code. All files are ready to compile:

```bash
# For Linux (AArch64)
aarch64-linux-gnu-gcc -nostartfiles -static -o bin/fundamentals/01_Registers Fundamentals/01_Registers.s

# For macOS (Apple Silicon)
clang -e _start -nostartfiles -o bin/fundamentals/01_Registers Fundamentals/01_Registers.s
```

All Fundamentals binaries are pre-compiled in `bin/fundamentals/` and ready to run on ARM64 systems.

### Building Curriculum Examples

The `Makefile` is designed to work with the curriculum structure.

#### Building a Bare-metal Example

The `bare` command is for pure assembly files.

```bash
make bare file=baremetal/01_Registers_and_Syscalls/registers.s
```

#### Building a Systems (ASM + C++) Example

The `build` command is for assembly files that have a corresponding `main.cpp`.

```bash
make build file=systems/01_Basic_Interop/hello.s
```

After building, you can run the output file from the `bin/` directory:

```bash
./bin/registers
./bin/hello
```

-----

## 📚 References

See `REFERENCES.md` for a comprehensive list of ARM64 learning resources.

Key references:
- [ARMv8-A Architecture Reference Manual](https://developer.arm.com/documentation/ddi0487/latest)
- [Linux AArch64 syscall table](https://chromium.googlesource.com/chromiumos/docs/+/master/constants/syscalls.md)
- [Apple Developer Docs: macOS system calls](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/syscall.2.html)
- [Procedure Call Standard for the ARM 64-bit Architecture (AArch64)](https://developer.arm.com/documentation/ihi0055/latest/)

## 🔒 Security & Code Quality

All code in this repository follows strict security and quality standards:
- ✅ No vulnerabilities
- ✅ No segmentation faults
- ✅ Clean code principles
- ✅ Secure coding practices
- ✅ Comprehensive error handling
- ✅ Input validation and bounds checking

## 📖 Fundamentals Reference

The `Fundamentals/` directory provides a complete reference covering:
- Register architecture and usage
- Basic and advanced instructions
- Memory operations and addressing modes
- Control flow and loops
- Stack management
- Function calling conventions
- System calls (macOS and Linux)
- Advanced arithmetic operations
- SIMD/NEON vector operations
- Apple Silicon specific features
- Security best practices

See `Fundamentals/README.md` for detailed documentation.





