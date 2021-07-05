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
    static let service = MarketDataRepository()
    typealias CoinCode = String
    typealias CurrencyCode = String
    typealias Rate = Double
    
    private let supportedFiatCurrenciesSymbols = "JPY USD KRW EUR INR CAD RUB GBP CNY NZD SGD"

    
    private var marketDataUpdater = MarketDataUpdater()
    private var currenciesUpdater = FiatCurrenciesUpdater(interval: 3600)
//    private var priceUpdater = PricesDataUpdater(interval: 60)
    
    private var cancellables: Set<AnyCancellable> = []
//    private var currencyRates = Synchronized([CurrencyCode : Rate]())
    private var marketData = Synchronized([CoinCode : CoinMarketData]())
    
    @Published private(set) var tickers: [Ticker]?
    @Published private(set) var fiatCurrencies: [FiatCurrency] = []
        
    private init() {
//        bindServices()
    }
    
    func start() {
        bindServices()
    }
    
    private func bindServices() {
        marketDataUpdater.onUpdateHistoricalPricePublisher
            .sink(receiveValue: { [weak self] (range, data) in
                guard let self = self else { return }
                self.update(range, data)
            })
            .store(in: &cancellables)
        
        marketDataUpdater.onUpdateHistoricalDataPublisher
            .sink(receiveValue: { [weak self] (range, data) in
                guard let self = self else { return }
                self.update(range, data)
            })
            .store(in: &cancellables)
        
        marketDataUpdater.onTickersUpdatePublisher
            .sink(receiveValue: { [weak self] tickers in
                guard let self = self else { return }
                self.tickers = tickers
            })
            .store(in: &cancellables)
        
        currenciesUpdater.onUpdatePublisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] currencies in
                guard let self = self else { return }
                self.fiatCurrencies = currencies.filter{ self.supportedFiatCurrenciesSymbols.contains($0.code)}.sorted(by: {$0.code < $1.code} )
            })
            .store(in: &cancellables)

//        priceUpdater.onUpdatePublisher
//            .sink(receiveValue: { [weak self] prices in
//                guard let self = self else { return }
//                self.update(prices)
//            })
//            .store(in: &cancellables)
    }
    
    func ticker(coin: Coin) -> Ticker? {
        tickers?.first(where: { $0.symbol == coin.code })
    }
    
    func data(coin: Coin) -> CoinMarketData {
        marketData.value[coin.code] ?? CoinMarketData()
    }

    func rate(for currency: FiatCurrency) -> Double {
        1.0
    }
    
    func rates() -> [String: Rate] {
        return [:]
    }
    
//    func pause() {
//        ratesUpdater.pause()
//        priceUpdater.pause()
//    }
//    
//    func resume() {
//        ratesUpdater.resume()
//        priceUpdater.resume()
//    }
}

extension MarketDataRepository {
    private func update(_ range: MarketDataRange, _ data: HistoricalTickerPrice) {
        for points in data {
            if self.marketData.value[points.key] == nil {
                self.marketData.writer({ (data) in
                    data[points.key] = CoinMarketData()
                })
            }
            self.marketData.writer({ (data) in
                switch range {
                case .day:
                    data[points.key]?.dayPoints = points.value
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
            if self.marketData.value[snap.key] == nil {
                self.marketData.writer({ (data) in
                    data[snap.key] = CoinMarketData()
                })
            }
            self.marketData.writer({ (data) in
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
    
    private func update(_ rates: Rates) {
//        currencyRates.writer({ (data) in
//            data = rates.filter{$0.key != "BTC"}
//        })
    }
    
    private func update(_ prices: PriceResponse) {
        for price in prices {
            if marketData.value[price.key] == nil {
                marketData.writer({ (data) in
                    data[price.key] = CoinMarketData()
                })
            }
            for currency in price.value {
                marketData.writer({ (data) in
                    data[price.key]?.priceData = currency.value
                })
            }
        }
    }
}

