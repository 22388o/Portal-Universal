//
//  WalletStorage.swift
//  Portal
//
//  Created by Farid on 19.07.2021.
//

import Foundation
import Combine

class WalletStorage: IWalletStorage {
    private let coinManager: ICoinManager
    private let accountManager: IAccountManager
    var wallets: [Wallet] = []
    
    private var cancelabel = Set<AnyCancellable>()

    init(coinManager: ICoinManager, accountManager: IAccountManager) {
        self.coinManager = coinManager
        self.accountManager = accountManager
        
        syncWallets()
        subscribeForUpdates()
    }
    
    private func subscribeForUpdates() {
        accountManager.onActiveAccountUpdatePublisher
            .sink { [weak self] _ in
                self?.syncWallets()
            }
            .store(in: &cancelabel)
    }
    
    func syncWallets() {
        wallets.removeAll()
        
        for account in accountManager.accounts {
            for coin in coinManager.coins {
                wallets.append(Wallet(coin: coin, account: account))
            }
        }
    }
    
    func wallets(account: Account) -> [Wallet] {
        wallets.filter{ $0.account == account }
    }
    
    func clearWallets() {
        wallets.removeAll()
    }
    
    func handle(newWallets: [Wallet], deletedWallets: [Wallet]) {
        
    }
}

