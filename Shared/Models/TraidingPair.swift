//
//  TraidingPair.swift
//  Portal
//
//  Created by Farid on 09.09.2021.
//

import Foundation

struct TradingPair: Identifiable {
    let id: UUID
    let base: String
    let baseCoinUrl: String
    let change: Float
    let last: Float
    let name: String
    let quote: String
    let quoteIcionUrl: String
    let symbol: String
    let tradingId: String
}

extension TradingPair {
    static func ethUsdt() -> TradingPair {
        TradingPair(
            id: UUID(),
            base: "ETH",
            baseCoinUrl: String(),
            change: 0.26,
            last: 3400,
            name: "ETH/USDT",
            quote: "USDT",
            quoteIcionUrl: String(),
            symbol: "ETH-USDT",
            tradingId: "tradingID"
        )
    }
    
    static func btcUsdt() -> TradingPair {
        TradingPair(
            id: UUID(),
            base: "BTC",
            baseCoinUrl: String(),
            change: 0.51,
            last: 47300,
            name: "BTC/USDT",
            quote: "USDT",
            quoteIcionUrl: String(),
            symbol: "BTC-USDT",
            tradingId: "tradingID"
        )
    }
}
