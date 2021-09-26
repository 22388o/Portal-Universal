//
//  TradingPairModel.swift
//  Portal
//
//  Created by Farid on 16.09.2021.
//

import Foundation

struct TradingPairModel: Decodable, Equatable {
    let name: String
    let quote_icon: String
    let id: String
    let symbol: String
    let icon: String
    let base: String
    let quote: String
    let change: Float
    let last: Float?
    let exchange: [ExchangeVolumeDataModel]
    
    static func == (lhs: TradingPairModel, rhs: TradingPairModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func supported(by activeExchanges: [ExchangeModel]) -> TradingPairModel? {
        for ex in exchange {
            for activeExchange in activeExchanges {
                if ex.id == activeExchange.id {
                    return self
                }
            }
        }
        return nil
    }
    func exchanger(_ id: String) -> ExchangeVolumeDataModel? {
        exchange.filter({$0.id == id}).first
    }
}

extension TradingPairModel {
    static func mltBtc() -> TradingPairModel {
        TradingPairModel(
            name: "Metal",
            quote_icon: "https://www.cryptocompare.com/media/37746251/btc.png",
            id: "MTL/BTC",
            symbol: "MTL/BTC",
            icon: "https://www.cryptocompare.com/media/37746820/mtl.png",
            base: "MTL",
            quote: "BTC",
            change: -5.014,
            last: 0.00007029,
            exchange: []
        )
    }
}
