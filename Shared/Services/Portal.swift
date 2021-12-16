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
import Mixpanel
import Bugsnag

final class Portal: ObservableObject {
    static let shared = Portal()
        
    private var anyCancellables: Set<AnyCancellable> = []

    private let localStorage: ILocalStorage
    private let secureStorage: IKeychainStorage
    
    let dbStorage: IDBStorage & IAccountStorage & IDBCacheStorage & IPriceAlertStorage
    let appConfigProvider: IAppConfigProvider
    let accountManager: IAccountManager
    let walletManager: IWalletManager
    let marketDataProvider: IMarketDataProvider
    let notificationService: NotificationService
    let feeRateProvider: FeeRateProvider
    let ethereumKitManager: EthereumKitManager
    let adapterManager: IAdapterManager
    let exchangeManager: ExchangeManager
    let reachabilityService: ReachabilityService
    let pushNotificationService: PushNotificationService
    let userId: String
    
    @Published var state = PortalState()
        
    private init() {
        reachabilityService = ReachabilityService()
        reachabilityService.startMonitoring()
        
        appConfigProvider = AppConfigProvider()
        
        let mixpanel = Mixpanel.initialize(token: appConfigProvider.mixpanelToken)
        userId = mixpanel.distinctId
        mixpanel.identify(distinctId: userId)
        
        Bugsnag.start()
        
        localStorage = LocalStorage()
        
        let keychain = Keychain(service: appConfigProvider.keychainStorageID)
        secureStorage = KeychainStorage(keychain: keychain)
        
        let dbContext: NSManagedObjectContext = {
            let backgroundContext = PersistenceController.shared.container.newBackgroundContext()
            backgroundContext.automaticallyMergesChangesFromParent = true
            return backgroundContext
        }()
        
        dbStorage = DBlocalStorage(context: dbContext)
        
        if localStorage.isFirstLaunch {
            localStorage.removeCurrentAccountID()
            try? secureStorage.clear()
            dbStorage.clear()
        }
        
        localStorage.incrementAppLaunchesCouner()
        
        feeRateProvider = FeeRateProvider(appConfigProvider: appConfigProvider)
        
        let exchangeDataUpdater = ExchangeDataUpdater()
        
        exchangeManager = ExchangeManager(
            localStorage: localStorage,
            secureStorage: secureStorage,
            exchangeDataUpdater: exchangeDataUpdater
        )
        
        let marketDataUpdater = MarketDataUpdater(cachedTickers: dbStorage.tickers, reachability: reachabilityService)
        
        let fiatCurrenciesUpdater = FiatCurrenciesUpdater(
            interval: TimeInterval(appConfigProvider.fiatCurrenciesUpdateInterval),
            fixerApiKey: appConfigProvider.fixerApiKey
        )
                
        let marketDataStorage = MarketDataStorage(mdUpdater: marketDataUpdater, fcUpdater: fiatCurrenciesUpdater, cacheStorage: dbStorage)
        marketDataProvider = MarketDataProvider(repository: marketDataStorage)
                        
        let accountStorage = AccountStorage(localStorage: localStorage, secureStorage: secureStorage, storage: dbStorage)
        accountManager = AccountManager(accountStorage: accountStorage)
        
        let erc20Updater: IERC20Updater = ERC20Updater()
        let coinStorage: ICoinStorage = CoinStorage(updater: erc20Updater, marketData: marketDataStorage)
        let coinManager: ICoinManager = CoinManager(storage: coinStorage)
        
        let walletStorage: IWalletStorage = WalletStorage(coinManager: coinManager, accountManager: accountManager)
        walletManager = WalletManager(accountManager: accountManager, storage: walletStorage)
        
        ethereumKitManager = EthereumKitManager(appConfigProvider: appConfigProvider)
        
        let adapterFactory = AdapterFactory(appConfigProvider: appConfigProvider, ethereumKitManager: ethereumKitManager)
        adapterManager = AdapterManager(adapterFactory: adapterFactory, ethereumKitManager: ethereumKitManager, walletManager: walletManager)
        
        notificationService = NotificationService(accountManager: accountManager)
        
        pushNotificationService = PushNotificationService(appId: userId)
        pushNotificationService.registerForRemoteNotifications()
                
        if let activeAccount = accountManager.activeAccount {
            updateWalletCurrency(code: activeAccount.fiatCurrencyCode)
        }
                                
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
            .receive(on: RunLoop.main)
            .sink { [weak self] account in
                if account != nil {
                    self?.state.loading = false
                    self?.updateWalletCurrency(code: account?.fiatCurrencyCode ?? "USD")
                }
            }
            .store(in: &anyCancellables)
        
        state
            .$walletCurrency
            .dropFirst()
            .sink { [weak self] currency in
                self?.accountManager.updateWalletCurrency(code: currency.code)
            }
            .store(in: &anyCancellables)
    }
    
    func updateWalletCurrency(code: String) {
        switch code {
        case "BTC":
            state.walletCurrency = .btc
        case "ETH":
            state.walletCurrency = .eth
        default:
            state.walletCurrency = marketDataProvider.fiatCurrencies.map { Currency.fiat($0) }.first(where: { $0.code == code }) ?? .fiat(.init(code: code, name: "-"))
        }
    }
 
    func onTerminate() {

    }
    
    func didEnterBackground() {

    }
    
    func didBecomeActive() {

    }
}
