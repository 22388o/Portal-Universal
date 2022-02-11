//
//  MockedAccountMannager.swift
//  UnitTestsMacOS
//
//  Created by farid on 1/21/22.
//

import Foundation
import Combine
@testable import Portal

struct MockedAccountManager: IAccountManager {
    
    private let mockedAccount = Account(
        id: UUID().uuidString,
        name: "Mocked",
        bip: .bip44,
        type: .mnemonic(words: [], salt: String())
    )
    
    private let accountToSave = Account(
        id: "accountToSave",
        name: "Account to save",
        bip: .bip44,
        type: .mnemonic(words: [], salt: String())
    )
    
    private let accountToDelete = Account(
        id: "accountToDelete",
        name: "Account to delete",
        bip: .bip49,
        type: .mnemonic(words: [], salt: String())
    )
    
    var onActiveAccountUpdate: PassthroughSubject<Account?, Never> = PassthroughSubject<Account?, Never>()
    
    var accounts: [Account] {
        [mockedAccount]
    }
    
    var activeAccount: Account? {
        mockedAccount
    }
    
    func account(id: String) -> Account? {
        mockedAccount
    }
    
    func updateWalletCurrency(code: String) {
        
    }
    
    func setActiveAccount(id: String) {
        onActiveAccountUpdate.send(accountToSave)
    }
    
    func save(account: Account) {
        onActiveAccountUpdate.send(accountToDelete)
    }
    
    func update(account: Account) {
        
    }
    
    func delete(account: Account) {
        onActiveAccountUpdate.send(accountToDelete)
    }
    
    func delete(accountId: String) {
        
    }
    
    func clear() {
        
    }
}
