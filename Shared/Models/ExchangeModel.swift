//
//  ExchangeModel.swift
//  Portal
//
//  Created by Farid on 09.09.2021.
//

import Foundation

class ExchangeModel: Codable, Identifiable {
    let name: String
    let id: String
    let icon: String
    let howToGetApiKeys: String
        
    enum CodingKeys: String, CodingKey {
        case name = "exchange"
        case id
        case icon
        case howToGetApiKeys = "keys"
    }
    
    init(name: String, id: String, icon: String, howToGetApiKeys: String) {
        self.name = name
        self.id = id
        self.icon = icon
        self.howToGetApiKeys = howToGetApiKeys
    }
    
    var configured: Bool {
        false
    }
    
    var balances: [ExchangeBalanceModel] = []
    var orders: [ExchangeOrderModel] = []
}

extension ExchangeModel: Equatable {
    static func == (lhs: ExchangeModel, rhs: ExchangeModel) -> Bool {
        lhs.id == rhs.id
    }
}

extension ExchangeModel {
    static func binanceMock() -> ExchangeModel {
        ExchangeModel(
            name: "Binance",
            id: "binance",
            icon: "https://cryptomarket-api.herokuapp.com/images/binance.png",
            howToGetApiKeys: "https://www.binance.com/en/support/articles/360002502072"
        )
    }
    
    static func coinbaseMock() -> ExchangeModel {
        ExchangeModel(
            name: "Coinbase Pro",
            id: "coinbasepro",
            icon: "https://cryptomarket-api.herokuapp.com/images/gdax.png",
            howToGetApiKeys: "https://support.pro.coinbase.com/customer/en/portal/articles/2945320-how-do-i-create-an-api-key-for-coinbase-pro-?b_id=17474"
        )
    }
}
