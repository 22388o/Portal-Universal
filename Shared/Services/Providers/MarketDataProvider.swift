//
//  MarketDataProvider.swift
//  Portal
//
//  Created by Farid on 15.05.2021.
//

import Foundation
import Coinpaprika

final class MarketDataProvider {
    private let repository: IMarketDataProvider
    
    init(repository: IMarketDataProvider) {
        self.repository = repository
    }
}

extension MarketDataProvider: IMarketDataProvider {
    func requestHistoricalData(coin: Coin, timeframe: Timeframe) {
        repository.requestHistoricalData(coin: coin, timeframe: timeframe)
    }
    
    var fiatCurrencies: [FiatCurrency] {
        repository.fiatCurrencies
    }
    
    var tickers: [Ticker]? {
        repository.tickers
    }
    
    func ticker(coin: Coin) -> Ticker? {
        repository.ticker(coin: coin)
    }
    
    func marketData(coin: Coin) -> CoinMarketData {
        repository.marketData(coin: coin)
    }
}


