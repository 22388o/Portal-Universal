//
//  OrderBook.swift
//  Portal
//
//  Created by Farid on 30.08.2021.
//

import Foundation

struct OrderBook: Codable {
    let bids: [OrderBookItem]
    let asks: [OrderBookItem]
    let nonce: Double
    
    enum Keys: String, CodingKey {
        case bids, asks, nonce
    }
}

extension OrderBook {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        let rawBids = try container.decode([[Double]].self, forKey: .bids)
        let rawAsks = try container.decode([[Double]].self, forKey: .asks)

        bids = rawBids.map{ OrderBookItem(price: $0[0], amount: $0[1], total: $0[0] * $0[1]) }
        asks = rawAsks.map{ OrderBookItem(price: $0[0], amount: $0[1], total: $0[0] * $0[1]) }

        nonce = try container.decode(Double.self, forKey: .nonce)
    }
}
