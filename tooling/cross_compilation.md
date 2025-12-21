# Cross-Compilation

> **Reference**: For ARM64 architecture details relevant to cross-compilation, see [`../references/arm_architecture.md`](../references/arm_architecture.md) and [`../references/external_links.md`](../references/external_links.md) for toolchain documentation.

## Toolchain Setup

### Linux
```bash
sudo apt-get install gcc-aarch64-linux-gnu
sudo apt-get install binutils-aarch64-linux-gnu
sudo apt-get install gdb-multiarch
```

### macOS
```bash
# Use clang with -target flag
clang -target arm64-apple-darwin -o program program.s
```

## Compilation

### Basic Cross-Compilation
```bash
aarch64-linux-gnu-gcc -nostdlib -o program program.s
```

### With Debugging
```bash
aarch64-linux-gnu-gcc -g -nostdlib -o program program.s
```

## Execution

### With QEMU
```bash
qemu-aarch64 ./program
```

### With GDB
```bash
qemu-aarch64 -g 1234 ./program &
gdb-multiarch ./program
(gdb) target remote :1234
```

## References

- GCC Cross-Compilation Guide
- QEMU User Mode Emulation
- ARM Toolchain Documentation
