# Makefile for Project 01: Userspace Tool
# ARM64 file copy utility demonstrating system calls
#
# Reference: See ../../references/syscalls.md for system call documentation
# Reference: See ../../references/calling_conventions.md for stack layout
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
# Try common paths for different distributions
ARM64_LIB_PATHS := /usr/aarch64-linux-gnu /usr/lib/aarch64-linux-gnu /usr/arm64-linux-gnu
ARM64_LIB_PATH := $(shell for path in $(ARM64_LIB_PATHS); do [ -d $$path/lib ] && echo $$path && break; done)

# Project configuration
PROJECT = cp_tool
SRCDIR = src
SOURCES = $(SRCDIR)/main.s
TARGET = $(PROJECT)
TEST_SRC = test.txt
TEST_DST = copy.txt

# Compilation flags
# -nostdlib: Don't use standard library (pure assembly)
# -static: Static linking for QEMU compatibility (no -L flag needed)
# Reference: See ../../tooling/qemu_execution.md for static linking details
CFLAGS = -nostdlib -static
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
		echo "✓ Cross-compiler found: $(shell which $(CC))"; \
	else \
		echo "Mode: Native ARM64"; \
		if ! command -v $(CC) >/dev/null 2>&1; then \
			echo "✗ Error: Compiler not found: $(CC)"; \
			exit 1; \
		fi; \
		echo "✓ Native compiler found: $(shell which $(CC))"; \
	fi
	@echo ""

# Build target - compile the program
.PHONY: build
build: check-env $(TARGET)

$(TARGET): $(SOURCES)
	@echo "Building $(TARGET)..."
	@echo "Reference: Using static linking for QEMU compatibility (../../tooling/qemu_execution.md)"
	@if [ "$(NATIVE)" = "0" ]; then \
		echo "Using cross-compiler: $(CC)"; \
	fi
	$(CC) $(CFLAGS) -o $(TARGET) $(SOURCES)
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
	@if [ -z "$(ARGS)" ]; then \
		echo "Usage: make run ARGS='source.txt dest.txt'"; \
		echo "Or: make test (uses test.txt -> copy.txt)"; \
		exit 1; \
	fi
	@echo "Running $(TARGET)..."
	@# Extract source and dest from ARGS
	@SOURCE_FILE=$$(echo $(ARGS) | awk '{print $$1}'); \
	DEST_FILE=$$(echo $(ARGS) | awk '{print $$2}'); \
	if [ -z "$$SOURCE_FILE" ] || [ -z "$$DEST_FILE" ]; then \
		echo "✗ Error: Invalid arguments. Expected: make run ARGS='source.txt dest.txt'"; \
		exit 1; \
	fi; \
	if [ ! -f "$$SOURCE_FILE" ]; then \
		echo "✗ Error: Source file not found: $$SOURCE_FILE"; \
		echo "  Current directory: $$(pwd)"; \
		echo "  Available files:"; \
		ls -la *.txt 2>/dev/null || echo "    (no .txt files found)"; \
		exit 1; \
	fi; \
	echo "Source file: $$SOURCE_FILE (exists)"; \
	echo "Destination file: $$DEST_FILE"; \
	if [ "$(NATIVE)" = "1" ]; then \
		echo "Mode: Native execution"; \
		./$(TARGET) $$SOURCE_FILE $$DEST_FILE; \
	else \
		echo "Mode: QEMU emulation"; \
		echo "Reference: Static binary execution (../../tooling/qemu_execution.md)"; \
		$(QEMU) ./$(TARGET) $$SOURCE_FILE $$DEST_FILE; \
	fi; \
	if [ $$? -eq 0 ] && [ -f "$$DEST_FILE" ]; then \
		echo "✓ Copy successful: $$SOURCE_FILE -> $$DEST_FILE"; \
	fi

