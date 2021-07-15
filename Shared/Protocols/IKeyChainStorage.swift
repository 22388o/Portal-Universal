//
//  IKeyChainStorage.swift
//  Portal
//
//  Created by Farid on 14.05.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation

protocol IKeychainStorage {
    func save(data: Data, key: String)
    func save(string: String, key: String)
    func string(for key: String) -> String?
    func data(for key: String) -> Data?
    func recoverStringArray(for key: String) -> [String]?
    func remove(key: String) throws
    func clear() throws
}
