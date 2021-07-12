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

let USD = FiatCurrency(code: "USD", name: "American Dollar", rate: 1)

import BitcoinCore

final class MockCoinKit: AbstractKit {
    func send(amount: Double) {
        print("Send coins...")
    }
}

class WalletMock: IWallet {
    var walletID: UUID = UUID()
    var name: String = "Personal"
    var fiatCurrencyCode: String = "USD"
    
    var assets = [IAsset]()
    
    init() {
        let btc = Coin(type: .bitcoin, code: "BTC", name: "Bitcoin", color: Color.green, icon: Image("iconBtc"))
//        let bch = Coin(code: "BCH", name: "Bitcoin Cash", color: Color.gray, icon: Image("iconBch"))
        let eth = Coin(type: .etherium, code: "ETH", name: "Ethereum", color: Color.yellow, icon: Image("iconEth"))
//        let xlm = Coin(code: "XLM", name: "Stellar Lumens", color: Color.blue, icon: Image("iconXlm"))
//        let xtz = Coin(code: "XTZ", name: "Tezos", color: Color.red, icon: Image("iconXtz"))
        
        self.assets = [
            Asset(coin: btc, walletID: UUID(), btcAddressFormat: .segwit),
            Asset(coin: eth, walletID: UUID(), btcAddressFormat: .segwit)
        ]
    }
    
    func setup() {}
    func stop() {}
    func addTx(coin: Coin, amount: Decimal, receiverAddress: String, memo: String?) {}
    func updateFiatCurrency(_ fiatCurrency: FiatCurrency) {}
}
