# HelloARM64: A Curriculum for ARM64 Assembly

Welcome! This repository provides a structured, curriculum-based approach to learning ARM64 (AArch64) assembly. It is designed to run on **any native ARM64 hardware**, including Linux servers, desktops, and Apple Silicon Macs.

This project contains two main learning tracks, as well as a `sample` folder for quickly testing your build environment.

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
├── tools/
└── Makefile
```

-----

## ▶️ Building the Curriculum Examples

The `Makefile` and `tools/` scripts are designed to work seamlessly with the new structure.

### Building a Bare-metal Example

The `bare` command is for pure assembly files.

```bash
make bare file=baremetal/01_Registers_and_Syscalls/registers.s
```

### Building a Systems (ASM + C++) Example

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

  * [ARMv8-A Architecture Reference Manual](https://developer.arm.com/documentation/ddi0487/latest)
  * [Linux AArch64 syscall table](https://chromium.googlesource.com/chromiumos/docs/+/master/constants/syscalls.md)
  * [Apple Developer Docs: macOS system calls](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/syscall.2.html)
  * [Procedure Call Standard for the ARM 64-bit Architecture (AArch64)](https://www.google.com/search?q=https://developer.arm.com/documentation/ihi0055/latest/)

<!-- end list -->

```
```





