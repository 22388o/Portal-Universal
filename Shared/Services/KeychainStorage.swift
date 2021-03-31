//
//  KeychainStorage.swift
//  Portal
//
//  Created by Farid on 14.05.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation
import KeychainAccess

final class KeychainStorage: IKeyChainStorage {
    private let keychain: Keychain
    
    init() {
        keychain = Keychain(service: "com.portal.keychain.service").accessibility(.whenPasscodeSetThisDeviceOnly)
    }
    
    func string(for key: String) -> String? {
        keychain[key]
    }
    
    func save(string: String, for key: String) {
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
}
