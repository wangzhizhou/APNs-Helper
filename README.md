# APNs-Helper

[![App Store](https://img.shields.io/badge/App%20Store-APNs%20Helper-0D96F6?logo=apple&logoColor=white)](https://apps.apple.com/cn/app/apns-helper/id6443608175)
[![App Store](https://img.shields.io/badge/App%20Store-APNs%20Helper%20Tester-0D96F6?logo=apple&logoColor=white)](https://apps.apple.com/cn/app/apns-helper-tester/id6444835507)
[![Documentation](https://img.shields.io/badge/Documentation-DocC-informational)](https://wangzhizhou.github.io/APNs-Helper/documentation/apns_helper_doc/)
[![Build & Test](https://github.com/wangzhizhou/APNs-Helper/actions/workflows/build.yml/badge.svg)](https://github.com/wangzhizhou/APNs-Helper/actions/workflows/build.yml)
[![License](https://img.shields.io/badge/License-Apache--2.0-blue)](LICENSE)

A macOS / iOS tool for developing and testing Apple Push Notification service (APNs) integrations.

It sends real APNs requests, shows the exact payload exchanged, and helps you diagnose why a
notification is not delivered or not decoded by the target app.

## Two ways to use it

| Scenario | What it is for |
| --- | --- |
| **Self-send** | The app itself registers for remote notifications, so you can push to your own device/mac and inspect the whole round trip (request headers, payload, response, received notification). |
| **Send to another app** | With that app's Key ID, Team ID, Bundle ID, `.p8` key and a device token, you can verify **reachability** and whether a specific payload is delivered and decoded as expected. |

Multiple apps can be stored as **presets**, so switching between "my app" and "the app I'm
debugging" is one tap.

## Features

- **All APNs push types**

  | Push type | Topic | Notes |
  | --- | --- | --- |
  | `alert` | `<bundleID>` | notification / badge / sound |
  | `background` | `<bundleID>` | silent push, priority must be 5 |
  | `voip` | `<bundleID>.voip` | PushKit token required |
  | `fileprovider` | `<bundleID>.pushkit.fileprovider` | File Provider extension |
  | `location` | `<bundleID>.location-query` | Location Push Service extension |
  | `liveactivity` | `<bundleID>.push-type.liveactivity` | ActivityKit |

- **Payload workbench** — a JSON editor with syntax highlighting, formatting and
  per-push-type templates. The text you write is sent verbatim as the HTTP body, so you can
  reproduce exactly what your server sends.
- **Credentials** — JWT (`.p8`) authentication, `.p8` import from file, presets persisted locally.
- **Diagnostics** — request/response headers and the APNs error are written to an in-app log;
  server reachability is checked before sending.
- **Receiving side** — [APNs Helper Tester](https://apps.apple.com/cn/app/apns-helper-tester/id6444835507)
  and the bundled extensions (Notification Service / Content, Widgets / Live Activity, File Provider,
  Location Push) demonstrate and verify each delivery path.

## Development

Requirements: Xcode 26 or newer (Swift 6.1+ is required by the current dependency set),
iOS 17 / macOS 14 deployment targets.
Code is written in Swift 6 language mode with Observation (`@Observable`); UI state models are `@MainActor`.

```bash
# Dependencies (SwiftPM, including APNSwift)
xcodebuild -resolvePackageDependencies -project "APNs Helper.xcodeproj" -scheme "APNs Helper"

# Build (macOS / iOS Simulator)
xcodebuild build -project "APNs Helper.xcodeproj" -scheme "APNs Helper" -destination 'platform=macOS'
xcodebuild build -project "APNs Helper.xcodeproj" -scheme "APNs Helper" -destination 'generic/platform=iOS Simulator'

# Unit tests (Swift Testing)
xcodebuild test -project "APNs Helper.xcodeproj" -scheme "APNs Helper Tests" -destination 'platform=macOS'

# Lint (same script and config as CI)
brew install swiftlint && ./Scripts/lint.sh
```

### Project layout

| Path | Contents |
| --- | --- |
| `APNs Helper/` | the app: SwiftUI views, `AppModel`/`AppContentModel`, `APNsService` + `PushRequest`, payload editors |
| `Common/` | shared code: AppDelegate, UNUserNotification / PushKit / CallKit / CoreLocation managers, utilities |
| `APNs Helper Tester/` | the receiving demo app |
| `Widgets/`, `FileProviderExtension/`, `FileProviderExtensionUI/`, `NotificationContentExtension/`, `NotificationServiceExtension/`, `LocationPushServiceExtension/` | delivery-path demo extensions |
| `APNs Helper Doc/` | DocC catalog for the documentation site |
| `APNs Helper Tests/` | Swift Testing suites |
| `Scripts/` | `lint.sh`, `build-docs.sh` |

## Documentation

The docs are written with DocC in `APNs Helper Doc/docs.docc/` and published from this repository:

- Online: <https://wangzhizhou.github.io/APNs-Helper/documentation/apns_helper_doc/>
- Locally: `./Scripts/build-docs.sh`, then serve the generated `dist/docs` at the `/APNs-Helper/` sub-path
  (the script prints the exact commands)

Deployment is handled by `.github/workflows/docs.yml` (GitHub Pages, `GITHUB_TOKEN`, no PAT).

Design file: [Figma](https://www.figma.com/file/sLVIKqiYfxHNb7gUnOUZ9x/APNs-Helper-And-Tester)

## Dependencies

| Package | Why |
| --- | --- |
| [APNSwift](https://github.com/kylebrowning/APNSwift) | APNs transport (JWT auth, HTTP/2) |
| [AlertToast](https://github.com/elai950/AlertToast) | toasts |
| [Highlightr](https://github.com/raspu/Highlightr) | JSON syntax highlighting |
| [Prettier](https://github.com/simonbs/Prettier) | JSON formatting |

`Package.resolved` is committed in **v3** format (with `originHash`). Do not downgrade it to v2:
newer Xcode treats a v2 file as stale and silently re-resolves to the latest transitive
dependencies, which can require a newer Swift toolchain than CI provides.

`swift-collections` is pinned to an exact version in the project: 1.7.3+ requires **Swift 6.4**
(Xcode 27), while CI and the oldest supported toolchain are on Swift 6.3. Bump the pin together
with the toolchain, not on its own.

## Isolation & data integrity

The app has no backend: credentials, device tokens and payloads never leave the device, and every
request goes straight to Apple's APNs endpoints. Two properties are enforced by design and covered
by tests:

- **Byte-exact payloads** — the JSON you write is sent *verbatim* as the HTTP body
  (`RawBodyEncoder` + `APNSRawPayloadTests`); nothing is re-serialized, so key order, whitespace and
  number formatting survive.
- **No credential sharing** — nothing ships with an APNs key, so users cannot interfere with each
  other: APNs scopes a `.p8` to one developer team, and device tokens are per device/app/environment.
  Presets (which contain the `.p8` and tokens) are stored in the **Keychain**, not `UserDefaults`.
- **Receiving side is untouched** — the Notification Service Extension only records the payload it
  received (into an App Group) and passes the notification through unmodified, so what you inspect is
  what APNs delivered.
- Importing app info from the clipboard asks for confirmation first; use **Import P8** to load a key
  from a file instead. Log output redacts PEM blocks and token-like strings.

## Sensitive information

This is a public repository and **contains no APNs auth key (`.p8`)** — neither does any build
product. The self-send test (**Fill this App's Info**) needs your own key, so the app asks for it
once, on the device:

1. Open **App Info → Self-Test Credentials…**
2. Fill in Key ID / Team ID and import (or paste) your `AuthKey_XXXX.p8`
3. Save — it is stored in the **Keychain** of that device only

The form validates before saving (10-character Key ID / Team ID, PKCS#8 `BEGIN/END PRIVATE KEY`
block), and **Forget Saved Credentials** removes it again. The key never leaves the device; it is
only used to sign your own JWT.

Older builds read the key from `UserDefaults` (`APNsHelperDevPrivateKey`). That legacy value is
still honoured, and is migrated into the Keychain the first time you save from the app.

## License

[Apache License 2.0](LICENSE)
