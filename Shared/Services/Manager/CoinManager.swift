//
//  CoinManager.swift
//  Portal
//
//  Created by Farid on 19.07.2021.
//

import Foundation
import SwiftUI

protocol ICoinManager {
    var coins: [Coin] { get }
}

class CoinManager: ICoinManager {
    var coins: [Coin] {
        [
            Coin(type: .bitcoin, code: "BTC", name: "Bitcoin", decimal: 18, color: Color.green, icon: Image("iconBtc")),
            Coin(type: .ethereum, code: "ETH", name: "Ethereum", decimal: 18, color: Color.blue, icon: Image("iconEth"))
        ]
    }
}
