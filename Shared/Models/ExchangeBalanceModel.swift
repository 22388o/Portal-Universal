//
//  ExchangeBalanceModel.swift
//  Portal
//
//  Created by Farid on 09.09.2021.
//

import Foundation

struct ExchangeBalanceModel: Identifiable, Codable {
    let id: UUID
    let asset: String
    let free: String
    let locked: String
    
    enum Keys: String, CodingKey {
        case asset
        case free
        case locked
    }
    
    init(asset: String, free: String, locked: String) {
        self.id = UUID()
        self.asset = asset
        self.free = free
        self.locked = locked
    }
    
    init(_ balance: BinanceBalance) {
        self.id = UUID()
        self.asset = balance.asset
        
        if let doubleBalance = Double(balance.free) {
            self.free = doubleBalance.precisionString()
        } else {
            self.free = balance.free
        }
        
        self.locked = balance.locked
    }
    
    init(_ balance: KrakenBalance) {
        self.id = UUID()
        self.asset = balance.asset
        self.free = String(balance.free)
        self.locked = String(balance.locked)
    }
    
    init(_ balance: CoinbaseBalancesResponse) {
        self.id = UUID()
        self.asset = balance.currency
        self.free = balance.available
        self.locked = balance.hold
    }
}

extension ExchangeBalanceModel {
    static func BTC() -> ExchangeBalanceModel {
        ExchangeBalanceModel(asset: "BTC", free: "0.001876", locked: "0"/*, icon: "https://icons.iconarchive.com/icons/cjdowner/cryptocurrency-flat/96/Bitcoin-BTC-icon.png"*/)
    }
    static func ETH() -> ExchangeBalanceModel {
        ExchangeBalanceModel(asset: "ETH", free: "0.0216", locked: "0"/*, icon: "https://icons.iconarchive.com/icons/cjdowner/cryptocurrency-flat/96/Ethereum-ETH-icon.png"*/)
    }
}
