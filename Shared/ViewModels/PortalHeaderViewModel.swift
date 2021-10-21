//
//  PortalHeaderViewModel.swift
//  Portal
//
//  Created by Farid on 22.07.2021.
//

import Foundation
import Combine

class PortalHeaderViewModel: ObservableObject {
    @Published var accountName = String()
    @Published var state = Portal.shared.state
    @Published var hasBadge: Bool = false
    @Published var newAlerts: Int = 0
    @Published var isOffline: Bool = false
    
    private var notificationService: NotificationService
    private var reachabillityService: ReachabilityService
    private var cancellables = Set<AnyCancellable>()
    
    init(accountManager: IAccountManager, notificationService: NotificationService, reachabilityService: ReachabilityService) {
        self.accountName = accountManager.activeAccount?.name ?? "-"
        self.notificationService = notificationService
        self.reachabillityService = reachabilityService
        
        accountManager.onActiveAccountUpdatePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] account in
                self?.accountName = account?.name ?? "-"
            }
            .store(in: &cancellables)
            
        notificationService.$newAlerts.combineLatest(notificationService.$alertsBeenSeen)
            .receive(on: RunLoop.main)
            .sink { [weak self] newAlerts, alertsBeenSeen in
                self?.newAlerts = newAlerts
                self?.hasBadge = !alertsBeenSeen && newAlerts > 0
            }
            .store(in: &cancellables)
        
        reachabilityService
            .$isReachable
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

extension PortalHeaderViewModel {
    static func config() -> PortalHeaderViewModel {
        let accountManager = Portal.shared.accountManager
        let notificationService = Portal.shared.notificationService
        let reachabilityService = Portal.shared.reachabilityService
        
        return PortalHeaderViewModel(
            accountManager: accountManager,
            notificationService: notificationService,
            reachabilityService: reachabilityService
            
        )
    }
}
