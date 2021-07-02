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
    let onUpdateHistoricalPricePublisher = PassthroughSubject<(MarketDataRange, HistoricalTickerPrice), Never>()
    let onUpdateHistoricalDataPublisher = PassthroughSubject<(MarketDataRange, HistoricalDataResponse), Never>()
    let onTickersUpdatePublisher = PassthroughSubject<([Ticker]), Never>()
    
    private(set) var tickers: [Ticker]?

    init() {
        fetchTickers()
    }
        
    private func fetchTickers() {
        Coinpaprika.API.tickers(quotes: [.usd, .btc, .eth])
            .perform { [unowned self] (response) in
                switch response {
                case .success(let tickers):
                    self.tickers = tickers
                    self.onTickersUpdatePublisher.send(tickers)
                    self.tickerHistory()
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    private func tickerHistory() {
        let coins =  [Coin.bitcoin(), Coin.bitcoinCash(), Coin.ethereum()]
        let coinPaprikaCoinIds = coins.compactMap { (coin) -> String? in
            tickers?.first(where: { (ticker) -> Bool in
                coin.name.lowercased() == ticker.name.lowercased()
            })?.id
        }
        
        for (index, id) in coinPaprikaCoinIds.enumerated() {
            Coinpaprika.API.coinLatestOhlcv(id: id, quote: .usd)
                .perform { (response) in
                    switch response {
                    case .success(let response):
                        self.onUpdateHistoricalDataPublisher.send((.day, [coins[index].code : response.map{ MarketSnapshot.init($0) }]))
                    case .failure(let error):
                        print(error)
                    }
                }
            let today = Date()
            if let yesteday = Calendar.current.date(byAdding: .day, value: -1, to: today) {
                Coinpaprika.API.tickerHistory(id: id, start: yesteday, end: today, limit: 60, quote: .usd, interval: .minutes15)
                    .perform { [unowned self] (response) in
                        switch response {
                        case .success(let response):
                            self.onUpdateHistoricalPricePublisher.send((.day, [coins[index].code : response.map{ $0.price }]))
                        case .failure(let error):
                            print(error)
                        }
                    }
            }
            if let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: today) {
                Coinpaprika.API.tickerHistory(id: id, start: weekAgo, end: today, limit: 60, quote: .usd, interval: .hours2)
                    .perform { [unowned self] (response) in
                        switch response {
                        case .success(let response):
                            self.onUpdateHistoricalPricePublisher.send((.week, [coins[index].code : response.map{ $0.price }]))
                        case .failure(let error):
                            print(error)
                        }
                    }
            }
            if let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: today) {
                Coinpaprika.API.tickerHistory(id: id, start: monthAgo, end: today, limit: 60, quote: .usd, interval: .hours12)
                    .perform { [unowned self] (response) in
                        switch response {
                        case .success(let response):
                            self.onUpdateHistoricalPricePublisher.send((.month, [coins[index].code : response.map{ $0.price }]))
                        case .failure(let error):
                            print(error)
                        }
                    }
            }
            if let aYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: today) {
                Coinpaprika.API.tickerHistory(id: id, start: aYearAgo, end: today, limit: 60, quote: .usd, interval: .days7)
                    .perform { [unowned self] (response) in
                        switch response {
                        case .success(let response):
                            self.onUpdateHistoricalPricePublisher.send((.year, [coins[index].code : response.map{ $0.price }]))
                        case .failure(let error):
                            print(error)
                        }
                    }
            }
        }
    }
}
