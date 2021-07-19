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
        
    let appConfigProvider: IAppConfigProvider
    let accountManager: IAccountManager
    let walletManager: IWalletManager
    let marketDataProvider: MarketDataProvider
    let localStorage: ILocalStorage
    let secureStorage: IKeychainStorage
    let notificationService: NotificationService
    let feeRateProvider: FeeRateProvider
    let ethereumKitManager: EthereumKitManager
    let adapterManager: AdapterManager
    
    @Published var state = PortalState()
    
    @Published private(set) var marketDataReady: Bool = false
    
    private var anyCancellables: Set<AnyCancellable> = []

    private init() {
        
        appConfigProvider = AppConfigProvider()
        
        localStorage = LocalStorage()
        
        let keychain = Keychain(service: appConfigProvider.keychainStorageID)
        secureStorage = KeychainStorage(keychain: keychain)
                
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
        
        let bdContext = PersistenceController.shared.container.viewContext
        let bdStorage: IDBStorage & IIDBStorage = DBlocalStorage(context: bdContext)
        
        accountManager = AccountManager(dbStorage: bdStorage, secureStorage: secureStorage, localStorage: localStorage)

        notificationService = NotificationService()
                
        let coinManager: ICoinManager = CoinManager()
        let walletStorage: IWalletStorage = WalletStorage(coinManager: coinManager, accountManager: accountManager)
        walletManager = WalletManager(accountManager: accountManager, storage: walletStorage)
        
        ethereumKitManager = EthereumKitManager(appConfigProvider: appConfigProvider)
        
        let adapterFactory = AdapterFactory(appConfigProvider: appConfigProvider, ethereumKitManager: ethereumKitManager)
        adapterManager = AdapterManager(adapterFactory: adapterFactory, ethereumKitManager: ethereumKitManager, walletManager: walletManager)
        
        if accountManager.activeAccount != nil {
            state.current = .currentWallet
        }
                        
        if localStorage.isFirstLaunch {
            localStorage.removeCurrentWalletID()
            try? secureStorage.clear()
            bdStorage.clear()
        }
        
        localStorage.incrementAppLaunchesCouner()
                        
        marketDataRepository.$tickersReady
            .sink(receiveValue: { [unowned self] dataIsReady in
                if dataIsReady {
                    self.marketDataReady = dataIsReady
                }
            })
            .store(in: &anyCancellables)
    }
    
    func onTerminate() {
//        walletsService.onTerminate()
    }
    
    func didEnterBackground() {
//        walletsService.didEnterBackground()
    }
    
    func didBecomeActive() {
//        walletsService.didBecomeActive()
    }
}

