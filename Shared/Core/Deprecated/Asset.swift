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

import SwiftUI

final class QRCodeProvider: IQRCodeProvider {}


final class Asset: IAsset {
    private(set) var id: UUID
    private(set) var coin: Coin
    
    private(set) var adapter: IAdapter?
    private(set) var balanceAdapter: IBalanceAdapter?
    private(set) var depositAdapter: IDepositAdapter?
    private(set) var transactionAdapter: ITransactionsAdapter?
    
    private(set) var sendBtcAdapter: ISendBitcoinAdapter?
    private(set) var sendEtherAdapter: ISendEthereumAdapter?
    
    private(set) var qrCodeProvider: IQRCodeProvider
    
    private var disposeBag = DisposeBag()
    private var subscriptions = Set<AnyCancellable>()
        
    init(account: IAccount, coin: Coin) {
        self.id = UUID()
        self.coin = coin
        
        let kit: (IAdapter & IBalanceAdapter & IDepositAdapter & ITransactionsAdapter)? = nil
        
        self.qrCodeProvider = QRCodeProvider()
        self.adapter = kit
        self.balanceAdapter = kit
        self.depositAdapter = kit
        self.transactionAdapter = kit
    }
        
    func availableBalance(feeRate: Int, address: String?) -> Decimal {
        switch coin.type {
        case .bitcoin:
            return sendBtcAdapter?.availableBalance(feeRate: feeRate, address: address, pluginData: [:]) ?? 0
        case .ethereum:
            return sendEtherAdapter?.balance ?? 0
        case .erc20( _):
            return 0
        }
    }

    func maximumSendAmount() -> Decimal? {
        switch coin.type {
        case .bitcoin:
            return sendBtcAdapter?.maximumSendAmount(pluginData: [:])
        case .ethereum:
            return sendEtherAdapter?.balance ?? 0
        case .erc20( _):
            return nil
        }
    }

    func minimumSendAmount(address: String?) -> Decimal {
        switch coin.type {
        case .bitcoin:
            return sendBtcAdapter?.minimumSendAmount(address: address) ?? 0
        case .ethereum:
            return 0
        case .erc20( _):
            return 0
        }
    }

    func validate(address: String) throws {
        switch coin.type {
        case .bitcoin:
            try sendBtcAdapter?.validate(address: address, pluginData: [:])
        case .ethereum:
            _ = try EthereumKit.Address.init(hex: address)
        case .erc20( _):
            break
        }
    }

    func fee(amount: Decimal, feeRate: Int, address: String?) -> Decimal {
        switch coin.type {
        case .bitcoin:
            return sendBtcAdapter?.fee(amount: amount, feeRate: feeRate, address: address, pluginData: [:]) ?? 0
        case .ethereum:
            return 0
        case .erc20( _):
            return 0
        }
    }

    func send(amount: Decimal, address: String, feeRate: Int, sortMode: TransactionDataSortMode) -> Future<Void, Error> {
        return Future { [weak self] promise in
            print("Sending to \(address)")
            
            guard let weakSelf = self else { return }
            
            switch self?.coin.type {
            case .bitcoin:
                weakSelf.sendBtcAdapter?.send(amount: amount, address: address, feeRate: feeRate, pluginData: [:], sortMode: sortMode)
                    .receive(on: RunLoop.main)
                    .sink(receiveCompletion: { completion in
                        
                    }, receiveValue: { _ in
                        promise(.success(()))
                    })
                    .store(in: &weakSelf.subscriptions)
            case .ethereum:
                
                promise(.success(()))
                
//                guard
//                    let amountToSend = BigUInt(amount.roundedString(decimal: 18)),
//                    let recepientAddress = try? Address(hex: address)
//                else {
//                    return promise(.failure(AppError.unknownError))
//                }
//                
//                Portal.shared.etherFeesProvider.feeRate(priority: .high)
//                    .flatMap({ gasPrice in
//                        return weakSelf.sendEtherAdapter!
//                            .evmKit
//                            .estimateGas(to: recepientAddress, amount: amountToSend, gasPrice: gasPrice)
//                            .flatMap({ gasLimit in
//                                return weakSelf.sendEtherAdapter!.evmKit.sendSingle(address: recepientAddress, value: amountToSend, gasPrice: gasPrice, gasLimit: gasLimit)
//                            })
//                    })
//                    .subscribe(onSuccess: { transaction in
//                        print(transaction.transaction.hash.hex)
//                        promise(.success(()))
//                    }, onError: { error in
//                        promise(.failure(error))
//                    })
//                    .disposed(by: weakSelf.disposeBag)
                
            case .erc20( _):
                promise(.failure(AppError.unknownError))
            case .none:
                promise(.failure(AppError.unknownError))
            }
        }
    }
}

extension Asset {
    static func bitcoin() -> IAsset {
        Asset(account: MockedAccount(), coin: Coin.bitcoin())
    }
}
