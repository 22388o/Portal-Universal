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
    private var allTxs: [PortalTx] = []
    
    @Published private(set) var txs: [PortalTx] = []
    @Published var txSortState: TxSortState = .all
    
    var balanceString: String {
        let balanceInSat = asset.kit?.balance.spendable ?? 0
        let coinRate = asset.coinRate
        let balance = Decimal(balanceInSat)/coinRate
        
        return "\(balance) \(asset.coin.code)"
    }
    
    init(asset: IAsset) {
        self.asset = asset
        
        self.asset.kit?.transactions()
            .subscribe{ [weak self] response in
                switch response {
                case .success(let txs):
                    self?.allTxs = txs.map{ PortalTx(transaction: $0, lastBlockInfo: self?.asset.kit?.lastBlockInfo) }
                case .error(let error):
                    print(error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
        
        cancellable = $txSortState.removeDuplicates().sink { [weak self] state in
            switch state {
            case .all:
                self?.txs = self?.allTxs ?? []
            case .sent:
                self?.txs = self?.allTxs.filter{ $0.destination == .outgoing } ?? []
            case .received:
                self?.txs = self?.allTxs.filter{ $0.destination == .incoming } ?? []
            case .swapped:
                self?.txs = []
            }
        }
    }
}
