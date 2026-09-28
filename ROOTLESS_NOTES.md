# Rootless implementation notes

- `THEOS_PACKAGE_SCHEME = rootless`.
- Supported target architectures are `arm64` and `arm64e`; deployment target is iOS 15.0+.
- The package declares `firmware (>= 15.0), ellekit`.
- No CydiaSubstrate, Cephei, or rootful `/Library/MobileSubstrate` runtime dependency is used.
- The respring action uses `ROOT_PATH("/usr/bin/sbreload")`; there is no rootful fallback path.
- No legacy FastX.dylib or legacy PreferenceBundle executable is copied into the build.
- The PreferenceBundle executable is compiled from `FastXPrefs/RootListController.m`.
- `ROOT_PATH_NS()` should be used whenever a rootless path is passed as an Objective-C string. This project currently has no Objective-C-string root path.
- The attached source archive did not contain the original FastX binary, so behavior reconstruction is limited to the hook/selector information present in the supplied source and notes.
- A real iOS build and signature verification require macOS + Xcode + an iPhoneOS SDK + Theos/ldid or codesign. This Linux environment cannot produce a valid iOS Mach-O dylib or signed iOS PreferenceBundle.
