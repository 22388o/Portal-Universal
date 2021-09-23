//
//  OrderBookItem.swift
//  Portal
//
//  Created by Farid on 30.08.2021.
//

import Foundation

struct OrderBookItem: Codable {
    let price: Double
    let amount: Double
    let total: Double
    
    enum Keys: String, CodingKey {
        case price, amount, total
    }
}
