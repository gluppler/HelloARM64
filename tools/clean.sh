#!/bin/bash
# tools/clean.sh
# Wipe bin/ and temporary files

echo "[*] Cleaning project..."
rm -rf bin/*
find . -name "*.o" -delete
echo "[*] Done."
