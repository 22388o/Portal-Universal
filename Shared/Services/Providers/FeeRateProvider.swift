//
//  FeeRateProvider.swift
//  Portal
//
//  Created by Farid on 15.07.2021.
//

import Foundation
import FeeRateKit
import RxSwift
import Combine

class FeeRateProvider {
    private let feeRateKit: FeeRateKit.Kit
    let disposeBag = DisposeBag()

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

    var ethereumGasPrice: Future<Int, Never> {
        Future { [unowned self] promisse in
            self.feeRateKit.ethereum
                .subscribe(onSuccess: { price in
                    promisse(.success(price))
                })
                .disposed(by: self.disposeBag)
        }
    }

    var binanceSmartChainGasPrice: Future<Int, Never> {
        Future { [unowned self] promisse in
            self.feeRateKit.binanceSmartChain
                .subscribe(onSuccess: { price in
                    promisse(.success(price))
                })
                .disposed(by: self.disposeBag)
        }
    }

    var litecoinFeeRate: Future<Int, Never> {
        Future { [unowned self] promisse in
            self.feeRateKit.litecoin
                .subscribe(onSuccess: { price in
                    promisse(.success(price))
                })
                .disposed(by: self.disposeBag)
        }
    }

    var bitcoinCashFeeRate: Future<Int, Never> {
        Future { [unowned self] promisse in
            self.feeRateKit.bitcoinCash
                .subscribe(onSuccess: { price in
                    promisse(.success(price))
                })
                .disposed(by: self.disposeBag)
        }
    }

    var dashFeeRate: Future<Int, Never> {
        Future { [unowned self] promisse in
            self.feeRateKit.dash
                .subscribe(onSuccess: { price in
                    promisse(.success(price))
                })
                .disposed(by: self.disposeBag)
        }
    }

    func bitcoinFeeRate(blockCount: Int) -> Future<Int, Never> {
        Future { [unowned self] promisse in
            self.feeRateKit.bitcoin(blockCount: blockCount)
                .subscribe(onSuccess: { rate in
                    promisse(.success(rate))
                })
                .disposed(by: self.disposeBag)
                
        }
    }

}
