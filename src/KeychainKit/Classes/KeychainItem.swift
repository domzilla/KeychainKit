//
//  KeychainItem.swift
//  KeychainKit
//
//  Created by Mars on 2019/9/22.
//  Copyright © 2019 Mars. All rights reserved.
//

import Foundation

@propertyWrapper
public struct KeychainStoreString {
  public let key: String
  
  public init(key: String) {
    self.key = key
  }
  
  public var wrappedValue: String? {
    get {
      Keychain.default.string(forKey: key)
    }
    
    set {
      guard let v = newValue else { return }
      
      Keychain.default.set(v, forKey: key)
    }
  }
  
  public var projectedValue: Keychain {
    get {
      return Keychain.default
    }
  }
}

@propertyWrapper
public struct KeychainStoreNumber<T> where T: Numeric, T: Codable {
  public let key: String
  
  public init(key: String) {
    self.key = key
  }
  
  public var wrappedValue: T? {
    get {
      Keychain.default.object(of: T.self, forKey: key)
    }
    
    set {
      guard let v = newValue else { return }
      
      Keychain.default.set(v, forKey: key)
    }
  }
  
  public var projectedValue: Keychain {
    get {
      return Keychain.default
    }
  }
}

@propertyWrapper
public struct KeychainStoreObject<T> where T: Codable {
  public let key: String
  
  public init(key: String) {
    self.key = key
  }
  
  public var wrappedValue: T? {
    get {
      Keychain.default.object(of: T.self, forKey: key)
    }
    
    set {
      guard let v = newValue else { return }
      
      Keychain.default.set(v, forKey: key)
    }
  }
  
  public var projectedValue: Keychain {
    get {
      return Keychain.default
    }
  }
}
