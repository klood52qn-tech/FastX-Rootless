#!/bin/sh
set -eu

PROJECT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$PROJECT_DIR"

need() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "ERROR: required command not found: $1" >&2
        exit 1
    }
}

need file
need shasum
need otool
need lipo
need dpkg-deb
need ldid

if [ ! -d packages ]; then
    echo "ERROR: packages/ does not exist; run ./build.sh first" >&2
    exit 1
fi

DEB=$(find packages -maxdepth 1 -type f -name '*.deb' -print | head -1)
[ -n "$DEB" ] || { echo "ERROR: no .deb found in packages/" >&2; exit 1; }

echo "== Package metadata =="
dpkg-deb -I "$DEB"

echo "== Package contents =="
LIST=$(mktemp -t fastx-package-list.XXXXXX)
trap 'rm -f "$LIST"' EXIT
dpkg-deb -c "$DEB" > "$LIST"
cat "$LIST"

require_path() {
    grep -Fq "$1" "$LIST" || {
        echo "ERROR: expected package path missing: $1" >&2
        exit 1
    }
}

forbid_path() {
    if grep -Fq "$1" "$LIST"; then
        echo "ERROR: forbidden/legacy package path found: $1" >&2
        exit 1
    fi
}

require_path 'var/jb/Library/MobileSubstrate/DynamicLibraries/FastX.dylib'
require_path 'var/jb/Library/MobileSubstrate/DynamicLibraries/FastX.plist'
require_path 'var/jb/Library/PreferenceBundles/FastXPrefs.bundle/FastXPrefs'
require_path 'var/jb/Library/PreferenceBundles/FastXPrefs.bundle/Info.plist'
require_path 'var/jb/Library/PreferenceBundles/FastXPrefs.bundle/Root.plist'
require_path 'var/jb/Library/PreferenceLoader/Preferences/FastX.plist'
forbid_path 'FastXPrefs.bundle/FastX'
forbid_path 'Library/MobileSubstrate/DynamicLibraries/FastX.dylib.disabled'

if grep -E '(^|[[:space:]])(Library|usr|System|Applications)/' "$LIST" >/dev/null 2>&1; then
    echo "ERROR: a rootful-style package path was detected." >&2
    exit 1
fi

echo "== Control metadata checks =="
dpkg-deb -f "$DEB" Package | grep -Fxq 'org.cydia.kiimo.fastx' || { echo 'ERROR: package ID mismatch' >&2; exit 1; }
dpkg-deb -f "$DEB" Version | grep -Fxq '1.5.1' || { echo 'ERROR: package version mismatch' >&2; exit 1; }
dpkg-deb -f "$DEB" Architecture | grep -Fxq 'iphoneos-arm64' || { echo 'ERROR: package architecture mismatch' >&2; exit 1; }
dpkg-deb -f "$DEB" Depends | grep -Fq 'ellekit' || { echo 'ERROR: ElleKit dependency missing' >&2; exit 1; }

echo "== Mach-O artifacts =="
FOUND=0
for f in $(find .theos -type f \( -name 'FastX.dylib' -o -name 'FastXPrefs' \) -print 2>/dev/null); do
    FOUND=1
    echo "-- $f"
    file "$f"
    lipo -info "$f"
    otool -hv "$f" | head -5
    otool -l "$f" | grep -A3 -E 'LC_CODE_SIGNATURE|LC_RPATH' || true
    ldid -e "$f" >/dev/null 2>&1 || {
        echo "ERROR: ldid could not read the code signature: $f" >&2
        exit 1
    }
    shasum -a 256 "$f"
done

[ "$FOUND" -eq 1 ] || {
    echo "ERROR: no FastX Mach-O artifacts found under .theos" >&2
    exit 1
}

echo "== Package checksums =="
shasum -a 256 "$DEB"
echo "VERIFICATION: Rootless package layout, Mach-O format, architecture metadata, and ldid-readable code-signing metadata passed."
