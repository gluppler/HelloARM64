# Cross-Compilation

> **Reference**: For ARM64 architecture details relevant to cross-compilation, see [`../references/arm_architecture.md`](../references/arm_architecture.md) and [`../references/external_links.md`](../references/external_links.md) for toolchain documentation.

## Toolchain Setup

### Linux (Debian/Ubuntu)
```bash
sudo apt-get install gcc-aarch64-linux-gnu
sudo apt-get install binutils-aarch64-linux-gnu
sudo apt-get install gdb-multiarch
sudo apt-get install qemu-user-static
```

### Linux (Arch Linux)
```bash
sudo pacman -S aarch64-linux-gnu-gcc
sudo pacman -S aarch64-linux-gnu-binutils
sudo pacman -S gdb
sudo pacman -S qemu-user-static
```

**Note**: All project Makefiles auto-detect the environment and use appropriate toolchains.

### macOS
```bash
# Use clang with -target flag
clang -target arm64-apple-darwin -o program program.s
```

## Compilation

### Basic Cross-Compilation (Static Linking - Recommended)
```bash
# Static linking - no dynamic library dependencies
aarch64-linux-gnu-gcc -nostdlib -static -o program program.s

# Verify static linking
file program
# Should show: "statically linked"
```

### With Debugging
```bash
aarch64-linux-gnu-gcc -g -nostdlib -static -o program program.s
```

### Dynamic Linking (Not Recommended for Simple Programs)
```bash
# If you need dynamic linking, compile without -static
aarch64-linux-gnu-gcc -nostdlib -o program program.s
# Note: Requires ARM64 library path for QEMU execution
```

## Execution

### With QEMU (Static Binary - Recommended)
```bash
# Static binaries don't need -L flag
qemu-aarch64 ./program
```

### With QEMU (Dynamic Binary)
```bash
# Option 1: Install binfmt support (automatic library resolution)
sudo apt-get install qemu-user-binfmt
qemu-aarch64 ./program

# Option 2: Specify library path manually
qemu-aarch64 -L /usr/aarch64-linux-gnu ./program

# Option 3: Use custom rootfs path
qemu-aarch64 -L /path/to/arm64/rootfs ./program
```

### With GDB
```bash
# Static binary
qemu-aarch64 -g 1234 ./program &
gdb-multiarch ./program
(gdb) target remote :1234

# Dynamic binary (with library path)
qemu-aarch64 -g 1234 -L /usr/aarch64-linux-gnu ./program &
gdb-multiarch ./program
(gdb) target remote :1234
```

## Troubleshooting

### "No such file or directory" Error
- **Cause**: Dynamic binary can't find ARM64 libraries
- **Solution**: Use `-static` flag when compiling, or use `-L` flag with QEMU

### "Exec format error"
- **Cause**: Binary format mismatch or missing interpreter
- **Solution**: Ensure static linking with `-static` flag, or provide correct library path with `-L`

### Library Path Issues
- **Find ARM64 library path**: `dpkg -L libc6-dev-arm64-cross | grep libc.so`
- **Common paths**: `/usr/aarch64-linux-gnu/`, `/usr/lib/aarch64-linux-gnu/`

## References

- GCC Cross-Compilation Guide
- QEMU User Mode Emulation
- ARM Toolchain Documentation
