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
    let onUpdateHistoricalPrice = PassthroughSubject<(MarketDataRange, HistoricalTickerPrice), Never>()
    let onUpdateHistoricalData = PassthroughSubject<(MarketDataRange, HistoricalDataResponse), Never>()
    let onTickersUpdate = PassthroughSubject<([Ticker]), Never>()
    
    private(set) var tickers: [Ticker]
    private var reachability: ReachabilityService

    init(cachedTickers: [Ticker], reachability: ReachabilityService) {
        self.tickers = cachedTickers
        self.reachability = reachability
        
        updateTickers()
        updateTickerHistory()
    }
        
    private func updateTickers() {
        guard reachability.isReachable else { return }
        
        Coinpaprika.API.tickers(quotes: [.usd, .btc, .eth])
            .perform { [unowned self] (response) in
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
        guard reachability.isReachable else { return }

        let coins =  [Coin.bitcoin(), Coin.ethereum()]
        let coinPaprikaCoinIds = coins.compactMap { (coin) -> String? in
            tickers.first(where: { (ticker) -> Bool in
                coin.name.lowercased() == ticker.name.lowercased()
            })?.id
        }

        for (index, id) in coinPaprikaCoinIds.enumerated() {
            print("Fetching ticker history \(id)")
            Coinpaprika.API.coinLatestOhlcv(id: id, quote: .usd)
                .perform { [unowned self] response in
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
    
    func requestHistoricalMarketData(coin: Coin, timeframe: Timeframe) {
        guard reachability.isReachable else { return }

        guard let coinPaprikaId = tickers.first(where: { (ticker) -> Bool in
            coin.code.lowercased() == ticker.symbol.lowercased()
        })?.id else { return }
                
        let today = Date()
                
        switch timeframe {
        case .day:
            if let yesteday = Calendar.current.date(byAdding: .day, value: -1, to: today) {
                Coinpaprika.API.tickerHistory(id: coinPaprikaId, start: yesteday, end: today, limit: 60, quote: .usd, interval: .minutes15)
                    .perform { [unowned self] (response) in
                        switch response {
                        case .success(let response):
                            self.onUpdateHistoricalPrice.send((.day, [coin.code : response.map{ $0.price }]))
                        case .failure(let error):
                            print(error)
                        }
                    }
            }
        case .week:
            if let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: today) {
                Coinpaprika.API.tickerHistory(id: coinPaprikaId, start: weekAgo, end: today, limit: 60, quote: .usd, interval: .hours3)
                    .perform { [unowned self] (response) in
                        switch response {
                        case .success(let response):
                            self.onUpdateHistoricalPrice.send((.week, [coin.code : response.map{ $0.price }]))
                        case .failure(let error):
                            print(error)
                        }
                    }
            }
        case .month:
            if let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: today) {
                Coinpaprika.API.tickerHistory(id: coinPaprikaId, start: monthAgo, end: today, limit: 60, quote: .usd, interval: .hours12)
                    .perform { [unowned self] (response) in
                        switch response {
                        case .success(let response):
                            self.onUpdateHistoricalPrice.send((.month, [coin.code : response.map{ $0.price }]))
                        case .failure(let error):
                            print(error)
                        }
                    }
            }
        case .year:
            if let aYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: today) {
                Coinpaprika.API.tickerHistory(id: coinPaprikaId, start: aYearAgo, end: today, limit: 60, quote: .usd, interval: .days7)
                    .perform { [unowned self] (response) in
                        switch response {
                        case .success(let response):
                            self.onUpdateHistoricalPrice.send((.year, [coin.code : response.map{ $0.price }]))
                        case .failure(let error):
                            print(error)
                        }
                    }
            }

        }
    }
}
