//
//  IAcountManager.swift
//  Portal
//
//  Created by Farid on 19.07.2021.
//

import Foundation
import Combine

protocol IAccountManager {
    var onActiveAccountUpdatePublisher: PassthroughSubject<Account?, Never> { get }
    var accounts: [Account] { get }
    var activeAccount: Account? { get }
    func account(id: String) -> Account?
    func updateWalletCurrency(code: String)
    func setActiveAccount(id: String)
    func save(account: Account)
    func update(account: Account)
    func delete(account: Account)
    func delete(accountId: String)
    func clear()
}

