//
//  Account.swift
//  Portal
//
//  Created by Farid on 19.07.2021.
//

import Foundation

class Account: IAccount {
    let id: UUID
    let type: AccountType
    let mnemonicDereviation: MnemonicDerivation

    private(set) var name: String
    private(set) var fiatCurrencyCode: String

    init(accountRecord: AccountRecord, type: AccountType) {
        self.id = accountRecord.id
        self.name = accountRecord.name
        self.type = type
        self.fiatCurrencyCode = accountRecord.fiatCurrencyCode
        
        guard let bip = MnemonicDerivation(rawValue: accountRecord.bip) else {
            fatalError("bip isn't set")
        }
        
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
    var id: UUID {
        UUID()
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
