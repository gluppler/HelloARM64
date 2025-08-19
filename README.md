
````
# HelloARM64

Learning ARM64 (AArch64) programming on Apple Silicon.  

This project is split into two parallel tracks:

- **Bare-Metal Track** → Learning how the CPU itself works: registers, instructions, memory, and control flow, without depending on an operating system.  
- **Systems-Level Track** → Writing ARM64 assembly that works with macOS: system calls, C interop, and debugging with LLDB.  

The goal is to understand ARM64 from both the *hardware-first* and *OS-aware* perspectives.

---

## ⚡ Quick Start

Get everything running in under a minute:

```bash
# 1. Clone the repo
git clone https://github.com/yourusername/HelloARM64.git
cd HelloARM64

# 2. Make scripts executable (one-time)
chmod +x tools/build.sh tools/debug.sh tools/clean.sh tools/run.sh

# 3. Build and run the sample Hello World
./tools/build.sh examples/hello_world.s

# 4. (Optional) Debug it in LLDB
./tools/build.sh examples/hello_world.s --debug
````

You should see:

```
Hello, world!
```

---

## 📂 Project Structure

```
HelloARM64/
├── README.md
├── Makefile                 # Root makefile (wrapping tools/)
│
├── baremetal/               # Track 1: CPU-only thinking
│   ├── 00_registers/
│   │   ├── main.s
│   │   └── Makefile
│   ├── 01_arithmetic/
│   ├── 02_memory/
│   ├── 03_functions/
│   └── projects/            # Larger bare-metal exercises
│       ├── fibonacci.s
│       └── bubblesort.s
│
├── systems/                 # Track 2: macOS + assembly
│   ├── 00_hello_syscall/
│   │   ├── hello.s
│   │   └── Makefile
│   ├── 01_calling_convention/
│   ├── 02_mixing_c/         # C <-> Assembly interop
│   │   ├── asm_func.s
│   │   ├── main.c
│   │   └── Makefile
│   ├── 03_debugging/
│   └── projects/            # Larger systems-level exercises
│       ├── strlen/
│       │   ├── strlen.s
│       │   ├── main.c
│       │   └── Makefile
│       └── factorial.s
│
├── examples/                # Sample assembly programs
│   └── hello_world.s
│
└── tools/                   # Helper scripts/configs
    ├── build.sh             # Universal build+run (file or folder)
    ├── debug.sh             # Shortcut: build + launch LLDB
    ├── debug.lldb           # Auto-run LLDB commands (regs, disasm, breakpoints)
    ├── clean.sh             # Clean up bin/ and temp files
    └── run.sh               # Run a binary from bin/ by name
```

---

## 🚀 Getting Started

### Requirements

* Apple Silicon Mac (M1/M2/M3).
* Xcode command line tools (`clang`, `make`, `lldb`).

Install with:

```bash
xcode-select --install
```

### Using Tools

* Build & run a file:

  ```bash
  ./tools/build.sh examples/hello_world.s
  ```
* Build & debug with LLDB:

  ```bash
  ./tools/build.sh examples/hello_world.s --debug
  ```
* Build all in a folder:

  ```bash
  ./tools/build.sh baremetal/
  ```
* Run an existing binary:

  ```bash
  ./tools/run.sh hello_world
  ```
* Clean everything:

  ```bash
  ./tools/clean.sh
  ```

### Using Root Makefile

* Build:

  ```bash
  make build file=examples/hello_world.s
  ```
* Debug:

  ```bash
  make debug file=examples/hello_world.s
  ```
* Run:

  ```bash
  make run file=examples/hello_world.s
  ```
* Clean:

  ```bash
  make clean
  ```

---

## 🧭 Learning Path

### 🟢 Bare-Metal Track

1. Registers & Instructions
2. Arithmetic & Control Flow
3. Memory (stack, load/store)
4. Functions (arguments, return values)
5. Projects (Fibonacci, Bubble Sort, etc.)

### 🔵 Systems-Level Track

1. Hello World with macOS syscall
2. Calling Convention & ABI
3. Mixing C & Assembly
4. Debugging with LLDB
5. Projects (`strlen`, factorial, etc.)

---

## 📚 References

* [ARM Architecture Reference Manual (ARMv8-A)](https://developer.arm.com/documentation/ddi0487/latest)
* [Apple Developer Documentation: Assembly Language](https://developer.apple.com/documentation/xcode/writing-arm64-code-for-apple-platforms)
* [LLVM/Clang ARM64 Docs](https://clang.llvm.org/docs/Arm.html)

---

## ✨ Goals

* Gain comfort with ARM64 registers and instructions.
* Learn how macOS expects functions, arguments, and syscalls to work.
* Build small but meaningful assembly programs in both contexts.
* Explore Apple Silicon at the lowest level for fun and mastery.



