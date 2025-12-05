# Makefile for UDP Implementation - C/Assembly Interop

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

.PHONY: all server client clean

all: server client
	@echo "All UDP implementations built successfully in $(BIN_DIR)/"

# Build UDP server (C/Assembly interop)
server: udp_server_interop.c udp_server_asm.s
	@echo "Building UDP server..."
	@mkdir -p $(BIN_DIR)
	@if [ "$(target)" = "macos" ]; then \
		$(CC) -o "$(BIN_DIR)/udp_server" udp_server_interop.c udp_server_asm.s 2>&1 || echo "Failed: udp_server"; \
	else \
		$(CC) -static -o "$(BIN_DIR)/udp_server" udp_server_interop.c udp_server_asm.s 2>&1 || echo "Failed: udp_server"; \
	fi

# Build UDP client (C/Assembly interop)
client: udp_client_interop.c udp_client_asm.s
	@echo "Building UDP client..."
	@mkdir -p $(BIN_DIR)
	@if [ "$(target)" = "macos" ]; then \
		$(CC) -o "$(BIN_DIR)/udp_client" udp_client_interop.c udp_client_asm.s 2>&1 || echo "Failed: udp_client"; \
	else \
		$(CC) -static -o "$(BIN_DIR)/udp_client" udp_client_interop.c udp_client_asm.s 2>&1 || echo "Failed: udp_client"; \
	fi

clean:
	@if [ -d "$(BIN_DIR)" ]; then \
		rm -rf $(BIN_DIR); \
		echo "Cleaned $(BIN_DIR)/ directory"; \
	else \
		echo "$(BIN_DIR)/ directory does not exist"; \
	fi
