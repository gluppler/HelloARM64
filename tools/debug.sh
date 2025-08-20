#!/bin/bash
# tools/debug.sh
#
# Builds a file in debug mode and launches the appropriate debugger
# for the current operating system (lldb for macOS, gdb for Linux).

if [ $# -lt 1 ]; then
    echo "Usage: $0 <asm-file> [--bare]"
    exit 1
fi

# Build the file first, passing along any extra flags like --bare
./tools/build.sh "$@" --debug

# Determine the binary name from the input file
BASE=$(basename "$1" .s)
OUT="bin/$BASE"

# --- Platform Detection for Debugger ---
echo "[*] Launching debugger..."
if [ "$(uname)" = "Darwin" ]; then
    # Use lldb on macOS with the pre-configured script
    lldb -s tools/debug.lldb "$OUT"
else
    # Use gdb on Linux
    echo "Starting GDB for $OUT..."
    gdb "$OUT"
fi