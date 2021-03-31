//
//  IMarketData.swift
//  Portal
//
//  Created by Farid on 14.04.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation

fileprivate let sharedMarketDataRepository = MarketDataRepository()

protocol IMarketData {
    func marketData(for coin: String) -> CoinMarketData
    func marketRate(for currency: FiatCurrency) -> Double
}

extension IMarketData {
    var assetSymbols: [String] {
        ["BTC", "BCH", "ETH"]
    }
    func marketData(for coin: String) -> CoinMarketData {
        sharedMarketDataRepository.data(for: coin)
    }
    func marketRate(for currency: FiatCurrency) -> Double {
        sharedMarketDataRepository.rate(for: currency)
    }
    func stopUpdatingMarketData() {
        sharedMarketDataRepository.pause()
    }
    func resumeUpdatingMarketData() {
        sharedMarketDataRepository.resume()
    }
}
