//
//  Keychain.swift
//  KeychainKit
//
//  Created by Mars on 2019/7/9.
//  Copyright © 2019 Mars. All rights reserved.
//

import Foundation

/// Keychain service attributes
private let secMatchLimit: String = kSecMatchLimit as String
private let secReturnData: String = kSecReturnData as String
private let secValueData: String = kSecValueData as String
private let secAttrAccessible: String = kSecAttrAccessible as String
private let secClass: String = kSecClass as String
private let secAttrService: String = kSecAttrService as String
private let secAttrGeneric: String = kSecAttrGeneric as String
private let secAttrAccount: String = kSecAttrAccount as String
private let secAttrAccessGroup: String = kSecAttrAccessGroup as String
private let secReturnAttributes: String = kSecReturnAttributes as String

/// An Objective-C compatible helper class for configuring the default Keychain access group.
///
/// This class provides a bridge for Objective-C code to set the default access group
/// used by ``Keychain`` instances created via ``Keychain/default``. In Swift code,
/// you can set ``Keychain/defaultAccessGroup`` directly instead.
///
/// Access groups allow keychain items to be shared between multiple apps and app extensions
/// that belong to the same developer team and have matching entitlements.
///
/// ```swift
/// // From Objective-C:
/// [KeychainAccessGroup setDefault:@"group.com.example.shared"];
///
/// // From Swift (preferred):
/// Keychain.defaultAccessGroup = "group.com.example.shared"
/// ```
///
/// - SeeAlso: ``Keychain/defaultAccessGroup``
@objc
public class KeychainAccessGroup: NSObject {
    /// Sets the default access group used by new ``Keychain`` instances created via ``Keychain/default``.
    ///
    /// Call this method early in your app lifecycle (e.g., in `application(_:didFinishLaunchingWithOptions:)`)
    /// to configure keychain sharing before any keychain operations occur.
    ///
    /// - Parameter defaultAccessGroup: The access group identifier (e.g., `"group.com.example.shared"`),
    ///   or `nil` to remove the default access group and use the app's private keychain.
    ///
    /// - SeeAlso: ``Keychain/defaultAccessGroup``
    @objc
    public static func setDefault(_ defaultAccessGroup: String?) {
        Keychain.defaultAccessGroup = defaultAccessGroup
    }
}

/// A lightweight Swift wrapper around the iOS and macOS Keychain Services API.
///
/// `Keychain` provides a `UserDefaults`-like interface for securely storing, retrieving,
/// and managing sensitive data in the system keychain. It supports strings, raw `Data`,
/// `Codable` objects, and numeric types out of the box.
///
/// All items are stored using the `kSecClassGenericPassword` keychain item class. Keys are
/// encoded as UTF-8 `Data` and stored in both the `kSecAttrGeneric` and `kSecAttrAccount`
/// attributes. Items are scoped to a configurable service name (defaulting to
/// `Bundle.main.bundleIdentifier`, with a fallback of `"Keychain"`).
///
/// ## Basic Usage
///
/// ```swift
/// // Store values
/// Keychain.default.set("secret", forKey: "api-token")
/// Keychain.default.set(42, forKey: "launch-count")
/// Keychain.default.set(myUser, forKey: "current-user")
///
/// // Retrieve values
/// let token = Keychain.default.string(forKey: "api-token")
/// let count = Keychain.default.object(of: Int.self, forKey: "launch-count")
/// let user = Keychain.default.object(of: User.self, forKey: "current-user")
///
/// // Remove values
/// Keychain.default.removeObject(forKey: "api-token")
/// ```
///
/// ## Custom Instances
///
/// Create custom `Keychain` instances with a specific service name or access group
/// for keychain item isolation or sharing between apps:
///
/// ```swift
/// let shared = Keychain(
///     serviceName: "com.example.shared",
///     accessGroup: "group.com.example.shared"
/// )
/// ```
///
/// ## Encoding Details
///
/// - `String` values are stored as UTF-8 encoded `Data`.
/// - `Codable` objects are serialized using `JSONEncoder` / `JSONDecoder`.
/// - `Numeric` types (e.g., `Int`, `Double`) are wrapped in a single-element array
///   (`[value]`) before JSON encoding to work around `JSONEncoder`'s restriction
///   on encoding top-level scalar fragments.
///
/// ## Accessibility
///
/// When no explicit ``KeychainItemAccessibility`` is provided, items default to
/// ``KeychainItemAccessibility/whenUnlocked``, meaning the data is accessible only
/// while the device is unlocked.
///
/// - SeeAlso: ``KeychainItemAccessibility``
/// - SeeAlso: ``KeychainStoreString``, ``KeychainStoreNumber``, ``KeychainStoreObject``
open class Keychain {
    /// The shared default `Keychain` instance.
    ///
    /// Uses the app's bundle identifier (or `"Keychain"` as a fallback) as its service name
    /// and ``defaultAccessGroup`` as its access group. This is the instance used by the
    /// property wrappers ``KeychainStoreString``, ``KeychainStoreNumber``,
    /// and ``KeychainStoreObject``.
    ///
    /// ```swift
    /// Keychain.default.set("value", forKey: "my-key")
    /// let value = Keychain.default.string(forKey: "my-key")
    /// ```
    public static let `default` = Keychain()

