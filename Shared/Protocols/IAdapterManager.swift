//
//  IAdapterManager.swift
//  Portal
//
//  Created by Farid on 19.07.2021.
//

import Foundation
import RxSwift
import Combine

protocol IAdapterManager: AnyObject {
    var adapterdReadyPublisher: CurrentValueSubject<Bool, Never> { get }
    func adapter(for wallet: Wallet) -> IAdapter?
    func adapter(for coin: Coin) -> IAdapter?
    func balanceAdapter(for wallet: Wallet) -> IBalanceAdapter?
    func transactionsAdapter(for wallet: Wallet) -> ITransactionsAdapter?
    func depositAdapter(for wallet: Wallet) -> IDepositAdapter?
    func refresh()
    func refreshAdapters(wallets: [Wallet])
    func refresh(wallet: Wallet)
}

protocol IAdapterFactory {
    func adapter(wallet: Wallet) -> IAdapter?
}
