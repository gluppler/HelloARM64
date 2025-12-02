# Makefile for the HelloARM64 Project

# --- Platform Detection ---
# Automatically detect the OS and set the default target.
# This makes the Makefile platform-agnostic.
ifeq ($(shell uname), Darwin)
    target ?= macos
    CC := clang
    CXX := clang++
else
    target ?= linux
    CC := aarch64-linux-gnu-gcc
    CXX := aarch64-linux-gnu-g++
endif

# Default to the bare-metal sample file for a quick first test.
file ?= sample/baremetal-test/hello-bare.s

# Define phony targets to prevent conflicts with file names.
.PHONY: all build bare debug clean fundamentals clean-fundamentals

# The 'all' target is a default that will run the bare-metal sample.
all:
	@echo "Running the default bare-metal sample for target: $(target)"
	@$(MAKE) bare file=$(file) target=$(target)
	@echo "\nTo build a specific file, use 'make bare file=...' or 'make build file=...'"

# --- Main Targets ---

# `make build` - For systems (C++/Assembly) projects.
# Note: Requires tools/build.sh script
build:
	@if [ -f ./tools/build.sh ]; then \
		./tools/build.sh $(file) --target=$(target); \
	else \
		echo "Error: tools/build.sh not found. Please create build scripts or use direct compilation."; \
		exit 1; \
	fi

# `make bare` - For bare-metal (pure Assembly) projects.
# Note: Requires tools/build.sh script
bare:
	@if [ -f ./tools/build.sh ]; then \
		./tools/build.sh $(file) --target=$(target) --bare; \
	else \
		echo "Error: tools/build.sh not found. Use 'make fundamentals' to build Fundamentals examples."; \
		exit 1; \
	fi

# `make debug` - Builds a file and launches the debugger.
# Note: Requires tools/build.sh script
debug:
	@if [ -f ./tools/build.sh ]; then \
		./tools/build.sh $(file) --target=$(target) --debug; \
	else \
		echo "Error: tools/build.sh not found."; \
		exit 1; \
	fi

# `make fundamentals` - Build all Fundamentals examples
fundamentals:
	@echo "Building Fundamentals examples for target: $(target)"
	@mkdir -p bin/fundamentals
	@for f in Fundamentals/*.s; do \
		name=$$(basename "$$f" .s); \
		echo "Compiling $$name..."; \
		if [ "$(target)" = "macos" ]; then \
			$(CC) -e _start -nostartfiles -o "bin/fundamentals/$$name" "$$f" 2>&1 || echo "Failed: $$name"; \
		else \
			$(CC) -nostartfiles -static -o "bin/fundamentals/$$name" "$$f" 2>&1 || echo "Failed: $$name"; \
		fi \
	done
	@echo "Fundamentals build complete. Binaries in bin/fundamentals/"

# `make clean` - Removes all compiled binaries and temporary files.
clean:
	@if [ -f ./tools/clean.sh ]; then \
		./tools/clean.sh; \
	else \
		rm -rf bin/*; \
		echo "Cleaned bin/ directory"; \
	fi

# `make clean-fundamentals` - Removes only Fundamentals binaries
clean-fundamentals:
	@rm -rf bin/fundamentals
	@echo "Cleaned bin/fundamentals/ directory"