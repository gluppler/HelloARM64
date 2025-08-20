# Makefile for the HelloARM64 Project

# --- Platform Detection ---
# Automatically detect the OS and set the default target.
# This makes the Makefile platform-agnostic.
ifeq ($(shell uname), Darwin)
    target ?= macos
else
    target ?= linux
endif

# Default to the bare-metal sample file for a quick first test.
file ?= sample/baremetal-test/hello-bare.s

# Define phony targets to prevent conflicts with file names.
.PHONY: all build bare debug clean

# The 'all' target is a default that will run the bare-metal sample.
all:
	@echo "Running the default bare-metal sample for target: $(target)"
	@$(MAKE) bare file=$(file) target=$(target)
	@echo "\nTo build a specific file, use 'make bare file=...' or 'make build file=...'"

# --- Main Targets ---

# `make build` - For systems (C++/Assembly) projects.
build:
	@./tools/build.sh $(file) --target=$(target)

# `make bare` - For bare-metal (pure Assembly) projects.
bare:
	@./tools/build.sh $(file) --target=$(target) --bare

# `make debug` - Builds a file and launches the debugger.
debug:
	@./tools/build.sh $(file) --target=$(target) --debug

# `make clean` - Removes all compiled binaries and temporary files.
clean:
	@./tools/clean.sh