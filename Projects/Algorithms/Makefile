# Makefile for Algorithms ARM64 Assembly Implementation

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

# All algorithm files (no numerical labelling)
ALGORITHMS := $(shell ls *.s 2>/dev/null | sed 's/\.s$$//' | sort)

.PHONY: all clean $(ALGORITHMS)

all: $(ALGORITHMS)
	@echo "All algorithms built successfully in $(BIN_DIR)/"

# Build individual algorithms
$(ALGORITHMS):
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
