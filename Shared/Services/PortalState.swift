//
//  PortalState.swift
//  Portal
//
//  Created by Farid on 19.07.2021.
//

import SwiftUI
import Combine

class PortalState: ObservableObject {
    enum State {
        case idle, currentAccount, createAccount, restoreAccount
    }
    
    @Published var current: State = .idle
    @Published var receiveAsset: Bool = false
    @Published var sendAsset: Bool = false
    @Published var switchWallet: Bool = false
    @Published var createAlert: Bool = false
    @Published var allTransactions: Bool = false
    @Published var allNotifications: Bool = false
    @Published var searchRequest = String()
    @Published var modalViewIsPresented: Bool = false
    @Published var exchangeSceneState: PortalExchangeSceneState = .full
    @Published var loading: Bool = false
    
    @Published var mainScene: Scenes = .wallet
    
    @Published var selectedCoin: Coin = Coin.bitcoin()
    @Published var fiatCurrency: FiatCurrency = USD
    
    private var anyCancellable = Set<AnyCancellable>()
    
    var scaleEffectRation: CGFloat {
        if switchWallet {
            return 0.45
        } else if receiveAsset || sendAsset || allTransactions || createAlert {
            return 0.98
        } else {
            return 1
        }
    }
    
    init() {
        #if os(macOS)
        self.exchangeSceneState = .full
        #else
        self.exchangeSceneState = UIScreen.main.bounds.width > 1180 ? .full : .compactRight
        #endif

        Publishers.MergeMany($receiveAsset, $sendAsset, $switchWallet, $allTransactions, $createAlert, $allNotifications)
            .sink { [weak self] output in
                self?.modalViewIsPresented = output
            }
            .store(in: &anyCancellable)
    }
}
