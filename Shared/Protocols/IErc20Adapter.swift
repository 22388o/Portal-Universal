//
//  IErc20Adapter.swift
//  Portal
//
//  Created by Farid on 16.07.2021.
//

import Foundation

protocol IErc20Adapter {
    var pendingTransactions: [TransactionRecord] { get }
    func allowanceSingle(spenderAddress: EthereumKit.Address, defaultBlockParameter: DefaultBlockParameter) -> Single<Decimal>
}
