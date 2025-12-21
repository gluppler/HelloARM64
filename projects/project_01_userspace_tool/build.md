# Build Instructions

## Prerequisites

- ARM64 toolchain (native or cross-compilation)
- Linux system (or QEMU for cross-compilation)

## Native Build (ARM64 Linux)

```bash
gcc -nostdlib -o cp_tool src/main.s
```

## Cross-Compilation (x86-64 → ARM64)

```bash
aarch64-linux-gnu-gcc -nostdlib -o cp_tool src/main.s
```

## Execution

### Native
```bash
./cp_tool source.txt dest.txt
```

### Cross-Compilation (with QEMU)
```bash
qemu-aarch64 ./cp_tool source.txt dest.txt
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

- **Permission denied**: Ensure executable bit is set (`chmod +x cp_tool`)
- **File not found**: Check file paths
- **Segmentation fault**: Use GDB to debug
