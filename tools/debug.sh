#!/bin/bash
# tools/debug.sh
# Build + debug with optional --bare flag

if [ $# -lt 1 ]; then
    echo "Usage: $0 <asm-file> [--bare]"
    exit 1
fi

./tools/build.sh "$@" --debug

