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
    var coinRate: Decimal { get }
    var marketDataProvider: IMarketDataProvider { get }
    var coin: Coin { get }
    var kit: AbstractKit? { get }
    var chartDataProvider: IChartDataProvider { get }
    var balanceProvider: IBalanceProvider { get }
    var marketChangeProvider: IMarketChangeProvider { get }
    var qrCodeProvider: IQRCodeProvider { get }
    var balanceStatePublisher: Published<KitSyncState>.Publisher { get }
    var balanceUpdatedSubject: PassthroughSubject<BalanceInfo, Never> { get }
    var txStatePublisher: Published<KitSyncState>.Publisher { get }
    
    func availableBalance(feeRate: Int, address: String?) -> Decimal
    func maximumSendAmount() -> Decimal?
    func minimumSendAmount(address: String?) -> Decimal
    func validate(address: String) throws
    func fee(amount: Decimal, feeRate: Int, address: String?) -> Decimal
    func send(amount: Decimal, address: String, feeRate: Int, sortMode: TransactionDataSortMode) -> Future<Void, Error>
}
