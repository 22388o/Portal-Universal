//
//  AccountManager.swift
//  Portal
//
//  Created by Farid on 19.07.2021.
//

import Foundation
import Combine

final class AccountManager {
    var onActiveAccountUpdatePublisher = PassthroughSubject<Account?, Never>()

    private let accountStorage: AccountStorage
    
    init(accountStorage: AccountStorage) {
        self.accountStorage = accountStorage
    }
        
    private func nextActiveAccount() {
        if let newWalletId = accounts.first?.id {
            setActiveAccount(id: newWalletId)
        } else {
            Portal.shared.state.current = .createAccount
        }
    }
}

extension AccountManager: IAccountManager {
    var activeAccount: Account? {
        accountStorage.activeAccount
    }
    
    var accounts: [Account] {
        accountStorage.allAccounts
    }
    
    func account(id: String) -> Account? {
        accounts.first(where: { $0.id == id })
    }
    
    func setActiveAccount(id: String) {
        accountStorage.setCurrentAccount(id: id)
        onActiveAccountUpdatePublisher.send(accountStorage.activeAccount)
    }
    
    func save(account: Account) {
        accountStorage.save(account: account)
        onActiveAccountUpdatePublisher.send(account)
    }
    
    func delete(account: Account) {
        accountStorage.delete(account: account)
        nextActiveAccount()
    }
    
    func delete(accountId: String) {
        accountStorage.delete(accountId: accountId)
        nextActiveAccount()
    }
    
    func update(account: Account) {
        
    }
    
    func clear() {
        accountStorage.clear()
    }
}
