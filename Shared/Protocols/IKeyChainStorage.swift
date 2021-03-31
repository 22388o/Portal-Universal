//
//  IKeyChainStorage.swift
//  Portal
//
//  Created by Farid on 14.05.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation

protocol IKeyChainStorage {
    func save(string: String, for key: String)
    func string(for key: String) -> String?
    func data(for key: String) -> Data?
    func save(data: Data, key: String)
    func clear() throws
}
