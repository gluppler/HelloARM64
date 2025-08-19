#!/bin/bash
# tools/run.sh
# Run a binary by name from bin/

if [ $# -lt 1 ]; then
    echo "Usage: $0 <program-name>"
    exit 1
fi

BIN_FILE="bin/$1"
if [ -x "$BIN_FILE" ]; then
    echo "[*] Running $BIN_FILE"
    "$BIN_FILE"
    echo "[*] Exit code: $?"
else
    echo "Error: $BIN_FILE not found or not executable."
fi
