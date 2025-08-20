#!/usr/bin/env bash
# tools/build.sh
#
# Builds bare-metal or systems (C++) projects.
# Automatically detects the OS and the project type (bare vs. systems).
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <asm-file> [--bare] [--debug]"
  exit 1
fi

ASM="$1"; shift || true
BARE=false
DEBUG=false

# --- Platform Detection ---
if [ "$(uname)" = "Darwin" ]; then
  TARGET="macos"
else
  TARGET="linux"
fi

for ARG in "$@"; do
  case "$ARG" in
    --bare) BARE=true ;;
    --debug) DEBUG=true ;;
    *) ;;
  esac
done

BIN_DIR="bin"
mkdir -p "$BIN_DIR"
BASE=$(basename "$ASM" .s)
OUT="$BIN_DIR/$BASE"

# For systems builds, find the main.cpp in the same directory.
DIR=$(dirname "$ASM")
CPP_FILE="$DIR/main.cpp"
MAIN_SRC=""

if [ -f "$CPP_FILE" ]; then
  MAIN_SRC="$CPP_FILE"
fi

echo "[*] Building $ASM for target=$TARGET (bare=$BARE, debug=$DEBUG) -> $OUT"

# Select compilers based on the auto-detected target
if [ "$TARGET" = "macos" ]; then
  CC="clang"
  CXX="clang++"
else
  CC="gcc" # Use system's native gcc/g++ on Linux
  CXX="g++"
fi

# Build logic
if [ -n "$MAIN_SRC" ] && [ "$BARE" = false ]; then
  # Systems build (with C++)
  $CXX -std=c++17 -o "$OUT" "$MAIN_SRC" "$ASM"
else
  # Bare-metal build
  if [ "$BARE" = true ]; then
    if [ "$TARGET" = "macos" ]; then
      # On macOS, explicitly set the entry point to _start for bare-metal
      $CC -e _start -nostartfiles -o "$OUT" "$ASM"
    else
      $CC -nostartfiles -o "$OUT" "$ASM"
    fi
  else
    $CC -o "$OUT" "$ASM"
  fi
fi

echo "[*] Build complete: $OUT"

# The debug script will handle launching the debugger
if [ "$DEBUG" = true ]; then
  echo "[*] Debug build is ready."
fi