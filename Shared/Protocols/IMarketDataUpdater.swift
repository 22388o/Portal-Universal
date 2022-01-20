//
//  IMarketDataUpdater.swift
//  Portal
//
//  Created by farid on 1/20/22.
//

import Foundation
import Coinpaprika
import Combine

protocol IMarketDataUpdater {
    var onUpdateHistoricalPrice: PassthroughSubject<(MarketDataRange, HistoricalTickerPrice), Never> { get }
    var onUpdateHistoricalData: PassthroughSubject<(MarketDataRange, HistoricalDataResponse), Never> { get }
    var onTickersUpdate: PassthroughSubject<([Ticker]), Never> { get }
    func requestHistoricalMarketData(coin: Coin, timeframe: Timeframe)
}
