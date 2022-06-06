//
//  PortalState.swift
//  Portal
//
//  Created by Farid on 19.07.2021.
//

import SwiftUI
import Combine

class WalletState: ObservableObject {
    @Published var search = String()
    @Published var coin: Coin = Coin.bitcoin()
    @Published var currency: Currency = .fiat(USD)
    @Published var switchState: HeaderSwitchState = .wallet
}

class ExchangeState: ObservableObject {
    @Published var mode: ExchangeViewMode
    
    init() {
        #if os(macOS)
        mode = .full
        #else
        mode = UIScreen.main.bounds.width > 1180 ? .full : .compactRight
        #endif
    }
}

class PortalState: ObservableObject {
    enum Scene {
        case idle, account, createAccount, restoreAccount
    }
    
    enum ModalViewState: Equatable {
        case none,
             manageAssets,
             receiveAsset,
             sendAsset,
             switchAccount,
             createAlert,
             allTransactions(selectedTx: TransactionRecord?),
             allNotifications,
             accountSettings,
             withdrawFromExchange(balance: ExchangeBalanceModel),
             channels
    }
        
    @Published var showPortfolio: Bool = true
    @Published var rootView: Scene = .idle
    @Published var loading: Bool = true
    @Published var modalView: ModalViewState = .none
    
    @ObservedObject var wallet: WalletState = WalletState()
    @ObservedObject var exchange: ExchangeState = ExchangeState()
    
    var onAssetBalancesUpdate = PassthroughSubject<Void, Never>()
    
    private(set) var userId: String
    private var anyCancellable = Set<AnyCancellable>()
    
    #if os(iOS)
    @Published var orientation = UIDeviceOrientation.unknown
    #endif
        
    init(userId: String = UUID().uuidString) {
        self.userId = userId
        
        #if os(iOS)
        orientation = UIDevice.current.orientation

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
