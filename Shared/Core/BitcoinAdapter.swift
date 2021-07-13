//
//  BitcoinAdapter.swift
//  Portal
//
//  Created by Farid on 10.07.2021.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import BitcoinKit
import BitcoinCore
import RxSwift
import Hodler

class BitcoinAdapter: BitcoinBaseAdapter {
    private let bitcoinKit: BitcoinKit

    init(walletID: String, seed: [String], dereviation: MnemonicDerivation, syncMode: SyncMode?, testMode: Bool) throws {
        let networkType: BitcoinKit.NetworkType = testMode ? .testNet : .mainNet
        let bip = BitcoinBaseAdapter.bip(from: dereviation)
        let syncMode = BitcoinBaseAdapter.kitMode(from: .fast)

        bitcoinKit = try BitcoinKit(
            withWords: seed,
            bip: bip,
            walletId: walletID,
            syncMode: syncMode,
            networkType: networkType,
            confirmationsThreshold: BitcoinBaseAdapter.confirmationsThreshold,
            logger: .init(minLogLevel: .error)
        )

        super.init(abstractKit: bitcoinKit)

        bitcoinKit.delegate = self
    }

}

extension BitcoinAdapter: ISendBitcoinAdapter {
}

extension BitcoinAdapter {
//    static func clear(except excludedWalletIds: [String]) throws {
//        try Kit.clear(exceptFor: excludedWalletIds)
//    }
}
