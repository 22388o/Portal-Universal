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
    let code: String
    let name: String
    let color: Color
    let icon: Image
    
    init(code: String, name: String, color: Color = .clear, icon: Image = Image("iconBtc")) {
        self.code = code
        self.name = name
        self.color = color
        self.icon = icon
    }
    
    static func bitcoin() -> Self {
        Coin(code: "BTC", name: "Bitcoin", color: Color.green)
    }
    
    static func bitcoinCash() -> Self {
        Coin(code: "BCH", name: "Bitcoin cash", color: Color.green)
    }
    
    static func ethereum() -> Self {
        Coin(code: "ETH", name: "Ethereum", color: Color.blue)
    }
}
