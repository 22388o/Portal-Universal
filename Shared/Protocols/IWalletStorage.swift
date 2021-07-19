//
//  IWalletStorage.swift
//  Portal
//
//  Created by Farid on 19.07.2021.
//

import Foundation

protocol IWalletStorage {
    var allWallets: [Wallet] { get }
//    func wallets(accounts: [Account]) -> [Wallet]
    func wallets(account: Account) -> [Wallet]
    func handle(newWallets: [Wallet], deletedWallets: [Wallet])
    func clearWallets()
}
