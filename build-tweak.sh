#!/bin/sh
set -eu

PROJECT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$PROJECT_DIR"

if [ "$(uname -s)" != "Darwin" ]; then
    echo "ERROR: build-tweak.sh must run on macOS with Xcode and an iOS SDK." >&2
    exit 1
fi
if [ -z "${THEOS:-}" ] || [ ! -d "$THEOS" ]; then
    echo "ERROR: set THEOS to an existing Theos directory first." >&2
    exit 1
fi
if ! command -v xcrun >/dev/null 2>&1; then
    echo "ERROR: Xcode command-line tools are not available." >&2
    exit 1
fi
if ! xcrun --sdk iphoneos --show-sdk-path >/dev/null 2>&1; then
    echo "ERROR: a working iPhoneOS SDK was not found through Xcode." >&2
    exit 1
fi

make clean
make FastX THEOS_PACKAGE_SCHEME=rootless FINALPACKAGE=1

rm -rf "$PROJECT_DIR/built-tweak"
mkdir -p "$PROJECT_DIR/built-tweak"

FOUND=0
for candidate in $(find .theos/obj -type f -name 'FastX.dylib' -print 2>/dev/null); do
    cp "$candidate" "$PROJECT_DIR/built-tweak/$(basename "$(dirname "$candidate")")-FastX.dylib"
    FOUND=1
done

if [ "$FOUND" -ne 1 ]; then
    echo "ERROR: no FastX.dylib artifact was found." >&2
    exit 1
fi

echo "Rootless tweak build completed:"
find "$PROJECT_DIR/built-tweak" -type f -name '*.dylib' -exec file {} \;
