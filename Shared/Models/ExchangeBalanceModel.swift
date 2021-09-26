//
//  ExchangeBalanceModel.swift
//  Portal
//
//  Created by Farid on 09.09.2021.
//

import Foundation

struct ExchangeBalanceModel: Identifiable {
    let id: UUID
    let asset: String
    let free: Float
    let locked: Float
    let icon: String
}

extension ExchangeBalanceModel {
    static func BTC() -> ExchangeBalanceModel {
        ExchangeBalanceModel(id: UUID(), asset: "BTC", free: 0.001876, locked: 0, icon: "https://icons.iconarchive.com/icons/cjdowner/cryptocurrency-flat/96/Bitcoin-BTC-icon.png")
    }
    static func ETH() -> ExchangeBalanceModel {
        ExchangeBalanceModel(id: UUID(), asset: "ETH", free: 0.0216, locked: 0, icon: "https://icons.iconarchive.com/icons/cjdowner/cryptocurrency-flat/96/Ethereum-ETH-icon.png")
    }
}

