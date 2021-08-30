//
//  SocketOrderBookItem.swift
//  Portal
//
//  Created by Farid on 30.08.2021.
//

import Foundation

struct SocketOrderBookItem: Identifiable {
    let id: UUID = UUID()
    let price: Double
    let amount: Double
    var total: Double { price * amount }
}
