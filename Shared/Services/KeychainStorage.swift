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
        self.keychain = keychain.accessibility(.whenUnlockedThisDeviceOnly)
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
}
