//
//  KeychainItem.swift
//  KeychainKit
//
//  Created by Mars on 2019/9/22.
//  Copyright © 2019 Mars. All rights reserved.
//

import Foundation

/// A property wrapper that provides keychain-backed storage for `String` values.
///
/// `KeychainStoreString` delegates all read and write operations to ``Keychain/default``,
/// storing values as UTF-8 encoded strings in the iOS/macOS Keychain. This gives you a
/// `UserDefaults`-like API for securely persisting sensitive string data such as tokens,
/// passwords, or API keys.
///
/// ## Usage
///
/// Declare a property using the `@KeychainStoreString` attribute and provide a keychain key:
///
/// ```swift
/// @KeychainStoreString(key: "com.example.apiToken")
/// var apiToken: String?
/// ```
///
/// Reading the property returns the stored string, or `nil` if no value exists for the key:
///
/// ```swift
/// if let token = apiToken {
///     print("Token: \(token)")
/// }
/// ```
///
/// Writing a non-nil value stores it in the keychain:
///
/// ```swift
/// apiToken = "my-secret-token"
/// ```
///
/// - Note: Setting the wrapped value to `nil` is a no-op and does **not** remove the
///   existing keychain item. To delete the stored value, use the projected value to access
///   the underlying ``Keychain`` instance and call ``Keychain/removeObject(forKey:withAccessibility:)``
///   directly: `$apiToken.removeObject(forKey: "com.example.apiToken")`.
///
/// - SeeAlso: ``Keychain``, ``KeychainStoreNumber``, ``KeychainStoreObject``
@propertyWrapper
public struct KeychainStoreString {
    /// The keychain key used to store and retrieve the string value.
    public let key: String

    /// Creates a new keychain-backed string property wrapper.
    ///
    /// - Parameter key: The unique key identifying this item in the keychain. This key is used
    ///   with ``Keychain/default`` for all read and write operations. Use a reverse-DNS style
    ///   string (e.g., `"com.example.authToken"`) to avoid collisions.
    public init(key: String) {
        self.key = key
    }

    /// The stored string value, or `nil` if no value exists for the configured key.
    ///
    /// - Getting: Retrieves the string from the keychain via ``Keychain/string(forKey:withAccessibility:)``.
    ///   Returns `nil` if no value is stored for ``key``.
    ///
    /// - Setting: Stores a non-nil string in the keychain via ``Keychain/set(_:forKey:withAccessibility:)``.
    ///   If the value is `nil`, the setter returns without modifying the keychain. To remove
    ///   a stored value, use the projected value (`$propertyName`) to access the ``Keychain``
    ///   instance and call ``Keychain/removeObject(forKey:withAccessibility:)`` directly.
    public var wrappedValue: String? {
        get {
            Keychain.default.string(forKey: self.key)
        }

        set {
            guard let v = newValue else { return }

            Keychain.default.set(v, forKey: self.key)
        }
    }

    /// The projected value, providing direct access to the underlying ``Keychain/default`` instance.
    ///
    /// Access this via the `$` prefix on the property name. This is useful for performing
    /// operations not exposed by the property wrapper itself, such as removing a keychain item
    /// or checking whether a value exists:
    ///
    /// ```swift
    /// @KeychainStoreString(key: "com.example.apiToken")
    /// var apiToken: String?
    ///
    /// // Remove the stored token
    /// $apiToken.removeObject(forKey: "com.example.apiToken")
    ///
    /// // Check if a value exists
    /// let exists = $apiToken.hasValue(forKey: "com.example.apiToken")
    /// ```
    ///
    /// - Returns: The shared ``Keychain/default`` singleton instance.
    public var projectedValue: Keychain {
        Keychain.default
    }
}

