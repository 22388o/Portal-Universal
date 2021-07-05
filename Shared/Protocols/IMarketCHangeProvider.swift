//
//  IMarketCHangeProvider.swift
//  Portal
//
//  Created by Farid on 19.05.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation
import Coinpaprika

protocol IMarketDataProvider {
    var ticker: Ticker? { get }
    var marketData: CoinMarketData? { get }
}

protocol IMarketChangeProvider {
    var changeString: String { get }
}
