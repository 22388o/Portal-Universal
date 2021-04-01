//
//  BalanceProvider.swift
//  Portal
//
//  Created by Farid on 19.05.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation

final class BalanceProvider: IBalanceProvider {
    let coin: Coin
    let coinKit: ICoinKit
    
    let tempBalance: String
    let tempTotalValue = "$\(Double.random(in: 255..<5955).rounded(toPlaces: 2))"
    let tempBalanceForCurrency = Double.random(in: 0.75 ..< 2.795).rounded(toPlaces: 1)
    let tempPrice = "$\(Double.random(in: 200..<5000).rounded(toPlaces: 1))"
    
    init(coin: Coin, kit: ICoinKit) {
        self.coin = coin
        self.coinKit = kit
        
        self.tempBalance = "\(coinKit.balance)"
    }
    
    var balanceString: String {
       tempBalance
    }
    
    var totalValueString: String {
        tempTotalValue
    }
    
    var price: String {
        tempPrice
    }
    
    func balance(currency: Currency) -> Double {
        tempBalanceForCurrency
        //balance * marketData.price(currency: currency)
    }
}
