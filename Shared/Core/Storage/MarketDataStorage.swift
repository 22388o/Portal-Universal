//
//  MarketDataStorage.swift
//  Portal
//
//  Created by Farid on 14.04.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import Coinpaprika

final class MarketDataStorage {
    typealias CoinCode = String
    typealias CurrencyCode = String
    typealias Rate = Double
    
    private let supportedFiatCurrenciesSymbols = "JPY USD KRW EUR INR CAD RUB GBP CNY NZD SGD"
    
    private var mdUpdater: IMarketDataUpdater
    private var fcUpdater: IFiatCurrenciesUpdater
    private var cacheStorage: IDBCacheStorage
    
    private var cancellables: Set<AnyCancellable> = []
    private var repository = Synchronized([CoinCode : CoinMarketData]())
    
    var onMarketDataUpdate = PassthroughSubject<Void, Never>()
    
    var tickers: [Ticker]? {
        cacheStorage.tickers
    }
    
    var fiatCurrencies: [FiatCurrency] {
        cacheStorage.fiatCurrencies
    }
            
    init(mdUpdater: IMarketDataUpdater, fcUpdater: IFiatCurrenciesUpdater, cacheStorage: IDBCacheStorage) {
        self.mdUpdater = mdUpdater
        self.fcUpdater = fcUpdater
        self.cacheStorage = cacheStorage
        
        bindServices()
    }
    
    private func bindServices() {
        mdUpdater.onUpdateHistoricalPrice
            .sink(receiveValue: { [weak self] (range, data) in
                guard let self = self else { return }
                self.update(range, data)
                self.onMarketDataUpdate.send()
            })
            .store(in: &cancellables)
        
        mdUpdater.onUpdateHistoricalData
            .sink(receiveValue: { [weak self] (range, data) in
                guard let self = self else { return }
                self.update(range, data)
            })
            .store(in: &cancellables)
        
        mdUpdater.onTickersUpdate
            .receive(on: DispatchQueue.global(qos: .userInteractive))
            .sink(receiveValue: { [weak self] tickers in
                guard let self = self else { return }
                self.cacheStorage.store(tickers: tickers)
            })
            .store(in: &cancellables)
        
        fcUpdater.onFiatCurrenciesUpdate
            .sink(receiveValue: { [weak self] currencies in
                guard let self = self else { return }
                
                let fiatCurrencies = currencies.filter {
                    self.supportedFiatCurrenciesSymbols.contains($0.code)
                }
                .sorted(by: {$0.code < $1.code})
                
                self.cacheStorage.store(fiatCurrencies: fiatCurrencies)
            })
            .store(in: &cancellables)
    }
    
    private func update(_ range: MarketDataRange, _ data: HistoricalTickerPrice) {
        for points in data {
            repository.writer({ (data) in
                switch range {
                case .day:
                    data[points.key, default: CoinMarketData()].dayPoints = points.value
                case .week:
                    data[points.key, default: CoinMarketData()].weekPoints = points.value
                case .month:
                    data[points.key, default: CoinMarketData()].monthPoints = points.value
                case .year:
                    data[points.key, default: CoinMarketData()].yearPoints = points.value
                }
            })
        }
    }
    
    private func update(_ range: MarketDataRange, _ data: HistoricalDataResponse) {
        for snap in data {
            repository.writer({ (data) in
                switch range {
                case .day:
                    data[snap.key, default: CoinMarketData()].dayOhlc = snap.value
                default:
                    break
                }
            })
        }
    }
        
    private func update(_ prices: PriceResponse) {
        for price in prices {
            for currency in price.value {
                repository.writer({ (data) in
                    data[price.key, default: CoinMarketData()].priceData = currency.value
                })
            }
        }
    }
}

extension MarketDataStorage: IMarketDataProvider {
    func requestHistoricalData(coin: Coin, timeframe: Timeframe) {
        mdUpdater.requestHistoricalMarketData(coin: coin, timeframe: timeframe)
    }
    
    func ticker(coin: Coin) -> Ticker? {
        tickers?.first(where: { $0.symbol == coin.code })
    }
    
    func marketData(coin: Coin) -> CoinMarketData {
        repository.value[coin.code] ?? CoinMarketData()
    }
}
