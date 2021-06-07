//
//  MarketSnapshot.swift
//  Portal
//
//  Created by Farid on 09.03.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation
import Coinpaprika

struct MarketSnapshot {
    let high: Decimal
    let low: Decimal
    let open: Decimal
    let close: Decimal
    
    init(_ ohlc: Coinpaprika.Ohlcv) {
        high = ohlc.high ?? 0
        low = ohlc.low ?? 0
        open = ohlc.open ?? 0
        close = ohlc.close ?? 0
    }
}

//extension MarketSnapshot: Decodable {
//    enum Keys: String, CodingKey {
//        case high
//        case low
//        case close
//        case open
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: Keys.self)
//
//        let h = try container.decode(Double.self, forKey: .high)
//        let l = try container.decode(Double.self, forKey: .low)
//        let o = try container.decode(Double.self, forKey: .open)
//        let c = try container.decode(Double.self, forKey: .close)
//
//        high = h
//        low = l
//        open = o
//        close = c
//    }
//}

