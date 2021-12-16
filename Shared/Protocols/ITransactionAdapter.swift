//
//  ITransactionAdapter.swift
//  Portal
//
//  Created by Farid on 13.07.2021.
//

import Foundation
import Combine

protocol ITransactionsAdapter {
    var coin: Coin { get }
    var transactionState: AdapterState { get }
    var lastBlockInfo: LastBlockInfo? { get }
    var transactionStateUpdatedPublisher: AnyPublisher<Void, Never> { get }
    var lastBlockUpdatedPublisher: AnyPublisher<Void, Never> { get }
    var transactionRecordsPublisher: AnyPublisher<[TransactionRecord], Never> { get }
    func transactions(from: TransactionRecord?, limit: Int) -> Future<[TransactionRecord], Never>
    func rawTransaction(hash: String) -> String?
}
