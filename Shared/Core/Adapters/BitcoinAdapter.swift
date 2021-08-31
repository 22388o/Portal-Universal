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

final class BitcoinAdapter: BitcoinBaseAdapter {
    private let bitcoinKit: Kit
    
    init(wallet: Wallet, syncMode: SyncMode?, testMode: Bool) throws {
        guard let seed = wallet.account.type.mnemonicSeed else {
            throw AdapterError.unsupportedAccount
        }
        
        guard let walletSyncMode = syncMode else {
            throw AdapterError.wrongParameters
        }

        let networkType: Kit.NetworkType = testMode ? .testNet : .mainNet
        let bip: Bip = BitcoinBaseAdapter.bip(from: wallet.account.mnemonicDereviation)
        let syncMode = BitcoinBaseAdapter.kitMode(from: walletSyncMode)
        
        bitcoinKit = try Kit(
            seed: seed,
            bip: bip,
            walletId: wallet.account.id,
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
    static func clear(except excludedWalletIds: [String]) throws {
        try Kit.clear(exceptFor: excludedWalletIds)
    }
}
