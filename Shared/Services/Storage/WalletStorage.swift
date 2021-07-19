//
//  WalletStorage.swift
//  Portal
//
//  Created by Farid on 19.07.2021.
//

import Foundation

class WalletStorage: IWalletStorage {
    private let coinManager: ICoinManager
    private let accountManager: IAccountManager
    var allWallets: [Wallet] = []

    init(coinManager: ICoinManager, accountManager: IAccountManager) {
        self.coinManager = coinManager
        self.accountManager = accountManager
        
        syncWallets()
    }
    
    func syncWallets() {
        allWallets.removeAll()
        
        for account in accountManager.accounts {
            for coin in coinManager.coins {
                allWallets.append(Wallet(coin: coin, account: account))
            }
        }
    }
    
    func wallets(account: Account) -> [Wallet] {
        allWallets.filter{ $0.account == account }
    }
    
    func clearWallets() {
        allWallets.removeAll()
    }
    
    func handle(newWallets: [Wallet], deletedWallets: [Wallet]) {
        
    }
}

