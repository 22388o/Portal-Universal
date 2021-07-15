//
//  IBDStorage.swift
//  Portal
//
//  Created by Farid on 15.07.2021.
//

import Foundation

protocol IDBStorage {
    func fetchWallets() throws -> [DBWallet]?
    func createWallet(model: NewWalletModel) throws -> DBWallet?
    func delete(wallet: DBWallet) throws
    func deleteWallets(wallets: [DBWallet]) throws
}
