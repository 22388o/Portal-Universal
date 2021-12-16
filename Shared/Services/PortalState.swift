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
    
    enum ModalViewState: Equatable {
        case none,
             receiveAsset,
             sendAsset,
             switchAccount,
             createAlert,
             allTransactions,
             allNotifications,
             accountSettings,
             withdrawFromExchange(balance: ExchangeBalanceModel)
    }
    
    @Published var current: State = .idle
    @Published var searchRequest = String()
    @Published var exchangeSceneState: PortalExchangeSceneState = .full
    @Published var loading: Bool = false
    
    @Published var mainScene: Scenes = .wallet
    
    @Published var selectedCoin: Coin = Coin.bitcoin()
    @Published var walletCurrency: Currency = .fiat(USD)
    
    @Published var modalView: ModalViewState = .none
    
    private var anyCancellable = Set<AnyCancellable>()
    #if os(iOS)
    @Published var orientation = UIDeviceOrientation.unknown
    #endif
        
    init() {
        #if os(macOS)
        self.exchangeSceneState = .full
        #else
        self.exchangeSceneState = UIScreen.main.bounds.width > 1180 ? .full : .compactRight
        
        self.orientation = UIDevice.current.orientation

        NotificationCenter
            .default
            .publisher(for: UIDevice.orientationDidChangeNotification)
            .map { _ in
                UIDevice.current.orientation
            }
            .sink { [weak self] orientation in
                if orientation.isValidInterfaceOrientation {
                    self?.orientation = orientation
                }
            }
            .store(in: &anyCancellable)
        #endif
    }
}
