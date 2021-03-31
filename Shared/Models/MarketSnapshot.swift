//
//  MarketSnapshot.swift
//  Portal
//
//  Created by Farid on 09.03.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation

struct MarketSnapshot {
    let high: Double
    let low: Double
    let open: Double
    let close: Double
}

extension MarketSnapshot: Decodable {
    enum Keys: String, CodingKey {
        case high
        case low
        case close
        case open
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        
        let h = try container.decode(Double.self, forKey: .high)
        let l = try container.decode(Double.self, forKey: .low)
        let o = try container.decode(Double.self, forKey: .open)
        let c = try container.decode(Double.self, forKey: .close)
        
        high = h
        low = l
        open = o
        close = c
    }
}

