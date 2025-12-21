# Makefile for Project 02: C/Assembly Runtime
# Runtime library functions demonstrating C/Assembly interop
#
# Reference: See ../../references/calling_conventions.md for AAPCS64
# Reference: See ../../references/instruction_set.md for instructions
# Reference: See ../../tooling/qemu_execution.md for QEMU execution guide

# Auto-detect host architecture
HOST_ARCH := $(shell uname -m)

# Auto-detect if we need cross-compilation
ifeq ($(HOST_ARCH),aarch64)
  # Native ARM64 - use native toolchain
  AS = as
  CC = gcc
  QEMU = 
  NATIVE = 1
else
  # Cross-compilation needed - use cross toolchain
  AS = aarch64-linux-gnu-as
  CC = aarch64-linux-gnu-gcc
  QEMU = qemu-aarch64
  NATIVE = 0
endif

# Auto-detect QEMU availability
QEMU_AVAILABLE := $(shell which $(QEMU) 2>/dev/null)

# Auto-detect ARM64 library paths (for dynamic linking fallback)
ARM64_LIB_PATHS := /usr/aarch64-linux-gnu /usr/lib/aarch64-linux-gnu /usr/arm64-linux-gnu
ARM64_LIB_PATH := $(shell for path in $(ARM64_LIB_PATHS); do [ -d $$path/lib ] && echo $$path && break; done)

# Project configuration
PROJECT = test_program
SRCDIR = src
ASM_SOURCES = $(SRCDIR)/runtime.s
C_SOURCES = $(SRCDIR)/main.c
ASM_OBJECTS = $(ASM_SOURCES:.s=.o)
C_OBJECTS = $(C_SOURCES:.c=.o)
TARGET = $(PROJECT)

# Compilation flags
# -static: Static linking for QEMU compatibility
# Reference: See ../../tooling/qemu_execution.md for static linking details
CFLAGS = -Wall -Wextra -static
ASFLAGS = 

# Default target
.PHONY: all
all: check-env build verify

# Check environment and toolchain
.PHONY: check-env
check-env:
	@echo "=== Environment Detection ==="
	@echo "Host architecture: $(HOST_ARCH)"
	@if [ "$(NATIVE)" = "0" ]; then \
		echo "Mode: Cross-compilation (x86-64 -> ARM64)"; \
		if [ -z "$(QEMU_AVAILABLE)" ]; then \
			echo "✗ Error: QEMU not found. Install with: sudo pacman -S qemu-user-static (Arch) or sudo apt-get install qemu-user-static (Debian/Ubuntu)"; \
			exit 1; \
		fi; \
		echo "✓ QEMU found: $(QEMU_AVAILABLE)"; \
		if [ -z "$(ARM64_LIB_PATH)" ]; then \
			echo "⚠ Warning: ARM64 library path not found (using static linking)"; \
		else \
			echo "✓ ARM64 library path: $(ARM64_LIB_PATH)"; \
		fi; \
		if ! command -v $(CC) >/dev/null 2>&1; then \
			echo "✗ Error: Cross-compiler not found: $(CC)"; \
			echo "  Install with: sudo pacman -S aarch64-linux-gnu-gcc (Arch) or sudo apt-get install gcc-aarch64-linux-gnu (Debian/Ubuntu)"; \
			exit 1; \
		fi; \
		if ! command -v $(AS) >/dev/null 2>&1; then \
			echo "✗ Error: Cross-assembler not found: $(AS)"; \
			echo "  Install with: sudo pacman -S aarch64-linux-gnu-binutils (Arch) or sudo apt-get install binutils-aarch64-linux-gnu (Debian/Ubuntu)"; \
			exit 1; \
		fi; \
		echo "✓ Cross-compiler found: $(shell which $(CC))"; \
		echo "✓ Cross-assembler found: $(shell which $(AS))"; \
	else \
		echo "Mode: Native ARM64"; \
		if ! command -v $(CC) >/dev/null 2>&1; then \
			echo "✗ Error: Compiler not found: $(CC)"; \
			exit 1; \
		fi; \
		echo "✓ Native compiler found: $(shell which $(CC))"; \
	fi
	@echo ""

# Build target - compile assembly and C, then link
.PHONY: build
build: check-env $(TARGET)

# Compile assembly source
$(ASM_OBJECTS): $(ASM_SOURCES)
	@echo "Assembling $(ASM_SOURCES)..."
	@echo "Reference: AAPCS64 calling convention (../../references/calling_conventions.md)"
	$(AS) $(ASFLAGS) -o $@ $<

# Compile C source
$(C_OBJECTS): $(C_SOURCES)
	@echo "Compiling $(C_SOURCES)..."
	$(CC) $(CFLAGS) -c -o $@ $<

# Link object files
$(TARGET): $(ASM_OBJECTS) $(C_OBJECTS)
	@echo "Linking $(TARGET)..."
	@echo "Reference: Static linking for QEMU (../../tooling/qemu_execution.md)"
	$(CC) $(CFLAGS) -o $(TARGET) $(ASM_OBJECTS) $(C_OBJECTS)
	@echo "Build complete: $(TARGET)"

