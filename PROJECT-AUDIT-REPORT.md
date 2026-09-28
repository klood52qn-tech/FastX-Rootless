# FastX Rootless — Deep Audit Report

## Scope

This audit covers the source tree, Theos Rootless configuration, Debian packaging metadata, PreferenceLoader integration, GitHub Actions workflow, build scripts, and static consistency of the reconstructed Logos code.

## Critical fixes applied

1. **Added `layout/DEBIAN/control`.** Current Theos DEB packaging requires a control file; the project previously had none. The control now declares package ID `org.cydia.kiimo.fastx`, version `1.5.1`, architecture `iphoneos-arm64`, and dependencies `firmware (>= 15.0), ellekit`.
2. **Added `FastX/FastX.plist`.** Current Theos tweak rules require either `<TWEAK_NAME>.plist` or `Filter.plist`. The project previously had neither. The new filter limits injection to `com.apple.springboard`, matching the private SpringBoard hooks in `Tweak.xm` and avoiding accidental injection into arbitrary applications.
3. **Hardened Xcode selection in GitHub Actions.** The workflow now falls back to an installed `Xcode*.app` if `/Applications/Xcode.app` is not present.
4. **Fixed PreferenceBundle respring environment handling.** `posix_spawn()` now passes `environ` instead of a null environment pointer.
5. **Strengthened package verification.** The verifier now checks package ID, version, architecture, and ElleKit dependency using `dpkg-deb -f`, in addition to package paths and Mach-O metadata.

## Rootless correctness

The Makefile uses `THEOS_PACKAGE_SCHEME = rootless`, `iphoneos-arm64`, and an iOS 15.0 deployment target. Theos documents that the rootless scheme installs under `/var/jb`, changes package architecture to `iphoneos-arm64`, and supplies rootless rpaths/libroot handling. The PreferenceBundle install path is `/Library/PreferenceBundles`, which Theos prefixes for a rootless package.

The preference controller uses `ROOT_PATH("/usr/bin/sbreload")`, so it does not hard-code a rootful runtime path.

## Theos build-critical files

- `layout/DEBIAN/control` — required DEB control metadata.
- `FastX/FastX.plist` — required tweak filter property list.
- `layout/Library/PreferenceLoader/Preferences/FastX.plist` — PreferenceLoader registration.
- `FastXPrefs/Resources/Info.plist` — PreferenceBundle metadata and executable name.
- `FastXPrefs/Resources/Root.plist` — settings UI.

## Code behavior

The reconstructed tweak suppresses selected UIKit/CoreAnimation actions when `com.gh.fastx:h1` is enabled and forces the observed SpringBoard icon fly-in setting off. The implementation is explicitly described as a reconstruction rather than the original source.

The filter is SpringBoard-only because the code hooks private SpringBoard classes. This is a deliberate safety boundary; it should not be changed to all applications without redesigning/guarding the private-class hooks.

## GitHub Actions

The workflow uses a macOS GitHub-hosted runner, installs `ldid`, `dpkg`, and `fakeroot`, clones Theos, builds the Rootless package, runs verification, and uploads separate DEB/binary/metadata artifacts.

The workflow records the exact Theos commit used for the build. Theos follows a rolling-release model, so the build is not fully reproducible across time unless the workflow pins a tested Theos commit.

## Static validation completed here

- Shell syntax checks: PASS.
- XML property-list parsing: PASS.
- GitHub Actions YAML parsing: PASS.
- Package-control presence/fields: PASS by source inspection.
- Rootless path consistency: PASS by source inspection.
- PreferenceBundle executable naming: internally consistent (`CFBundleExecutable = FastXPrefs` and bundle target name `FastXPrefs`).
- Theos package/tweak rule requirements checked against current Theos source.

## What is not proven in this environment

This environment does not contain Xcode, the iPhoneOS SDK, a real Theos/macOS toolchain, or an iPhone running Dopamine/ElleKit. Therefore the following remain unverified until GitHub Actions or a Mac build runs:

- successful Objective-C/Logos compilation;
- successful arm64/arm64e linking;
- final code signing/ldid output;
- final DEB generation and exact staged paths;
- PreferenceLoader behavior on-device;
- actual SpringBoard hook behavior on the intended iOS version.

## Bottom line

The project had two build-blocking omissions that the previous review missed: the Debian `control` file and the tweak filter plist. Those are now fixed. The source is substantially more complete and internally consistent for a Theos Rootless build, but it is **not honestly possible to call it 100% device-verified** until the GitHub Actions build completes and the resulting DEB is tested on the target Dopamine/ElleKit device.
