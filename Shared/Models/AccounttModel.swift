//
//  AccountModel.swift
//  Portal
//
//  Created by Farid on 14.05.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation
import HdWalletKit

struct AccountModel {
    let name: String
    let addressType: BtcAddressFormat
    let seed: [String]
    
    var seedData: Data? {
        return try? JSONSerialization.data(withJSONObject: seed, options: [])
    }
    
    init(name: String, addressType: BtcAddressFormat = .segwit, seed: [String]) {
        self.name = name
        self.addressType = addressType
        self.seed = seed
    }
    
    private func tesmpSeed() -> [String] {
        ["fruit", "seat", "assault", "fit", "daughter", "minute", "outer", "boy", "illness", "make", "genius", "confirm", "describe", "fox", "furnace", "meadow", "used", "goat", "mom", "deliver", "traffic", "much", "deer", "silver"]
    }
    
    static func generateWords() throws -> [String] {
        try Mnemonic.generate(wordCount: .twentyFour, language: .english)
    }
}
