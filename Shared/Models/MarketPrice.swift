//
//  MarketPrice.swift
//  Portal
//
//  Created by Farid on 15.04.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation

struct MarketPrice {
    let price: Decimal
    let dayHigh: Float
    let dayLow: Float
    let changeIn24Hrs: Float
    let changeDayPercent: Float
}

extension MarketPrice: Decodable {
    
    enum Keys: String, CodingKey {
        case price = "PRICE"
        case dayHigh = "HIGHDAY"
        case dayLow = "LOWDAY"
        case changeIn24Hrs = "CHANGEDAY"
        case changeDayPercent = "CHANGEPCTDAY"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        price = try container.decode(Decimal.self, forKey: .price)
        dayHigh = try container.decode(Float.self, forKey: .dayHigh)
        dayLow = try container.decode(Float.self, forKey: .dayLow)
        changeIn24Hrs = try container.decode(Float.self, forKey: .changeIn24Hrs)
        changeDayPercent = try container.decode(Float.self, forKey: .changeDayPercent)
    }
}
