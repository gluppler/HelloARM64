# HelloARM64

Learn ARM64 (AArch64) programming on both **Linux** and **macOS (Apple Silicon)**.  
This project is organized into two parallel **tracks**:

- **Bare-metal track**: pure assembly with direct syscalls, no libc.
- **Systems track**: assembly + C interop to build realistic userland programs.

---

## 📂 Project Structure

```

HelloARM64/
├── baremetal/           # Low-level assembly lessons
│    ├── 00\_registers/
│    ├── 01\_arithmetic/
│    └── ...
├── examples/
│    ├── hello\_world/
│    │    ├── hello\_world\_bare\_linux.s
│    │    ├── hello\_world\_bare\_macos.s
│    │    ├── hello\_world\_sys\_linux.s
│    │    ├── hello\_world\_sys\_linux.c
│    │    ├── hello\_world\_sys\_macos.s
│    │    ├── hello\_world\_sys\_macos.c
│    │    └── README.md
│    └── ...
├── tools/
│    ├── build.sh        # Unified build script (Linux + macOS)
│    ├── debug.lldb      # Debug setup for macOS
│    └── (future Linux debug configs)
├── Makefile             # Frontend for build.sh
└── README.md            # (this file)

````

---

## ⚙️ Toolchain

### macOS (Apple Silicon)
- `clang` (built-in)
- `lldb` (debugger)

### Linux (AArch64)
- `aarch64-linux-gnu-gcc` or `clang --target=aarch64-linux-gnu`
- `qemu-aarch64` (to run Linux binaries from macOS)
- `gdb-multiarch` (optional debugger for Linux)

Install via Homebrew (macOS):
```bash
brew install qemu
brew install llvm
````

---

## ▶️ Building & Running

### macOS bare-metal

```bash
make bare file=examples/hello_world/hello_world_bare_macos.s target=macos
./bin/hello_world_bare_macos
```

### macOS systems (ASM + C)

```bash
make build file=examples/hello_world/hello_world_sys_macos.s target=macos
./bin/hello_world_sys_macos
```

### Linux bare-metal (cross-compiled, run in QEMU)

```bash
make bare file=examples/hello_world/hello_world_bare_linux.s target=linux
qemu-aarch64 ./bin/hello_world_bare_linux
```

### Linux systems (ASM + C)

```bash
make build file=examples/hello_world/hello_world_sys_linux.s target=linux
qemu-aarch64 ./bin/hello_world_sys_linux
```

---

## 🐞 Debugging

### macOS

```bash
make debug file=examples/hello_world/hello_world_bare_macos.s target=macos
```

Runs `lldb` with `tools/debug.lldb` preloaded.

### Linux

* Use `gdb-multiarch` attached to `qemu-aarch64`.
* Example:

  ```bash
  qemu-aarch64 -g 1234 ./bin/hello_world_bare_linux
  gdb-multiarch ./bin/hello_world_bare_linux
  (gdb) target remote :1234
  ```

---

## 📚 References

* [Linux AArch64 syscall table](https://chromium.googlesource.com/chromiumos/docs/+/master/constants/syscalls.md)
* [Apple Developer Docs: macOS system calls](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/syscall.2.html)
* [ARMv8-A Architecture Reference Manual (ARM64)](https://developer.arm.com/documentation/ddi0487/latest)

````

---

### 📘 `examples/hello_world/README.md`

```markdown
# Hello World (Assembly + C Interop)

This directory introduces the **first programs** in ARM64 assembly, for both Linux and macOS.  
Each platform has two variants:

- **Bare-metal (`hello_world_bare_*`)**
  - Pure assembly.
  - Makes syscalls directly (no libc).
  - Minimal starting point for learning.

- **Systems (`hello_world_sys_*`)**
  - Assembly provides helper functions (`get_message`).
  - C code calls into assembly and prints strings.
  - Demonstrates real-world interop.

---

## 📂 Files

````

hello\_world\_bare\_linux.s   # Linux syscall: write(64), exit(93)
hello\_world\_bare\_macos.s   # macOS syscall: write(0x2000004), exit(0x2000001)

hello\_world\_sys\_linux.s    # Provides get\_message()
hello\_world\_sys\_linux.c    # Calls get\_message(), prints message

hello\_world\_sys\_macos.s    # Provides \_get\_message()
hello\_world\_sys\_macos.c    # Calls get\_message(), prints message

````

---

## 🔧 Syscall Differences

| Platform | Write syscall | Exit syscall | Register |
|----------|---------------|--------------|----------|
| **Linux** | `x8 = 64`     | `x8 = 93`    | `svc #0` |
| **macOS** | `x16 = 0x2000004` | `x16 = 0x2000001` | `svc #0` |

---

## ▶️ Build & Run

### Linux bare-metal
```bash
make bare file=examples/hello_world/hello_world_bare_linux.s target=linux
qemu-aarch64 ./bin/hello_world_bare_linux
````

### macOS bare-metal

```bash
make bare file=examples/hello_world/hello_world_bare_macos.s target=macos
./bin/hello_world_bare_macos
```

### Linux systems

```bash
make build file=examples/hello_world/hello_world_sys_linux.s target=linux
qemu-aarch64 ./bin/hello_world_sys_linux
```

### macOS systems

```bash
make build file=examples/hello_world/hello_world_sys_macos.s target=macos
./bin/hello_world_sys_macos
```

---

## 🧠 Concepts

* **Registers**:

  * `x0`–`x2`: syscall args
  * `x8` (Linux) or `x16` (macOS): syscall number
* **Bare vs Systems**:

  * Bare = minimal learning scaffold.
  * Systems = more realistic, with C integration.
* **Cross-platform portability**:

  * Assembly differs only in syscall numbers + exported symbol names.

---

## 📚 Further Reading

* Linux: [Syscall numbers for AArch64](https://chromium.googlesource.com/chromiumos/docs/+/master/constants/syscalls.md)
* macOS: [Mach syscalls](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/syscall.2.html)







