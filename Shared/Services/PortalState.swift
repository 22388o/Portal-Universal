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
        case currentWallet, createWallet, restoreWallet
    }
    
    @Published var current: State = .createWallet
    @Published var receiveAsset: Bool = false
    @Published var sendAsset: Bool = false
    @Published var switchWallet: Bool = false
    @Published var createAlert: Bool = false
    @Published var allTransactions: Bool = false
    @Published var allNotifications: Bool = false
    @Published var searchRequest = String()
    @Published var modalViewIsPresented: Bool = false
    @Published var sceneState: WalletSceneState
    
    @Published var mainScene: Scenes = .wallet
    
    @Published var selectedCoin: Coin = Coin.bitcoin()
    
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
    
    init() {
        self.sceneState = UIScreen.main.bounds.width > 1180 ? .full : .walletAsset

        Publishers.MergeMany($receiveAsset, $sendAsset, $switchWallet, $allTransactions, $createAlert)
            .sink { [weak self] output in
                self?.modalViewIsPresented = output
            }
            .store(in: &anyCancellable)
    }
}
