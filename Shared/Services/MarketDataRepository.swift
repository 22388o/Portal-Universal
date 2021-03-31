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

final class MarketDataRepository  {    
    typealias CoinCode = String
    typealias CurrencyCode = String
    typealias Rate = Double
    
    private var marketDataUpdater = MarketDataUpdater()
    private var ratesUpdater = RatesDataUpdater(interval: 60)
    private var priceUpdater = PricesDataUpdater(interval: 60)
    
    private var cancellables: Set<AnyCancellable> = []
    
    private var currencyRates = Synchronized([CurrencyCode : Rate]())
    private var marketData = Synchronized([CoinCode : CoinMarketData]())
        
    init() {
        bindServices()
    }
    
    private func bindServices() {
        marketDataUpdater.onUpdatePublisher
            .sink(receiveValue: { [weak self] (range, data) in
                guard let self = self else { return }
                self.update(range, data)
            })
            .store(in: &cancellables)
        
        ratesUpdater.onUpdatePublisher
            .sink(receiveValue: { [weak self] rates in
                guard let self = self else { return }
                self.update(rates)
            })
            .store(in: &cancellables)
        
        priceUpdater.onUpdatePublisher
            .sink(receiveValue: { [weak self] prices in
                guard let self = self else { return }
                self.update(prices)
            })
            .store(in: &cancellables)
    }
    
    func data(for coin: String) -> CoinMarketData {
        marketData.value[coin] ?? CoinMarketData()
    }

    func rate(for currency: FiatCurrency) -> Double {
        let code = currency.code
        return currencyRates.value[code] ?? 1.0
    }
    
    func pause() {
        ratesUpdater.pause()
        priceUpdater.pause()
    }
    
    func resume() {
        ratesUpdater.resume()
        priceUpdater.resume()
    }
}

extension MarketDataRepository {
    private func update(_ range: MarketDataRange, _ data: HistoricalDataResponse) {
        for points in data {
            if self.marketData.value[points.key] == nil {
                self.marketData.writer({ (data) in
                    data[points.key] = CoinMarketData()
                })
            }
            self.marketData.writer({ (data) in
                switch range {
                case .hour:
                    data[points.key]?.hourPoints = points.value
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
    
    private func update(_ rates: Rates) {
        currencyRates.writer({ (data) in
            data = rates.filter{$0.key != "BTC"}
        })
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

