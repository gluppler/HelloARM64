# QEMU Execution Guide

> **Reference**: For ARM64 architecture details, see [`../references/arm_architecture.md`](../references/arm_architecture.md). For cross-compilation setup, see [`cross_compilation.md`](./cross_compilation.md).

## Overview

QEMU user-mode emulation allows running ARM64 binaries on x86-64 systems. Proper execution requires understanding static vs dynamic linking and library paths.

## Static vs Dynamic Linking

### Static Linking (Recommended)

**Advantages**:
- No library dependencies
- Works directly with QEMU (no `-L` flag needed)
- Portable - can run on any system with QEMU
- Simpler execution

**Compilation**:
```bash
aarch64-linux-gnu-gcc -nostdlib -static -o program program.s
```

**Execution**:
```bash
qemu-aarch64 ./program
```

**Verification**:
```bash
file program
# Should show: "statically linked"
```

### Dynamic Linking

**Requirements**:
- ARM64 library path must be available
- Requires `-L` flag with QEMU or binfmt support
- More complex setup

**Compilation**:
```bash
aarch64-linux-gnu-gcc -nostdlib -o program program.s
# Note: Without -static flag
```

**Execution Options**:

#### Option 1: With Library Path
```bash
qemu-aarch64 -L /usr/aarch64-linux-gnu ./program
```

#### Option 2: With binfmt Support
```bash
# Install binfmt support (automatic library resolution)
sudo apt-get install qemu-user-binfmt
qemu-aarch64 ./program
```

## Common Errors and Solutions

### Error: "No such file or directory"

**Cause**: Dynamic binary can't find ARM64 libraries

**Solutions**:
1. **Recompile with static linking** (recommended):
   ```bash
   aarch64-linux-gnu-gcc -nostdlib -static -o program program.s
   qemu-aarch64 ./program
   ```

2. **Use -L flag with library path**:
   ```bash
   qemu-aarch64 -L /usr/aarch64-linux-gnu ./program
   ```

3. **Install binfmt support**:
   ```bash
   sudo apt-get install qemu-user-binfmt
   qemu-aarch64 ./program
   ```

### Error: "Exec format error"

**Cause**: Binary format mismatch or missing interpreter

**Solutions**:
1. **Verify binary format**:
   ```bash
   file program
   readelf -h program | grep Machine
   # Should show: "ARM aarch64"
   ```

2. **Use static linking**:
   ```bash
   aarch64-linux-gnu-gcc -nostdlib -static -o program program.s
   ```

3. **Check QEMU installation**:
   ```bash
   qemu-aarch64 --version
   ```

### Error: "Cannot find library"

**Cause**: Dynamic library not found in library path

**Solutions**:
1. **Find ARM64 library path**:
   ```bash
   dpkg -L libc6-dev-arm64-cross | grep libc.so
   ```

2. **Use correct library path**:
   ```bash
   qemu-aarch64 -L /usr/aarch64-linux-gnu ./program
   ```

3. **Install missing libraries**:
   ```bash
   sudo apt-get install libc6-dev-arm64-cross
   ```

## Finding Library Paths

### Common ARM64 Library Paths

```bash
# Debian/Ubuntu
/usr/aarch64-linux-gnu/
/usr/lib/aarch64-linux-gnu/

# Arch Linux
/usr/aarch64-linux-gnu/
/usr/lib/aarch64-linux-gnu/

# Find installed paths
# Debian/Ubuntu:
dpkg -L libc6-dev-arm64-cross | grep -E "libc\.so|ld-linux"

# Arch Linux:
pacman -Ql aarch64-linux-gnu-glibc | grep -E "libc\.so|ld-linux"
```

**Note**: All project Makefiles auto-detect library paths for your distribution.

### Verify Library Path

```bash
# Check if path exists
ls -la /usr/aarch64-linux-gnu/lib/

# Check for libc
ls -la /usr/aarch64-linux-gnu/lib/libc.so*
```

## Best Practices

1. **Use static linking** for standalone programs
   - Simplifies execution
   - No library path issues
   - More portable

2. **Verify binary type** before execution
   ```bash
   file program
   ```

3. **Test with simple program first**
   ```bash
   echo 'int main(){return 0;}' > test.c
   aarch64-linux-gnu-gcc -static test.c -o test
   qemu-aarch64 ./test
   ```

4. **Use binfmt for development** (if needed)
   - Automatic library resolution
   - Transparent execution

## Debugging with QEMU

### Static Binary
```bash
qemu-aarch64 -g 1234 ./program &
gdb-multiarch ./program
(gdb) target remote :1234
```

### Dynamic Binary
```bash
qemu-aarch64 -g 1234 -L /usr/aarch64-linux-gnu ./program &
gdb-multiarch ./program
(gdb) target remote :1234
```

## References

- QEMU User Mode Emulation Documentation
- [`../references/arm_architecture.md`](../references/arm_architecture.md) - ARM64 architecture
- [`cross_compilation.md`](./cross_compilation.md) - Cross-compilation guide
