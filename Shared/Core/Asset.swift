//
//  Asset.swift
//  Portal
//
//  Created by Farid on 19.05.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation
import Combine
import BitcoinCore
import RxSwift
import Hodler

final class Asset: IAsset {
    private(set) var id: UUID
    private(set) var coin: Coin
    
    private(set) var adapter: IAdapter?
    private(set) var balanceAdapter: IBalanceAdapter?
    private(set) var depositAdapter: IDepositAdapter?
    private(set) var transactionAdaper: ITransactionsAdapter?
    private(set) var sendBtcAdapter: ISendBitcoinAdapter?
    
    private(set) var marketDataProvider: IMarketDataProvider
    private(set) var qrCodeProvider: IQRCodeProvider
        
    init(coin: Coin, walletID: UUID, seed: [String] = [], btcAddressDereviation: MnemonicDerivation) {
        self.id = UUID()
        self.coin = coin
        
        if !seed.isEmpty {
            switch coin.type {
            case .bitcoin:
                let walletID = "\(walletID)_\(coin.name.lowercased())_wallet_id"
                
                let kit = try? BitcoinAdapter(walletID: walletID, seed: seed, dereviation: btcAddressDereviation, syncMode: .fast, testMode: true)
                
                self.adapter = kit
                self.balanceAdapter = kit
                self.depositAdapter = kit
                self.transactionAdaper = kit
                self.sendBtcAdapter = kit
                 
            case .etherium:
                break
            default:
                break
            }
        }
                
        self.marketDataProvider = MarketDataProvider(coin: coin)
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
            return 0
        case .erc20( _):
            return 0
        }
    }

    func maximumSendAmount() -> Decimal? {
        switch coin.type {
        case .bitcoin:
            return sendBtcAdapter?.maximumSendAmount(pluginData: [:])
        case .etherium:
            return nil
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
            break
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
            
            switch self?.coin.type {
            case .bitcoin:
                _ = self?.sendBtcAdapter?.sendSingle(amount: amount, address: address, feeRate: feeRate, pluginData: [:], sortMode: sortMode)
                promisse(.success(()))
            case .etherium:
                promisse(.failure(AppError.unknownError))
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
        Asset(coin: Coin.bitcoin(), walletID: UUID(), btcAddressDereviation: .bip49)
    }
}

protocol IBitcoinPluginData: IPluginData {}

extension HodlerData: IBitcoinPluginData {}
