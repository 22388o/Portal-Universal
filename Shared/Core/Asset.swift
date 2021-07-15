//
//  Asset.swift
//  Portal
//
//  Created by Farid on 19.05.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation
import Combine
import RxSwift
import Hodler
import BitcoinCore
import EthereumKit
import BigInt

final class Asset: IAsset {
    private(set) var id: UUID
    private(set) var coin: Coin
    
    private(set) var adapter: IAdapter?
    private(set) var balanceAdapter: IBalanceAdapter?
    private(set) var depositAdapter: IDepositAdapter?
    private(set) var transactionAdaper: ITransactionsAdapter?
    
    private(set) var sendBtcAdapter: ISendBitcoinAdapter?
    private(set) var sendEtherAdapter: ISendEthereumAdapter?
    
    private(set) var qrCodeProvider: IQRCodeProvider
    
    private var disposeBag = DisposeBag()
        
    init(coin: Coin, walletID: UUID, data: Data?, bip: MnemonicDerivation? = nil) {
        self.id = UUID()
        self.coin = coin
        
        let walletID = "\(walletID)_\(coin.name.lowercased())_wallet_id"
        var kit: (IAdapter & IBalanceAdapter & IDepositAdapter & ITransactionsAdapter)? = nil
        
        if let seed = data {
            switch coin.type {
            case .bitcoin:
                
                guard let dereviation = bip else {
                    fatalError("Bip cannot be nil for bitcoin")
                }
                
                if let bitcoinKit = try? BitcoinAdapter(
                    walletID: walletID,
                    data: seed,
                    dereviation: dereviation,
                    syncMode: .fast,
                    testMode: true
                ) {
                    kit = bitcoinKit
                    sendBtcAdapter = bitcoinKit
                }
                 
            case .etherium:

                let configProvider: IAppConfigProvider = AppConfigProvider()
                
                let networkType: NetworkType = .ropsten

                guard
                    !configProvider.infuraCredentials.id.isEmpty,
                    let infuraSecret = configProvider.infuraCredentials.secret,
                    !infuraSecret.isEmpty,
                    let syncSource = EthereumKit.Kit.infuraWebsocketSyncSource(networkType: networkType, projectId: configProvider.infuraCredentials.id, projectSecret: infuraSecret) else {
                    fatalError("Sync source isn't set")
                }

                do {
                    let evmKit = try EthereumKit.Kit.instance(
                        seed: seed,
                        networkType: .ropsten,
                        syncSource: syncSource,
                        etherscanApiKey: configProvider.etherscanKey,
                        walletId: walletID,
                        minLogLevel: .error
                    )
                                        
                    let etheriumKit = EtheriumAdapter(evmKit: evmKit)
                    kit = etheriumKit
                    sendEtherAdapter = etheriumKit
                    
                } catch {
                    fatalError("Cannot create eth kit")
                }
                                
            default:
                break
            }
        }
        
        self.adapter = kit
        self.balanceAdapter = kit
        self.depositAdapter = kit
        self.transactionAdaper = kit
                
        self.qrCodeProvider = QRCodeProvider()
        
        start()
    }
    
    private func start() {
        self.adapter?.start()
    }
    
    func availableBalance(feeRate: Int, address: String?) -> Decimal {
        switch coin.type {
        case .bitcoin:
            return sendBtcAdapter?.availableBalance(feeRate: feeRate, address: address, pluginData: [:]) ?? 0
        case .etherium:
            return sendEtherAdapter?.balance ?? 0
        case .erc20( _):
            return 0
        }
    }

    func maximumSendAmount() -> Decimal? {
        switch coin.type {
        case .bitcoin:
            return sendBtcAdapter?.maximumSendAmount(pluginData: [:])
        case .etherium:
            return sendEtherAdapter?.balance ?? 0
        case .erc20( _):
            return nil
        }
    }

    func minimumSendAmount(address: String?) -> Decimal {
        switch coin.type {
        case .bitcoin:
            return sendBtcAdapter?.minimumSendAmount(address: address) ?? 0
        case .etherium:
            return 0
        case .erc20( _):
            return 0
        }
    }

    func validate(address: String) throws {
        switch coin.type {
        case .bitcoin:
            try sendBtcAdapter?.validate(address: address, pluginData: [:])
        case .etherium:
            _ = try EthereumKit.Address.init(hex: address)
        case .erc20( _):
            break
        }
    }

    func fee(amount: Decimal, feeRate: Int, address: String?) -> Decimal {
        switch coin.type {
        case .bitcoin:
            return sendBtcAdapter?.fee(amount: amount, feeRate: feeRate, address: address, pluginData: [:]) ?? 0
        case .etherium:
            return 0
        case .erc20( _):
            return 0
        }
    }

    func send(amount: Decimal, address: String, feeRate: Int, sortMode: TransactionDataSortMode) -> Future<Void, Error> {
        return Future { [weak self] promisse in
            print("Sending to \(address)")
            
            guard let weakSelf = self else { return }
            
            switch self?.coin.type {
            case .bitcoin:
                weakSelf.sendBtcAdapter?
                    .sendSingle(amount: amount, address: address, feeRate: feeRate, pluginData: [:], sortMode: sortMode)
                    .subscribe(onSuccess: { _ in
                        promisse(.success(()))
                    }, onError: { error in
                        promisse(.failure(error))
                    })
                    .disposed(by: weakSelf.disposeBag)
            case .etherium:
                
                guard
                    let amountToSend = BigUInt(amount.roundedString(decimal: 18)),
                    let recepientAddress = try? Address(hex: address)
                else {
                    return promisse(.failure(AppError.unknownError))
                }
                
                Portal.shared.etherFeesProvider.feeRate(priority: .high)
                    .flatMap({ gasPrice in
                        return weakSelf.sendEtherAdapter!
                            .evmKit
                            .estimateGas(to: recepientAddress, amount: amountToSend, gasPrice: gasPrice * 4)
                            .flatMap({ gasLimit in
                                return weakSelf.sendEtherAdapter!.evmKit.sendSingle(address: recepientAddress, value: amountToSend, gasPrice: gasPrice * 4, gasLimit: gasLimit)
                            })
                    })
                    .subscribe(onSuccess: { transaction in
                        print(transaction.transaction.hash.hex)
                        promisse(.success(()))
                    }, onError: { error in
                        promisse(.failure(error))
                    })
                    .disposed(by: weakSelf.disposeBag)
                
            case .erc20( _):
                promisse(.failure(AppError.unknownError))
            case .none:
                promisse(.failure(AppError.unknownError))
            }
        }
    }
}

extension Asset {
    static func bitcoin() -> IAsset {
        Asset(coin: Coin.bitcoin(), walletID: UUID(), data: Data(), bip: .bip49)
    }
}
