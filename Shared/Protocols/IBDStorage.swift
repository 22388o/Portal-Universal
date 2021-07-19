//
//  IBDStorage.swift
//  Portal
//
//  Created by Farid on 15.07.2021.
//

import Foundation

protocol IDBStorage {
    func fetchWallets() throws -> [AccountRecord]?
    func createWallet(model: NewAccountModel) throws -> AccountRecord?
    func delete(wallet: AccountRecord) throws
    func deleteWallets(wallets: [AccountRecord]) throws
}

protocol IIDBStorage {
    func accountRecords() -> [AccountRecord]
    func account(id: UUID) -> AccountRecord?
    func save(account: Account) throws
    func createAccount(model: NewAccountModel) throws -> AccountRecord?
    func deleteAccount(id: String) throws
    func delete(account: Account) throws
    func deleteAccounts(accounts: [Account]) throws
    func clear()
}
