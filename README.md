# FastX Rootless — Theos source project

This project is a clean-source Rootless reimplementation of the original FastX behavior that can be identified from the supplied binary. It builds both the `FastX` tweak target and a source-backed `FastXPrefs` PreferenceBundle, so the settings bundle no longer depends on a copied legacy executable. The package is intended for Dopamine's ElleKit injection environment rather than the old rootful CydiaSubstrate layout.

## Reconstructed behavior

The original binary contains Logos hooks for `UIViewAnimationState`, `UIViewInProcessAnimationState`, `UIPopoverBackgroundView`, `SBCoverSheetTranstionSettings`, and `SBFluidSwitcherViewController`. The source therefore suppresses layer actions and animation objects while `com.gh.fastx` preference key `h1` is enabled, disables the cover-sheet icon fly-in, and preserves the normal SpringBoard icon-selection semantics. The tweak filter is explicitly limited to `com.apple.springboard`; this prevents the SpringBoard-private hooks from being injected into arbitrary apps. The preference defaults to enabled, matching the original plist.

This is a source-level reconstruction, not the original source. Private UIKit/SpringBoard classes can change between iOS releases, so each target iOS/Dopamine version still requires compilation and device testing. The code deliberately avoids undocumented filesystem paths and does not claim that every future SpringBoard ABI is identical.

## Build environment

Build on macOS with Xcode, an iOS SDK, and Theos installed. The Linux sandbox cannot compile iOS Objective-C/Logos code because it does not contain Apple SDKs or Theos.

```sh
export THEOS=~/theos
cd FastX-Rootless-Source
make clean
make package THEOS_PACKAGE_SCHEME=rootless FINALPACKAGE=1
```

The output package is written to `./packages/`. The package control file declares `firmware (>= 15.0), ellekit`; no Cephei, CydiaSubstrate, or rootful framework dependency is used by the source.

For an automated build with environment checks, run:

```sh
chmod +x build.sh
./build.sh
```

## Rootless behavior

The Makefile uses `THEOS_PACKAGE_SCHEME = rootless`, builds only `arm64` and `arm64e` for iOS 15+, installs the preference bundle under the Rootless prefix, registers it with PreferenceLoader, and uses `ROOT_PATH()` for the C-string respring helper. Theos supplies the Rootless `@rpath` and libroot handling. No hard-coded rootful `/Library` runtime path is used by the source.

## Build-critical files

The package includes a real Debian control file under `layout/DEBIAN/control`, and the tweak includes `FastX/FastX.plist` with a SpringBoard bundle filter. Both are required by current Theos packaging/tweak rules.

## Remaining verification

The attached DEB supplied the original arm64/arm64e binaries but no source or device logs. A final compatibility pass must be performed on the intended iOS and Dopamine versions. If a private class or selector is renamed, that hook should be guarded or removed for that target SDK rather than forcing an unsafe load.


## Verification status of this delivered source

The source archive was reviewed in a Linux environment. No Apple SDK, Xcode, Theos installation, iOS linker, or Apple code-signing environment is available here, and the uploaded archive does not contain the original FastX binary. Therefore this delivery does **not** claim a built dylib, signed PreferenceBundle, or installable DEB. Do not treat any locally generated placeholder as a valid iOS binary.

On macOS, run `./build.sh`, then `./verify-build.sh`. Verify both arm64/arm64e Mach-O slices, load commands, dependencies, code signatures, and the final DEB contents before installing on Dopamine.
