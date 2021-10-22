//
//  Portal.swift
//  Portal
//
//  Created by Farid on 15.07.2021.
//

import Foundation
import KeychainAccess
import Combine
import CoreData

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
    let exchangeManager: ExchangeManager
    let reachabilityService: ReachabilityService
    
    @Published var state = PortalState()
        
    private init() {
        reachabilityService = ReachabilityService()
        reachabilityService.startMonitoring()
        
        appConfigProvider = AppConfigProvider()
        
        localStorage = LocalStorage()
        
        let keychain = Keychain(service: appConfigProvider.keychainStorageID)
        secureStorage = KeychainStorage(keychain: keychain)
        
        let bdContext: NSManagedObjectContext = {
            let backgroundContext = PersistenceController.shared.container.newBackgroundContext()
            backgroundContext.automaticallyMergesChangesFromParent = true
            return backgroundContext
        }()
        
        let bdStorage: IDBStorage & IAccountStorage & IDBCacheStorage = DBlocalStorage(context: bdContext)
        
        if localStorage.isFirstLaunch {
            localStorage.removeCurrentAccountID()
            try? secureStorage.clear()
            bdStorage.clear()
        }
        
        localStorage.incrementAppLaunchesCouner()
        
        notificationService = NotificationService()
        
        feeRateProvider = FeeRateProvider(appConfigProvider: appConfigProvider)
        
        let exchangeDataUpdater = ExchangeDataUpdater()
        
        exchangeManager = ExchangeManager(
            localStorage: localStorage,
            secureStorage: secureStorage,
            exchangeDataUpdater: exchangeDataUpdater,
            notificationService: notificationService
        )
        
        let marketDataUpdater = MarketDataUpdater(cachedTickers: bdStorage.tickers, reachability: reachabilityService)
        
        let fiatCurrenciesUpdater = FiatCurrenciesUpdater(
            interval: TimeInterval(appConfigProvider.fiatCurrenciesUpdateInterval),
            fixerApiKey: appConfigProvider.fixerApiKey
        )
                
        let marketDataStorage = MarketDataStorage(mdUpdater: marketDataUpdater, fcUpdater: fiatCurrenciesUpdater, cacheStorage: bdStorage)
        marketDataProvider = MarketDataProvider(repository: marketDataStorage)
                        
        let accountStorage = AccountStorage(localStorage: localStorage, secureStorage: secureStorage, storage: bdStorage)
        accountManager = AccountManager(accountStorage: accountStorage)
        
        let erc20Updater = ERC20TokensUpdater()
        let coinStorage = CoinStorage(updater: erc20Updater, marketData: marketDataStorage)
        let coinManager: ICoinManager = CoinManager(storage: coinStorage)
        
        let walletStorage: IWalletStorage = WalletStorage(coinManager: coinManager, accountManager: accountManager)
        walletManager = WalletManager(accountManager: accountManager, storage: walletStorage)
        
        ethereumKitManager = EthereumKitManager(appConfigProvider: appConfigProvider)
        
        let adapterFactory = AdapterFactory(appConfigProvider: appConfigProvider, ethereumKitManager: ethereumKitManager)
        adapterManager = AdapterManager(adapterFactory: adapterFactory, ethereumKitManager: ethereumKitManager, walletManager: walletManager)
                                
        marketDataStorage.$dataReady
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] ready in
                guard let self = self else { return }
                if !ready && self.reachabilityService.isReachable {
                    self.state.loading = true
                } else {
                    self.state.loading = false
                }
            })
            .store(in: &anyCancellables)
                
        adapterManager.adapterdReadyPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] ready in
                if ready && self?.accountManager.activeAccount != nil {
                    if self?.state.current != .currentAccount {
                        self?.state.current = .currentAccount
                    }
                } else if self?.accountManager.activeAccount == nil {
                    self?.state.loading = false
                    self?.state.current = .createAccount
                }
            }
            .store(in: &anyCancellables)
        
        accountManager.onActiveAccountUpdatePublisher
            .debounce(for: 2, scheduler: RunLoop.main)
            .sink { [weak self] account in
                if account != nil {
                    self?.state.loading = false
                }
            }
            .store(in: &anyCancellables)
    }
    
    func onTerminate() {

    }
    
    func didEnterBackground() {

    }
    
    func didBecomeActive() {

    }
}

