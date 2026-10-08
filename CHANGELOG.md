# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]
### Added
- Documentation for all public APIs, including the keychain wrapper, access groups, accessibility options, and property wrappers.

### Fixed
- On macOS, storing a second key under the same service no longer fails with a duplicate item error; items stored by earlier versions on macOS are not found any more and have to be stored again.
- On macOS, `removeAllKeys()` removes every item of the service instead of only the first one.
- Reading a numeric value no longer crashes when the stored data is an empty array; `nil` is returned instead.
- Setting a value with a different accessibility level than the existing item now updates the item and its accessibility instead of silently failing.

## [November 2024]
### Added
- Method to set the default access group from Objective-C.
- Dictionary usage example.

## [September 2024]
### Added
- Demo project.

### Removed
- Obsolete files.

## [December 2020]
### Removed
- Demo and test applications.

## [November 2019]
### Added
- Swift Package Manager support.

## [September 2019]
### Added
- Property wrapper support for keychain items.

## [August 2019]
### Added
- Video session references in the documentation.

## [July 2019]
### Added
- README, MIT license, and CI integration.

### Changed
- All APIs now return nil on error instead of throwing.

## [July 2019 - Initial Release]
### Added
- Initial release with the core keychain wrapper.
