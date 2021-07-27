//
//  MarketDataRepository.swift
//  Portal
//
//  Created by Farid on 14.04.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import Coinpaprika

final class MarketDataRepository: ObservableObject {
    typealias CoinCode = String
    typealias CurrencyCode = String
    typealias Rate = Double
    
    private let supportedFiatCurrenciesSymbols = "JPY USD KRW EUR INR CAD RUB GBP CNY NZD SGD"
    
    private var mdUpdater: MarketDataUpdater
    private var fcUpdater: FiatCurrenciesUpdater
    private var pdUpdater: PricesDataUpdater
    
    private var cancellables: Set<AnyCancellable> = []
    private var repository = Synchronized([CoinCode : CoinMarketData]())
    
    var tickers: [Ticker]?
    var fiatCurrencies: [FiatCurrency] = []
    
    @Published var marketDataReady: Bool = false
    @Published var tickersReady: Bool = false
    @Published var historicalDataReady: Bool = false
    @Published var dataReady: Bool = false
    
        
    init(mdUpdater: MarketDataUpdater, fcUpdater: FiatCurrenciesUpdater, pdUpdater: PricesDataUpdater) {
        self.mdUpdater = mdUpdater
        self.fcUpdater = fcUpdater
        self.pdUpdater = pdUpdater
        
        bindServices()
    }
    
    private func bindServices() {
        mdUpdater.onUpdateHistoricalPricePublisher
            .sink(receiveValue: { [weak self] (range, data) in
                guard let self = self else { return }
                self.update(range, data)
            })
            .store(in: &cancellables)
        
        mdUpdater.onUpdateHistoricalDataPublisher
            .sink(receiveValue: { [weak self] (range, data) in
                guard let self = self else { return }
                if !self.historicalDataReady {
                    self.historicalDataReady = true
                }
                self.update(range, data)
            })
            .store(in: &cancellables)
        
        mdUpdater.onTickersUpdatePublisher
            .sink(receiveValue: { [weak self] tickers in
                guard let self = self else { return }
                if !self.tickersReady {
                    self.tickersReady = true
                }
                self.tickers = tickers
            })
            .store(in: &cancellables)
        
        fcUpdater.onUpdatePublisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] currencies in
                guard let self = self else { return }
                self.fiatCurrencies = currencies.filter {
                    self.supportedFiatCurrenciesSymbols.contains($0.code)}.sorted(by: {$0.code < $1.code})
            })
            .store(in: &cancellables)
        
        Publishers.MergeMany($historicalDataReady, $tickersReady, $marketDataReady)
            .sink { [weak self] ready in
                self?.dataReady = ready
            }
            .store(in: &cancellables)
    }
    
    private func update(_ range: MarketDataRange, _ data: HistoricalTickerPrice) {
        for points in data {
            if repository.value[points.key] == nil {
                repository.writer({ (data) in
                    data[points.key] = CoinMarketData()
                })
            }
            repository.writer({ (data) in
                switch range {
                case .day:
                    data[points.key]?.dayPoints = points.value
                    if !self.marketDataReady {
                        self.marketDataReady = true
                    }
                case .week:
                    data[points.key]?.weekPoints = points.value
                case .month:
                    data[points.key]?.monthPoints = points.value
                case .year:
                    data[points.key]?.yearPoints = points.value
                }
            })
        }
    }
    
    private func update(_ range: MarketDataRange, _ data: HistoricalDataResponse) {
        for snap in data {
            if repository.value[snap.key] == nil {
                repository.writer({ (data) in
                    data[snap.key] = CoinMarketData()
                })
            }
            self.repository.writer({ (data) in
                switch range {
                case .day:
                    data[snap.key]?.dayOhlc = snap.value
                case .week:
                    break
//                    data[snap.key]?.weekPoints = points.value
                case .month:
                    break
//                    data[snap.key]?.monthPoints = points.value
                case .year:
                    break
                }
            })
        }
    }
        
    private func update(_ prices: PriceResponse) {
        for price in prices {
            if repository.value[price.key] == nil {
                repository.writer({ (data) in
                    data[price.key] = CoinMarketData()
                })
            }
            for currency in price.value {
                repository.writer({ (data) in
                    data[price.key]?.priceData = currency.value
                })
            }
        }
    }
}

extension MarketDataRepository: IMarketDataProvider {
    func ticker(coin: Coin) -> Ticker? {
        tickers?.first(where: { $0.symbol == coin.code })
    }
    
    func marketData(coin: Coin) -> CoinMarketData {
        repository.value[coin.code] ?? CoinMarketData()
    }
    
}
