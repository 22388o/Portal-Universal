//
//  HeaderViewModel.swift
//  Portal
//
//  Created by Farid on 22.07.2021.
//

import Foundation
import Combine

class HeaderViewModel: ObservableObject {
    @Published var accountName = String()
    @Published var state = Portal.shared.state
    @Published var hasBadge: Bool = false
    @Published var newAlerts: Int = 0
    @Published var isOffline: Bool = false
    
    var currencies: [Currency] = []
    
    private var notificationService: INotificationService
    private var reachabillityService: IReachabilityService
    private var cancellables = Set<AnyCancellable>()
    
    init(accountManager: IAccountManager, notificationService: INotificationService, reachabilityService: IReachabilityService, currencies: [Currency]) {
        self.accountName = accountManager.activeAccount?.name ?? "-"
        self.notificationService = notificationService
        self.reachabillityService = reachabilityService
        self.currencies = currencies
        
        accountManager.onActiveAccountUpdate
            .receive(on: RunLoop.main)
            .sink { [weak self] account in
                self?.accountName = account?.name ?? "-"
            }
            .store(in: &cancellables)
            
        notificationService.newAlerts.combineLatest(notificationService.alertsBeenSeen)
            .receive(on: RunLoop.main)
            .sink { [weak self] newAlerts, alertsBeenSeen in
                self?.newAlerts = newAlerts
                self?.hasBadge = !alertsBeenSeen && newAlerts > 0
            }
            .store(in: &cancellables)
        
        reachabilityService
            .isReachable
            .receive(on: RunLoop.main)
            .sink { [weak self] online in
                self?.isOffline = !online
            }
            .store(in: &cancellables)
    }
    
    func markAllNotificationsViewed() {
        notificationService.markAllAlertsViewed()
    }
}

extension HeaderViewModel {
    static func config() -> HeaderViewModel {
        let accountManager = Portal.shared.accountManager
        let notificationService = Portal.shared.notificationService
        let reachabilityService = Portal.shared.reachabilityService
        let fiatCurrencies = Portal.shared.marketDataProvider.fiatCurrencies.map{ Currency.fiat($0) }
        let currencies = [Currency.btc, Currency.eth] + fiatCurrencies
        
        return HeaderViewModel(
            accountManager: accountManager,
            notificationService: notificationService,
            reachabilityService: reachabilityService,
            currencies: currencies
        )
    }
}
