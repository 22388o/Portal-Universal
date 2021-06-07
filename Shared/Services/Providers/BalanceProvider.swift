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
    
    private let tempBalance: String
    private let tempTotalValue = "$\(Double.random(in: 255..<5955).rounded(toPlaces: 1))"
    private let tempBalanceForCurrency: Double
    private let tempPrice = "$\(Double.random(in: 200..<5000).rounded(toPlaces: 1))"
    
    init(coin: Coin, kit: ICoinKit) {
        self.coin = coin
        self.coinKit = kit
        
        let balance = coinKit.balance
        self.tempBalance = "\(balance)"
        self.tempBalanceForCurrency = balance
        
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
    
    func balance(currency: Currency) -> Decimal {
        Decimal(tempBalanceForCurrency)
        //balance * marketData.price(currency: currency)
    }
    
    static func mocked() -> IBalanceProvider {
        BalanceProvider(coin: Coin.bitcoin(), kit: MockCoinKit())
    }
}
