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
    private let asset: IAsset
    private var allTxs: [TransactionRecord] = [] {
        didSet {
            updateTxList()
        }
    }
    
    @Published private(set) var txs: [TransactionRecord] = []
    @Published var txSortState: TxSortState = .all
    
    var balanceString: String {
        return "\(asset.balanceAdapter?.balance ?? 0) \(asset.coin.code)"
    }
    
    init(asset: IAsset) {
        self.asset = asset
        
        cancellable = $txSortState
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                self?.updateTxList()
            }
        
        asset.transactionAdaper?.transactionRecordsObservable
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] records in
                self?.allTxs = records
            })
            .disposed(by: disposeBag)
        
        asset.transactionAdaper?.transactionsSingle(from: nil, limit: 100)
            .asObservable()
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] records in
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
        print("Tx view Model deinited")
    }
}
