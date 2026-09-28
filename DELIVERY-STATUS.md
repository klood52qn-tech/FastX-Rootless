# FastX Rootless — Delivery Status

## Completed in this environment

- ZIP archive integrity verified with `unzip -t`.
- All shell scripts pass `sh -n` syntax validation.
- All four property lists parse successfully.
- Build scripts are executable.
- Rootless package metadata, SpringBoard filter, PreferenceLoader registration, and PreferenceBundle naming are internally consistent by source inspection.
- The source tree contains no generated placeholder binaries.

## Not buildable in this environment

The current environment is Linux and does not provide Xcode, `xcrun`, an iPhoneOS SDK, `ldid`, or `fakeroot`. Running `./build.sh` therefore stops before compilation with its intended platform-check error. No fake `.dylib`, signed PreferenceBundle, or installable `.deb` has been produced.

## Exact build procedure

On macOS with Xcode, Theos, and the required packaging tools installed:

```sh
export THEOS="$HOME/theos"
./build.sh
./verify-build.sh
```

The GitHub Actions workflow in `.github/workflows/build.yml` performs the same build on `macos-14` and publishes the DEB, binaries, and metadata as workflow artifacts.

## Device verification still required

Before installing, test the resulting package on the intended iOS 15+ and Dopamine/ElleKit combination. The tweak hooks private SpringBoard classes, so compatibility depends on the target iOS version.
