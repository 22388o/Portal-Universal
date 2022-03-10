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
    var coins = CurrentValueSubject<[Coin], Never>([])
        
    private var subscriptions = Set<AnyCancellable>()
    private var updater: IERC20Updater
    private var marketData: IMarketDataProvider
    
    init(updater: IERC20Updater, marketDataProvider: IMarketDataProvider) {
        self.updater = updater
        self.marketData = marketDataProvider
        
        self.syncCoins(tokens: updater.tokens)
        
        subscribe()
    }
    
    private func subscribe() {
        updater.onTokensUpdate
            .sink { [weak self] tokens in
                self?.syncCoins(tokens: tokens)
            }
            .store(in: &subscriptions)
    }
    
    private func syncCoins(tokens: [Erc20TokenCodable]) {
        if !tokens.isEmpty {
            let coins = tokens.compactMap {
                Coin(
                    type: .erc20(address: $0.contractAddress),
                    code: $0.symbol,
                    name: $0.name,
                    decimal: $0.decimal,
                    iconUrl: $0.iconURL
                )
            }
                .filter { marketData.ticker(coin: $0) != nil }
                .sorted(by: { $0.code < $1.code })
            
            self.coins.send(coins)
        }
    }
}
 


