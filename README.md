# iOS-BLE-Library

![Platforms](https://img.shields.io/badge/Platforms-iOS%20|%20iPadOS%20|%20macOS-333333.svg)
[![License](https://img.shields.io/github/license/nordicsemi/IOS-BLE-Library)](https://github.com/nordicsemi/IOS-BLE-Library/blob/main/LICENSE)
[![Release](https://img.shields.io/github/release/nordicsemi/IOS-BLE-Library.svg)](https://github.com/nordicsemi/IOS-BLE-Library/releases)
[![GitHub stars](https://img.shields.io/github/stars/nordicsemi/IOS-BLE-Library)](https://github.com/nordicsemi/IOS-BLE-Library/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/nordicsemi/IOS-BLE-Library)](https://github.com/nordicsemi/IOS-BLE-Library/members)
[![GitHub contributors](https://img.shields.io/github/contributors/nordicsemi/IOS-BLE-Library)](https://github.com/nordicsemi/IOS-BLE-Library/graphs/contributors)

This library is a wrapper around the [CoreBluetooth](https://developer.apple.com/documentation/corebluetooth/) framework which provides a modern async API based on [Combine](https://developer.apple.com/documentation/combine).

# Library Versions

The package ships **two products**, and consumers pick the one that fits their needs:

- `iOS-BLE-Library` — links real [`CoreBluetooth`](https://developer.apple.com/documentation/corebluetooth/). For production apps.
- `iOS-BLE-Library-Mock` — links [`CoreBluetoothMock`](https://github.com/nordicsemi/IOS-CoreBluetooth-Mock). The public API is identical (a top-level `Alias.swift` re-exports `CB*` names for the underlying `CBM*` types), so code written for `iOS-BLE-Library` recompiles unchanged against `iOS-BLE-Library-Mock` for unit testing.

# Architecture

Both products are built from a single source tree at `Sources/iOS-BLE-Library/`. The Mock target's compilation unit is produced at build time by the `MockGenerator` SwiftPM build plugin — there are no Python scripts, no committed duplicates, no manual sync step.

At the handful of sites where the two products diverge (mostly imports, plus a couple of init-time branches), the source uses native Swift conditional compilation:

```swift
#if MOCK_TRANSPORT
import CoreBluetoothMock
#else
import CoreBluetooth
#endif
```

The Mock target sets `swiftSettings: [.define("MOCK_TRANSPORT")]`; the native target leaves the flag undefined. The compiler picks the right branch per build.

## For contributors

1. Edit files only in `Sources/iOS-BLE-Library/`. Do not edit anything under `Sources/iOS-BLE-Library-Mock/` (other than `Alias.swift` and `Documentation.docc/`, which are static).
2. For code that needs to behave differently in the Mock build, wrap it in `#if MOCK_TRANSPORT … #else … #endif`.
3. Run `swift build` — the plugin re-generates the Mock target's sources automatically.

That's the whole workflow. No `code_gen` step, no marker DSL.

# Installation

## Swift Package Manager

Add the package to your `Package.swift` dependencies and pick the product you need:

```swift
let package = Package(
    // ...
    dependencies: [
        .package(url: "https://github.com/nordicsemi/IOS-BLE-Library.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "MyApp",
            dependencies: [
                // Production: links real CoreBluetooth
                .product(name: "iOS-BLE-Library", package: "IOS-BLE-Library")
            ]
        ),
        .testTarget(
            name: "MyAppTests",
            dependencies: [
                "MyApp",
                // Testing: links CoreBluetoothMock
                .product(name: "iOS-BLE-Library-Mock", package: "IOS-BLE-Library")
            ]
        ),
    ]
)
```

# Documentation & Examples

Please check the [Documentation Page](https://nordicsemi.github.io/IOS-BLE-Library/documentation/ios_ble_library/) to start using the library.

Also you can check [iOS-nRF-Toolbox](https://github.com/nordicsemi/IOS-nRF-Toolbox/tree/develop) to find more examples.
