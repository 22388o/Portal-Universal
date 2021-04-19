//
//  MockData.swift
//  Portal
//
//  Created by Farid on 06.03.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation
import SwiftUI

let btcMockAddress = "1HqwV7F9hpUpJXubLFomcrNMUqPLzeTVNd"

let USD = FiatCurrency(code: "USD", name: "American Dollar")

final class MockCoinKit: ICoinKit {
    var balance: Double {
        Double.random(in: 0.285..<2.567).rounded(toPlaces: 4)
    }
    func send(amount: Double) {
        print("Send coins...")
    }
}

class WalletMock: IWallet {
    var walletID: UUID = UUID()
    var name: String = "Personal"
    
    var assets = [IAsset]()
    
    init() {
        let btc = Coin(code: "BTC", name: "Bitcoin", color: Color.green, icon: Image("iconBtc"))
        let bch = Coin(code: "BCH", name: "Bitcoin Cash", color: Color.gray, icon: Image("iconBch"))
        let eth = Coin(code: "ETH", name: "Ethereum", color: Color.yellow, icon: Image("iconEth"))
        let xlm = Coin(code: "XLM", name: "Stellar Lumens", color: Color.blue, icon: Image("iconXlm"))
        let xtz = Coin(code: "XTZ", name: "Tezos", color: Color.red, icon: Image("iconXtz"))
        
        self.assets = [
            Asset(coin: btc),
            Asset(coin: bch),
            Asset(coin: eth),
            Asset(coin: xlm),
            Asset(coin: xtz)
        ]
    }
    
    func setup() {}
    func addTx(coin: Coin, amount: Decimal, receiverAddress: String, memo: String?) {}
}

//let CoinsMock: [Asset] = [BTC(), BCH(), ETH(), XLM(), XTZ()]
