//
//  MockedAdapterManager.swift
//  Portal
//
//  Created by farid on 1/10/22.
//

import Combine
@testable import Portal

class MockedAdapterManager: IAdapterManager {
    var adapterReady = CurrentValueSubject<Bool, Never>(false)
    
    func adapter(for wallet: Wallet) -> IAdapter? {
        nil
    }
    
    func adapter(for coin: Coin) -> IAdapter? {
        nil
    }
    
    func balanceAdapter(for wallet: Wallet) -> IBalanceAdapter? {
        MockedBalanceAdapter()
    }
    
    func transactionsAdapter(for wallet: Wallet) -> ITransactionsAdapter? {
        MockedTransactionAdapter()
    }
    
    func depositAdapter(for wallet: Wallet) -> IDepositAdapter? {
        nil
    }
    
    func refresh() {
        
    }
    
    func refreshAdapters(wallets: [Wallet]) {
        
    }
    
    func refresh(wallet: Wallet) {
        
    }
}
