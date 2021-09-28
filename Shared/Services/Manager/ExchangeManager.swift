//
//  ExchangeManager.swift
//  Portal
//
//  Created by Farid on 09.09.2021.
//

import Foundation
import Combine

final class ExchangeManager {
    var exchanges: [ExchangeModel] = []
    var traidingPairs: [TradingPairModel] = []
    private var subscriptions = Set<AnyCancellable>()
    private let exchangeDataUpdater: ExchangeDataUpdater
    
    init(exchangeDataUpdater: ExchangeDataUpdater) {
        self.exchangeDataUpdater = exchangeDataUpdater
        self.setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        exchangeDataUpdater.onExchangesUpdatePublisher
            .sink(receiveValue: { [weak self] models in
                self?.exchanges = models
            })
            .store(in: &subscriptions)
        
        exchangeDataUpdater.onTraidingPairsUpdatePublisher
            .sink(receiveValue: { [weak self] models in
                self?.traidingPairs = models
            })
            .store(in: &subscriptions)
    }
}
