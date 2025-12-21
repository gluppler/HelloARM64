# Build Instructions

## Prerequisites

- ARM64 toolchain (native or cross-compilation)
- Linux system (or QEMU for cross-compilation)

## Native Build (ARM64 Linux)

```bash
# Static linking (recommended for standalone programs)
gcc -nostdlib -static -o cp_tool src/main.s
```

## Cross-Compilation (x86-64 → ARM64)

```bash
# Static linking (recommended - no library dependencies)
aarch64-linux-gnu-gcc -nostdlib -static -o cp_tool src/main.s

# Verify it's statically linked
file cp_tool
# Should show: "statically linked"
```

## Execution

### Native
```bash
./cp_tool source.txt dest.txt
```

### Cross-Compilation (with QEMU)

#### Static Binary (Recommended)
```bash
# Static binaries don't need -L flag
qemu-aarch64 ./cp_tool source.txt dest.txt
```

#### Dynamic Binary (if not using -static)
```bash
# Install ARM64 rootfs first:
# sudo apt-get install qemu-user-binfmt
# Or specify library path:
qemu-aarch64 -L /usr/aarch64-linux-gnu ./cp_tool source.txt dest.txt
```

## Testing

```bash
# Create test file
echo "Hello, ARM64!" > test.txt

# Copy file
./cp_tool test.txt copy.txt

# Verify
cat copy.txt
```

## Troubleshooting

### Common Issues

#### "No such file or directory" Error
- **Cause**: Dynamic binary can't find ARM64 libraries
- **Solution**: Recompile with `-static` flag: `aarch64-linux-gnu-gcc -nostdlib -static -o cp_tool src/main.s`

#### "Exec format error"
- **Cause**: Binary format mismatch or missing interpreter
- **Solution**: Ensure static linking with `-static` flag, or use `qemu-aarch64 -L /usr/aarch64-linux-gnu ./cp_tool`

#### Permission denied
- **Solution**: Ensure executable bit is set (`chmod +x cp_tool`)

#### File not found
- **Solution**: Check file paths are correct

#### Segmentation fault
- **Solution**: Use GDB to debug: `qemu-aarch64 -g 1234 ./cp_tool &` then `gdb-multiarch ./cp_tool` and `target remote :1234`

### Verifying Static Linking
```bash
file cp_tool
# Should show: "statically linked" for QEMU compatibility
```
