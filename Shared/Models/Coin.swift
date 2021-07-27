//
//  Coin.swift
//  Portal
//
//  Created by Farid on 19.05.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation
import SwiftUI

struct Coin {
    enum CoinType {
        case bitcoin
        case ethereum
        case erc20(address: String)
    }
    
    let type: CoinType
    let code: String
    let name: String
    let decimal: Int
    let color: Color
    let icon: Image
    
    init(type: CoinType, code: String, name: String, decimal: Int, color: Color = .clear, icon: Image = Image("iconBtc")) {
        self.type = type
        self.code = code
        self.name = name
        self.decimal = decimal
        self.color = color
        self.icon = icon
    }
    
    static func bitcoin() -> Self {
        Coin(type: .bitcoin, code: "BTC", name: "Bitcoin", decimal: 18, color: Color.green)
    }
    
    static func ethereum() -> Self {
        Coin(type: .ethereum, code: "ETH", name: "Ethereum", decimal: 18, color: Color.blue)
    }
}

extension Coin: Hashable {

    public static func ==(lhs: Coin, rhs: Coin) -> Bool {
        lhs.code == rhs.code && lhs.name == rhs.name
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(code)
        hasher.combine(name)
    }

}