# Verify target - check binary type
.PHONY: verify
verify: $(TARGET)
	@echo "Verifying binary..."
	@if file $(TARGET) | grep -q "statically linked"; then \
		echo "✓ Binary is statically linked (QEMU compatible)"; \
	else \
		echo "✗ Warning: Binary is not statically linked"; \
		exit 1; \
	fi
	@if readelf -h $(TARGET) 2>/dev/null | grep -qiE "(Machine.*AArch64|Machine.*ARM.*aarch64)"; then \
		echo "✓ Binary is ARM64 format"; \
	elif file $(TARGET) | grep -qiE "(ARM|aarch64)"; then \
		echo "✓ Binary is ARM64 format (verified via file command)"; \
	else \
		echo "✗ Error: Binary is not ARM64 format"; \
		echo "  Binary info:"; \
		file $(TARGET) || true; \
		readelf -h $(TARGET) 2>/dev/null | grep -i machine || true; \
		exit 1; \
	fi

# Run target - execute the program (auto-detect native vs QEMU)
.PHONY: run
run: $(TARGET)
	@echo "Running $(TARGET)..."
	@if [ "$(NATIVE)" = "1" ]; then \
		echo "Mode: Native execution"; \
		./$(TARGET); \
	else \
		echo "Mode: QEMU emulation"; \
		echo "Reference: Static binary execution (../../tooling/qemu_execution.md)"; \
		$(QEMU) ./$(TARGET); \
	fi

# Native run target (explicit native execution)
.PHONY: run-native
run-native: $(TARGET)
	@if [ "$(NATIVE)" = "0" ]; then \
		echo "⚠ Warning: Not on native ARM64, using QEMU instead"; \
		make run; \
		exit 0; \
	fi
	@echo "Running $(TARGET) natively..."
	./$(TARGET)

# Debug target - run with GDB
.PHONY: debug
debug: $(TARGET)
	@echo "Starting GDB debugging session..."
	@echo "Reference: See ../../references/debugging.md for debugging techniques"
	@if [ "$(NATIVE)" = "1" ]; then \
		echo "Mode: Native debugging"; \
		echo "Run: gdb $(TARGET)"; \
		echo "Then: run"; \
	else \
		echo "Mode: QEMU remote debugging"; \
		echo "Starting QEMU with GDB server on port 1234..."; \
		echo "In another terminal, run: gdb-multiarch $(TARGET)"; \
		echo "Then in GDB: target remote :1234"; \
		$(QEMU) -g 1234 ./$(TARGET) & \
		sleep 1; \
		echo "QEMU GDB server running. Connect with: gdb-multiarch $(TARGET)"; \
	fi

# Test target - verify runtime functions work
.PHONY: test
test: $(TARGET)
	@echo "Testing runtime functions..."
	@echo "Reference: Testing AAPCS64 compliance (../../references/calling_conventions.md)"
	@if [ "$(NATIVE)" = "1" ]; then \
		./$(TARGET); \
	else \
		$(QEMU) ./$(TARGET); \
	fi
	@echo "✓ Runtime functions test complete"

# Clean target - remove build artifacts
.PHONY: clean
clean:
	@echo "Cleaning..."
	rm -f $(TARGET) $(ASM_OBJECTS) $(C_OBJECTS)
	@echo "Clean complete"

# Help target
.PHONY: help
help:
	@echo "Project 02: C/Assembly Runtime - Makefile"
	@echo ""
	@echo "Reference: ../../references/calling_conventions.md - AAPCS64"
	@echo "Reference: ../../references/instruction_set.md - Instructions"
	@echo "Reference: ../../tooling/qemu_execution.md - QEMU execution"
	@echo ""
	@echo "Environment: Auto-detected"
	@echo "  Host: $(HOST_ARCH)"
	@if [ "$(NATIVE)" = "0" ]; then \
		echo "  Mode: Cross-compilation (requires QEMU)"; \
		echo "  QEMU: $(if $(QEMU_AVAILABLE),$(QEMU_AVAILABLE),not found)"; \
	else \
		echo "  Mode: Native ARM64"; \
	fi
	@echo ""
	@echo "Targets:"
	@echo "  make          - Check environment, build and verify (default)"
	@echo "  make build    - Compile assembly and C, then link"
	@echo "  make verify   - Verify binary format and linking"
	@echo "  make run      - Run with auto-detected method (QEMU or native)"
	@echo "  make test     - Run automated test"
	@echo "  make run-native - Run natively (ARM64 only, falls back to QEMU)"
	@echo "  make debug    - Run with GDB server"
	@echo "  make clean    - Remove build artifacts"
	@echo "  make help     - Show this help"
	@echo ""
	@echo "Examples:"
	@echo "  make test"
	@echo "  make run"
