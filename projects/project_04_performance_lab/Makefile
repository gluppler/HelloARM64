# Makefile for Project 04: Performance Lab
# Performance benchmarks and optimization analysis
#
# Reference: See ../../references/performance.md for optimization strategies
# Reference: See ../../references/instruction_set.md for instruction details
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
PROJECT = benchmarks
SOURCES = benchmarks.s
TARGET = $(PROJECT)

# Compilation flags
# -nostdlib: Don't use standard library (pure assembly)
# -static: Static linking for QEMU compatibility
# -O2: Optimization level for performance testing
# Reference: See ../../references/performance.md for optimization details
CFLAGS = -nostdlib -static -O2
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
		echo "⚠ Note: QEMU emulation may not reflect real hardware performance"; \
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
		echo "✓ Native execution provides accurate performance measurements"; \
		if ! command -v $(CC) >/dev/null 2>&1; then \
			echo "✗ Error: Compiler not found: $(CC)"; \
			exit 1; \
		fi; \
		echo "✓ Native compiler found: $(shell which $(CC))"; \
	fi
	@echo ""

# Build target - compile the benchmarks
.PHONY: build
build: check-env $(TARGET)

$(TARGET): $(SOURCES)
	@echo "Building $(TARGET)..."
	@echo "Reference: Performance optimization (../../references/performance.md)"
	@echo "Reference: Static linking for QEMU (../../tooling/qemu_execution.md)"
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
	@echo "✓ Verification complete"

# Run target - execute benchmarks (auto-detect native vs QEMU)
.PHONY: run
run: $(TARGET)
	@echo "Running performance benchmarks..."
	@echo "Reference: Performance analysis (../../references/performance.md)"
	@if [ "$(NATIVE)" = "1" ]; then \
		echo "Mode: Native execution (accurate performance measurements)"; \
		./$(TARGET); \
	else \
		echo "Mode: QEMU emulation"; \
		echo "⚠ Note: QEMU emulation may not reflect real hardware performance"; \
		echo "Reference: Static binary execution (../../tooling/qemu_execution.md)"; \
		$(QEMU) ./$(TARGET); \
	fi
	@echo ""
	@echo "Benchmark execution complete"

# Native run target (explicit native execution)
.PHONY: run-native
run-native: $(TARGET)
	@if [ "$(NATIVE)" = "0" ]; then \
		echo "⚠ Warning: Not on native ARM64, using QEMU instead"; \
		echo "⚠ Note: QEMU emulation may not reflect real hardware performance"; \
		make run; \
		exit 0; \
	fi
	@echo "Running performance benchmarks natively..."
	@echo "Reference: Performance analysis (../../references/performance.md)"
	@echo "Note: Native execution provides accurate performance measurements"
	@echo ""
	./$(TARGET)
	@echo ""
	@echo "Benchmark execution complete"

# Profile target - run with profiling
.PHONY: profile
profile: $(TARGET)
	@echo "Profiling benchmarks..."
	@echo "Reference: Performance measurement (../../references/performance.md)"
	@if [ "$(NATIVE)" = "1" ]; then \
		if command -v perf >/dev/null 2>&1; then \
			echo "Using perf for profiling..."; \
			perf stat ./$(TARGET); \
		else \
			echo "perf not available, using time..."; \
			time ./$(TARGET); \
		fi; \
	else \
		echo "⚠ Note: Profiling with QEMU may not be accurate"; \
		if command -v perf >/dev/null 2>&1; then \
			echo "Using perf for profiling (QEMU)..."; \
			perf stat $(QEMU) ./$(TARGET); \
		else \
			echo "perf not available, using time..."; \
			time $(QEMU) ./$(TARGET); \
		fi; \
	fi

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

# Test target - verify benchmarks run
.PHONY: test
test: $(TARGET)
	@echo "Testing benchmarks..."
	@echo "Reference: Performance testing (../../references/performance.md)"
	@if [ "$(NATIVE)" = "1" ]; then \
		if ./$(TARGET) > /dev/null 2>&1; then \
			echo "✓ Benchmarks executed successfully"; \
		else \
			echo "✗ Benchmark execution failed"; \
			exit 1; \
		fi; \
	else \
		if $(QEMU) ./$(TARGET) > /dev/null 2>&1; then \
			echo "✓ Benchmarks executed successfully"; \
		else \
			echo "✗ Benchmark execution failed"; \
			exit 1; \
		fi; \
	fi

# Clean target - remove build artifacts
.PHONY: clean
clean:
	@echo "Cleaning..."
	rm -f $(TARGET)
	@echo "Clean complete"

# Help target
.PHONY: help
help:
	@echo "Project 04: Performance Lab - Makefile"
	@echo ""
	@echo "Reference: ../../references/performance.md - Optimization"
	@echo "Reference: ../../references/instruction_set.md - Instructions"
	@echo "Reference: ../../tooling/qemu_execution.md - QEMU execution"
	@echo ""
	@echo "Environment: Auto-detected"
	@echo "  Host: $(HOST_ARCH)"
	@if [ "$(NATIVE)" = "0" ]; then \
		echo "  Mode: Cross-compilation (requires QEMU)"; \
		echo "  QEMU: $(if $(QEMU_AVAILABLE),$(QEMU_AVAILABLE),not found)"; \
		echo "  ⚠ Note: QEMU emulation may not reflect real hardware performance"; \
	else \
		echo "  Mode: Native ARM64 (accurate performance measurements)"; \
	fi
	@echo ""
	@echo "Targets:"
	@echo "  make          - Check environment, build and verify (default)"
	@echo "  make build    - Compile the benchmarks"
	@echo "  make verify   - Verify binary format and linking"
	@echo "  make run      - Run benchmarks with auto-detected method (QEMU or native)"
	@echo "  make run-native - Run benchmarks natively (ARM64 only, falls back to QEMU)"
	@echo "  make profile  - Run with performance profiling"
	@echo "  make test     - Verify benchmarks execute"
	@echo "  make debug    - Run with GDB server"
	@echo "  make clean    - Remove build artifacts"
	@echo "  make help     - Show this help"
	@echo ""
	@echo "Examples:"
	@echo "  make test"
	@echo "  make run"
	@echo "  make run-native  # For accurate performance measurements (native ARM64 only)"
