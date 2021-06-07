//
//  IMarketData.swift
//  Portal
//
//  Created by Farid on 14.04.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation
import Coinpaprika

//fileprivate let sharedMarketDataRepository = MarketDataRepository()

protocol IMarketData {
    func ticker(coin: Coin) -> Ticker?
    func marketData(for coin: String) -> CoinMarketData
    func marketRate(for currency: FiatCurrency) -> Double
}

extension IMarketData {
    var assetSymbols: [String] {
        ["BTC", "BCH", "ETH"]
    }
    func ticker(coin: Coin) -> Ticker? {
        nil
//        sharedMarketDataRepository.ticker(coin: coin)
    }
    func marketData(for coin: String) -> CoinMarketData {
        CoinMarketData()
//        sharedMarketDataRepository.data(for: coin)
    }
    func marketRate(for currency: FiatCurrency) -> Double {
        0
//        sharedMarketDataRepository.rate(for: currency)
    }
    func stopUpdatingMarketData() {
//        sharedMarketDataRepository.pause()
    }
    func resumeUpdatingMarketData() {
//        sharedMarketDataRepository.resume()
    }
}
