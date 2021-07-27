//
//  Account.swift
//  Portal
//
//  Created by Farid on 19.07.2021.
//

import Foundation

class Account: IAccount {
    let id: String
    let type: AccountType
    let mnemonicDereviation: MnemonicDerivation

    private(set) var name: String
    private(set) var fiatCurrencyCode: String

    init(id: String, name: String, bip: MnemonicDerivation, type: AccountType) {
        self.id = id
        self.name = name
        self.type = type
        self.fiatCurrencyCode = "USD"
        self.mnemonicDereviation = bip
    }
}

extension Account: Hashable {

    public static func ==(lhs: Account, rhs: Account) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}

class MockedAccount: IAccount {
    var id: String {
        UUID().uuidString
    }
    
    var name: String {
        "Mocked"
    }
    
    var type: AccountType {
        AccountType.mnemonic(words: [], salt: String())
    }
    
    var fiatCurrencyCode: String {
        "USD"
    }
    
    var mnemonicDereviation: MnemonicDerivation {
        MnemonicDerivation(rawValue: "bip44")!
    }
}
