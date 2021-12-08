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
            DispatchQueue.main.async {
                Portal.shared.state.loading = false
                Portal.shared.state.rootView = .createAccount
            }
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
        accountStorage.update(account: account)
        nextActiveAccount()
        setActiveAccount(id: account.id)
    }
    
    func updateWalletCurrency(code: String) {
        if let account = activeAccount, account.fiatCurrencyCode != code {
            account.fiatCurrencyCode = code
            accountStorage.update(account: account)
        }
    }
    
    func clear() {
        accountStorage.clear()
    }
}