    /// The service name used to scope keychain items for this instance.
    ///
    /// All items stored by this `Keychain` instance are tagged with this service name
    /// via the `kSecAttrService` attribute, allowing logical separation of keychain items
    /// between different services or modules. The service name is set at initialization
    /// and cannot be changed afterward.
    ///
    /// - SeeAlso: ``init(serviceName:accessGroup:)``
    public private(set) var serviceName: String

    /// The optional access group used to share keychain items across apps and app extensions.
    ///
    /// When set, keychain items are stored in the specified access group, allowing them
    /// to be read and written by any app or extension with matching entitlements. When `nil`,
    /// items are stored in the app's private keychain.
    ///
    /// The access group is set at initialization and cannot be changed afterward.
    ///
    /// - SeeAlso: ``init(serviceName:accessGroup:)``
    /// - SeeAlso: ``KeychainAccessGroup``
    public private(set) var accessGroup: String?

    private static let defaultServiceName: String = Bundle.main.bundleIdentifier ?? "Keychain"

    /// The default access group applied to the shared ``default`` instance.
    ///
    /// Set this property before accessing ``default`` for the first time to configure
    /// keychain sharing across apps and extensions. Once ``default`` has been accessed,
    /// changing this property has no effect on the existing singleton.
    ///
    /// ```swift
    /// // In application(_:didFinishLaunchingWithOptions:):
    /// Keychain.defaultAccessGroup = "group.com.example.shared"
    /// ```
    ///
    /// - Note: For Objective-C compatibility, use ``KeychainAccessGroup/setDefault(_:)`` instead.
    /// - SeeAlso: ``KeychainAccessGroup``
    public static var defaultAccessGroup: String?

    // MARK: - Initializers

    /// Creates a new `Keychain` instance with the specified service name and optional access group.
    ///
    /// Use this initializer when you need keychain storage that is isolated from the
    /// shared ``default`` instance, or when you need to target a specific access group
    /// for sharing keychain items between apps.
    ///
    /// ```swift
    /// let keychain = Keychain(serviceName: "com.example.myservice")
    ///
    /// let shared = Keychain(
    ///     serviceName: "com.example.shared",
    ///     accessGroup: "group.com.example.shared"
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - serviceName: A string identifying the service associated with keychain items.
    ///     This is stored in the `kSecAttrService` attribute and used to scope queries.
    ///   - accessGroup: An optional access group identifier for sharing keychain items
    ///     across apps and extensions. Pass `nil` (the default) to use the app's private keychain.
    public init(serviceName: String, accessGroup: String? = nil) {
        self.serviceName = serviceName
        self.accessGroup = accessGroup
    }

