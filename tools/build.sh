#!/bin/bash
# tools/build.sh
# Universal build script for ARM64 assembly projects on Apple Silicon.
# Handles both bare-metal and systems-level builds (with optional C interop).

set -e  # exit on error

if [ $# -lt 1 ]; then
    echo "Usage: $0 <path-to-asm-file> [--bare] [--debug]"
    echo "Example: ./tools/build.sh examples/hello_world.s"
    exit 1
fi

ASM_FILE=$1
BASENAME=$(basename "$ASM_FILE" .s)
DIRNAME=$(dirname "$ASM_FILE")
OUT_FILE="bin/$BASENAME"

# Optional flags
MODE="normal"
DEBUG=false

for arg in "$@"; do
    case $arg in
        --bare) MODE="bare"; shift ;;
        --debug) DEBUG=true; shift ;;
    esac
done

mkdir -p bin

echo "[*] Building $ASM_FILE -> $OUT_FILE"

# Check if matching C file exists
C_FILE="$DIRNAME/$BASENAME.c"
if [ -f "$C_FILE" ]; then
    echo "[*] Detected companion C file: $C_FILE"
    # Systems track: compile C + ASM together
    clang -arch arm64 -Wall -o "$OUT_FILE" "$C_FILE" "$ASM_FILE"
else
    if [ "$MODE" = "bare" ]; then
        echo "[*] Bare-metal mode"
        clang -arch arm64 -nostdlib -o "$OUT_FILE" "$ASM_FILE"
    else
        echo "[*] Systems mode (assembly only)"
        clang -arch arm64 -o "$OUT_FILE" "$ASM_FILE"
    fi
fi

if [ "$DEBUG" = true ]; then
    echo "[*] Launching LLDB"
    lldb -s tools/debug.lldb "$OUT_FILE"
else
    echo "[*] Running $OUT_FILE"
    "$OUT_FILE" || true
    echo "[*] Exit code: $?"
fi
