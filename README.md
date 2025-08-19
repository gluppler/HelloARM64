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
    ├── build.sh             # Universal build+run (file or folder, supports --bare, --debug)
    ├── debug.sh             # Shortcut: build + launch LLDB
    ├── debug.lldb           # Auto-run LLDB commands (regs, disasm, tracer aliases)
    ├── clean.sh             # Clean up bin/ and temp files
    └── run.sh               # Run a binary from bin/ by name
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

## 🛠 LLDB Tracer (Debugging Helper)

Inside LLDB, you now have extra commands:

* `st` → step one instruction **with trace** (regs + disasm)
* `nt` → next instruction **with trace**
* `rr` → read all registers manually
* `di` → disassemble around current PC

By default, whenever the program stops (breakpoint or step), LLDB will:

* Show register state
* Show 10 instructions around the current PC

This makes stepping through ARM64 assembly much easier.

---

## 🐞 Troubleshooting

### Always getting exit code `0`

* If you’re using `_main` and `ret`, the runtime may swallow your return value.
* Fix:

  * Use `_start` with `--bare` mode (`make bare_build`) for true bare-metal exit control.
  * Or return via `ret` in `_main` **without syscalls**, so libc calls `exit()` correctly.

### `lldb: error: invalid combination of options`

* Old LLDB script used `disassemble -f -n`. Fixed with `disassemble -a $pc -c 10`.
* Update your `tools/debug.lldb`.

### Rosetta / x86\_64 interference

* Ensure you are compiling for `arm64`. Run `file bin/hello_world` to confirm.
* If you see `x86_64`, you are running under Rosetta. Use:

  ```bash
  arch -arm64 ./tools/build.sh ...
  ```

### `clang: command not found`

* Install Xcode command-line tools:

  ```bash
  xcode-select --install
  ```

### Permission denied on tools

* Make sure scripts are executable:

  ```bash
  chmod +x tools/*.sh
  ```

### LLDB doesn’t break at `_start`

* If you built with `--bare`, your entry point is `_start`.
* If you built normally, your entry point is `_main`.
* LLDB script sets breakpoints on both, so one of them should hit.

### String printing doesn’t work

* macOS uses Mach syscalls, not Linux syscall numbers.
* Example:

  * Exit = `0x2000001`
  * Write = `0x2000004`
* Check you’re using the right constants.

---

## 📚 References

* [ARM Architecture Reference Manual (ARMv8-A)](https://developer.arm.com/documentation/ddi0487/latest)
* [Apple Developer Documentation: Assembly Language](https://developer.apple.com/documentation/xcode/writing-arm64-code-for-apple-platforms)
* [LLVM/Clang ARM64 Docs](https://clang.llvm.org/docs/Arm.html)
* [LLDB Command Guide](https://lldb.llvm.org/use/map.html)

---

## ✨ Goals

* Gain comfort with ARM64 registers and instructions.
* Learn how macOS expects functions, arguments, and syscalls to work.
* Build small but meaningful assembly programs in both contexts.
* Explore Apple Silicon at the lowest level for fun and mastery.




