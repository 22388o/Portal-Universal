//
//  BaseEthereumAdapter.swift
//  Portal
//
//  Created by Farid on 10.07.2021.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import EthereumKit
import Combine
import BigInt
import HsToolKit

class BaseEthereumAdapter {
    let ethereumKit: EthereumKit.Kit

    let decimal: Int

    init(kit: EthereumKit.Kit, decimal: Int) {
        self.ethereumKit = kit
        self.decimal = decimal
    }

    func balanceDecimal(kitBalance: BigUInt?, decimal: Int) -> Decimal {
        guard let kitBalance = kitBalance else {
            return 0
        }

        guard let significand = Decimal(string: kitBalance.description) else {
            return 0
        }

        return Decimal(sign: .plus, exponent: -decimal, significand: significand)
    }

    func convertToAdapterState(evmSyncState: EthereumKit.SyncState) -> AdapterState {
        switch evmSyncState {
            case .synced: return .synced
            case .notSynced(let error): return .notSynced(error: error)
            case .syncing: return .syncing(progress: 50, lastBlockDate: nil)
        }
    }

}

// ITransactionsAdapter
extension BaseEthereumAdapter {

    var lastBlockInfo: LastBlockInfo? {
        ethereumKit.lastBlockHeight.map { LastBlockInfo(height: $0, timestamp: nil, headerHash: nil) }
    }
    
    var lastBlockUpdated: AnyPublisher<LastBlockInfo?, Never> {
        ethereumKit.lastBlockHeightObservable.map {
            LastBlockInfo(height: $0, timestamp: nil, headerHash: nil)
        }.publisher.catch { _ in Just(nil) }.eraseToAnyPublisher()
    }

}

extension BaseEthereumAdapter: IDepositAdapter {

    var receiveAddress: String {
        ethereumKit.receiveAddress.eip55
    }

}
