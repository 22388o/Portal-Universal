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
    func account(id: UUID) -> Account?
    func createAccount(model: NewAccountModel) -> Account?
    func createNewAccount(model: NewAccountModel)
    func setActiveAccount(id: UUID)
    func save(account: Account)
    func delete(account: Account)
    func delete(accountId: String)
    func clear()
}
