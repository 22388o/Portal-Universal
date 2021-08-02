//
//  Portal.swift
//  Portal
//
//  Created by Farid on 15.07.2021.
//

import Foundation
import KeychainAccess
import Combine

final class Portal: ObservableObject {
    static let shared = Portal()
        
    private var anyCancellables: Set<AnyCancellable> = []

    private let localStorage: ILocalStorage
    private let secureStorage: IKeychainStorage
    
    let appConfigProvider: IAppConfigProvider
    let accountManager: IAccountManager
    let walletManager: IWalletManager
    let marketDataProvider: MarketDataProvider
    let notificationService: NotificationService
    let feeRateProvider: FeeRateProvider
    let ethereumKitManager: EthereumKitManager
    let adapterManager: AdapterManager
    
    @Published var state = PortalState()
        
    private init() {
        appConfigProvider = AppConfigProvider()
        
        localStorage = LocalStorage()
        
        let keychain = Keychain(service: appConfigProvider.keychainStorageID)
        secureStorage = KeychainStorage(keychain: keychain)
        
        let bdContext = PersistenceController.shared.container.viewContext
        let bdStorage: IDBStorage & IAccountStorage = DBlocalStorage(context: bdContext)
        
        if localStorage.isFirstLaunch {
            localStorage.removeCurrentAccountID()
            try? secureStorage.clear()
            bdStorage.clear()
        }
        
        localStorage.incrementAppLaunchesCouner()
        
        feeRateProvider = FeeRateProvider(appConfigProvider: appConfigProvider)
        
        let marketDataUpdater = MarketDataUpdater()
        
        let fiatCurrenciesUpdater = FiatCurrenciesUpdater(
            interval: TimeInterval(appConfigProvider.fiatCurrenciesUpdateInterval),
            fixerApiKey: appConfigProvider.fixerApiKey
        )
        
        let pricesDataUpdater = PricesDataUpdater(interval: TimeInterval(appConfigProvider.pricesUpdateInterval))
        
        let marketDataRepository = MarketDataRepository(
            mdUpdater: marketDataUpdater,
            fcUpdater: fiatCurrenciesUpdater,
            pdUpdater: pricesDataUpdater
        )
        
        marketDataProvider = MarketDataProvider(repository: marketDataRepository)
                        
        let accountStorage = AccountStorage(localStorage: localStorage, secureStorage: secureStorage, storage: bdStorage)
        accountManager = AccountManager(accountStorage: accountStorage)
        
        let coinStorage = CoinStorage(marketData: marketDataRepository)
        let coinManager: ICoinManager = CoinManager(storage: coinStorage)
        
        let walletStorage: IWalletStorage = WalletStorage(coinManager: coinManager, accountManager: accountManager)
        walletManager = WalletManager(accountManager: accountManager, storage: walletStorage)
        
        ethereumKitManager = EthereumKitManager(appConfigProvider: appConfigProvider)
        
        let adapterFactory = AdapterFactory(appConfigProvider: appConfigProvider, ethereumKitManager: ethereumKitManager)
        adapterManager = AdapterManager(adapterFactory: adapterFactory, ethereumKitManager: ethereumKitManager, walletManager: walletManager)
        
        notificationService = NotificationService(adapterManager: adapterManager)
                        
        marketDataRepository.$dataReady
            .sink(receiveValue: { [weak self] ready in
                if !ready {
                    self?.state.loading = true
                }
            })
            .store(in: &anyCancellables)
        
        adapterManager.adapterdReadyPublisher
            .sink { [weak self] ready in
                if ready && self?.accountManager.activeAccount != nil {
                    if self?.state.current != .currentAccount {
                        self?.state.current = .currentAccount
                    }
                }
            }
            .store(in: &anyCancellables)
        
        coinManager.onCoinsUpdatePublisher
            .debounce(for: 2, scheduler: RunLoop.main)
            .sink(receiveValue: { [weak self] coins in
                if !coins.isEmpty {
                    self?.state.loading = false
                    self?.state.selectedCoin = Coin.bitcoin()
                }
            })
            .store(in: &anyCancellables)
    }
    
    func onTerminate() {

    }
    
    func didEnterBackground() {

    }
    
    func didBecomeActive() {

    }
}

