//
//  WalletSceneViewModel.swift
//  Portal
//
//  Created by Farid on 24.06.2021.
//

import Combine
import SwiftUI
import Foundation

final class WalletSceneViewModel: ObservableObject {
    @Published var walletName: String
    @Published var selectedAsset: IAsset
    @Published var wallet: IWallet
    
    @Published var receiveAsset: Bool = false
    @Published var sendAsset: Bool = false
    @Published var switchWallet: Bool = false
    @Published var createAlert: Bool = false
    @Published var allTransactions: Bool = false
    @Published var allNotifications: Bool = false
    @Published var searchRequest = String()
    @Published var sceneState: WalletSceneState
            
    @Published var modalViewIsPresented: Bool = false
    @Published var fiatCurrency: FiatCurrency
    
    @ObservedObject var portfolioViewModel: PortfolioViewModel
    
    @Published private(set) var fiatCurrencies: [FiatCurrency] = []
    
    private var anyCancellable = Set<AnyCancellable>()
        
    var scaleEffectRation: CGFloat {
        if switchWallet {
            return 0.45
        } else if receiveAsset || sendAsset || allTransactions || createAlert {
            return 0.9
        } else {
            return 1
        }
    }
    
    init(wallet: IWallet, userCurrrency: FiatCurrency, allCurrencies: [FiatCurrency]) {
        print("WalletViewModel init")
        self.fiatCurrency = userCurrrency
        
        self.wallet = wallet
        self.walletName = wallet.name
        self.selectedAsset = wallet.assets.first ?? Asset.bitcoin()
        self.portfolioViewModel = .init(assets: wallet.assets)
        self.sceneState = UIScreen.main.bounds.width > 1180 ? .full : .walletAsset
        self.fiatCurrencies = allCurrencies
        
        Publishers.MergeMany($receiveAsset, $sendAsset, $switchWallet, $allTransactions, $createAlert)
            .sink { [weak self] output in
                self?.modalViewIsPresented = output
            }
            .store(in: &anyCancellable)
        
        print("wallet name: \(wallet.name)")
                                
        $fiatCurrency.sink { (currency) in
            let walletCurrencyCode = wallet.fiatCurrencyCode
            if currency.code != walletCurrencyCode {
                wallet.updateFiatCurrency(currency)
            }
        }
        .store(in: &anyCancellable)
    }
    
    deinit {
        print("WalletScene view model deinit")
    }
}
