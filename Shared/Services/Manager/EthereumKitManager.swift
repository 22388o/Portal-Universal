//
//  EthereumKitManager.swift
//  Portal
//
//  Created by Farid on 19.07.2021.
//

import Foundation
import EthereumKit
import Erc20Kit

final class EthereumKitManager {
    private let appConfigProvider: IAppConfigProvider
    weak var ethereumKit: EthereumKit.Kit?

    private var currentAccount: Account?

    init(appConfigProvider: IAppConfigProvider) {
        self.appConfigProvider = appConfigProvider
    }

    func kit(account: Account) throws -> EthereumKit.Kit {
        if let ethKit = ethereumKit, let currentAccount = currentAccount, currentAccount == account {
            return ethKit
        }

        guard let seed = account.type.mnemonicSeed else {
            throw AdapterError.unsupportedAccount
        }
        
        let networkType = account.ethNetworkType

        guard let syncSource = EthereumKit.Kit.infuraWebsocketSyncSource(
            networkType: networkType,
            projectId: appConfigProvider.infuraCredentials.id,
            projectSecret: appConfigProvider.infuraCredentials.secret
        ) else {
            throw AdapterError.wrongParameters
        }
        
        let ethKit = try EthereumKit.Kit.instance(
            seed: seed,
            networkType: networkType,
            syncSource: syncSource,
            etherscanApiKey: appConfigProvider.etherscanKey,
            walletId: account.id,
            minLogLevel: .error
        )
        
        ethKit.add(decorator: Erc20Kit.Kit.getDecorator())
        ethKit.add(transactionSyncer: Erc20Kit.Kit.getTransactionSyncer(evmKit: ethKit))

        ethKit.start()

        self.ethereumKit = ethKit
        currentAccount = account
        
        return ethKit
    }

    var statusInfo: [(String, Any)]? {
        ethereumKit?.statusInfo()
    }

}
