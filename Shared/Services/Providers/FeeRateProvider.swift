//
//  FeeRateProvider.swift
//  Portal
//
//  Created by Farid on 15.07.2021.
//

import Foundation
import FeeRateKit
import RxSwift

class FeeRateProvider {
    private let feeRateKit: FeeRateKit.Kit

    init(appConfigProvider: IAppConfigProvider) {
        let providerConfig = FeeProviderConfig(
                ethEvmUrl: FeeProviderConfig.infuraUrl(projectId: appConfigProvider.infuraCredentials.id),
                ethEvmAuth: appConfigProvider.infuraCredentials.secret,
                bscEvmUrl: FeeProviderConfig.defaultBscEvmUrl,
                btcCoreRpcUrl: appConfigProvider.btcCoreRpcUrl,
                btcCoreRpcUser: nil,
                btcCoreRpcPassword: nil
        )
        feeRateKit = FeeRateKit.Kit.instance(providerConfig: providerConfig, minLogLevel: .error)
    }

    // Fee rates

    var ethereumGasPrice: Single<Int> {
        feeRateKit.ethereum
    }

    var binanceSmartChainGasPrice: Single<Int> {
        feeRateKit.binanceSmartChain
    }

    var litecoinFeeRate: Single<Int> {
        feeRateKit.litecoin
    }

    var bitcoinCashFeeRate: Single<Int> {
        feeRateKit.bitcoinCash
    }

    var dashFeeRate: Single<Int> {
        feeRateKit.dash
    }

    func bitcoinFeeRate(blockCount: Int) -> Single<Int> {
        feeRateKit.bitcoin(blockCount: blockCount)
    }

}
