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
        
    let walletsService: WalletsService
    let appConfigProvider: IAppConfigProvider
    let marketDataProvider: MarketDataProvider
    let localStorage: ILocalStorage
    let secureStorage: IKeychainStorage
    let notificationService: NotificationService
    let etherFeesProvider: IFeeRateProvider
    let bitcoinFeeRateProvider: IFeeRateProvider
    
    @Published private(set) var marketDataReady: Bool = false
    
    private var anyCancellables: Set<AnyCancellable> = []

    private init() {
        
        appConfigProvider = AppConfigProvider()
        
        localStorage = LocalStorage()
        
        let keychain = Keychain(service: appConfigProvider.keychainStorageID)
        secureStorage = KeychainStorage(keychain: keychain)
        
        let feeRateProvider = FeeRateProvider(appConfigProvider: appConfigProvider)
        bitcoinFeeRateProvider = BitcoinFeeRateProvider(feeRateProvider: feeRateProvider)
        etherFeesProvider = EthereumFeeRateProvider(feeRateProvider: feeRateProvider)
        
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
        
        marketDataProvider =  MarketDataProvider(repository: marketDataRepository)
        
        let bdContext = PersistenceController.shared.container.viewContext
        let bdStorage: IDBStorage = DBlocalStorage(context: bdContext)
        
        walletsService = WalletsService(dbStorage: bdStorage, localStorage: localStorage, secureStorage: secureStorage)
        
        notificationService = NotificationService()
        
        if localStorage.isFirstLaunch {
            walletsService.clear()
        }
        
        localStorage.incrementAppLaunchesCouner()
                
        marketDataRepository.$dataIsLoaded
            .sink(receiveValue: { [unowned self] dataIsReady in
                if dataIsReady {
                    self.marketDataReady = dataIsReady
                }
            })
            .store(in: &anyCancellables)
    }
    
    func onTerminate() {
        walletsService.onTerminate()
    }
    
    func didEnterBackground() {
        print("App did enter background")
    }
    
    func willEnterForeground() {
        walletsService.willEnterForeground()
    }
    
    func didBecomeActive() {
        walletsService.didBecomeActive()
    }
}
