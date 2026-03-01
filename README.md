# KeychainKit

A lightweight Swift wrapper for the iOS and macOS Keychain — as simple as `UserDefaults`.

[![Platform](https://img.shields.io/badge/platforms-iOS%2015.0%20|%20macOS%2013.0%20|%20Mac%20Catalyst-blue.svg)](https://developer.apple.com/documentation/security/keychain_services)
[![Swift](https://img.shields.io/badge/Swift-6-orange.svg)](https://swift.org)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](LICENSE)

## Features

- **Simple API** — `UserDefaults`-like interface for Keychain access
- **Codable support** — Store and retrieve any `Codable` type
- **Property wrappers** — Declarative Keychain storage with `@KeychainStoreString`, `@KeychainStoreNumber`, and `@KeychainStoreObject`
- **Access groups** — Share Keychain items between apps and extensions
- **Configurable accessibility** — Control when Keychain items are accessible
- **Multi-platform** — iOS, macOS, and Mac Catalyst
- **Zero dependencies** — Uses only Foundation and Security

## Installation

Add the KeychainKit Xcode project as a dependency to your project and link the `KeychainKit.framework` to your target.

## Usage

### Basic Operations

Use the `default` singleton for quick access — it uses your bundle identifier as the service name.

**Store values:**

```swift
Keychain.default.set(42, forKey: "user.age")
Keychain.default.set("hello", forKey: "user.greeting")
Keychain.default.set([1, 2, 3], forKey: "user.favorites")
```

**Retrieve values:**

```swift
let age = Keychain.default.object(of: Int.self, forKey: "user.age")
let greeting = Keychain.default.string(forKey: "user.greeting")
let favorites = Keychain.default.object(of: [Int].self, forKey: "user.favorites")
```

**Remove values:**

```swift
Keychain.default.removeObject(forKey: "user.age")
Keychain.default.removeAllKeys()
```

### Property Wrappers

Declare Keychain-backed properties directly on your types:

```swift
struct Settings {
    @KeychainStoreString(key: "api.token")
    var apiToken: String?

    @KeychainStoreNumber(key: "login.count")
    var loginCount: Int?

    @KeychainStoreObject(key: "user.profile")
    var profile: UserProfile?
}
```

### Custom Service Name

By default, the `default` Keychain uses your main bundle identifier as the service name. You can create a Keychain instance with a custom service name:

```swift
let keychain = Keychain(serviceName: "com.example.MyService")
```

### Access Groups

Share Keychain items between apps and extensions using access groups:

```swift
let keychain = Keychain(
    serviceName: "com.example.MyService",
    accessGroup: "TEAM_ID.com.example.shared"
)
```

You can also set a default access group for all new `Keychain` instances:

```swift
Keychain.defaultAccessGroup = "TEAM_ID.com.example.shared"
```

### Accessibility

Control when Keychain items are accessible. The default is `.whenUnlocked`.

```swift
Keychain.default.set(
    "secret",
    forKey: "auth.token",
    withAccessibility: .afterFirstUnlock
)
```

Available accessibility levels:

| Level | Description |
|---|---|
| `.whenUnlocked` | Only when the device is unlocked (default) |
| `.whenUnlockedThisDeviceOnly` | When unlocked, not included in backups |
| `.afterFirstUnlock` | After first unlock following a restart |
| `.afterFirstUnlockThisDeviceOnly` | After first unlock, not included in backups |
| `.whenPasscodeSetThisDeviceOnly` | Only when a passcode is set |

### Querying Keys

```swift
// Check if a key exists
if Keychain.default.hasValue(forKey: "auth.token") { ... }

// Get all stored keys
let keys = Keychain.default.allKeys()

// Check the accessibility of a key
let accessibility = Keychain.default.accessibilityOfKey("auth.token")
```

## License

KeychainKit is released under the [MIT License](LICENSE).
