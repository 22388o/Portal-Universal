//
//  Asset.swift
//  Portal
//
//  Created by Farid on 19.05.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation
import Combine

final class TxProvider: ITxProvider {
    let coin: Coin
    let kit: ICoinKit
    
    init(coin: Coin, kit: ICoinKit) {
        self.coin = coin
        self.kit = kit
    }
}
protocol ITxProvider {}

import BitcoinKit
import RxSwift
import Hodler

final class Asset: IAsset {
    var id: UUID
    var coin: Coin
    var kit: AbstractKit?
    var marketDataProvider: IMarketDataProvider
    var balanceProvider: IBalanceProvider
    var chartDataProvider: IChartDataProvider
    var marketChangeProvider: IMarketChangeProvider
    var qrCodeProvider: IQRCodeProvider
    var balanceStatePublisher: Published<KitSyncState>.Publisher { $balanceState }
    var balanceUpdatedSubject = PassthroughSubject<BalanceInfo, Never>()
    var txStatePublisher: Published<KitSyncState>.Publisher { $transactionState }
    
    @Published private var balanceState: KitSyncState {
        didSet {
            transactionState = balanceState
        }
    }
    @Published private var transactionState: KitSyncState
//    @Published private var balanceUpdated: Void
    
    let coinRate: Decimal = pow(10, 8)
    
    init(coin: Coin, walletID: UUID, seed: [String] = [], btcAddressFormat: BtcAddressFormat, kit: AbstractKit? = nil) {
        self.id = UUID()
        self.coin = coin
        
        self.balanceState = .notSynced(error: PError.unknow)
        self.transactionState = .notSynced(error: PError.unknow)
        
        let walletID = "\(walletID)_\(coin.name.lowercased())_wallet_id"
        
        if !seed.isEmpty {
            switch coin.type {
            case .bitcoin:
                let bip: Bip
                
                switch btcAddressFormat {
                case .legacy:
                    bip = .bip44
                case .segwit:
                    bip = .bip49
                case .nativeSegwit:
                    bip = .bip49//.bip84
                }
                
                self.kit = try? BitcoinKit(
                    withWords: seed,
                    bip: bip,
                    walletId: walletID,
                    syncMode: .api,
                    networkType: .testNet,
                    confirmationsThreshold: 0,
                    logger: .init(minLogLevel: .error)
                )
            case .etherium:
                break
            default:
                break
            }
        } else {
            self.kit = nil
        }
                
        self.marketDataProvider = MarketDataProvider(coin: coin)
        self.balanceProvider = BalanceProvider(coin: coin, kit: kit)
        self.chartDataProvider = ChartDataProvider()
        self.marketChangeProvider = MarketChangeProvider()
        self.qrCodeProvider = QRCodeProvider()
        
        start()
    }
    
    private func start() {
        switch coin.type {
        case .bitcoin:
            (self.kit as? BitcoinKit)?.delegate = self
            self.kit?.start()
        default:
            break
        }
    }
    
    static func bitcoin() -> IAsset {
        Asset(coin: Coin.bitcoin(), walletID: UUID(), btcAddressFormat: .segwit)
    }
    
    func availableBalance(feeRate: Int, address: String?) -> Decimal {
        let amount = (try? kit?.maxSpendableValue(toAddress: address, feeRate: feeRate, pluginData: [:])) ?? 0
        return Decimal(amount) / coinRate
    }

    func maximumSendAmount() -> Decimal? {
        try? kit?.maxSpendLimit(pluginData: [:]).flatMap { Decimal($0) / coinRate }
    }

    func minimumSendAmount(address: String?) -> Decimal {
        Decimal(kit?.minSpendableValue(toAddress: address) ?? 0) / coinRate
    }

    func validate(address: String) throws {
        try kit?.validate(address: address, pluginData: [:])
    }

    func fee(amount: Decimal, feeRate: Int, address: String?) -> Decimal {
        do {
            let amount = convertToSatoshi(value: amount)
            let fee = try kit?.fee(for: amount, toAddress: address, feeRate: feeRate, pluginData: [:]) ?? 0
            return Decimal(fee) / coinRate
        } catch {
            return 0
        }
    }

    func send(amount: Decimal, address: String, feeRate: Int, sortMode: TransactionDataSortMode) -> Future<Void, Error> {
        let satoshiAmount = convertToSatoshi(value: amount)
        let sortType = convertToKitSortMode(sort: sortMode)

        return Future { [weak self] promisse in
            do {
                print("Sending to \(address)")
                _ = try self?.kit?.send(to: address, value: satoshiAmount, feeRate: feeRate, sortType: sortType, pluginData: [:])
                promisse(.success(()))
            } catch {
                promisse(.failure(error))
            }
        }
    }

    var statusInfo: [(String, Any)] {
        kit?.statusInfo ?? []
    }
    
    private func convertToSatoshi(value: Decimal) -> Int {
        let coinValue: Decimal = value * coinRate
        let handler = NSDecimalNumberHandler(roundingMode: .plain, scale: Int16(truncatingIfNeeded: 0), raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        return NSDecimalNumber(decimal: coinValue).rounding(accordingToBehavior: handler).intValue
    }
    
    private func convertToKitSortMode(sort: TransactionDataSortMode) -> TransactionDataSortType {
        switch sort {
        case .shuffle: return .shuffle
        case .bip69: return .bip69
        }
    }
}

extension Asset: BitcoinCoreDelegate {
    func transactionsUpdated(inserted: [TransactionInfo], updated: [TransactionInfo]) {
        print("inserted: \(inserted)")
        let insertedTxs = inserted.map{ PortalTx(transaction: $0, lastBlockInfo: kit?.lastBlockInfo)}
        for tx in insertedTxs {
            NotificationService.shared.add(PNotification(message: "New transaction: \(tx.amount) BTC"))
        }
    }
    
    func transactionsDeleted(hashes: [String]) {
    }
    
    func balanceUpdated(balance: BalanceInfo) {
        balanceUpdatedSubject.send(balance)
    }
    
    func lastBlockInfoUpdated(lastBlockInfo: BlockInfo) {
        print("last block: \(lastBlockInfo)")
    }
    
    func kitStateUpdated(state: BitcoinCore.KitState) {
        switch state {
        case .synced:
            if case .synced = self.balanceState {
                return
            }
    
            print("Synced!")

            self.balanceState = .synced
        case .notSynced(let error):
            print(error.localizedDescription)
            if case .notSynced(let appError) = self.balanceState, "\(error)" == "\(appError)" {
                return
            }

            self.balanceState = .notSynced(error: error)
        case .syncing(let progress):
            let newProgress = Int(progress * 100)
            let newDate = kit?.lastBlockInfo?.timestamp.map { Date(timeIntervalSince1970: Double($0)) }

            if case let .syncing(currentProgress, currentDate) = self.balanceState, newProgress == currentProgress {
                if let currentDate = currentDate, let newDate = newDate, currentDate.isSameDay(as: newDate) {
                    return
                }
            }

            self.balanceState = .syncing(progress: newProgress, lastBlockDate: newDate)
        case .apiSyncing(let newCount):
            if case .searchingTxs(let count) = self.balanceState, newCount == count {
                return
            }

            self.balanceState = .searchingTxs(count: newCount)
        }
    }
}

import BitcoinCore
import Hodler

protocol IBitcoinPluginData: IPluginData {}

extension HodlerData: IBitcoinPluginData {}
