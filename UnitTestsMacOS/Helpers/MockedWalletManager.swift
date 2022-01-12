//
//  MockedWalletManager.swift
//  UnitTestsMacOS
//
//  Created by farid on 1/11/22.
//

import Combine
import Foundation
@testable import Portal

class MockedWalletManager: IWalletManager {
    static let mockedWallet = Wallet(
        coin: .bitcoin(),
        account: Account(
            id: UUID().uuidString,
            name: "Mocked",
            bip: .bip44,
            type: .mnemonic(words: [], salt: String())
        )
    )
    
    var onWalletsUpdate = PassthroughSubject<[Wallet], Never>()
    var activeWallets: [Wallet] = [MockedWalletManager.mockedWallet]
    var wallets: [Wallet] = [MockedWalletManager.mockedWallet]
    
    func preloadWallets() {
        
    }
    
    func wallets(account: Account) -> [Wallet] {
        wallets
    }
    
    func handle(newWallets: [Wallet], deletedWallets: [Wallet]) {
        
    }
    
    func save(wallets: [Wallet]) {
        
    }
    
    func delete(wallets: [Wallet]) {
        
    }
    
    func clearWallets() {
        
    }
}
