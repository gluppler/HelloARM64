# HelloARM64

Learning ARM64 (AArch64) programming on Apple Silicon.  

This project is split into two parallel tracks:

- **Bare-Metal Track** → Learning how the CPU itself works: registers, instructions, memory, and control flow, without depending on an operating system. Uses `_start` as the entry point and direct syscalls.  
- **Systems-Level Track** → Writing ARM64 assembly that works with macOS: system calls, C interop, and debugging with LLDB. Uses `_main` and links with the C runtime.  

The goal is to understand ARM64 from both the *hardware-first* and *OS-aware* perspectives.

---

## ⚡ Quick Start

```bash
# 1. Clone the repo
git clone https://github.com/yourusername/HelloARM64.git
cd HelloARM64

# 2. Make scripts executable (one-time)
chmod +x tools/build.sh tools/debug.sh tools/clean.sh tools/run.sh

# 3. Build and run the sample Hello World (runtime mode)
./tools/build.sh examples/hello_world.s

# 4. (Optional) Run in bare-metal mode (no libc)
./tools/build.sh examples/hello_world.s --bare

# 5. (Optional) Debug with LLDB tracer
./tools/build.sh examples/hello_world.s --bare --debug
````

Expected output:

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
│   │   ├── registers.s
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
│   └── projects/
│       ├── strlen/
│       │   ├── strlen.s
│       │   ├── main.c
│       │   └── Makefile
│       └── factorial.s
│
├── examples/                # Sample assembly programs
│   ├── hello_world.s
│   ├── hello_world_c.s
│   └── hello_world_c.c
│
└── tools/                   # Helper scripts/configs
    ├── build.sh
    ├── debug.sh
    ├── debug.lldb
    ├── clean.sh
    └── run.sh
```

---

## 🚀 Building & Running

### Using Tools

* Build & run normally (`_main` + libc exit):

  ```bash
  ./tools/build.sh baremetal/00_registers/registers.s
  ```
* Build & run bare-metal (`_start` + direct syscalls):

  ```bash
  ./tools/build.sh baremetal/00_registers/registers.s --bare
  ```
* Debug with LLDB tracer:

  ```bash
  ./tools/build.sh baremetal/00_registers/registers.s --bare --debug
  ```
* Clean all binaries:

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
* Bare-metal build:

  ```bash
  make bare_build file=baremetal/00_registers/registers.s
  ```
* Bare-metal debug:

  ```bash
  make bare_debug file=baremetal/00_registers/registers.s
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

1. Registers & Instructions (`mov`, `add`, `sub`)
2. Arithmetic & Control Flow (loops, comparisons)
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

## 🔑 Naming Rule on macOS ARM64

On macOS, the **Mach-O ABI** requires all global symbols to have a **leading underscore**.

* In **assembly**:

  ```asm
  .global _foo
  _foo:
      ret
  ```
* In **C code**:

  ```c
  extern long foo(void);  // notice: no underscore in C
  ```

✅ Always remember:

* **Track 1**: Use `_start` (bare entry) or `_main` (system entry).
* **Track 2**: Functions must be `_funcname` in assembly, `funcname` in C.

---

## 🛠 LLDB Tracer (Debugging Helper)

Inside LLDB, you now have extra commands:

* `st` → step one instruction **with trace** (regs + disasm)
* `nt` → next instruction **with trace**
* `rr` → read all registers manually
* `di` → disassemble around current PC

By default, whenever the program stops, LLDB will:

* Show register state
* Show 10 instructions around current PC

---

## 📝 ARM64 + macOS ABI Cheatsheet

**Registers**

* `x0–x7` → function arguments (1st arg in `x0`, 2nd in `x1`, etc.)
* `x0` → return value register
* `x8` → indirect result pointer
* `x9–x15` → temporaries (caller-saved)
* `x19–x28` → callee-saved registers (must be preserved)
* `x29` → frame pointer
* `x30` → link register (return address)
* `sp` → stack pointer

**Stack Alignment**

* Must be 16-byte aligned at function calls.

**Syscalls (bare-metal track only)**

* `x16` → syscall number
* `x0–x2` → syscall args (fd, buffer, size, etc.)
* `svc #0` → trigger kernel call

**Symbol Rules**

* `_foo` in assembly ↔ `foo()` in C
* Prefix all assembly globals with `_` for interop

**Exit codes**

* Bare-metal: explicit `exit` syscall.
* Systems: return in `x0` and `ret`; libc calls `exit(x0)`.

**Interop Example**

```c
// C file
extern long add_two(long x, long y);
int main() {
    return (int)add_two(7, 3);
}
```

```asm
// Assembly file
.global _add_two
_add_two:
    add x0, x0, x1
    ret
```

---

## 🐞 Troubleshooting

### Always getting exit code `0`

* If using `_main`, libc may swallow return value.
* Use `_start` in bare-metal, or `ret` in `_main` so libc calls `exit(x0)`.

### `lldb: error: invalid combination of options`

* Fixed by using `disassemble -a $pc -c 10`.

### Rosetta / x86\_64 interference

* Confirm binary arch with `file bin/hello_world`.
* If wrong, force build with `arch -arm64`.

### Permissions

```bash
chmod +x tools/*.sh
```

---

## 📚 References

- [LLVM Clang Compiler User Manual](https://clang.llvm.org/docs/UsersManual.html) — Comprehensive guide to Clang usage and options :contentReference[oaicite:0]{index=0}  
- [LLVM Download & Documentation](https://releases.llvm.org/download.html) — Central hub for LLVM and Clang releases and documentation :contentReference[oaicite:1]{index=1}  
- [ARM C/C++ Compiler (Clang/LLVM-based)](https://developer.arm.com/documentation/101458/latest/Supporting-reference-information/Clang-and-LLVM-documentation) — ARM-specific insights on the Clang/LLVM toolchain :contentReference[oaicite:2]{index=2}  
- [ARM Architecture Reference Manual (ARMv8-A)](https://developer.arm.com/documentation/ddi0487/latest)  
- [Apple Developer: Writing ARM64 Code for Apple Platforms](https://developer.apple.com/documentation/xcode/writing-arm64-code-for-apple-platforms)  
- [LLDB Command Guide](https://lldb.llvm.org/use/map.html)

---

## ✨ Goals

* Gain comfort with ARM64 registers and instructions.
* Learn how macOS expects functions, arguments, and syscalls to work.
* Build small but meaningful assembly programs in both contexts.
* Explore Apple Silicon at the lowest level for fun and mastery.





