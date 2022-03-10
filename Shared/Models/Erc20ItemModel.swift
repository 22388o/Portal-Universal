//
//  Erc20ItemModel.swift
//  Portal
//
//  Created by farid on 3/10/22.
//

import Foundation

class Erc20ItemModel: ObservableObject, Identifiable {
    let id: UUID = UUID()
    let coin: Coin
    
    var isInWallet: Bool {
        didSet {
            Portal.shared.accountManager.addCoin(coin: coin.code)
        }
    }
    
    init(coin: Coin, isInWallet: Bool) {
        self.coin = coin
        self.isInWallet = isInWallet
    }
}
