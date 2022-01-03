//
//  EthereumAdapter.swift
//  Portal
//
//  Created by Farid on 10.07.2021.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import EthereumKit
import RxSwift
import BigInt
import HsToolKit
import Combine

final class EthereumAdapter: BaseEthereumAdapter {
    static let decimal = 18
    private var confirmationsThreshold: Int

    init(ethKit: EthereumKit.Kit, confirmationsThreshold: Int) {
        self.confirmationsThreshold = confirmationsThreshold
        super.init(kit: ethKit, decimal: EthereumAdapter.decimal)
    }

    private func convertAmount(amount: BigUInt, fromAddress: EthereumKit.Address) -> Decimal {
        guard let significand = Decimal(string: amount.description), significand != 0 else {
            return 0
        }

        let fromMine = fromAddress == ethereumKit.receiveAddress
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
                confirmationsThreshold: confirmationsThreshold,
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

extension EthereumAdapter {

    static func clear(except excludedWalletIds: [String]) throws {
        try EthereumKit.Kit.clear(exceptFor: excludedWalletIds)
    }

}

extension EthereumAdapter: IAdapter {

    func start() {
//        evmKit.start()
    }

    func stop() {
//        evmKit.stop()
    }

    func refresh() {
//        evmKit.start()
    }

    var debugInfo: String {
        ethereumKit.debugInfo
    }

}

extension EthereumAdapter: IBalanceAdapter {

    var balanceState: AdapterState {
        convertToAdapterState(evmSyncState: ethereumKit.syncState)
    }

    var balance: Decimal {
        balanceDecimal(kitBalance: ethereumKit.accountState?.balance, decimal: EthereumAdapter.decimal)
    }
    
    var balanceStateUpdated: AnyPublisher<Void, Never> {
        ethereumKit.syncStateObservable.map { _ in() }.publisher.catch { _ in Just(()) }.eraseToAnyPublisher()
    }
    
    var balanceUpdated: AnyPublisher<Void, Never> {
        ethereumKit.accountStateObservable.map { _ in() }.publisher.catch { _ in Just(()) }.eraseToAnyPublisher()
    }
}

extension EthereumAdapter: ISendEthereumAdapter {
    func send(address: Address, value: BigUInt, transactionInput: Data, gasPrice: Int, gasLimit: Int, nonce: Int?) -> Future<FullTransaction, Error> {
        Future { [weak self] promisse in
            let disposeBag = DisposeBag()
            self?.ethereumKit.sendSingle(address: address, value: value, gasPrice: gasPrice, gasLimit: 21000)
                .subscribe(onSuccess: { transaction in
                    promisse(.success(transaction))
                }, onError: { error in
                    promisse(.failure(error))
                })
                .disposed(by: disposeBag)
        }
    }
    
    func transactionData(amount: BigUInt, address: EthereumKit.Address) -> TransactionData {
        ethereumKit.transferTransactionData(to: address, value: amount)
    }

}

extension EthereumAdapter: ITransactionsAdapter {
    var coin: Coin {
        Coin(type: .ethereum, code: "ETH", name: "Etherium", decimal: 18, iconUrl: String())
    }
    
    var transactionState: AdapterState {
        convertToAdapterState(evmSyncState: ethereumKit.transactionsSyncState)
    }
    
    var transactionStateUpdated: AnyPublisher<Void, Never> {
        ethereumKit
            .transactionsSyncStateObservable
            .map { _ in () }
            .publisher.catch { _ in Just(()) }
            .eraseToAnyPublisher()
    }
        
    var transactionRecords: AnyPublisher<[TransactionRecord], Never> {
        ethereumKit.etherTransactionsObservable.map { [weak self] in
            $0.compactMap { self?.transactionRecord(fromTransaction: $0) }
        }
        .publisher.catch { _ in Just([]) }
        .eraseToAnyPublisher()
    }
    
    func transactions(from: TransactionRecord?, limit: Int) -> Future<[TransactionRecord], Never> {
        Future { [weak self] promisse in
            let disposeBag = DisposeBag()
            
            self?.ethereumKit.etherTransactionsSingle(fromHash: from.flatMap { Data(hex: $0.transactionHash) }, limit: limit)
                    .map { transactions -> [TransactionRecord] in
                        transactions.compactMap {
                            self?.transactionRecord(fromTransaction: $0)
                        }
                    }
                    .subscribe(onSuccess: { records in
                        promisse(.success(records))
                    })
                    .disposed(by: disposeBag)
        }
    }

    func rawTransaction(hash: String) -> String? {
        nil
    }

}