    private convenience init() {
        self.init(serviceName: Keychain.defaultServiceName, accessGroup: Keychain.defaultAccessGroup)
    }

    // MARK: - Querying

    /// Checks whether a value exists in the keychain for the specified key.
    ///
    /// This method attempts to retrieve the raw data for the given key. If data is found,
    /// it returns `true`; otherwise, it returns `false`.
    ///
    /// ```swift
    /// if Keychain.default.hasValue(forKey: "auth-token") {
    ///     // Token exists, proceed with authenticated request
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - key: The key to look up in the keychain.
    ///   - accessibility: An optional accessibility level to use when looking up the keychain item.
    ///     When `nil`, the query does not filter by accessibility.
    /// - Returns: `true` if a value exists for the given key, `false` otherwise.
    ///
    /// - SeeAlso: ``data(forKey:withAccessibility:)``
    open func hasValue(
        forKey key: String,
        withAccessibility accessibility: KeychainItemAccessibility? = nil
    )
        -> Bool
    {
        if let _ = data(forKey: key, withAccessibility: accessibility) {
            return true
        }

        return false
    }

    /// Returns the accessibility level currently assigned to a keychain item.
    ///
    /// Queries the keychain for the item associated with the given key and reads its
    /// `kSecAttrAccessible` attribute to determine the current accessibility setting.
    ///
    /// ```swift
    /// if let accessibility = Keychain.default.accessibilityOfKey("auth-token") {
    ///     print("Token accessibility: \(accessibility)")
    /// }
    /// ```
    ///
    /// - Parameter key: The key of the keychain item to inspect.
    /// - Returns: The ``KeychainItemAccessibility`` value for the item, or `nil` if the
    ///   item does not exist or its accessibility could not be determined.
    ///
    /// - SeeAlso: ``KeychainItemAccessibility``
    open func accessibilityOfKey(_ key: String) -> KeychainItemAccessibility? {
        var queryDictionary = self.setupQueryDictionary(forKey: key)
        queryDictionary[secMatchLimit] = kSecMatchLimitOne
        queryDictionary[secReturnAttributes] = kCFBooleanTrue

        var results: AnyObject?
        let status = SecItemCopyMatching(queryDictionary as CFDictionary, &results)

        guard
            status == errSecSuccess,
            let dictionary = results as? [String: AnyObject],
            let accessibility = dictionary[secAttrAccessible] as? String else
        {
            return nil
        }

        return KeychainItemAccessibility.accessbilityForAttributeValue(accessibility as CFString)
    }

    /// Returns the set of all keys stored in the keychain for this instance's service name and access group.
    ///
    /// Queries the keychain for all `kSecClassGenericPassword` items matching the current
    /// ``serviceName`` and ``accessGroup``, then extracts the key from each item's
    /// `kSecAttrAccount` attribute (decoded as UTF-8).
    ///
    /// ```swift
    /// let keys = Keychain.default.allKeys()
    /// for key in keys {
    ///     print("Stored key: \(key)")
    /// }
    /// ```
    ///
    /// - Returns: A `Set<String>` containing all keys. Returns an empty set if no items
    ///   are found or if the query fails.
    open func allKeys() -> Set<String> {
        var queryDictionary: [String: Any] = [
            secClass: kSecClassGenericPassword,
            secAttrService: serviceName,
            secReturnAttributes: kCFBooleanTrue!,
            secMatchLimit: kSecMatchLimitAll,
        ]

        if let accessGroup {
            queryDictionary[secAttrAccessGroup] = accessGroup
        }

        var results: AnyObject?
        let status = SecItemCopyMatching(queryDictionary as CFDictionary, &results)

        guard status == errSecSuccess else { return [] }

        var keys = Set<String>()

        if let results = results as? [[String: AnyObject]] {
            keys = results.reduce(into: Set<String>()) {
                (result: inout Set<String>, attr: [String: AnyObject]) in
                if
                    let accountData = attr[secAttrAccount] as? Data,
                    let key = String(data: accountData, encoding: .utf8)
                {
                    result.insert(key)
                }
            }
        }

        return keys
    }

