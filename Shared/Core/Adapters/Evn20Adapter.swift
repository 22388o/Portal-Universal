//
//  Evn20Adapter.swift
//  Portal
//
//  Created by Farid on 16.07.2021.
//
import Combine
import RxCombine
import RxSwift
import EthereumKit
import Erc20Kit
import BigInt
import HsToolKit
import class Erc20Kit.Transaction

class Evm20Adapter: BaseEvmAdapter {
    let evm20Kit: Erc20Kit.Kit
    private let confirmationsThreshold: Int
    private let contractAddress: EthereumKit.Address

    init(evmKit: EthereumKit.Kit, contractAddress: String, decimal: Int, confirmationsThreshold: Int) throws {
        let address = try EthereumKit.Address(hex: contractAddress)
        evm20Kit = try Erc20Kit.Kit.instance(ethereumKit: evmKit, contractAddress: address)
        self.contractAddress = address
        self.confirmationsThreshold = confirmationsThreshold

        super.init(evmKit: evmKit, decimal: decimal)
    }

    private func transactionRecord(fromTransaction fullTransaction: FullTransaction) -> TransactionRecord {
        let transaction = fullTransaction.transaction
        let receipt = fullTransaction.receiptWithLogs?.receipt

        var type: TransactionType = .sentToSelf
        var amount: Decimal = 0

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
    var balanceStateUpdated: AnyPublisher<Void, Never> {
        evm20Kit.syncStateObservable.map { _ in () }.publisher.catch { _ in Just(()) }.eraseToAnyPublisher()
    }
    
    var balanceUpdated: AnyPublisher<Void, Never> {
        evm20Kit.balanceObservable.map { _ in () }.publisher.catch { _ in Just(()) }.eraseToAnyPublisher()
    }
    
    var balanceState: AdapterState {
        convertToAdapterState(evmSyncState: evm20Kit.syncState)
    }

    var balance: Decimal {
        balanceDecimal(kitBalance: evm20Kit.balance, decimal: decimal)
    }
}

extension Evm20Adapter: ISendEthereumAdapter {
    func send(address: Address, value: BigUInt, transactionInput: Data, gasPrice: Int, gasLimit: Int, nonce: Int?) -> Future<FullTransaction, Error> {
        Future { promiss in
            
        }
    }

    func transactionData(amount: BigUInt, address: EthereumKit.Address) -> TransactionData {
        evm20Kit.transferTransactionData(to: address, value: amount)
    }

}

extension Evm20Adapter: IErc20Adapter {

    var pendingTransactions: [TransactionRecord] {
        evm20Kit.pendingTransactions().map { transactionRecord(fromTransaction: $0.fullTransaction) }
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
    
    var transactionStateUpdated: AnyPublisher<Void, Never> {
        evm20Kit
            .transactionsSyncStateObservable
            .map { _ in () }
            .publisher.catch { _ in Just(()) }
            .eraseToAnyPublisher()
    }
    
    var transactionRecords: AnyPublisher<[TransactionRecord], Never> {
        evm20Kit.transactionsObservable.map { [weak self] in
            $0.compactMap { self?.transactionRecord(fromTransaction: $0.fullTransaction) }
        }
        .publisher.catch { _ in Just([]) }
        .eraseToAnyPublisher()
    }
    
    func transactions(from: TransactionRecord?, limit: Int) -> Future<[TransactionRecord], Never> {
        Future { [weak self] promisse in
            let disposeBag = DisposeBag()
            
            try? self?.evm20Kit.transactionsSingle(from: nil, limit: nil)
                .map { transactions -> [TransactionRecord] in
                    transactions.compactMap { self?.transactionRecord(fromTransaction: $0.fullTransaction) }
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
