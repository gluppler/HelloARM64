# Build Systems

> **Reference**: For ARM64 toolchain information, see [`../references/external_links.md`](../references/external_links.md) for official ARM documentation links.

## GNU Make

### Basic Makefile
```makefile
AS = aarch64-linux-gnu-as
LD = aarch64-linux-gnu-ld
CC = aarch64-linux-gnu-gcc

CFLAGS = -nostdlib
LDFLAGS = 

SRCDIR = src
BUILDDIR = build

SOURCES = $(wildcard $(SRCDIR)/*.s)
OBJECTS = $(SOURCES:$(SRCDIR)/%.s=$(BUILDDIR)/%.o)
TARGETS = $(SOURCES:$(SRCDIR)/%.s=$(BUILDDIR)/%)

all: $(TARGETS)

$(BUILDDIR)/%: $(BUILDDIR)/%.o
	$(CC) $(CFLAGS) -o $@ $<

$(BUILDDIR)/%.o: $(SRCDIR)/%.s
	$(AS) -o $@ $<

clean:
	rm -f $(BUILDDIR)/*

.PHONY: all clean
```

## CMake

### CMakeLists.txt
```cmake
cmake_minimum_required(VERSION 3.10)
project(ARM64Assembly)

set(CMAKE_ASM_COMPILER aarch64-linux-gnu-gcc)
set(CMAKE_ASM_FLAGS "-nostdlib")

add_executable(hello src/hello.s)
```

## Build Commands

### Native Build
```bash
gcc -nostdlib -o program program.s
```

### Cross-Compilation
```bash
aarch64-linux-gnu-gcc -nostdlib -o program program.s
```

### With Debugging
```bash
aarch64-linux-gnu-gcc -g -nostdlib -o program program.s
```

## References

- GNU Make Manual
- CMake Documentation
- GCC ARM Options
