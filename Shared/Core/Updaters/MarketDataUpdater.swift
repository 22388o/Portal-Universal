//
//  MarketDataUpdater.swift
//  Portal
//
//  Created by Farid on 16.04.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation
import Combine
import Coinpaprika

final class MarketDataUpdater {
    private(set) var onUpdateHistoricalPrice = PassthroughSubject<(MarketDataRange, HistoricalTickerPrice), Never>()
    private(set) var onUpdateHistoricalData = PassthroughSubject<(MarketDataRange, HistoricalDataResponse), Never>()
    private(set) var onTickersUpdate = PassthroughSubject<([Ticker]), Never>()
    
    private(set) var tickers: [Ticker]
    private var reachability: IReachabilityService

    init(cachedTickers: [Ticker], reachability: IReachabilityService) {
        self.tickers = cachedTickers
        self.reachability = reachability
        
        updateTickers()
        updateTickerHistory()
    }
        
    private func updateTickers() {
        guard reachability.isReachable.value else { return }
        
        Coinpaprika.API.tickers(quotes: [.usd, .btc, .eth])
            .perform { [weak self] (response) in
                guard let self = self else { return }
                switch response {
                case .success(let tickers):
                    self.tickers = tickers
                    self.onTickersUpdate.send(tickers)
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    private func updateTickerHistory() {
        guard reachability.isReachable.value else { return }

        let coins =  [Coin.bitcoin(), Coin.ethereum()]
        let coinPaprikaCoinIds = coins.compactMap { (coin) -> String? in
            tickers.first(where: { (ticker) -> Bool in
                coin.name.lowercased() == ticker.name.lowercased()
            })?.id
        }

        for (index, id) in coinPaprikaCoinIds.enumerated() {
            print("Fetching ticker history \(id)")
            Coinpaprika.API.coinLatestOhlcv(id: id, quote: .usd)
                .perform { [weak self] response in
                    guard let self = self else { return }
                    switch response {
                    case .success(let response):
                        self.onUpdateHistoricalData.send((.day, [coins[index].code : response.map{ MarketSnapshot.init($0) }]))
                    case .failure(let error):
                        print(error)
                    }
                }
            
            requestHistoricalMarketData(coin: coins[index], timeframe: .day)
            requestHistoricalMarketData(coin: coins[index], timeframe: .week)
            requestHistoricalMarketData(coin: coins[index], timeframe: .month)
            requestHistoricalMarketData(coin: coins[index], timeframe: .year)
        }
    }
}

extension MarketDataUpdater: IMarketDataUpdater {
    func requestHistoricalMarketData(coin: Coin, timeframe: Timeframe) {
        guard reachability.isReachable.value else { return }

        guard let coinPaprikaId = tickers.first(where: { (ticker) -> Bool in
            coin.code.lowercased() == ticker.symbol.lowercased()
        })?.id else { return }
                
        let today = Date()
                
        switch timeframe {
        case .day:
            if let yesteday = Calendar.current.date(byAdding: .day, value: -1, to: today) {
                Coinpaprika.API.tickerHistory(id: coinPaprikaId, start: yesteday, end: today, limit: 95, quote: .usd, interval: .minutes15)
                    .perform { [weak self] (response) in
                        guard let self = self else { return }

                        switch response {
                        case .success(let response):
                            self.onUpdateHistoricalPrice.send((.day, [coin.code : response.map{ PricePoint(timestamp: $0.timestamp, price: $0.price) }]))
                        case .failure(let error):
                            print(error)
                        }
                    }
            }
        case .week:
            if let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: today) {
                Coinpaprika.API.tickerHistory(id: coinPaprikaId, start: weekAgo, end: today, limit: 56, quote: .usd, interval: .hours3)
                    .perform { [weak self] (response) in
                        guard let self = self else { return }

                        switch response {
                        case .success(let response):
                            self.onUpdateHistoricalPrice.send((.week, [coin.code : response.map{ PricePoint(timestamp: $0.timestamp, price: $0.price) }]))
                        case .failure(let error):
                            print(error)
                        }
                    }
            }
        case .month:
            if let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: today) {
                Coinpaprika.API.tickerHistory(id: coinPaprikaId, start: monthAgo, end: today, limit: 56, quote: .usd, interval: .hours12)
                    .perform { [weak self] (response) in
                        guard let self = self else { return }

                        switch response {
                        case .success(let response):
                            self.onUpdateHistoricalPrice.send((.month, [coin.code : response.map{ PricePoint(timestamp: $0.timestamp, price: $0.price) }]))
                        case .failure(let error):
                            print(error)
                        }
                    }
            }
        case .year:
            if let aYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: today) {
                Coinpaprika.API.tickerHistory(id: coinPaprikaId, start: aYearAgo, end: today, limit: 52, quote: .usd, interval: .days7)
                    .perform { [weak self] (response) in
                        guard let self = self else { return }

                        switch response {
                        case .success(let response):
                            self.onUpdateHistoricalPrice.send((.year, [coin.code : response.map{ PricePoint(timestamp: $0.timestamp, price: $0.price) }]))
                        case .failure(let error):
                            print(error)
                        }
                    }
            }

        }
    }
}
