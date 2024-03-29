//
//  IWallet.swift
//  Portal
//
//  Created by Farid on 18.05.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation

protocol IWallet {
    var walletID: UUID { get }
    var mnemonicDereviation: MnemonicDerivation { get }
    var name: String { get }
    var fiatCurrencyCode: String { get }
    var assets: [IAsset] { get }
    func updateFiatCurrency(_ fiatCurrency: FiatCurrency)
    func stop()
    func start()
}
