//
//  AccountManager.swift
//  Portal
//
//  Created by Farid on 19.07.2021.
//

import Foundation
import Combine

final class AccountManager: IAccountManager {
    var onActiveAccountUpdatePublisher = PassthroughSubject<Account?, Never>()

    private let storage: IIDBStorage
    private let secureStorage: IKeychainStorage
    private let localStorage: ILocalStorage
    
    private(set) var accounts: [Account] = []
    
    init(dbStorage: IIDBStorage, secureStorage: IKeychainStorage, localStorage: ILocalStorage) {
        self.storage = dbStorage
        self.secureStorage = secureStorage
        self.localStorage = localStorage
                
        syncAccounts()        
    }
    
    private func syncAccounts() {
        accounts.removeAll()
        
        let accountRecords = storage.accountRecords()
        
        for record in accountRecords {
            if let words = secureStorage.recoverStringArray(for: record.id) {
                let account = Account(accountRecord: record, type: .mnemonic(words: words, salt: ""))
                accounts.append(account)
            }
        }
    }
    
    var activeAccount: Account? {
        guard let id = localStorage.getCurrentWalletID() else { return nil }
        return account(id: id)
    }
    
    func account(id: UUID) -> Account? {
        accounts.first(where: { $0.id == id })
    }
    
    func createNewAccount(model: NewAccountModel) {
        guard
            let record = try? storage.createAccount(model: model),
            let data = model.seedData
        else { return }
        
        secureStorage.save(data: data, key: record.id)
        
        let newAccount = Account(accountRecord: record, type: .mnemonic(words: model.seed, salt: ""))
        localStorage.setCurrentWalletID(newAccount.id)
        
        accounts.append(newAccount)
        
        onActiveAccountUpdatePublisher.send(newAccount)
    }
    
    func createAccount(model: NewAccountModel) -> Account? {
        guard
            let record = try? storage.createAccount(model: model),
            let data = model.seedData
        else { return nil }
        
        secureStorage.save(data: data, key: record.id)
        
        let newAccount = Account(accountRecord: record, type: .mnemonic(words: model.seed, salt: ""))
        localStorage.setCurrentWalletID(newAccount.id)
        
        accounts.append(newAccount)
        
        onActiveAccountUpdatePublisher.send(newAccount)
        
        return newAccount
    }
    
    func setActiveAccount(id: UUID) {
        localStorage.setCurrentWalletID(id)
        onActiveAccountUpdatePublisher.send(activeAccount)
    }
    
    func save(account: Account) {
        do {
            try storage.save(account: account)
        } catch {
            print("Cannot save account")
        }
        syncAccounts()
    }
    
    func delete(account: Account) {
        do {
            try storage.delete(account: account)
        } catch {
            print("Cannot delete account")
        }
        syncAccounts()
    }
    
    func delete(accountId: String) {
        do {
            try storage.deleteAccount(id: accountId)
        } catch {
            print("Cannot delete account")
        }
        syncAccounts()
    }
    
    func clear() {
        storage.clear()
    }
}
