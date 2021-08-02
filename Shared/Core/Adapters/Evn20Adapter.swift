//
//  Evn20Adapter.swift
//  Portal
//
//  Created by Farid on 16.07.2021.
//

import EthereumKit
import Erc20Kit
import RxSwift
import BigInt
import HsToolKit

class Evm20Adapter: BaseEvmAdapter {
    private static let approveConfirmationsThreshold: Int? = nil
    let evm20Kit: Erc20Kit.Kit
    private let contractAddress: EthereumKit.Address

    init(evmKit: EthereumKit.Kit, contractAddress: String, decimal: Int) throws {
        let address = try EthereumKit.Address(hex: contractAddress)
        evm20Kit = try Erc20Kit.Kit.instance(ethereumKit: evmKit, contractAddress: address)
        self.contractAddress = address

        super.init(evmKit: evmKit, decimal: decimal)
    }

    private func transactionRecord(fromTransaction fullTransaction: FullTransaction) -> TransactionRecord {
        let transaction = fullTransaction.transaction
        let receipt = fullTransaction.receiptWithLogs?.receipt

        var type: TransactionType = .sentToSelf
        var amount: Decimal = 0
        let confirmationsThreshold: Int? = BaseEvmAdapter.confirmationsThreshold

        if let significand = Decimal(string: transaction.value.description) {
            amount = Decimal(sign: .plus, exponent: -decimal, significand: significand)

            if transaction.from == transaction.to {
                type = .sentToSelf
            } else if amount < 0 {
                type = .outgoing
            } else {
                type = .incoming
            }
        }
        
        let txHash = transaction.hash.toHexString()

        return TransactionRecord(
                uid: txHash + contractAddress.hex,
                transactionHash: txHash,
                transactionIndex: receipt?.transactionIndex ?? 0,
                interTransactionIndex: receipt?.transactionIndex ?? 0,
                type: type,
                blockHeight: receipt?.blockNumber,
                confirmationsThreshold: confirmationsThreshold,
                amount: abs(amount),
                fee: nil,
                date: Date(timeIntervalSince1970: Double(transaction.timestamp)),
                failed: fullTransaction.failed,
                from: transaction.from.eip55,
                to: transaction.to?.eip55,
                lockInfo: nil,
                conflictingHash: nil,
                showRawTransaction: false,
                memo: nil
        )
    }

}

extension Evm20Adapter: IAdapter {

    func start() {
        evm20Kit.start()
    }

    func stop() {
        evm20Kit.stop()
    }

    func refresh() {
        evm20Kit.refresh()
    }

    var debugInfo: String {
        evmKit.debugInfo
    }

}

extension Evm20Adapter: IBalanceAdapter {

    var balanceState: AdapterState {
        convertToAdapterState(evmSyncState: evm20Kit.syncState)
    }

    var balanceStateUpdatedObservable: Observable<Void> {
        evm20Kit.syncStateObservable.map { _ in () }
    }

    var balance: Decimal {
        balanceDecimal(kitBalance: evm20Kit.balance, decimal: decimal)
    }

    var balanceUpdatedObservable: Observable<Void> {
        evm20Kit.balanceObservable.map { _ in () }
    }

}

extension Evm20Adapter: ISendEthereumAdapter {

    func transactionData(amount: BigUInt, address: EthereumKit.Address) -> TransactionData {
        evm20Kit.transferTransactionData(to: address, value: amount)
    }

}

extension Evm20Adapter: IErc20Adapter {

    var pendingTransactions: [TransactionRecord] {
        evm20Kit.pendingTransactions().map { transactionRecord(fromTransaction: $0) }
    }

    func allowanceSingle(spenderAddress: EthereumKit.Address, defaultBlockParameter: DefaultBlockParameter = .latest) -> Single<Decimal> {
        evm20Kit.allowanceSingle(spenderAddress: spenderAddress, defaultBlockParameter: defaultBlockParameter)
                .map { [unowned self] allowanceString in
                    if let significand = Decimal(string: allowanceString) {
                        return Decimal(sign: .plus, exponent: -self.decimal, significand: significand)
                    }

                    return 0
                }
    }

}

extension Evm20Adapter: ITransactionsAdapter {
    var coin: Coin {
        Coin(type: .erc20(address: contractAddress.hex), code: "ERC20", name: "ERC20 token", decimal: 0, iconUrl: String())
    }

    var transactionState: AdapterState {
        convertToAdapterState(evmSyncState: evm20Kit.transactionsSyncState)
    }

    var transactionStateUpdatedObservable: Observable<Void> {
        evm20Kit.transactionsSyncStateObservable.map { _ in () }
    }

    var transactionRecordsObservable: Observable<[TransactionRecord]> {
        evm20Kit.transactionsObservable.map { [weak self] in
            $0.compactMap { self?.transactionRecord(fromTransaction: $0) }
        }
    }

    func transactionsSingle(from: TransactionRecord?, limit: Int) -> Single<[TransactionRecord]> {
        do {
            let fromData = from.flatMap { record in
                Data(hex: record.transactionHash)
            }
            return try evm20Kit.transactionsSingle(from: fromData, limit: limit)
                    .map { [weak self] transactions -> [TransactionRecord] in
                        transactions.compactMap { self?.transactionRecord(fromTransaction: $0) }
                    }
        } catch {
            return Single.error(error)
        }
    }

    func rawTransaction(hash: String) -> String? {
        nil
    }

}
