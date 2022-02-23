//
//  Erc20Updater.swift
//  Portal
//
//  Created by Farid on 28.07.2021.
//

import Foundation
import Combine
import Coinpaprika

final class CoinStorage: ICoinStorage {
    var onCoinsUpdate = PassthroughSubject<[Coin], Never>()
    
    var coins: [Coin] = []
    
    private var subscriptions = Set<AnyCancellable>()
    private var updater: IERC20Updater
    private var marketData: IMarketDataProvider
    
    init(updater: IERC20Updater, marketDataProvider: IMarketDataProvider) {
        self.updater = updater
        self.marketData = marketDataProvider
        
        subscribe()
    }
    
    private func subscribe() {
        updater.onTokensUpdate
            .sink { [weak self] tokens in
                guard let self = self else { return }
                if !tokens.isEmpty {
                    let coins = tokens.compactMap {
                        Coin(
                            type: .erc20(address: $0.contractAddress),
                            code: $0.symbol,
                            name: $0.name,
                            decimal: $0.decimal,
                            iconUrl: $0.iconURL
                        )
                    }.filter { self.marketData.ticker(coin: $0) != nil }
                    .sorted(by: { $0.code < $1.code })
                    
                    self.coins = coins
                    self.onCoinsUpdate.send(coins)
                }
            }
            .store(in: &subscriptions)
    }
}
 


