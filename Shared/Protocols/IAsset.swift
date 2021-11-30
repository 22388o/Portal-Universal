//
//  IAsset.swift
//  Portal
//
//  Created by Farid on 18.05.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation
import BitcoinCore
import Combine

protocol IAsset {
    var id: UUID { get }
    var coin: Coin { get }
    var adapter: IAdapter? { get }
    var sendBtcAdapter: ISendBitcoinAdapter? { get }
    var balanceAdapter: IBalanceAdapter? { get }
    var depositAdapter: IDepositAdapter? { get }
    var transactionAdapter: ITransactionsAdapter? { get }
    var qrCodeProvider: IQRCodeProvider { get }
    func availableBalance(feeRate: Int, address: String?) -> Decimal
    func maximumSendAmount() -> Decimal?
    func minimumSendAmount(address: String?) -> Decimal
    func validate(address: String) throws
    func fee(amount: Decimal, feeRate: Int, address: String?) -> Decimal
    func send(amount: Decimal, address: String, feeRate: Int, sortMode: TransactionDataSortMode) -> Future<Void, Error>
}
