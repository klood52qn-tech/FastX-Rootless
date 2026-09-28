#!/bin/sh
set -eu

PROJECT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$PROJECT_DIR"

if [ "$(uname -s)" != "Darwin" ]; then
    echo "ERROR: build.sh must run on macOS with Xcode and an iOS SDK." >&2
    exit 1
fi

if [ -z "${THEOS:-}" ]; then
    echo "ERROR: THEOS is not set. Example: export THEOS=\"$HOME/theos\"" >&2
    exit 1
fi

if [ ! -d "$THEOS" ]; then
    echo "ERROR: THEOS directory does not exist: $THEOS" >&2
    exit 1
fi

command -v xcrun >/dev/null 2>&1 || {
    echo "ERROR: Xcode command-line tools are not available." >&2
    exit 1
}

SDK=$(xcrun --sdk iphoneos --show-sdk-path 2>/dev/null || true)
if [ -z "$SDK" ] || [ ! -d "$SDK" ]; then
    echo "ERROR: iPhoneOS SDK was not found through xcrun." >&2
    exit 1
fi

command -v ldid >/dev/null 2>&1 || {
    echo "ERROR: ldid is required. Install it with: brew install ldid" >&2
    exit 1
}
command -v dpkg-deb >/dev/null 2>&1 || {
    echo "ERROR: dpkg-deb is required. Install it with Homebrew." >&2
    exit 1
}
command -v fakeroot >/dev/null 2>&1 || {
    echo "ERROR: fakeroot is required by Theos packaging on macOS. Install it with Homebrew." >&2
    exit 1
}

export THEOS_PACKAGE_SCHEME=rootless
export THEOS

THEOS_VERSION=$(git -C "$THEOS" rev-parse --short HEAD 2>/dev/null || echo unknown)
XCODE_VERSION=$(xcodebuild -version | tr '\n' ' ')

echo "Theos: $THEOS ($THEOS_VERSION)"
echo "Xcode: $XCODE_VERSION"
echo "iPhoneOS SDK: $SDK"
echo "Cleaning previous build artifacts..."
make clean

rm -rf built-tweak
mkdir -p built-tweak

echo "Building FastX Rootless package..."
make package THEOS_PACKAGE_SCHEME=rootless FINALPACKAGE=1

echo "Building standalone tweak target for artifact export..."
make FastX THEOS_PACKAGE_SCHEME=rootless FINALPACKAGE=1

find "$PROJECT_DIR/packages" -maxdepth 1 -type f -name '*.deb' -print
