#!/usr/bin/env bash
# tools/build.sh
# Usage: ./tools/build.sh <path-to-.s> [--target=linux|macos] [--bare] [--debug]
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <asm-file> [--target=linux|macos] [--bare] [--debug]"
  exit 1
fi

ASM="$1"; shift || true
TARGET="macos"
BARE=false
DEBUG=false

for ARG in "$@"; do
  case "$ARG" in
    --target=linux) TARGET="linux" ;;
    --target=macos) TARGET="macos" ;;
    --bare) BARE=true ;;
    --debug) DEBUG=true ;;
    *) ;;
  esac
done

BIN_DIR="bin"
mkdir -p "$BIN_DIR"
BASE=$(basename "$ASM" .s)
OUT="$BIN_DIR/$BASE"

DIR=$(dirname "$ASM")
C="$DIR/$BASE.c"

echo "[*] Building $ASM for target=$TARGET (bare=$BARE, debug=$DEBUG) -> $OUT"

if [ "$TARGET" = "macos" ]; then
  # macOS native clang
  if [ -f "$C" ]; then
    clang -arch arm64 -o "$OUT" "$C" "$ASM"
  else
    if [ "$BARE" = true ]; then
      clang -arch arm64 -nostartfiles -o "$OUT" "$ASM"
    else
      clang -arch arm64 -o "$OUT" "$ASM"
    fi
  fi

elif [ "$TARGET" = "linux" ]; then
  # prefer aarch64-linux-gnu-gcc if present
  if command -v aarch64-linux-gnu-gcc >/dev/null 2>&1; then
    CC="aarch64-linux-gnu-gcc"
  elif command -v clang >/dev/null 2>&1; then
    CC="clang --target=aarch64-linux-gnu"
  else
    echo "No cross-compiler found. Install aarch64-linux-gnu-gcc or clang."
    exit 1
  fi

  if [ -f "$C" ]; then
    if [[ "$CC" == *clang* ]]; then
      clang --target=aarch64-linux-gnu -o "$OUT" "$C" "$ASM"
    else
      $CC -o "$OUT" "$C" "$ASM"
    fi
  else
    if [ "$BARE" = true ]; then
      if [[ "$CC" == *clang* ]]; then
        clang --target=aarch64-linux-gnu -nostartfiles -o "$OUT" "$ASM"
      else
        $CC -nostartfiles -o "$OUT" "$ASM"
      fi
    else
      if [[ "$CC" == *clang* ]]; then
        clang --target=aarch64-linux-gnu -o "$OUT" "$ASM"
      else
        $CC -o "$OUT" "$ASM"
      fi
    fi
  fi
else
  echo "Unknown target: $TARGET"
  exit 1
fi

if [ "$DEBUG" = true ]; then
  echo "[*] Debug mode requested."
  if [ "$TARGET" = "macos" ]; then
    echo "[*] Launching lldb..."
    lldb "$OUT"
  else
    echo "Debugging cross-compiled Linux binary is not automated here. Use QEMU/GDB or run on a Linux/aarch64 host."
  fi
else
  echo "[*] Running: $OUT"
  if [ "$TARGET" = "linux" ]; then
    echo "Note: Linux AArch64 binaries may not run natively on macOS. Use qemu-aarch64 or run on an aarch64 host."
  fi
  "$OUT" || true
fi
