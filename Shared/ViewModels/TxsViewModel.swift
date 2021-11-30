//
//  TxsViewModel.swift
//  Portal
//
//  Created by Farid on 24.06.2021.
//

import Foundation
import BitcoinCore
import RxSwift
import Combine

final class TxsViewModel: ObservableObject {
    private let disposeBag = DisposeBag()
    private var cancellable: AnyCancellable?
    let coin: Coin
    private var allTxs: [TransactionRecord] = [] {
        didSet {
            updateTxList()
        }
    }
    
    @Published private(set) var txs: [TransactionRecord] = []
    @Published var txSortState: TxSortState = .all
    var lastBlockInfo: LastBlockInfo?
    
    private var transactionAdapter: ITransactionsAdapter
    private var balance: Decimal
    
    var balanceString: String {
        return "\(balance) \(coin.code)"
    }
    
    func title(tx: TransactionRecord) -> String {
        switch tx.type {
        case .incoming:
            return "Received \(tx.amount.double.rounded(toPlaces: 6)) \(coin.code)"
        case .outgoing:
            return "Sent \(tx.amount.double.rounded(toPlaces: 6)) \(coin.code)"
        case .sentToSelf:
            return "Send to self \(tx.amount.double.rounded(toPlaces: 6)) \(coin.code)"
        case .approve:
            return "Approving... \(tx.amount.double.rounded(toPlaces: 6)) \(coin.code)"
        case .transfer:
            return "Trasfer... \(tx.amount.double.rounded(toPlaces: 6)) \(coin.code)"
        }
    }
    
    func date(tx: TransactionRecord) -> String {
        tx.date.timeAgoSinceDate(shortFormat: true)
    }
    
    func confimations(tx: TransactionRecord) -> String {
        "\(tx.confirmations(lastBlockHeight: transactionAdapter.lastBlockInfo?.height)) confirmations"
    }
    
    init(coin: Coin, balance: Decimal, transactionAdapter: ITransactionsAdapter) {
        self.coin = coin
        self.balance = balance
        self.transactionAdapter = transactionAdapter
        self.lastBlockInfo = transactionAdapter.lastBlockInfo
        
        cancellable = $txSortState
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                self?.updateTxList()
            }
        
        transactionAdapter.transactionRecordsObservable
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] records in
                self?.allTxs = records
            })
            .disposed(by: disposeBag)
        
        transactionAdapter.transactionsSingle(from: nil, limit: 100)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] records in
                self?.allTxs = records
            })
            .disposed(by: disposeBag)
    }
    
    func updateTxList() {
        switch txSortState {
        case .all:
            txs = allTxs
        case .sent:
            txs = allTxs.filter{ $0.type == .outgoing }
        case .received:
            txs = allTxs.filter{ $0.type == .incoming }
        case .swapped:
            txs = []
        }
    }
    
    deinit {
//        print("Tx view Model deinited")
    }
}

extension TxsViewModel {
    static func config(coin: Coin) -> TxsViewModel? {
        let walletManager: IWalletManager = Portal.shared.walletManager
        let adapterManager: IAdapterManager = Portal.shared.adapterManager
        
        guard
            let wallet = walletManager.activeWallets.first(where: { $0.coin == coin }),
            let balanceAdapter = adapterManager.balanceAdapter(for: wallet),
            let transactionAdapter = adapterManager.transactionsAdapter(for: wallet)
        else {
            return nil
        }
        
        return TxsViewModel(coin: coin, balance: balanceAdapter.balance, transactionAdapter: transactionAdapter)
    }
}
