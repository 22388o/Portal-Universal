//
//  WalletViewModel.swift
//  Portal
//
//  Created by Farid on 20.07.2021.
//

import Foundation
import SwiftUI
import Combine

class WalletViewModel: ObservableObject {
    @Published var items: [WalletItem] = []
    
    var fiatCurrencies: [FiatCurrency] {
        marketDataProvider.fiatCurrencies
    }
        
    private var cancellables = Set<AnyCancellable>()
    private var adapterManager: IAdapterManager
    private var walletManager: IWalletManager
    private var marketDataProvider: IMarketDataProvider
        
    init(walletManager: IWalletManager, adapterManager: IAdapterManager, marketDataProvider: IMarketDataProvider) {
        self.walletManager = walletManager
        self.adapterManager = adapterManager
        self.marketDataProvider = marketDataProvider
        
        subscribe()
    }
    
    private func subscribe() {
        adapterManager.adapterdReadyPublisher
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.items = self.walletManager.activeWallets.compactMap({ wallet in
                    let coin = wallet.coin
                    guard let adapter = self.adapterManager.balanceAdapter(for: wallet) else { return nil }
                    return WalletItem(coin: coin, adapter: adapter)
                })
            }
            .store(in: &cancellables)
    }
    
    deinit {
        print("VM deinited")
    }
}

extension WalletViewModel {
    static func config() -> WalletViewModel {
        let adapterManager = Portal.shared.adapterManager
        let walletManager = Portal.shared.walletManager
        let marketDataProvider = Portal.shared.marketDataProvider
        
        return WalletViewModel(
            walletManager: walletManager,
            adapterManager: adapterManager,
            marketDataProvider: marketDataProvider
        )
    }
}