/// A property wrapper that provides keychain-backed storage for numeric values.
///
/// `KeychainStoreNumber` delegates all read and write operations to ``Keychain/default``,
/// encoding numeric values as JSON via `Codable` conformance before storing them in the
/// iOS/macOS Keychain. The generic type `T` must conform to both `Numeric` and `Codable`,
/// supporting types such as `Int`, `Double`, `Float`, `Int64`, `Decimal`, and others.
///
/// ## Usage
///
/// Declare a property using the `@KeychainStoreNumber` attribute with an explicit type
/// and a keychain key:
///
/// ```swift
/// @KeychainStoreNumber<Int>(key: "com.example.loginCount")
/// var loginCount: Int?
///
/// @KeychainStoreNumber<Double>(key: "com.example.balance")
/// var balance: Double?
/// ```
///
/// Reading the property returns the stored numeric value, or `nil` if no value exists:
///
/// ```swift
/// if let count = loginCount {
///     print("Logged in \(count) times")
/// }
/// ```
///
/// Writing a non-nil value stores it in the keychain:
///
/// ```swift
/// loginCount = 42
/// ```
///
/// - Note: Setting the wrapped value to `nil` is a no-op and does **not** remove the
///   existing keychain item. To delete the stored value, use the projected value to access
///   the underlying ``Keychain`` instance and call ``Keychain/removeObject(forKey:withAccessibility:)``
///   directly: `$loginCount.removeObject(forKey: "com.example.loginCount")`.
///
/// - Note: Numeric values are internally wrapped in a single-element array during JSON encoding
///   (e.g., `[42]`) to ensure reliable `Codable` round-tripping for primitive numeric types.
///
/// - SeeAlso: ``Keychain``, ``KeychainStoreString``, ``KeychainStoreObject``
@propertyWrapper
public struct KeychainStoreNumber<T: Numeric & Codable> {
    /// The keychain key used to store and retrieve the numeric value.
    public let key: String

    /// Creates a new keychain-backed numeric property wrapper.
    ///
    /// - Parameter key: The unique key identifying this item in the keychain. This key is used
    ///   with ``Keychain/default`` for all read and write operations. Use a reverse-DNS style
    ///   string (e.g., `"com.example.loginCount"`) to avoid collisions.
    public init(key: String) {
        self.key = key
    }

    /// The stored numeric value, or `nil` if no value exists for the configured key.
    ///
    /// - Getting: Retrieves the value from the keychain via ``Keychain/object(of:forKey:withAccessibility:)``,
    ///   decoding it from its JSON representation. Returns `nil` if no value is stored for ``key``
    ///   or if decoding fails.
    ///
    /// - Setting: Stores a non-nil numeric value in the keychain via ``Keychain/set(_:forKey:withAccessibility:)``.
    ///   If the value is `nil`, the setter returns without modifying the keychain. To remove
    ///   a stored value, use the projected value (`$propertyName`) to access the ``Keychain``
    ///   instance and call ``Keychain/removeObject(forKey:withAccessibility:)`` directly.
    public var wrappedValue: T? {
        get {
            Keychain.default.object(of: T.self, forKey: self.key)
        }

        set {
            guard let v = newValue else { return }

            Keychain.default.set(v, forKey: self.key)
        }
    }

    /// The projected value, providing direct access to the underlying ``Keychain/default`` instance.
    ///
    /// Access this via the `$` prefix on the property name. This is useful for performing
    /// operations not exposed by the property wrapper itself, such as removing a keychain item
    /// or checking whether a value exists:
    ///
    /// ```swift
    /// @KeychainStoreNumber<Int>(key: "com.example.loginCount")
    /// var loginCount: Int?
    ///
    /// // Remove the stored value
    /// $loginCount.removeObject(forKey: "com.example.loginCount")
    ///
    /// // Check if a value exists
    /// let exists = $loginCount.hasValue(forKey: "com.example.loginCount")
    /// ```
    ///
    /// - Returns: The shared ``Keychain/default`` singleton instance.
    public var projectedValue: Keychain {
        Keychain.default
    }
}

