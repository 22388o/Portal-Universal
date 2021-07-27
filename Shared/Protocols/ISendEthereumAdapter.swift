//
//  ISendEthereumAdapter.swift
//  Portal
//
//  Created by Farid on 16.07.2021.
//

import Foundation
import EthereumKit
import BigInt

protocol ISendEthereumAdapter {
    var evmKit: EthereumKit.Kit { get }
    var balance: Decimal { get }
    func transactionData(amount: BigUInt, address: EthereumKit.Address) -> TransactionData
}
