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
    
    var assets = [IAsset]()
    
    init() {
        let btc = Coin(code: "BTC", name: "Bitcoin", color: UIColor.green, icon: UIImage(imageLiteralResourceName: "iconBtc"))
        let bch = Coin(code: "BCH", name: "Bitcoin Cash", color: UIColor.gray, icon: UIImage(imageLiteralResourceName: "iconBch"))
        let eth = Coin(code: "ETH", name: "Ethereum", color: UIColor.yellow, icon: UIImage(imageLiteralResourceName: "iconEth"))
        let xlm = Coin(code: "XLM", name: "Stellar Lumens", color: UIColor.blue, icon: UIImage(imageLiteralResourceName: "iconXlm"))
        let xtz = Coin(code: "XTZ", name: "Tezos", color: UIColor.brown, icon: UIImage(imageLiteralResourceName: "iconXtz"))
        
        self.assets = [
            Asset(coin: btc),
            Asset(coin: bch),
            Asset(coin: eth),
            Asset(coin: xlm),
            Asset(coin: xtz)
        ]
    }
    
    func setup() {}
}

//let CoinsMock: [Asset] = [BTC(), BCH(), ETH(), XLM(), XTZ()]
