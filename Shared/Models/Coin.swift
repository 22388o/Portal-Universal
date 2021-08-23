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
    let icon: String
    
    init(type: CoinType, code: String, name: String, decimal: Int, iconUrl: String) {
        self.type = type
        self.code = code
        self.name = name
        self.decimal = decimal
        self.icon = iconUrl
    }
    
    static func bitcoin() -> Self {
        Coin(type: .bitcoin, code: "BTC", name: "Bitcoin", decimal: 18, iconUrl: "https://icons.iconarchive.com/icons/cjdowner/cryptocurrency-flat/96/Bitcoin-BTC-icon.png")
    }
    
    static func ethereum() -> Self {
        Coin(type: .ethereum, code: "ETH", name: "Ethereum", decimal: 18, iconUrl: "https://icons.iconarchive.com/icons/cjdowner/cryptocurrency-flat/96/Ethereum-ETH-icon.png")
    }
    
    static func portal() -> Self {
        Coin(type: .erc20(address: "0x83Fc886c260C1FAfEd46A14a0b524B9Fe3C1FaAD"), code: "WHALE", name: "Portal whale token", decimal: 18, iconUrl: "https://icons.iconarchive.com/icons/cjdowner/cryptocurrency-flat/96/Ethereum-ETH-icon.png")
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