    // MARK: - Getters

    /// Retrieves and decodes a `Decodable` object from the keychain for the specified key.
    ///
    /// The stored data is decoded using `JSONDecoder`. This method is suitable for any
    /// `Decodable` type that was previously stored via the corresponding `set` method.
    ///
    /// ```swift
    /// struct User: Codable {
    ///     let name: String
    ///     let email: String
    /// }
    ///
    /// let user = Keychain.default.object(of: User.self, forKey: "current-user")
    /// ```
    ///
    /// - Note: For `Numeric` types (e.g., `Int`, `Double`), the numeric-specific overload
    ///   is selected automatically by the compiler, which handles the single-element array
    ///   encoding format used during storage.
    ///
    /// - Parameters:
    ///   - type: The expected type to decode. Must conform to `Decodable`.
    ///   - key: The key of the keychain item to retrieve.
    ///   - accessibility: An optional accessibility level to use when looking up the keychain item.
    ///     When `nil`, the query does not filter by accessibility.
    /// - Returns: The decoded object of type `T`, or `nil` if the key does not exist
    ///   or decoding fails.
    open func object<T: Decodable>(
        of _: T.Type,
        forKey key: String,
        withAccessibility accessibility: KeychainItemAccessibility? = nil
    )
        -> T?
    {
        guard let data = data(forKey: key, withAccessibility: accessibility) else {
            return nil
        }

        return try? JSONDecoder().decode(T.self, from: data)
    }

    /// Retrieves and decodes a `Numeric` value from the keychain for the specified key.
    ///
    /// This overload handles numeric types (e.g., `Int`, `Double`, `Float`) which are stored
    /// as single-element JSON arrays (`[value]`) to work around `JSONEncoder`'s restriction
    /// on encoding top-level scalar fragments. The value is decoded from the array and the
    /// first element is returned.
    ///
    /// ```swift
    /// let count = Keychain.default.object(of: Int.self, forKey: "launch-count")
    /// let rating = Keychain.default.object(of: Double.self, forKey: "user-rating")
    /// ```
    ///
    /// - Parameters:
    ///   - type: The expected numeric type to decode. Must conform to both `Numeric` and `Decodable`.
    ///   - key: The key of the keychain item to retrieve.
    ///   - accessibility: An optional accessibility level to use when looking up the keychain item.
    ///     When `nil`, the query does not filter by accessibility.
    /// - Returns: The decoded numeric value of type `T`, or `nil` if the key does not exist
    ///   or decoding fails.
    open func object<T: Numeric & Decodable>(
        of _: T.Type,
        forKey key: String,
        withAccessibility accessibility: KeychainItemAccessibility? = nil
    )
        -> T?
    {
        guard let data = data(forKey: key, withAccessibility: accessibility) else {
            return nil
        }

        return try? JSONDecoder().decode([T].self, from: data)[0]
    }

