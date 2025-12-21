# Makefile for Project 03: Bare Metal Firmware
# Minimal firmware demonstrating boot, exceptions, and MMU
#
# Reference: See ../../references/mmu_and_translation.md for MMU documentation
# Reference: See ../../references/arm_architecture.md for boot process
# Reference: See ../../references/memory_management.md for memory setup

# Auto-detect host architecture
HOST_ARCH := $(shell uname -m)

# Auto-detect if we need cross-compilation
ifeq ($(HOST_ARCH),aarch64)
  # Native ARM64 - use native toolchain
  AS = as
  LD = ld
  OBJCOPY = objcopy
  QEMU = qemu-system-aarch64
  NATIVE = 1
else
  # Cross-compilation needed - use cross toolchain
  AS = aarch64-linux-gnu-as
  LD = aarch64-linux-gnu-ld
  OBJCOPY = aarch64-linux-gnu-objcopy
  QEMU = qemu-system-aarch64
  NATIVE = 0
endif

# Auto-detect QEMU system emulation availability
QEMU_AVAILABLE := $(shell which $(QEMU) 2>/dev/null)

# Project configuration
PROJECT = firmware
# Auto-detect available source files
SOURCES = $(wildcard *.s)
OBJECTS = $(SOURCES:.s=.o)
TARGET_ELF = $(PROJECT).elf
TARGET_BIN = $(PROJECT).bin
LINKER_SCRIPT = linker.ld

# Verify required files exist
REQUIRED_FILES = boot.s $(LINKER_SCRIPT)

# Compilation flags
ASFLAGS = 
LDFLAGS = -T $(LINKER_SCRIPT)

# QEMU configuration for bare metal
QEMU_MACHINE = virt
QEMU_CPU = cortex-a57
QEMU_MEM = 256M

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
			echo "✗ Error: QEMU system emulation not found: $(QEMU)"; \
			echo "  Install with: sudo pacman -S qemu-system-aarch64 (Arch) or sudo apt-get install qemu-system-aarch64 (Debian/Ubuntu)"; \
			exit 1; \
		fi; \
		echo "✓ QEMU system emulation found: $(QEMU_AVAILABLE)"; \
		if ! command -v $(AS) >/dev/null 2>&1; then \
			echo "✗ Error: Cross-assembler not found: $(AS)"; \
			echo "  Install with: sudo pacman -S aarch64-linux-gnu-binutils (Arch) or sudo apt-get install binutils-aarch64-linux-gnu (Debian/Ubuntu)"; \
			exit 1; \
		fi; \
		if ! command -v $(LD) >/dev/null 2>&1; then \
			echo "✗ Error: Cross-linker not found: $(LD)"; \
			echo "  Install with: sudo pacman -S aarch64-linux-gnu-binutils (Arch) or sudo apt-get install binutils-aarch64-linux-gnu (Debian/Ubuntu)"; \
			exit 1; \
		fi; \
		if ! command -v $(OBJCOPY) >/dev/null 2>&1; then \
			echo "✗ Error: Cross-objcopy not found: $(OBJCOPY)"; \
			echo "  Install with: sudo pacman -S aarch64-linux-gnu-binutils (Arch) or sudo apt-get install binutils-aarch64-linux-gnu (Debian/Ubuntu)"; \
			exit 1; \
		fi; \
		echo "✓ Cross-assembler found: $(shell which $(AS))"; \
		echo "✓ Cross-linker found: $(shell which $(LD))"; \
		echo "✓ Cross-objcopy found: $(shell which $(OBJCOPY))"; \
	else \
		echo "Mode: Native ARM64"; \
		if ! command -v $(AS) >/dev/null 2>&1 || ! command -v $(LD) >/dev/null 2>&1 || ! command -v $(OBJCOPY) >/dev/null 2>&1; then \
			echo "✗ Error: Native toolchain not complete"; \
			exit 1; \
		fi; \
		echo "✓ Native toolchain found"; \
	fi
	@echo ""

# Build target - assemble, link, and create binary
.PHONY: build
build: check-env check-files $(TARGET_BIN)

# Check required files exist
.PHONY: check-files
check-files:
	@echo "Checking required files..."
	@for file in $(REQUIRED_FILES); do \
		if [ ! -f $$file ]; then \
			echo "✗ Error: Required file not found: $$file"; \
			exit 1; \
		fi; \
	done
	@echo "✓ Required files found: $(REQUIRED_FILES)"
	@if [ -z "$(SOURCES)" ]; then \
		echo "✗ Error: No source files (*.s) found"; \
		exit 1; \
	fi
	@echo "✓ Source files found: $(SOURCES)"
	@echo ""

# Assemble source files
%.o: %.s
	@echo "Assembling $<..."
	@if [ "$<" = "boot.s" ]; then \
		echo "Reference: Boot process (../../references/arm_architecture.md)"; \
	fi
	@if [ "$<" = "exception_vectors.s" ]; then \
		echo "Reference: Exception handling (../../references/arm_architecture.md)"; \
	fi
	@if [ "$<" = "mmu_enable.s" ]; then \
		echo "Reference: MMU setup (../../references/mmu_and_translation.md)"; \
	fi
	$(AS) $(ASFLAGS) -o $@ $<

# Link object files into ELF
$(TARGET_ELF): $(OBJECTS) $(LINKER_SCRIPT)
	@echo "Linking $(TARGET_ELF)..."
	@echo "Reference: Memory layout (../../references/memory_management.md)"
	$(LD) $(LDFLAGS) -o $(TARGET_ELF) $(OBJECTS)

