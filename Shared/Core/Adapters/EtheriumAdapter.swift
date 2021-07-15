//
//  EtheriumAdapter.swift
//  Portal
//
//  Created by Farid on 10.07.2021.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import EthereumKit
import RxSwift
import BigInt
import HsToolKit

final class EtheriumAdapter: BaseEtheriumAdapter {
    static let decimal = 18

    init(evmKit: EthereumKit.Kit) {
        super.init(evmKit: evmKit, decimal: EtheriumAdapter.decimal)
    }

    private func convertAmount(amount: BigUInt, fromAddress: EthereumKit.Address) -> Decimal {
        guard let significand = Decimal(string: amount.description), significand != 0 else {
            return 0
        }

        let fromMine = fromAddress == evmKit.receiveAddress
        let sign: FloatingPointSign = fromMine ? .minus : .plus
        return Decimal(sign: sign, exponent: -decimal, significand: significand)
    }

    private func transactionRecord(fromTransaction fullTransaction: FullTransaction) -> TransactionRecord {
        let transaction = fullTransaction.transaction
        let receipt = fullTransaction.receiptWithLogs?.receipt

        var from = transaction.from
        var to = transaction.to

        var amount = convertAmount(amount: transaction.value, fromAddress: transaction.from)

        amount += fullTransaction.internalTransactions.reduce(0) { internalAmount, internalTransaction in
            from = internalTransaction.from
            to = internalTransaction.to
            return internalAmount + convertAmount(amount: internalTransaction.value, fromAddress: internalTransaction.from)
        }

        let type: TransactionType
        if transaction.from == transaction.to {
            type = .sentToSelf
        } else if amount < 0 {
            type = .outgoing
        } else {
            type = .incoming
        }

        let txHash = transaction.hash.toHexString()

        return TransactionRecord(
                uid: txHash,
                transactionHash: txHash,
                transactionIndex: receipt?.transactionIndex ?? 0,
                interTransactionIndex: 0,
                type: type,
                blockHeight: receipt?.blockNumber,
                confirmationsThreshold: BaseEtheriumAdapter.confirmationsThreshold,
                amount: abs(amount),
                fee: receipt.map { Decimal(sign: .plus, exponent: -decimal, significand: Decimal($0.gasUsed * transaction.gasPrice)) },
                date: Date(timeIntervalSince1970: Double(transaction.timestamp)),
                failed: fullTransaction.failed,
                from: from.eip55,
                to: to?.eip55,
                lockInfo: nil,
                conflictingHash: nil,
                showRawTransaction: false,
                memo: nil
        )
    }

}

extension EtheriumAdapter {

    static func clear(except excludedWalletIds: [String]) throws {
        try EthereumKit.Kit.clear(exceptFor: excludedWalletIds)
    }

}

// IAdapter
extension EtheriumAdapter: IAdapter {

    func start() {
        evmKit.start()
    }

    func stop() {
        evmKit.stop()
    }

    func refresh() {
        evmKit.start()
    }

    var debugInfo: String {
        evmKit.debugInfo
    }

}

protocol ISendEthereumAdapter {
    var evmKit: EthereumKit.Kit { get }
    var balance: Decimal { get }
    func transactionData(amount: BigUInt, address: EthereumKit.Address) -> TransactionData
}

extension EtheriumAdapter: IBalanceAdapter {

    var balanceState: AdapterState {
        convertToAdapterState(evmSyncState: evmKit.syncState)
    }

    var balanceStateUpdatedObservable: Observable<Void> {
        evmKit.syncStateObservable.map { _ in () }
    }

    var balance: Decimal {
        balanceDecimal(kitBalance: evmKit.accountState?.balance, decimal: EtheriumAdapter.decimal)
    }

    var balanceUpdatedObservable: Observable<Void> {
        evmKit.accountStateObservable.map { _ in () }
    }

}

extension EtheriumAdapter: ISendEthereumAdapter {

    func transactionData(amount: BigUInt, address: EthereumKit.Address) -> TransactionData {
        evmKit.transferTransactionData(to: address, value: amount)
    }

}

extension EtheriumAdapter: ITransactionsAdapter {

    var coin: Coin {
        Coin(type: .etherium, code: "ETH", name: "Etherium")
    }
    
    var transactionState: AdapterState {
        convertToAdapterState(evmSyncState: evmKit.transactionsSyncState)
    }

    var transactionStateUpdatedObservable: Observable<Void> {
        evmKit.transactionsSyncStateObservable.map { _ in () }
    }

    var transactionRecordsObservable: Observable<[TransactionRecord]> {
        evmKit.etherTransactionsObservable.map { [weak self] in
            $0.compactMap { self?.transactionRecord(fromTransaction: $0) }
        }
    }

    func transactionsSingle(from: TransactionRecord?, limit: Int) -> Single<[TransactionRecord]> {
        evmKit.etherTransactionsSingle(fromHash: from.flatMap { Data(hex: $0.transactionHash) }, limit: limit)
                .map { [weak self] transactions -> [TransactionRecord] in
                    transactions.compactMap { self?.transactionRecord(fromTransaction: $0) }
                }
    }

    func rawTransaction(hash: String) -> String? {
        nil
    }

}
