//
//  BalanceProvider.swift
//  Portal
//
//  Created by Farid on 19.05.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation
import BitcoinCore

final class BalanceProvider: IBalanceProvider {
    let coin: Coin
    let coinKit: AbstractKit?
    
    private let tempTotalValue = "$\(Double.random(in: 255..<5955).rounded(toPlaces: 1))"
    private let tempPrice = "$\(Double.random(in: 200..<5000).rounded(toPlaces: 1))"
    
    init(coin: Coin, kit: AbstractKit? = nil) {
        self.coin = coin
        self.coinKit = kit
    }
    
    var balanceString: String {
        "\(coinKit?.balance.spendable ?? 0)"
    }
    
    var totalValueString: String {
        tempTotalValue
    }
    
    var price: String {
        tempPrice
    }
    
    func balance(currency: Currency) -> Decimal {
        Decimal(string: balanceString) ?? 0
    }
    
    static func mocked() -> IBalanceProvider {
        BalanceProvider(coin: Coin.bitcoin())
    }
}
