//
//  AccountsViewModel.swift
//  Portal
//
//  Created by Farid on 27.08.2021.
//

import Foundation
import Combine

class AccountsViewModel: ObservableObject {
    private let manager: IAccountManager
    
    @Published var state: PortalState
    @Published var showDeletionAlert: Bool = false
    @Published var accountToDelete: Account?
    
    @Published private(set) var accounts: [Account] = []
    @Published private(set) var activeAcount: Account?
    
    init(accountManager: IAccountManager, state: PortalState) {
        self.manager = accountManager
        self.state = state
        
        accounts = manager.accounts
        activeAcount = manager.activeAccount
    }
    
    func switchAccount(account: Account) {
        state.loading = true
        setActiveAccount(id: account.id)
        state.modalView = .none
    }
    
    func setActiveAccount(id: String) {
        DispatchQueue.main.async {
            self.manager.setActiveAccount(id: id)
            self.activeAcount = self.manager.activeAccount
            self.state.wallet.coin = Coin.bitcoin()
        }
    }
    
    func delete(account: Account) {
        manager.delete(account: account)
    }
    
    deinit {
//        print("Deinit")
    }
}

extension AccountsViewModel {
    static func config() -> AccountsViewModel {
        let accountManager = Portal.shared.accountManager
        let state = Portal.shared.state
        return AccountsViewModel(accountManager: accountManager, state: state)
    }
}
