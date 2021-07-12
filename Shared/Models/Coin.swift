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
        case etherium
        case erc20(address: String)
    }
    
    let type: CoinType
    let code: String
    let name: String
    let color: Color
    let icon: Image
    
    init(type: CoinType, code: String, name: String, color: Color = .clear, icon: Image = Image("iconBtc")) {
        self.type = type
        self.code = code
        self.name = name
        self.color = color
        self.icon = icon
    }
    
    static func bitcoin() -> Self {
        Coin(type: .bitcoin, code: "BTC", name: "Bitcoin", color: Color.green)
    }
    
    static func ethereum() -> Self {
        Coin(type: .etherium, code: "ETH", name: "Ethereum", color: Color.blue)
    }
}
