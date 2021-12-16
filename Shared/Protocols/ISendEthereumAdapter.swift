//
//  ISendEthereumAdapter.swift
//  Portal
//
//  Created by Farid on 16.07.2021.
//

import Foundation
import EthereumKit
import BigInt
import Combine

protocol ISendEthereumAdapter {
    var balance: Decimal { get }
    func transactionData(amount: BigUInt, address: EthereumKit.Address) -> TransactionData
    func send(address: Address, value: BigUInt, transactionInput: Data, gasPrice: Int, gasLimit: Int, nonce: Int?) -> Future<FullTransaction, Error>
}
