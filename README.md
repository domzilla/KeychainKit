
KeychainKit is a lightweight Swift wrapper for the iOS Keychain. It makes accessing the Keychain as simple as using `UserDefaults`. It is based on [KeychainWrapper](https://github.com/puretears/KeychainWrapper).

### KeychainKit 101

The simplest use case is by using the `default` singleton, allowing you to save and load data in a way similar to manipulating `UserDefaults`.

You can add values to the Keychain. All `set` methods return a `Bool` to indicate whether the data was saved successfully. If the key already exists, the data will be overwritten.

```swift
/// Save data
Keychain.default.set(1, forKey: "key.int.value")
Keychain.default.set([1, 2, 3], forKey: "key.array.value")
Keychain.default.set("string value", forKey: "key.string.value")
```

You can retrieve values from the Keychain. All getter methods return `T?`. If the data corresponding to `forKey` cannot be decoded back to `T`, it returns `nil`.

```swift
/// Load data
Keychain.default.object(of: Int.self, forKey: "key.int.value")
Keychain.default.object(of: Array.self, forKey: "key.array.value")
Keychain.default.string(forKey: "key.string.value")
```

You can remove data from the Keychain. The method returns a `Bool` indicating whether the deletion was successful.

```swift
Keychain.default.removeObject(forKey: "key.to.be.deleted")
```

## Customization

### Specify Service Name

When you use the `default` Keychain object, all keys are linked to your main bundle identifier as the service name. However, you can change it as follows:

```swift
let serviceName = "Custom.Service.Name"
let keychain = Keychain(serviceName: serviceName)
```

### Specify Access Group

You can also share Keychain items through a customized access group:

```swift
let serviceName = "Custom.Service.Name"
let accessGroup = "Shared.Access.Group"
let keychain = Keychain(serviceName: serviceName, accessGroup: accessGroup)
```

The `default` Keychain object does not share any Keychain items, and its `accessGroup` is `nil`.

### Accessibility

By default, all items saved by `Keychain` can only be accessed when the device is unlocked. The `enum KeychainItemAccessibility` provides a customization point to specify a different accessibility level.

```swift
Keychain.default.set(1, forKey: "key.int.value", withAccessibility: .afterFirstUnlock)
```

The `kSecAttrAccessibleAlways` and `kSecAttrAccessibleAlwaysThisDeviceOnly` attributes were deprecated in iOS 12.0, so we do not include them in `KeychainItemAccessibility`.

## License

KeychainKit is released under the MIT license. See the LICENSE file for details.
