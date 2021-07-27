//
//  ITransactionAdapter.swift
//  Portal
//
//  Created by Farid on 13.07.2021.
//

import Foundation
import RxSwift

protocol ITransactionsAdapter {
    var coin: Coin { get }
    var transactionState: AdapterState { get }
    var transactionStateUpdatedObservable: Observable<Void> { get }
    var lastBlockInfo: LastBlockInfo? { get }
    var lastBlockUpdatedObservable: Observable<Void> { get }
    var transactionRecordsObservable: Observable<[TransactionRecord]> { get }
    func transactionsSingle(from: TransactionRecord?, limit: Int) -> Single<[TransactionRecord]>
    func rawTransaction(hash: String) -> String?
}
