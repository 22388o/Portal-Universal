//
//  AccountSettingsViewModel.swift
//  Portal
//
//  Created by Farid on 01.11.2021.
//

import Combine
import BitcoinKit
import EthereumKit

final class AccountSettingsViewModel: ObservableObject {
    private let accountManager: IAccountManager
    private let adapterManager: IAdapterManager
    
    @Published var account: Account
    @Published var btcNetwork: BitcoinKit.Kit.NetworkType = .testNet
    @Published var ethNetwork: EthereumKit.NetworkType = .ropsten
    @Published var ethNetworkString: String = "ropsten"
    @Published var confirmationThreshold: Int = 1
    @Published var canApplyChanges: Bool = false
    
    private var subscriptions = Set<AnyCancellable>()
    
    init(accountManager: IAccountManager, adapterManager: IAdapterManager) {
        self.accountManager = accountManager
        self.adapterManager = adapterManager
        
        guard let account = accountManager.activeAccount else {
            fatalError("Account manager active account is nil")
        }
        
        self.account = account
                
        accountManager
            .onActiveAccountUpdatePublisher
            .sink { [weak self] account in
                guard let self = self, let newAccount = account else { return }
                self.onAccountUpdate(account: newAccount)
            }
            .store(in: &subscriptions)
        
        $ethNetwork
            .sink { [weak self] network in
                if network != self?.ethNetwork {
                    switch network {
                    case .ethMainNet:
                        self?.ethNetworkString = "mainNet"
                    case .kovan:
                        self?.ethNetworkString = "kovan"
                    case .ropsten:
                        self?.ethNetworkString = "ropsten"
                    default:
                        self?.ethNetworkString = "bscMainNet"
                    }
                }
            }
            .store(in: &subscriptions)
        
        Publishers.CombineLatest3($btcNetwork, $ethNetwork, $confirmationThreshold)
            .sink { [weak self] in
                self?.canApplyChanges = account.btcNetworkType != $0 || account.ethNetworkType != $1 || account.confirmationsThreshold != $2
            }
            .store(in: &subscriptions)
        
        onAccountUpdate(account: account)
    }
    
    private func onAccountUpdate(account: Account) {
        self.account = account
        self.btcNetwork = account.btcNetworkType
        self.ethNetwork = account.ethNetworkType
        self.confirmationThreshold = account.confirmationsThreshold
        self.canApplyChanges = false
    }
    
    func applySettings() {
        account.btcNetworkType = btcNetwork
        account.ethNetworkType = ethNetwork
        account.confirmationsThreshold = confirmationThreshold
        
        accountManager.update(account: account)
    }
}

extension AccountSettingsViewModel {
    static func config() -> AccountSettingsViewModel {
        let mannager = Portal.shared.accountManager
        let adapterManager = Portal.shared.adapterManager
        
        return AccountSettingsViewModel(accountManager: mannager, adapterManager: adapterManager)
    }
}
