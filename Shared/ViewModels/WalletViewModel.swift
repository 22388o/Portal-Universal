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
            .receive(on: DispatchQueue.global())
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                let configuredItems = self.configuredItems()
                
                DispatchQueue.main.async {
                    self.items = configuredItems
                }
            }
            .store(in: &cancellables)
    }
    
    private func configuredItems() -> [WalletItem] {
        walletManager.activeWallets.compactMap({ wallet in
            let coin = wallet.coin
            guard let adapter = adapterManager.balanceAdapter(for: wallet) else { return nil }
            let viewModel = AssetItemViewModel(coin: coin, adapter: adapter, selectedTimeFrame: .day, fiatCurrency: USD, ticker: marketDataProvider.ticker(coin: coin))
            return WalletItem(coin: coin, viewModel: viewModel)
        })
    }
    
    deinit {
        print("WalletViewModel deinited")
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

