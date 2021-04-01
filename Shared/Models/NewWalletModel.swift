//
//  NewWalletModel.swift
//  Portal
//
//  Created by Farid on 14.05.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation

struct NewWalletModel {
    let id: UUID
    let name: String
    let addressType: BtcAddressFormat
    let seed: [String]
    
    var seedData: Data? {
        seed.joined(separator: ",").data(using: .utf8)
    }
    
    init(name: String, addressType: BtcAddressFormat = .segwit) {
        self.id = UUID()
        self.name = name
        self.addressType = addressType
        self.seed = NewWalletModel.randomSeed()
    }
    
    static func randomSeed() -> [String] {
        ["merge", "symptom", "old", "tail", "earth", "metal", "identify", "lonely", "bottom", "other", "local", "trophy", "mom", "wide", "multiply", "earn", "embrace", "fly", "tube", "hammer", "pet", "gun", "cake", "laundry"]
    }
}