# Create binary from ELF
$(TARGET_BIN): $(TARGET_ELF)
	@echo "Creating binary $(TARGET_BIN)..."
	$(OBJCOPY) -O binary $(TARGET_ELF) $(TARGET_BIN)
	@echo "Build complete: $(TARGET_BIN)"

# Verify target - check binary format
.PHONY: verify
verify: $(TARGET_BIN)
	@echo "Verifying binary..."
	@# For bare metal, raw binary is expected (not ELF)
	@if [ -f $(TARGET_BIN) ] && [ -s $(TARGET_BIN) ]; then \
		echo "✓ Binary file exists and is non-empty"; \
		BIN_SIZE=$$(stat -c%s $(TARGET_BIN) 2>/dev/null || stat -f%z $(TARGET_BIN) 2>/dev/null || echo "unknown"); \
		echo "  Binary size: $$BIN_SIZE bytes"; \
	else \
		echo "✗ Error: Binary file missing or empty"; \
		exit 1; \
	fi
	@# Verify ELF format (before objcopy)
	@if readelf -h $(TARGET_ELF) 2>/dev/null | grep -qiE "(Machine.*AArch64|Machine.*ARM.*aarch64)"; then \
		echo "✓ ELF is ARM64 format"; \
	elif file $(TARGET_ELF) | grep -qiE "(ARM|aarch64)"; then \
		echo "✓ ELF is ARM64 format (verified via file command)"; \
	else \
		echo "✗ Error: ELF is not ARM64 format"; \
		echo "  ELF info:"; \
		file $(TARGET_ELF) || true; \
		readelf -h $(TARGET_ELF) 2>/dev/null | grep -i machine || true; \
		exit 1; \
	fi
	@echo "✓ Verification complete"

# Run target - execute with QEMU system emulation
.PHONY: run
run: $(TARGET_BIN)
	@echo "Running $(TARGET_BIN) with QEMU system emulation..."
	@echo "Reference: Bare metal execution (../../references/arm_architecture.md)"
	@echo "Machine: $(QEMU_MACHINE), CPU: $(QEMU_CPU), Memory: $(QEMU_MEM)"
	@if [ -z "$(QEMU_AVAILABLE)" ]; then \
		echo "✗ Error: QEMU system emulation not found"; \
		echo "  Install with: sudo pacman -S qemu-system-aarch64 (Arch) or sudo apt-get install qemu-system-aarch64 (Debian/Ubuntu)"; \
		exit 1; \
	fi
	@echo ""
	@echo "Note: QEMU window will open showing the bootloader."
	@echo "      UART output appears in the QEMU window."
	@echo "      To exit QEMU: Close the window, or press Ctrl+Alt+G then type 'quit'"
	@echo ""
	$(QEMU) \
		-M $(QEMU_MACHINE) \
		-cpu $(QEMU_CPU) \
		-m $(QEMU_MEM) \
		-display gtk \
		-serial vc \
		-semihosting \
		-semihosting-config target=native \
		-no-reboot \
		-kernel $(TARGET_BIN)

# Debug target - run with GDB
.PHONY: debug
debug: $(TARGET_BIN)
	@echo "Starting GDB debugging session..."
	@echo "Reference: See ../../references/debugging.md for debugging techniques"
	@echo "Starting QEMU with GDB server on port 1234..."
	@echo "In another terminal, run: gdb-multiarch $(TARGET_ELF)"
	@echo "Then in GDB: target remote :1234"
	@if [ -z "$(QEMU_AVAILABLE)" ]; then \
		echo "✗ Error: QEMU system emulation not found"; \
		exit 1; \
	fi
	$(QEMU) \
		-M $(QEMU_MACHINE) \
		-cpu $(QEMU_CPU) \
		-m $(QEMU_MEM) \
		-display gtk \
		-serial stdio \
		-kernel $(TARGET_BIN) \
		-gdb tcp::1234 \
		-S &
	@sleep 1
	@echo "QEMU GDB server running. Connect with: gdb-multiarch $(TARGET_ELF)"

# Clean target - remove build artifacts
.PHONY: clean
clean:
	@echo "Cleaning..."
	rm -f $(OBJECTS) $(TARGET_ELF) $(TARGET_BIN)
	@echo "Clean complete"

# Help target
.PHONY: help
help:
	@echo "Project 03: Bare Metal Firmware - Makefile"
	@echo ""
	@echo "Reference: ../../references/mmu_and_translation.md - MMU"
	@echo "Reference: ../../references/arm_architecture.md - Boot process"
	@echo "Reference: ../../references/memory_management.md - Memory"
	@echo ""
	@echo "Environment: Auto-detected"
	@echo "  Host: $(HOST_ARCH)"
	@if [ "$(NATIVE)" = "0" ]; then \
		echo "  Mode: Cross-compilation (requires QEMU system emulation)"; \
		echo "  QEMU: $(if $(QEMU_AVAILABLE),$(QEMU_AVAILABLE),not found)"; \
	else \
		echo "  Mode: Native ARM64"; \
	fi
	@echo ""
	@echo "Targets:"
	@echo "  make          - Check environment, build and verify (default)"
	@echo "  make build    - Assemble, link, and create binary"
	@echo "  make verify   - Verify binary format"
	@echo "  make run      - Run with QEMU system emulation (opens graphical window)"
	@echo "  make debug    - Run with GDB server"
	@echo "  make clean    - Remove build artifacts"
	@echo "  make help     - Show this help"
	@echo ""
	@echo "Note: This project requires QEMU system emulation (qemu-system-aarch64)"
	@echo "      not user-mode emulation (qemu-aarch64)"
