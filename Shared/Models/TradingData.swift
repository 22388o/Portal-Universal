//
//  TradingData.swift
//  Portal
//
//  Created by Farid on 16.09.2021.
//

import Foundation

struct TradingData {
    let exchangeSelectorState: ExchangeSelectorState
    let exchanges: [ExchangeModel]
    let supportedByExchanges: [ExchangeVolumeDataModel]
    let pairs: [TradingPairModel]
    
    var pairIndex: Int {
        pairs.firstIndex(of: currentPair) ?? 0
    }
    
    var currentPair: TradingPairModel
    
    var exchange: ExchangeModel? {
        switch exchangeSelectorState {
        case .merged:
            return currentPair.exchange.exchangeWithHighterQuoteBalance(activeExchanges: exchanges, quote: currentPair.quote)
        case .selected(let exchange):
            return exchange
        }
    }
    
    var exchangesMerged: Bool {
        switch exchangeSelectorState {
        case .merged:
            return true
        case .selected(_):
            return false
        }
    }
}

