//
//  KeychainItemAccesssibility.swift
//  KeychainKit
//
//  Created by Mars on 2019/7/9.
//  Copyright © 2019 Mars. All rights reserved.
//

import Foundation

/// A protocol that defines the ability to convert a keychain accessibility value
/// to its corresponding `CFString` representation in the Security framework.
///
/// Types conforming to this protocol can be used with Security framework functions
/// such as `SecItemAdd`, `SecItemUpdate`, and `SecItemCopyMatching` by providing
/// the appropriate `kSecAttrAccessible` attribute value.
///
/// - SeeAlso: `KeychainItemAccessibility`
protocol KeychainAttrReprentable {
    /// The `CFString` value representing this accessibility level in the Security framework.
    ///
    /// This value corresponds to one of the `kSecAttrAccessible*` constants defined in
    /// the Security framework and is used when constructing keychain query dictionaries.
    var keychainAttrValue: CFString { get }
}

/// Represents the accessibility levels for keychain items, controlling when the data
/// stored in the keychain can be accessed.
///
/// Each case maps to a `kSecAttrAccessible*` constant from the Security framework.
/// The accessibility level determines both when the data is available for reading
/// and whether the data can be migrated to other devices via backups.
///
/// Variants with a `ThisDeviceOnly` suffix prevent keychain items from being included
/// in encrypted backups or transferred to other devices (e.g., via iCloud Keychain
/// or device migration). Use these when the stored secret is inherently tied to the
/// current device (e.g., device-specific tokens).
///
/// When no accessibility is explicitly specified in ``Keychain`` operations, the
/// framework defaults to ``whenUnlocked``.
///
/// - SeeAlso: `KeychainAttrReprentable`
/// - SeeAlso: `Keychain`
public enum KeychainItemAccessibility {
    /// The keychain item is accessible after the first unlock of the device in the current
    /// boot cycle.
    ///
    /// Once the user unlocks the device for the first time after a restart, the item remains
    /// accessible until the device is restarted again. This is suitable for items that need
    /// to be accessed by background processes.
    ///
    /// Maps to `kSecAttrAccessibleAfterFirstUnlock` in the Security framework.
    case afterFirstUnlock

    /// The keychain item is accessible after the first unlock of the device and cannot
    /// be migrated to another device.
    ///
    /// Behaves identically to ``afterFirstUnlock``, but the item is excluded from backups
    /// and will not be transferred during device migration.
    ///
    /// Maps to `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly` in the Security framework.
    case afterFirstUnlockThisDeviceOnly

    /// The keychain item is only accessible when the device has a passcode set and
    /// cannot be migrated to another device.
    ///
    /// The item is only available when the device is unlocked. If the user removes the
    /// device passcode, all items with this accessibility level are permanently deleted
    /// from the keychain.
    ///
    /// This is the most restrictive accessibility level and is appropriate for highly
    /// sensitive data that should only exist while the device maintains a passcode
    /// (e.g., authentication tokens, encryption keys).
    ///
    /// - Warning: Items stored with this accessibility level are irreversibly deleted
    ///   when the user removes their device passcode.
    ///
    /// Maps to `kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly` in the Security framework.
    case whenPasscodeSetThisDeviceOnly

    /// The keychain item is only accessible while the device is unlocked by the user.
    ///
    /// This is the effective default accessibility level used by ``Keychain`` when no
    /// explicit accessibility is provided. Items are available only while the device
    /// is unlocked and can be migrated to other devices via backups.
    ///
    /// Maps to `kSecAttrAccessibleWhenUnlocked` in the Security framework.
    case whenUnlocked

    /// The keychain item is only accessible while the device is unlocked and cannot
    /// be migrated to another device.
    ///
    /// Behaves identically to ``whenUnlocked``, but the item is excluded from backups
    /// and will not be transferred during device migration.
    ///
    /// Maps to `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` in the Security framework.
    case whenUnlockedThisDeviceOnly

    /// Creates a ``KeychainItemAccessibility`` value from a raw `CFString` attribute
    /// returned by the Security framework.
    ///
    /// This method performs a reverse lookup against the known `kSecAttrAccessible*`
    /// constants to find the corresponding enum case. It is primarily used when reading
    /// keychain item attributes via `SecItemCopyMatching` to convert the raw accessibility
    /// attribute back into a strongly-typed enum value.
    ///
    /// - Parameter keychainAttrValue: A `CFString` value corresponding to one of the
    ///   `kSecAttrAccessible*` constants from the Security framework.
    /// - Returns: The matching ``KeychainItemAccessibility`` case, or `nil` if the
    ///   provided value does not match any known accessibility constant.
    /// - SeeAlso: ``keychainAttrValue``
    static func accessbilityForAttributeValue(_ keychainAttrValue: CFString) -> KeychainItemAccessibility? {
        for (key, value) in keychainAccessibilityLookup {
            if value == keychainAttrValue {
                return key
            }
        }

        return nil
    }
}

extension KeychainItemAccessibility: KeychainAttrReprentable {
    /// The `CFString` representation of this accessibility level for use in Security
    /// framework keychain queries.
    ///
    /// Converts this enum case to the corresponding `kSecAttrAccessible*` constant.
    /// The returned value is used when constructing query dictionaries for
    /// `SecItemAdd`, `SecItemUpdate`, and `SecItemCopyMatching`.
    ///
    /// - SeeAlso: ``accessbilityForAttributeValue(_:)``
    var keychainAttrValue: CFString {
        keychainAccessibilityLookup[self]!
    }
}

private let keychainAccessibilityLookup: [KeychainItemAccessibility: CFString] = [
    .afterFirstUnlock: kSecAttrAccessibleAfterFirstUnlock,
    .afterFirstUnlockThisDeviceOnly: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
    .whenPasscodeSetThisDeviceOnly: kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
    .whenUnlocked: kSecAttrAccessibleWhenUnlocked,
    .whenUnlockedThisDeviceOnly: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
]
