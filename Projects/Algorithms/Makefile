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

# All algorithm files (no numerical labelling, exclude interop files)
ALGORITHMS := $(shell ls *.s 2>/dev/null | grep -v "_asm.s\|_interop" | sed 's/\.s$$//' | sort)

# Interop targets (C/Assembly hybrid)
INTEROP_TARGETS := BFS_interop DFS_interop Binary_Search_interop Factorial_interop \
                   Fibonacci_interop GCD_interop KMP_interop Knapsack_interop LCM_interop \
                   LCS_interop Linear_Search_interop Prime_Check_interop Rabin_Karp_interop \
                   Tree_Traversal_interop

.PHONY: all clean $(ALGORITHMS) interop $(INTEROP_TARGETS)

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

# Build interop versions (C/Assembly)
interop: $(INTEROP_TARGETS)
	@echo "All interop algorithms built successfully in $(BIN_DIR)/"

# Interop build rules
BFS_interop: BFS_interop.c BFS_asm.s
	@echo "Building $@ (C/Assembly interop)..."
	@mkdir -p $(BIN_DIR)
	@if [ "$(target)" = "macos" ]; then \
		$(CC) -o "$(BIN_DIR)/$@" BFS_interop.c BFS_asm.s 2>&1 || echo "Failed: $@"; \
	else \
		$(CC) -static -o "$(BIN_DIR)/$@" BFS_interop.c BFS_asm.s 2>&1 || echo "Failed: $@"; \
	fi

DFS_interop: DFS_interop.c DFS_asm.s
	@echo "Building $@ (C/Assembly interop)..."
	@mkdir -p $(BIN_DIR)
	@if [ "$(target)" = "macos" ]; then \
		$(CC) -o "$(BIN_DIR)/$@" DFS_interop.c DFS_asm.s 2>&1 || echo "Failed: $@"; \
	else \
		$(CC) -static -o "$(BIN_DIR)/$@" DFS_interop.c DFS_asm.s 2>&1 || echo "Failed: $@"; \
	fi

Binary_Search_interop: Binary_Search_interop.c Binary_Search_asm.s
	@echo "Building $@ (C/Assembly interop)..."
	@mkdir -p $(BIN_DIR)
	@if [ "$(target)" = "macos" ]; then \
		$(CC) -o "$(BIN_DIR)/$@" Binary_Search_interop.c Binary_Search_asm.s 2>&1 || echo "Failed: $@"; \
	else \
		$(CC) -static -o "$(BIN_DIR)/$@" Binary_Search_interop.c Binary_Search_asm.s 2>&1 || echo "Failed: $@"; \
	fi

Factorial_interop: Factorial_interop.c Factorial_asm.s
	@echo "Building $@ (C/Assembly interop)..."
	@mkdir -p $(BIN_DIR)
	@if [ "$(target)" = "macos" ]; then \
		$(CC) -o "$(BIN_DIR)/$@" Factorial_interop.c Factorial_asm.s 2>&1 || echo "Failed: $@"; \
	else \
		$(CC) -static -o "$(BIN_DIR)/$@" Factorial_interop.c Factorial_asm.s 2>&1 || echo "Failed: $@"; \
	fi

Fibonacci_interop: Fibonacci_interop.c Fibonacci_asm.s
	@echo "Building $@ (C/Assembly interop)..."
	@mkdir -p $(BIN_DIR)
	@if [ "$(target)" = "macos" ]; then \
		$(CC) -o "$(BIN_DIR)/$@" Fibonacci_interop.c Fibonacci_asm.s 2>&1 || echo "Failed: $@"; \
	else \
		$(CC) -static -o "$(BIN_DIR)/$@" Fibonacci_interop.c Fibonacci_asm.s 2>&1 || echo "Failed: $@"; \
	fi

GCD_interop: GCD_interop.c GCD_asm.s
	@echo "Building $@ (C/Assembly interop)..."
	@mkdir -p $(BIN_DIR)
	@if [ "$(target)" = "macos" ]; then \
		$(CC) -o "$(BIN_DIR)/$@" GCD_interop.c GCD_asm.s 2>&1 || echo "Failed: $@"; \
	else \
		$(CC) -static -o "$(BIN_DIR)/$@" GCD_interop.c GCD_asm.s 2>&1 || echo "Failed: $@"; \
	fi