    /// Retrieves a string value from the keychain for the specified key.
    ///
    /// The raw keychain data is decoded as a UTF-8 string. This method should be used
    /// to retrieve values that were stored via the `String` overload of ``set(_:forKey:withAccessibility:)-4z1a0``.
    ///
    /// ```swift
    /// if let token = Keychain.default.string(forKey: "auth-token") {
    ///     // Use the token
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - key: The key of the keychain item to retrieve.
    ///   - accessibility: An optional accessibility level to use when looking up the keychain item.
    ///     When `nil`, the query does not filter by accessibility.
    /// - Returns: The string value associated with the key, or `nil` if the key does not exist
    ///   or the data cannot be decoded as UTF-8.
    open func string(
        forKey key: String,
        withAccessibility accessibility: KeychainItemAccessibility? = nil
    )
        -> String?
    {
        guard let data = data(forKey: key, withAccessibility: accessibility) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    /// Retrieves raw `Data` from the keychain for the specified key.
    ///
    /// This is the lowest-level retrieval method. All other getter methods
    /// (``string(forKey:withAccessibility:)``, ``object(of:forKey:withAccessibility:)-4lcpw``,
    /// etc.) ultimately call this method to fetch the underlying data.
    ///
    /// The query is constructed using the key (encoded as UTF-8 data in both `kSecAttrGeneric`
    /// and `kSecAttrAccount`), the instance's ``serviceName``, and optionally the ``accessGroup``
    /// and the specified accessibility level.
    ///
    /// - Parameters:
    ///   - key: The key of the keychain item to retrieve.
    ///   - accessibility: An optional accessibility level to use when looking up the keychain item.
    ///     When `nil`, the query does not filter by accessibility.
    /// - Returns: The raw `Data` associated with the key, or `nil` if the key does not exist
    ///   or the query fails.
    open func data(
        forKey key: String,
        withAccessibility accessibility: KeychainItemAccessibility? = nil
    )
        -> Data?
    {
        var queryDictionary = self.setupQueryDictionary(forKey: key, withAccessibility: accessibility)

        // Limit result to 1
        queryDictionary[secMatchLimit] = kSecMatchLimitOne

        // Specify we want data only
        queryDictionary[secReturnData] = kCFBooleanTrue

        // Search
        var result: AnyObject?
        let status = SecItemCopyMatching(queryDictionary as CFDictionary, &result)

        return (status == errSecSuccess) ? (result as? Data) : nil
    }

    // MARK: - Setters

    /// Stores an `Encodable` object in the keychain for the specified key.
    ///
    /// The value is serialized to JSON using `JSONEncoder` and then stored as raw data.
    /// If an item with the same key already exists, it is overwritten.
    ///
    /// ```swift
    /// struct User: Codable {
    ///     let name: String
    ///     let email: String
    /// }
    ///
    /// let user = User(name: "Dom", email: "dom@example.com")
    /// Keychain.default.set(user, forKey: "current-user")
    /// ```
    ///
    /// - Note: For `Numeric` types (e.g., `Int`, `Double`), the numeric-specific overload
    ///   is selected automatically by the compiler, which wraps the value in a single-element
    ///   array before encoding.
    ///
    /// - Parameters:
    ///   - value: The `Encodable` value to store.
    ///   - key: The key to associate with the stored value.
    ///   - accessibility: An optional accessibility level for the keychain item.
    ///     When `nil`, defaults to ``KeychainItemAccessibility/whenUnlocked``.
    /// - Returns: `true` if the value was successfully stored, `false` if encoding or the
    ///   keychain operation failed.
    @discardableResult
    open func set(
        _ value: some Encodable,
        forKey key: String,
        withAccessibility accessibility: KeychainItemAccessibility? = nil
    )
        -> Bool
    {
        guard let data = try? JSONEncoder().encode(value) else { return false }

        return self.set(data, forKey: key, withAccessibility: accessibility)
    }

    /// Stores a `Numeric` value in the keychain for the specified key.
    ///
    /// The value is wrapped in a single-element array (`[value]`) before JSON encoding
    /// to work around `JSONEncoder`'s restriction on encoding top-level scalar fragments.
    /// If an item with the same key already exists, it is overwritten.
    ///
    /// ```swift
    /// Keychain.default.set(42, forKey: "launch-count")
    /// Keychain.default.set(3.14, forKey: "pi-value")
    /// ```
    ///
    /// - Parameters:
    ///   - value: The `Numeric` and `Encodable` value to store.
    ///   - key: The key to associate with the stored value.
    ///   - accessibility: An optional accessibility level for the keychain item.
    ///     When `nil`, defaults to ``KeychainItemAccessibility/whenUnlocked``.
    /// - Returns: `true` if the value was successfully stored, `false` if encoding or the
    ///   keychain operation failed.
    @discardableResult
    open func set(
        _ value: some Numeric & Encodable,
        forKey key: String,
        withAccessibility accessibility: KeychainItemAccessibility? = nil
    )
        -> Bool
    {
        guard let data = try? JSONEncoder().encode([value]) else { return false }

        return self.set(data, forKey: key, withAccessibility: accessibility)
    }

    /// Stores a `String` value in the keychain for the specified key.
    ///
    /// The string is encoded to `Data` using UTF-8 encoding and then stored.
    /// If an item with the same key already exists, it is overwritten.
    ///
    /// ```swift
    /// Keychain.default.set("my-secret-token", forKey: "auth-token")
    /// ```
    ///
    /// - Parameters:
    ///   - value: The string value to store.
    ///   - key: The key to associate with the stored value.
    ///   - accessibility: An optional accessibility level for the keychain item.
    ///     When `nil`, defaults to ``KeychainItemAccessibility/whenUnlocked``.
    /// - Returns: `true` if the value was successfully stored, `false` if UTF-8 encoding
    ///   or the keychain operation failed.
    @discardableResult
    open func set(
        _ value: String,
        forKey key: String,
        withAccessibility accessibility: KeychainItemAccessibility? = nil
    )
        -> Bool
    {
        guard let data = value.data(using: .utf8) else { return false }

        return self.set(data, forKey: key, withAccessibility: accessibility)
    }

    /// Stores raw `Data` in the keychain for the specified key.
    ///
    /// This is the lowest-level setter method. All other setter methods ultimately call
    /// this method to persist data to the keychain.
    ///
    /// The method first attempts to add the item using `SecItemAdd`. If an item with
    /// the same key already exists (`errSecDuplicateItem`), it falls back to updating
    /// the existing item using `SecItemUpdate`.
    ///
    /// - Parameters:
    ///   - value: The raw `Data` to store.
    ///   - key: The key to associate with the stored value.
    ///   - accessibility: An optional accessibility level for the keychain item.
    ///     When `nil`, defaults to ``KeychainItemAccessibility/whenUnlocked``.
    /// - Returns: `true` if the data was successfully stored (either added or updated),
    ///   `false` if the keychain operation failed.
    @discardableResult
    open func set(
        _ value: Data,
        forKey key: String,
        withAccessibility accessibility: KeychainItemAccessibility? = nil
    )
        -> Bool
    {
        var queryDictionary: [String: Any] = self.setupQueryDictionary(forKey: key, withAccessibility: accessibility)
        queryDictionary[secValueData] = value

        if accessibility == nil {
            // Default protection level. The data is only valid when the device is unlocked.
            queryDictionary[secAttrAccessible] = KeychainItemAccessibility.whenUnlocked.keychainAttrValue
        }

        let status = SecItemAdd(queryDictionary as CFDictionary, nil)

        if status == errSecSuccess {
            return true
        } else if status == errSecDuplicateItem {
            return self.update(value, forKey: key, withAccessibility: accessibility)
        } else {
            return false
        }
    }

    // MARK: - Removal

    /// Removes a single keychain item associated with the specified key.
    ///
    /// If you are re-using a key but with a different accessibility level, you should
    /// call this method to delete the previous value first, since keychain items with
    /// different accessibility settings are stored as separate entries.
    ///
    /// ```swift
    /// Keychain.default.removeObject(forKey: "auth-token")
    /// ```
    ///
    /// - Parameters:
    ///   - key: The key of the keychain item to remove.
    ///   - accessbility: An optional accessibility level to use when looking up the keychain
    ///     item to remove. When `nil`, the query does not filter by accessibility.
    /// - Returns: `true` if the item was successfully removed, `false` if the item was
    ///   not found or the operation failed.
    @discardableResult
    open func removeObject(
        forKey key: String,
        withAccessibility accessbility: KeychainItemAccessibility? = nil
    )
        -> Bool
    {
        let queryDictionary: [String: Any] = self.setupQueryDictionary(forKey: key, withAccessibility: accessbility)
        let status = SecItemDelete(queryDictionary as CFDictionary)

        return status == errSecSuccess
    }

    /// Removes all keychain items matching this instance's ``serviceName`` and ``accessGroup``.
    ///
    /// This method deletes all `kSecClassGenericPassword` items that were stored using
    /// this `Keychain` instance's service name and access group. Items stored by other
    /// `Keychain` instances with different service names are not affected.
    ///
    /// ```swift
    /// Keychain.default.removeAllKeys()
    /// ```
    ///
    /// - Returns: `true` if the items were successfully removed, `false` if the operation
    ///   failed (e.g., no items existed to remove).
    ///
    /// - SeeAlso: ``wipeKeychain()``
    @discardableResult
    open func removeAllKeys() -> Bool {
        var queryDictionary: [String: Any] = [secClass: kSecClassGenericPassword]
        queryDictionary[secAttrService] = self.serviceName

        if let accessGroup {
            queryDictionary[secAttrAccessGroup] = accessGroup
        }

        let status = SecItemDelete(queryDictionary as CFDictionary)

        return status == errSecSuccess
    }

    /// Removes ALL keychain items from the device, regardless of service name, access group, or item class.
    ///
    /// This class method deletes every keychain item across all security classes:
    /// - `kSecClassGenericPassword` (generic passwords)
    /// - `kSecClassInternetPassword` (internet passwords)
    /// - `kSecClassCertificate` (certificates)
    /// - `kSecClassKey` (cryptographic keys)
    /// - `kSecClassIdentity` (identities)
    ///
    /// - Warning: This is a destructive operation that removes keychain items globally,
    ///   including items that were **not** added by KeychainKit. This may affect other
    ///   apps, system certificates, and cryptographic keys. Use with extreme caution
    ///   and only for development or testing purposes.
    ///
    /// - SeeAlso: ``removeAllKeys()`` for a scoped alternative that only removes items
    ///   matching the current service name and access group.
    open class func wipeKeychain() {
        self.deleteKeychainSecClass(kSecClassGenericPassword)
        self.deleteKeychainSecClass(kSecClassInternetPassword)
        self.deleteKeychainSecClass(kSecClassCertificate)
        self.deleteKeychainSecClass(kSecClassKey)
        self.deleteKeychainSecClass(kSecClassIdentity)
    }

    // MARK: - Private Methods

    /// Remove all items for a given keychain item class.
    @discardableResult
    private class func deleteKeychainSecClass(
        _ destSecClass: AnyObject
    )
        -> Bool
    {
        let queryDictionary = [secClass: destSecClass]
        let status = SecItemDelete(queryDictionary as CFDictionary)

        return status == errSecSuccess
    }

    /// Update existing data associated with a key name.
    private func update(
        _ value: Data,
        forKey key: String,
        withAccessibility accessbility: KeychainItemAccessibility? = nil
    )
        -> Bool
    {
        let queryDictionary = self.setupQueryDictionary(
            forKey: key, withAccessibility: accessbility
        )
        let updateDictionary = [secValueData: value]

        let status = SecItemUpdate(
            queryDictionary as CFDictionary, updateDictionary as CFDictionary
        )

        return status == errSecSuccess
    }

    /// Setup the query dictionary used to access the keychain on iOS for a specific key name.
    ///
    /// - parameter forKey: The key this query is for
    /// - parameter withAccessibility: Optional accessibility to use when setting the keychain item.
    /// Default to `.whenUnlocked`
    /// - returns: A dictionary with all the needed properties setup to access the keychain on iOS.
    private func setupQueryDictionary(
        forKey key: String,
        withAccessibility accessibility: KeychainItemAccessibility? = nil
    )
        -> [String: Any]
    {
        var queryDictionary: [String: Any] = [secClass: kSecClassGenericPassword]
        queryDictionary[secAttrService] = self.serviceName

        if let accessibility {
            queryDictionary[secAttrAccessible] = accessibility.keychainAttrValue
        }

        if let accessGroup {
            queryDictionary[secAttrAccessGroup] = accessGroup
        }

        let encodedKey = key.data(using: .utf8)

        queryDictionary[secAttrGeneric] = encodedKey
        queryDictionary[secAttrAccount] = encodedKey

        return queryDictionary
    }
}
