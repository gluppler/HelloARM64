#!/bin/bash
# tools/build.sh
# Build script for ARM64 assembly on Apple Silicon (macOS).
# Supports normal (_main) builds and bare-metal (_start) builds.

set -e

BIN_DIR="bin"
DEBUG_FLAG="-g"
mkdir -p "$BIN_DIR"

if [ $# -lt 1 ]; then
    echo "Usage: $0 <asm-file> [--debug] [--bare]"
    exit 1
fi

INPUT=$1
DEBUG_MODE=false
BARE_MODE=false

# Parse flags
shift || true
while [ $# -gt 0 ]; do
    case "$1" in
        --debug) DEBUG_MODE=true ;;
        --bare)  BARE_MODE=true ;;
    esac
    shift
done

BASE_NAME=$(basename "$INPUT" .s)
OUT_FILE="$BIN_DIR/$BASE_NAME"

echo "[*] Assembling $INPUT -> $OUT_FILE"

if [ "$BARE_MODE" = true ]; then
    clang $DEBUG_FLAG -nostartfiles -o "$OUT_FILE" "$INPUT"
else
    clang $DEBUG_FLAG -o "$OUT_FILE" "$INPUT"
fi

if [ "$DEBUG_MODE" = true ]; then
    echo "[*] Launching in LLDB"
    lldb -s tools/debug.lldb "$OUT_FILE"
else
    echo "[*] Running $OUT_FILE"
    "$OUT_FILE" || true
    echo "[*] Exit code: $?"
fi
