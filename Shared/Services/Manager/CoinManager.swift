//
//  CoinManager.swift
//  Portal
//
//  Created by Farid on 19.07.2021.
//

import Foundation
import SwiftUI
import Combine

class CoinManager: ICoinManager {
    var onCoinsUpdatePublisher = PassthroughSubject<[Coin], Never>()
    
    private var storage: ICoinStorage
    private var subscriptions = Set<AnyCancellable>()
    var coins: [Coin] = []
    
    init(storage: ICoinStorage) {
        self.storage = storage
        
        storage.onCoinsUpdatePublisher
            .sink { [weak self] coins in
                guard let self = self else { return }
                self.coins = [Coin.bitcoin(), Coin.ethereum()] + coins
                self.onCoinsUpdatePublisher.send(self.coins)
            }
            .store(in: &subscriptions)
    }
}
