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
import SwiftUI

final class Portal {
    static let shared = Portal()
        
    private var anyCancellables: Set<AnyCancellable> = []

    private let localStorage: ILocalStorage
    private let secureStorage: IKeychainStorage
    
    let dbStorage: IDBStorage & IAccountStorage & IDBCacheStorage & IPriceAlertStorage
    let appConfigProvider: IAppConfigProvider
    let accountManager: IAccountManager
    let walletManager: IWalletManager
    let marketDataProvider: IMarketDataProvider
    let notificationService: INotificationService
    let feeRateProvider: FeeRateProvider
    let ethereumKitManager: EthereumKitManager
    let adapterManager: IAdapterManager
    let exchangeManager: ExchangeManager
    let reachabilityService: IReachabilityService
    let pushNotificationService: PushNotificationService
    
    @ObservedObject var state: PortalState
        
    private init() {
        reachabilityService = ReachabilityService()
        reachabilityService.startMonitoring()
        
        appConfigProvider = AppConfigProvider()
        
        let mixpanel = Mixpanel.initialize(token: appConfigProvider.mixpanelToken)
        let userId = mixpanel.distinctId
        mixpanel.identify(distinctId: userId)
        
        Bugsnag.start()
        
        state = PortalState(userId: userId)
        
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
        
        let marketDataUpdater: IMarketDataUpdater = MarketDataUpdater(cachedTickers: dbStorage.tickers, reachability: reachabilityService)
        
        let fiatCurrenciesUpdater: IFiatCurrenciesUpdater = FiatCurrenciesUpdater(
            interval: TimeInterval(appConfigProvider.fiatCurrenciesUpdateInterval),
            fixerApiKey: appConfigProvider.fixerApiKey
        )
                
        let marketDataStorage = MarketDataStorage(mdUpdater: marketDataUpdater, fcUpdater: fiatCurrenciesUpdater, cacheStorage: dbStorage)
        marketDataProvider = MarketDataProvider(repository: marketDataStorage)
                        
        let accountStorage = AccountStorage(localStorage: localStorage, secureStorage: secureStorage, accountStorage: dbStorage)
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
                
        adapterManager.adapterdReady
            .receive(on: RunLoop.main)
            .sink { [unowned self] ready in
                let hasAccount = self.accountManager.activeAccount != nil
                if hasAccount && ready {
                    if self.state.rootView != .account {
                        self.state.rootView = .account
                    }
                    self.state.wallet.coin = .bitcoin()
                } else if !hasAccount {
                    self.state.rootView = .createAccount
                }
            }
            .store(in: &anyCancellables)
        
        accountManager.onActiveAccountUpdate
            .receive(on: RunLoop.main)
            .sink { [unowned self] account in
                guard let activeAccount = account else  { return }
                
                self.state.loading = false
                self.updateWalletCurrency(code: activeAccount.fiatCurrencyCode)
            }
            .store(in: &anyCancellables)
        
        state.wallet.$currency
            .dropFirst()
            .sink { [unowned self] currency in
                self.accountManager.updateWalletCurrency(code: currency.code)
            }
            .store(in: &anyCancellables)
    }
    
    private func updateWalletCurrency(code: String) {
        switch code {
        case "BTC":
            state.wallet.currency = .btc
        case "ETH":
            state.wallet.currency = .eth
        default:
            let currency = Currency.fiat(.init(code: code, name: "-"))
            state.wallet.currency = marketDataProvider.fiatCurrencies.map { Currency.fiat($0) }.first(where: { $0.code == code }) ?? currency
        }
    }
 
    func onTerminate() {

    }
    
    func didEnterBackground() {

    }
    
    func didBecomeActive() {

    }
}
