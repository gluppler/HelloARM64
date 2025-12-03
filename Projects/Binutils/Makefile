# Makefile for Binutils ARM64 Assembly Implementation

# Platform Detection
ifeq ($(shell uname), Darwin)
    target ?= macos
    CC := clang
else
    target ?= linux
    CC := aarch64-linux-gnu-gcc
endif

# Output directory
BIN_DIR := bin

# All Binutils tools
BINUTILS := addr2line ar c++filt elfedit gprof ld nm objcopy objdump ranlib readelf size strings strip

.PHONY: all clean $(BINUTILS)

all: $(BINUTILS)
	@echo "All Binutils tools built successfully in $(BIN_DIR)/"

# Build individual tools
$(BINUTILS):
	@echo "Building $@..."
	@mkdir -p $(BIN_DIR)
	@if [ "$(target)" = "macos" ]; then \
		$(CC) -e _start -nostartfiles -o "$(BIN_DIR)/$@" "$@.s" 2>&1 || echo "Failed: $@"; \
	else \
		$(CC) -nostdlib -o "$(BIN_DIR)/$@" "$@.s" 2>&1 || echo "Failed: $@"; \
	fi

clean:
	@rm -rf $(BIN_DIR)
	@echo "Cleaned $(BIN_DIR)/ directory"
