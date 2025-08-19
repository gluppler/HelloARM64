
# HelloARM64

Learning ARM64 (AArch64) programming on Apple Silicon.  

This project is split into two parallel tracks:

- **Bare-Metal Track** → Learning how the CPU itself works: registers, instructions, memory, and control flow, without depending on an operating system.  
- **Systems-Level Track** → Writing ARM64 assembly that works with macOS: system calls, C interop, and debugging with LLDB.  

The goal is to understand ARM64 from both the *hardware-first* and *OS-aware* perspectives.

---

## 📂 Project Structure

```

HelloARM64/
├── README.md
├── baremetal/                # Track 1: CPU-only thinking
│   ├── 00\_registers/         # Playgrounds for registers/instructions
│   │   ├── main.s
│   │   └── Makefile
│   ├── 01\_arithmetic/
│   ├── 02\_memory/
│   ├── 03\_functions/
│   └── projects/             # Larger bare-metal exercises
│       ├── fibonacci.s
│       └── bubblesort.s
│
├── systems/                  # Track 2: macOS + assembly
│   ├── 00\_hello\_syscall/     # Hello World with syscalls
│   │   ├── hello.s
│   │   └── Makefile
│   ├── 01\_calling\_convention/
│   ├── 02\_mixing\_c/          # C <-> Assembly interop
│   │   ├── asm\_func.s
│   │   ├── main.c
│   │   └── Makefile
│   ├── 03\_debugging/
│   └── projects/             # Larger systems-level exercises
│       ├── strlen/
│       │   ├── strlen.s
│       │   ├── main.c
│       │   └── Makefile
│       └── factorial.s
│
└── tools/                    # Helper scripts/configs
└── build.sh

````

---

## 🚀 Getting Started

### Requirements
- Apple Silicon Mac (M1/M2/M3).  
- Xcode command line tools (`clang`, `make`, `lldb`).  

Install with:
```bash
xcode-select --install
````

### Building & Running

Each subfolder has its own **Makefile**.

Example (bare-metal registers demo):

```bash
cd baremetal/00_registers
make run
```

Example (systems-level hello syscall):

```bash
cd systems/00_hello_syscall
make run
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


