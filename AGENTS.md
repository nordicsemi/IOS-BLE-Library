# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

```bash
# Build the package (plugin runs automatically; both products compile)
swift build

# Run tests
swift test

# Build documentation
swift package generate-documentation

# Format code (uses swift-format with configuration in format.swift-format)
swift-format --in-place --recursive Sources/ Tests/
```

## Architecture

### Source tree

- **Sources/iOS-BLE-Library/** — canonical implementation. Both products are built from these files.
  - **CentralManager/** — central manager + reactive delegate
  - **Peripheral/** — peripheral wrapper + reactive delegate
  - **Utilities/** — shared utilities, extensions, custom publishers
  - **Documentation.docc/** — DocC documentation
- **Sources/iOS-BLE-Library-Mock/** — Mock-specific static files only:
  - `Alias.swift` — public `CB*` typealiases for the corresponding `CBM*` types
  - `Documentation.docc/` — Mock-specific docc (hand-maintained)
  - **All other .swift files are GENERATED at build time** by the `MockGenerator` plugin into the plugin work directory; they are not in git.
- **Sources/MockGeneratorTool/** — `.executableTarget`, a ~10-line wrapper around `FileManager.copyItem`. Invoked once per file by the plugin.
- **Plugins/MockGenerator/** — `BuildToolPlugin`. Enumerates `.swift` files under `Sources/iOS-BLE-Library/` and declares one `Command.buildCommand` per file invoking `MockGeneratorTool`.

### How the two builds differ

The Mock target is declared in `Package.swift` with `swiftSettings: [.define("MOCK_TRANSPORT")]`. The shared source uses `#if MOCK_TRANSPORT … #else … #endif` blocks at the handful of sites where the two products differ:

- **Imports**: native imports `CoreBluetooth`; Mock imports `CoreBluetoothMock`.
- **`Peripheral.init`** branches at runtime on `CBMPeripheralNative` vs `CBMPeripheralMock` to install the right state observer (Mock build only).
- **`CentralManager.init`** uses `CBCentralManager(...)` directly (native) vs `CBMCentralManagerFactory.instance(...)` (Mock).
- **`MockObserver`** class — Mock-only, gated by `#if MOCK_TRANSPORT`.

The Mock target's `Alias.swift` (`public typealias CBPeripheral = CBMPeripheral`, etc.) means shared code that references `CBPeripheral` resolves to the real type in the native build and to `CBMPeripheral` in the Mock build, without changing the source.

### Package structure

- Supports iOS 13+, macOS 10.15+, watchOS 6+
- Dependencies: `CoreBluetoothMock` (≥1.0), `swift-docc-plugin`
- Two library products (`iOS-BLE-Library`, `iOS-BLE-Library-Mock`), one executable target (`MockGeneratorTool`), one plugin (`MockGenerator`), one test target.

## Contributor workflow

1. Edit files only in `Sources/iOS-BLE-Library/`.
2. For code that needs to behave differently in the Mock build (rare — mostly import swaps and a couple of init-time branches), use:
   ```swift
   #if MOCK_TRANSPORT
   // CoreBluetoothMock-aware code
   #else
   // CoreBluetooth-only code
   #endif
   ```
3. Run `swift build` — the plugin re-generates the Mock target's sources automatically.
4. Run `swift test` to verify.

## Code Style

### Swift Formatting

Uses swift-format with configuration in `format.swift-format`:
- Tab indentation (width 8)
- 100 character line length
- File-scoped declaration privacy

## Testing

- Tests are in `Tests/iOS-BLE-LibraryTests/`, depend on `iOS-BLE-Library-Mock`.
- Run with `swift test`.
- **Known disabled test**: `CentralManagerTests.swift` is wrapped in `#if false`. It depends on `CoreBluetoothMock-Collection`, which is pinned to `CoreBluetoothMock 0.17.x` and is incompatible with the `1.x` line that this package requires. Re-enable once Collection is updated to `1.x`, or inline the `RunningSpeedAndCadence` fixture into the test target.

## Documentation

- Uses DocC for documentation generation
- Documentation source in `Sources/iOS-BLE-Library/Documentation.docc/`
- The Mock product's separate docc is hand-maintained in `Sources/iOS-BLE-Library-Mock/Documentation.docc/`.
