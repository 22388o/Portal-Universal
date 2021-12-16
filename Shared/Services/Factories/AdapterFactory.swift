//
//  AdapterFactory.swift
//  Portal
//
//  Created by Farid on 19.07.2021.
//

import Foundation

class AdapterFactory: IAdapterFactory {
    private let appConfigProvider: IAppConfigProvider
    private let ethereumKitManager: EthereumKitManager

    init(appConfigProvider: IAppConfigProvider, ethereumKitManager: EthereumKitManager) {
        self.appConfigProvider = appConfigProvider
        self.ethereumKitManager = ethereumKitManager
    }

    func adapter(wallet: Wallet) -> IAdapter? {
        switch wallet.coin.type {
        case .bitcoin:
            return try? BitcoinAdapter(wallet: wallet, syncMode: .fast)
        case .ethereum:
            if let ethKit = try? ethereumKitManager.kit(account: wallet.account) {
                return EthereumAdapter(ethKit: ethKit, confirmationsThreshold: wallet.account.confirmationsThreshold)
            }
        case let .erc20(address):
            if let ethKit = try? ethereumKitManager.kit(account: wallet.account) {
                return try? Erc20Adapter(ethKit: ethKit, contractAddress: address, decimal: wallet.coin.decimal, confirmationsThreshold: wallet.account.confirmationsThreshold)
            }
        }

        return nil
    }

}