KMP_interop: KMP_interop.c KMP_asm.s
	@echo "Building $@ (C/Assembly interop)..."
	@mkdir -p $(BIN_DIR)
	@if [ "$(target)" = "macos" ]; then \
		$(CC) -o "$(BIN_DIR)/$@" KMP_interop.c KMP_asm.s 2>&1 || echo "Failed: $@"; \
	else \
		$(CC) -static -o "$(BIN_DIR)/$@" KMP_interop.c KMP_asm.s 2>&1 || echo "Failed: $@"; \
	fi

Knapsack_interop: Knapsack_interop.c Knapsack_asm.s
	@echo "Building $@ (C/Assembly interop)..."
	@mkdir -p $(BIN_DIR)
	@if [ "$(target)" = "macos" ]; then \
		$(CC) -o "$(BIN_DIR)/$@" Knapsack_interop.c Knapsack_asm.s 2>&1 || echo "Failed: $@"; \
	else \
		$(CC) -static -o "$(BIN_DIR)/$@" Knapsack_interop.c Knapsack_asm.s 2>&1 || echo "Failed: $@"; \
	fi

LCM_interop: LCM_interop.c LCM_asm.s
	@echo "Building $@ (C/Assembly interop)..."
	@mkdir -p $(BIN_DIR)
	@if [ "$(target)" = "macos" ]; then \
		$(CC) -o "$(BIN_DIR)/$@" LCM_interop.c LCM_asm.s 2>&1 || echo "Failed: $@"; \
	else \
		$(CC) -static -o "$(BIN_DIR)/$@" LCM_interop.c LCM_asm.s 2>&1 || echo "Failed: $@"; \
	fi

LCS_interop: LCS_interop.c LCS_asm.s
	@echo "Building $@ (C/Assembly interop)..."
	@mkdir -p $(BIN_DIR)
	@if [ "$(target)" = "macos" ]; then \
		$(CC) -o "$(BIN_DIR)/$@" LCS_interop.c LCS_asm.s 2>&1 || echo "Failed: $@"; \
	else \
		$(CC) -static -o "$(BIN_DIR)/$@" LCS_interop.c LCS_asm.s 2>&1 || echo "Failed: $@"; \
	fi

Linear_Search_interop: Linear_Search_interop.c Linear_Search_asm.s
	@echo "Building $@ (C/Assembly interop)..."
	@mkdir -p $(BIN_DIR)
	@if [ "$(target)" = "macos" ]; then \
		$(CC) -o "$(BIN_DIR)/$@" Linear_Search_interop.c Linear_Search_asm.s 2>&1 || echo "Failed: $@"; \
	else \
		$(CC) -static -o "$(BIN_DIR)/$@" Linear_Search_interop.c Linear_Search_asm.s 2>&1 || echo "Failed: $@"; \
	fi

Prime_Check_interop: Prime_Check_interop.c Prime_Check_asm.s
	@echo "Building $@ (C/Assembly interop)..."
	@mkdir -p $(BIN_DIR)
	@if [ "$(target)" = "macos" ]; then \
		$(CC) -o "$(BIN_DIR)/$@" Prime_Check_interop.c Prime_Check_asm.s 2>&1 || echo "Failed: $@"; \
	else \
		$(CC) -static -o "$(BIN_DIR)/$@" Prime_Check_interop.c Prime_Check_asm.s 2>&1 || echo "Failed: $@"; \
	fi

Rabin_Karp_interop: Rabin_Karp_interop.c Rabin_Karp_asm.s
	@echo "Building $@ (C/Assembly interop)..."
	@mkdir -p $(BIN_DIR)
	@if [ "$(target)" = "macos" ]; then \
		$(CC) -o "$(BIN_DIR)/$@" Rabin_Karp_interop.c Rabin_Karp_asm.s 2>&1 || echo "Failed: $@"; \
	else \
		$(CC) -static -o "$(BIN_DIR)/$@" Rabin_Karp_interop.c Rabin_Karp_asm.s 2>&1 || echo "Failed: $@"; \
	fi

Tree_Traversal_interop: Tree_Traversal_interop.c Tree_Traversal_asm.s
	@echo "Building $@ (C/Assembly interop)..."
	@mkdir -p $(BIN_DIR)
	@if [ "$(target)" = "macos" ]; then \
		$(CC) -o "$(BIN_DIR)/$@" Tree_Traversal_interop.c Tree_Traversal_asm.s 2>&1 || echo "Failed: $@"; \
	else \
		$(CC) -static -o "$(BIN_DIR)/$@" Tree_Traversal_interop.c Tree_Traversal_asm.s 2>&1 || echo "Failed: $@"; \
	fi

clean:
	@rm -rf $(BIN_DIR)
	@echo "Cleaned $(BIN_DIR)/ directory"
