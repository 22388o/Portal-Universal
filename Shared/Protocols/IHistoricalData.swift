//
//  IHistoricalData.swift
//  Portal
//
//  Created by Farid on 16.04.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation
import Combine

typealias HistoricalDataResponse = Dictionary<String, [MarketSnapshot]>

typealias HistoricalTickerPrice = Dictionary<String, [Decimal]>

protocol IHistoricalData {
    var onUpdatePublisher: PassthroughSubject<(MarketDataRange, HistoricalDataResponse), Never> { get }
    func fetchHistoricalData(assets: String)
}
