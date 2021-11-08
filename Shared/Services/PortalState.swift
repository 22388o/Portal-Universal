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
    @Published var accountSettings: Bool = false
    @Published var searchRequest = String()
    @Published var modalViewIsPresented: Bool = false
    @Published var exchangeSceneState: PortalExchangeSceneState = .full
    @Published var loading: Bool = false
    
    @Published var mainScene: Scenes = .wallet
    
    @Published var selectedCoin: Coin = Coin.bitcoin()
    @Published var fiatCurrency: FiatCurrency = USD
    
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

        Publishers.MergeMany($receiveAsset, $sendAsset, $switchWallet, $allTransactions, $createAlert, $allNotifications, $accountSettings)
            .sink { [weak self] output in
                self?.modalViewIsPresented = output
            }
            .store(in: &anyCancellable)
    }
    
    func dismissModalView() {
        receiveAsset = false
        sendAsset = false
        switchWallet = false
        allTransactions = false
        createAlert = false
        allNotifications = false
        accountSettings = false
    }

}
