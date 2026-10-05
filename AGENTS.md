# KeychainKit - AGENTS.md

## Project Overview
KeychainKit is a lightweight Swift wrapper for the iOS and macOS Keychain. It provides a `UserDefaults`-like API for securely storing, retrieving, and managing data in the Keychain. Supports `Codable` types, property wrappers, and access group sharing for app extensions.

## Tech Stack
- **Language**: Swift
- **Type**: Xcode Framework
- **Target-Platforms**: iOS / macOS / Mac Catalyst
- **Dependencies**: None (uses Foundation and Security frameworks only)

## Guides (MANDATORY)
- Swift style: `~/Agents/Style/swift-swiftui-style-guide.md`
- Accessibility: `~/Agents/Guides/accessibility-guide.md`
- Xcode projects: `~/Agents/Guides/xcode-project-guide.md`

## Build Commands
```bash
# Build (iOS)
xcodebuild -project src/KeychainKit.xcodeproj -scheme KeychainKit \
  -destination 'generic/platform=iOS' \
  -configuration Debug build

# Build (macOS)
xcodebuild -project src/KeychainKit.xcodeproj -scheme KeychainKit \
  -destination 'generic/platform=macOS' \
  -configuration Debug build

# Clean
xcodebuild -project src/KeychainKit.xcodeproj -scheme KeychainKit clean
```

No test targets exist in this project.

## Testing (MANDATORY)
No test targets exist in this project.

## Notes
- This framework has no user-facing strings — localization is not applicable
