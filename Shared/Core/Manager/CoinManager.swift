//
//  CoinManager.swift
//  Portal
//
//  Created by Farid on 19.07.2021.
//

import Foundation
import SwiftUI
import Combine

final class CoinManager: ICoinManager {
    var onCoinsUpdate = PassthroughSubject<[Coin], Never>()
    
    private var storage: ICoinStorage
    private var subscriptions = Set<AnyCancellable>()
    var coins: [Coin] = []
    
    init(storage: ICoinStorage) {
        self.storage = storage
        
        self.coins = [Coin.bitcoin(), Coin.ethereum()/*, Coin.portal()*/]
        self.onCoinsUpdate.send(self.coins)
            
//        subscribe()
    }
    
    private func subscribe() {
        storage.onCoinsUpdate
            .sink { [weak self] coins in
                guard let self = self else { return }
                self.coins = [Coin.bitcoin(), Coin.ethereum(), Coin.portal()]// + coins
                self.onCoinsUpdate.send(self.coins)
            }
            .store(in: &subscriptions)
    }
}
