//
//  MarketDataProvider.swift
//  Portal
//
//  Created by Farid on 15.05.2021.
//

import Foundation
import Coinpaprika

final class MarketDataProvider: ObservableObject {
    private let repository: IMarketDataProvider
    
    init(repository: IMarketDataProvider) {
        self.repository = repository
    }
}

extension MarketDataProvider: IMarketDataProvider {
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


