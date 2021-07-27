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
    var fiatCurrencies: [FiatCurrency] { get }
    var tickers: [Ticker]? { get }
    func ticker(coin: Coin) -> Ticker?
    func marketData(coin: Coin) -> CoinMarketData
}

protocol IMarketChangeProvider {
    var changeString: String { get }
}
