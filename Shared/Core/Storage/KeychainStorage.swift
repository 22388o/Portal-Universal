//
//  KeychainStorage.swift
//  Portal
//
//  Created by Farid on 14.05.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation
import KeychainAccess

final class KeychainStorage: IKeychainStorage {
    private let keychain: Keychain
        
    init(keychain: Keychain) {
        self.keychain = keychain.accessibility(.whenPasscodeSetThisDeviceOnly)
    }
    
    func string(for key: String) -> String? {
        keychain[key]
    }
    
    func save(string: String, key: String) {
        keychain[key] = string
    }
    
    func data(for key: String) -> Data? {
        keychain[data: key]
    }
    
    func save(data: Data, key: String) {
        keychain[data: key] = data
    }
    
    func clear() throws {
        try keychain.removeAll()
    }
    
    func remove(key: String) throws {
        try keychain.remove(key)
    }
    
    func recoverStringArray(for key: String) -> [String]? {
        guard let data = data(for: key), let seed = data.toStringArray else { return nil }
        return seed
    }
    
    func value<T: LosslessStringConvertible>(for key: String) -> T? {
        guard let string = keychain[key] else {
            return nil
        }
        return T(string)
    }

    func set<T: LosslessStringConvertible>(value: T?, for key: String) throws {
        if let value = value {
            try keychain.set(value.description, key: key)
        } else {
            try keychain.remove(key)
        }
    }

    func value(for key: String) -> Data? {
        try? keychain.getData(key)
    }

    func set(value: Data?, for key: String) throws {
        if let value = value {
            try keychain.set(value, key: key)
        } else {
            try keychain.remove(key)
        }
    }

    func removeValue(for key: String) throws {
        try keychain.remove(key)
    }
}