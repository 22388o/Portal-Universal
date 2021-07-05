//
//  MarketDataProvider.swift
//  Portal
//
//  Created by Farid on 15.05.2021.
//

import Foundation
import Coinpaprika

final class MarketDataProvider: IMarketDataProvider {
    private let repo: MarketDataRepository
    private let coin: Coin
    
    var ticker: Ticker? {
        repo.ticker(coin: coin)
    }
    var marketData: CoinMarketData? {
        repo.data(coin: coin)
    }
    
    init(coin: Coin, repo: MarketDataRepository = MarketDataRepository.service) {
        self.coin = coin
        self.repo = repo
    }
}


