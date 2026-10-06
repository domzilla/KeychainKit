//
//  KeychainItemAccesssibility.swift
//  KeychainKit
//
//  Created by Mars on 2019/7/9.
//  Copyright © 2019 Mars. All rights reserved.
//

import Foundation

protocol KeychainAttrReprentable {
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
/// When no accessibility is specified while storing a new item via ``Keychain``, the
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