# Test target - run with test files
.PHONY: test
test: $(TARGET)
	@echo "Testing $(TARGET)..."
	@echo "Creating test file: $(TEST_SRC)"
	@echo "Hello, ARM64 from $(TARGET)!" > $(TEST_SRC)
	@echo "Test file created: $(TEST_SRC)"
	@ls -lh $(TEST_SRC) || true
	@echo "Running: $(TARGET) $(TEST_SRC) $(TEST_DST)"
	@if [ "$(NATIVE)" = "1" ]; then \
		echo "Mode: Native execution"; \
		./$(TARGET) $(TEST_SRC) $(TEST_DST); \
		EXIT_CODE=$$?; \
	else \
		echo "Mode: QEMU emulation"; \
		echo "Reference: Static binary execution (../../tooling/qemu_execution.md)"; \
		$(QEMU) ./$(TARGET) $(TEST_SRC) $(TEST_DST); \
		EXIT_CODE=$$?; \
	fi; \
	if [ $$EXIT_CODE -ne 0 ]; then \
		echo "✗ Copy failed with exit code $$EXIT_CODE"; \
		echo "Debugging info:"; \
		echo "  Source file exists: $$([ -f $(TEST_SRC) ] && echo 'yes' || echo 'no')"; \
		echo "  Source file readable: $$([ -r $(TEST_SRC) ] && echo 'yes' || echo 'no')"; \
		echo "  Current directory: $$(pwd)"; \
		echo "  Binary exists: $$([ -f $(TARGET) ] && echo 'yes' || echo 'no')"; \
		exit $$EXIT_CODE; \
	fi
	@echo "Verifying copy..."
	@if [ -f $(TEST_DST) ]; then \
		echo "✓ Copy successful!"; \
		echo "Contents of $(TEST_DST):"; \
		cat $(TEST_DST); \
		echo ""; \
		echo "File sizes:"; \
		ls -lh $(TEST_SRC) $(TEST_DST) || true; \
	else \
		echo "✗ Copy failed - destination file not found"; \
		echo "Debugging info:"; \
		echo "  Source file: $$([ -f $(TEST_SRC) ] && echo 'exists' || echo 'missing')"; \
		echo "  Destination file: $$([ -f $(TEST_DST) ] && echo 'exists' || echo 'missing')"; \
		exit 1; \
	fi

# Native run target (explicit native execution)
.PHONY: run-native
run-native: $(TARGET)
	@if [ "$(NATIVE)" = "0" ]; then \
		echo "⚠ Warning: Not on native ARM64, using QEMU instead"; \
		make run ARGS="$(ARGS)"; \
		exit 0; \
	fi
	@if [ -z "$(ARGS)" ]; then \
		echo "Usage: make run-native ARGS='source.txt dest.txt'"; \
		exit 1; \
	fi
	@echo "Running $(TARGET) natively..."
	./$(TARGET) $(ARGS)

# Debug target - run with GDB
.PHONY: debug
debug: $(TARGET)
	@echo "Starting GDB debugging session..."
	@echo "Reference: See ../../references/debugging.md for debugging techniques"
	@if [ "$(NATIVE)" = "1" ]; then \
		echo "Mode: Native debugging"; \
		echo "Run: gdb $(TARGET)"; \
		echo "Then: run $(ARGS)"; \
	else \
		echo "Mode: QEMU remote debugging"; \
		echo "Starting QEMU with GDB server on port 1234..."; \
		echo "In another terminal, run: gdb-multiarch $(TARGET)"; \
		echo "Then in GDB: target remote :1234"; \
		$(QEMU) -g 1234 ./$(TARGET) $(ARGS) & \
		sleep 1; \
		echo "QEMU GDB server running. Connect with: gdb-multiarch $(TARGET)"; \
	fi

# Clean target - remove build artifacts
.PHONY: clean
clean:
	@echo "Cleaning..."
	rm -f $(TARGET) $(TEST_DST)
	@echo "Clean complete"

# Help target
.PHONY: help
help:
	@echo "Project 01: Userspace Tool - Makefile"
	@echo ""
	@echo "Reference: ../../references/syscalls.md - System calls"
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
	@echo "  make build    - Compile the program"
	@echo "  make verify   - Verify binary format and linking"
	@echo "  make run      - Run with auto-detected method (QEMU or native)"
	@echo "  make test     - Run automated test (test.txt -> copy.txt)"
	@echo "  make run-native - Run natively (ARM64 only, falls back to QEMU)"
	@echo "  make debug    - Run with GDB server"
	@echo "  make clean    - Remove build artifacts"
	@echo "  make help     - Show this help"
	@echo ""
	@echo "Examples:"
	@echo "  make test"
	@echo "  make run ARGS='source.txt dest.txt'"
