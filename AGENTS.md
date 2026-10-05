# KeychainKit - AGENTS.md

## Project Overview
KeychainKit is a lightweight Swift wrapper for the iOS and macOS Keychain. It provides a `UserDefaults`-like API for securely storing, retrieving, and managing data in the Keychain. Supports `Codable` types, property wrappers, and access group sharing for app extensions.

## Tech Stack
- **Language**: Swift
- **Type**: Xcode Framework
- **Target-Platforms**: iOS / macOS / Mac Catalyst
- **Dependencies**: None (uses Foundation and Security frameworks only)

## Guides (MANDATORY)
Read `~/Agents/Guides/xcode-project-guide.md` in full before planning or editing anything.

Read these in full before touching the matching code:
- Swift style (`.swift`): `~/Agents/Style/swift-swiftui-style-guide.md`
- Accessibility (UI code, XIBs, storyboards): `~/Agents/Guides/accessibility-guide.md`

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

## Testing (MANDATORY)
No test targets exist in this project.

## Notes
- This framework has no user-facing strings — localization is not applicable
