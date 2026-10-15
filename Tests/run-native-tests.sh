#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
output="$(mktemp -d "${TMPDIR:-/tmp}/swift-gfx-tests.XXXXXX")"
trap 'rm -rf "$output"' EXIT
# Set SANITIZE=1 to check memory safety; timings then include sanitizer overhead.
if [ "${SANITIZE:-0}" = 1 ]; then
    flags="-O1 -g -fsanitize=address,undefined -fno-omit-frame-pointer"
else
    flags="-O3"
fi
clang++ -std=c++14 $flags -DARDUINO=100 \
    -IShared/lib/inc -IShared/lib/Adafruit-GFX-Library -IShared/lib/VirtualDotMatrix \
    Tests/VirtualDotMatrixTests.cpp Shared/lib/VirtualDotMatrix/VirtualDotMatrix.cpp \
    Shared/lib/Adafruit-GFX-Library/Adafruit_GFX.cpp Shared/lib/inc/Print.cpp \
    -o "$output/tests"
"$output/tests"
