# Emulator vs Hardware

> **Reference**: For ARM64 architecture details relevant to emulation and hardware, see [`../references/arm_architecture.md`](../references/arm_architecture.md) and [`../references/external_links.md`](../references/external_links.md) for development tools.

## QEMU Emulation

### Advantages
- Run ARM64 on x86-64
- Easy setup and testing
- Good for development
- Cross-platform compatibility

### Limitations
- Performance overhead
- May not match hardware exactly
- Limited hardware features

### Usage
```bash
# For static binaries (recommended)
qemu-aarch64 ./program

# For dynamic binaries (requires library path)
qemu-aarch64 -L /usr/aarch64-linux-gnu ./program
```

### Static vs Dynamic Linking
- **Static linking** (`-static` flag): No library dependencies, works directly with QEMU
- **Dynamic linking**: Requires ARM64 library path with `-L` flag or binfmt support

## Native Hardware

### Advantages
- Full performance
- Real hardware behavior
- All features available
- Production-like environment

### Limitations
- Requires ARM64 hardware
- Less convenient for development
- Platform-specific

## When to Use Each

### Use Emulator For:
- Development and testing
- Learning and experimentation
- Cross-platform development
- Quick iteration

### Use Hardware For:
- Performance testing
- Final validation
- Production deployment
- Hardware-specific features

## References

- QEMU Documentation
- ARM Development Boards
- ARM Development Studio