/// A property wrapper that provides keychain-backed storage for any `Codable` type.
///
/// `KeychainStoreObject` delegates all read and write operations to ``Keychain/default``,
/// encoding values as JSON via `Codable` conformance before storing them in the iOS/macOS
/// Keychain. This is the most flexible property wrapper in KeychainKit, supporting any type
/// that conforms to `Codable` -- including custom structs, enums, dictionaries, arrays,
/// and other complex data structures.
///
/// ## Usage
///
/// Declare a property using the `@KeychainStoreObject` attribute with an explicit type
/// and a keychain key:
///
/// ```swift
/// struct UserCredentials: Codable {
///     var username: String
///     var refreshToken: String
/// }
///
/// @KeychainStoreObject<UserCredentials>(key: "com.example.credentials")
/// var credentials: UserCredentials?
///
/// @KeychainStoreObject<[String: String]>(key: "com.example.metadata")
/// var metadata: [String: String]?
/// ```
///
/// Reading the property returns the stored object, or `nil` if no value exists:
///
/// ```swift
/// if let creds = credentials {
///     print("User: \(creds.username)")
/// }
/// ```
///
/// Writing a non-nil value stores it in the keychain:
///
/// ```swift
/// credentials = UserCredentials(username: "dom", refreshToken: "abc123")
/// ```
///
/// - Note: Setting the wrapped value to `nil` is a no-op and does **not** remove the
///   existing keychain item. To delete the stored value, use the projected value to access
///   the underlying ``Keychain`` instance and call ``Keychain/removeObject(forKey:withAccessibility:)``
///   directly: `$credentials.removeObject(forKey: "com.example.credentials")`.
///
/// - Note: For numeric types (`Int`, `Double`, etc.), prefer ``KeychainStoreNumber`` instead,
///   as it uses a specialized encoding path optimized for primitive numeric values.
///
/// - SeeAlso: ``Keychain``, ``KeychainStoreString``, ``KeychainStoreNumber``
@propertyWrapper
public struct KeychainStoreObject<T: Codable> {
    /// The keychain key used to store and retrieve the `Codable` object.
    public let key: String

    /// Creates a new keychain-backed object property wrapper.
    ///
    /// - Parameter key: The unique key identifying this item in the keychain. This key is used
    ///   with ``Keychain/default`` for all read and write operations. Use a reverse-DNS style
    ///   string (e.g., `"com.example.credentials"`) to avoid collisions.
    public init(key: String) {
        self.key = key
    }

    /// The stored `Codable` object, or `nil` if no value exists for the configured key.
    ///
    /// - Getting: Retrieves the value from the keychain via ``Keychain/object(of:forKey:withAccessibility:)``,
    ///   decoding it from its JSON representation. Returns `nil` if no value is stored for ``key``
    ///   or if JSON decoding fails.
    ///
    /// - Setting: Stores a non-nil object in the keychain via ``Keychain/set(_:forKey:withAccessibility:)``,
    ///   encoding it to JSON first. If the value is `nil`, the setter returns without modifying
    ///   the keychain. To remove a stored value, use the projected value (`$propertyName`) to
    ///   access the ``Keychain`` instance and call ``Keychain/removeObject(forKey:withAccessibility:)``
    ///   directly.
    public var wrappedValue: T? {
        get {
            Keychain.default.object(of: T.self, forKey: self.key)
        }

        set {
            guard let v = newValue else { return }

            Keychain.default.set(v, forKey: self.key)
        }
    }

    /// The projected value, providing direct access to the underlying ``Keychain/default`` instance.
    ///
    /// Access this via the `$` prefix on the property name. This is useful for performing
    /// operations not exposed by the property wrapper itself, such as removing a keychain item
    /// or checking whether a value exists:
    ///
    /// ```swift
    /// @KeychainStoreObject<UserCredentials>(key: "com.example.credentials")
    /// var credentials: UserCredentials?
    ///
    /// // Remove the stored object
    /// $credentials.removeObject(forKey: "com.example.credentials")
    ///
    /// // Check if a value exists
    /// let exists = $credentials.hasValue(forKey: "com.example.credentials")
    /// ```
    ///
    /// - Returns: The shared ``Keychain/default`` singleton instance.
    public var projectedValue: Keychain {
        Keychain.default
    }
}
