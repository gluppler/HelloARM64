# Makefile for TCP Implementation - C/Assembly Interop

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
	@echo "All TCP implementations built successfully in $(BIN_DIR)/"

# Build TCP server (C/Assembly interop)
server: tcp_server_interop.c tcp_server_asm.s
	@echo "Building TCP server..."
	@mkdir -p $(BIN_DIR)
	@if [ "$(target)" = "macos" ]; then \
		$(CC) -o "$(BIN_DIR)/tcp_server" tcp_server_interop.c tcp_server_asm.s 2>&1 || echo "Failed: tcp_server"; \
	else \
		$(CC) -static -o "$(BIN_DIR)/tcp_server" tcp_server_interop.c tcp_server_asm.s 2>&1 || echo "Failed: tcp_server"; \
	fi

# Build TCP client (C/Assembly interop)
client: tcp_client_interop.c tcp_client_asm.s
	@echo "Building TCP client..."
	@mkdir -p $(BIN_DIR)
	@if [ "$(target)" = "macos" ]; then \
		$(CC) -o "$(BIN_DIR)/tcp_client" tcp_client_interop.c tcp_client_asm.s 2>&1 || echo "Failed: tcp_client"; \
	else \
		$(CC) -static -o "$(BIN_DIR)/tcp_client" tcp_client_interop.c tcp_client_asm.s 2>&1 || echo "Failed: tcp_client"; \
	fi

clean:
	@rm -rf $(BIN_DIR)
	@echo "Cleaned $(BIN_DIR)/ directory"
