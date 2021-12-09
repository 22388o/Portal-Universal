//
//  MarketDataProvider.swift
//  Portal
//
//  Created by Farid on 15.05.2021.
//

import Foundation
import Coinpaprika
import Combine

final class MarketDataProvider {
    var onMarketDataUpdatePublisher = PassthroughSubject<Void, Never>()

    private let repository: IMarketDataProvider
    private var subscriptions = Set<AnyCancellable>()
    
    init(repository: IMarketDataProvider) {
        self.repository = repository
        subscribe()
    }
    
    private func subscribe() {
        repository.onMarketDataUpdatePublisher.sink { [weak self] _ in
            self?.onMarketDataUpdatePublisher.send()
        }
        .store(in: &subscriptions)
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


