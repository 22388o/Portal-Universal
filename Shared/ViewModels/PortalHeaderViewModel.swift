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
    
    private var notificationService: NotificationService
    private var cancellable = Set<AnyCancellable>()
    
    var hasBadge: Bool {
        !notificationService.alertsBeenSeen && notificationService.newAlerts > 0
    }
    
    var newAlerts: Int {
        notificationService.newAlerts
    }
    
    init(accountManager: IAccountManager, notificationService: NotificationService) {
        self.accountName = accountManager.activeAccount?.name ?? "-"
        self.notificationService = notificationService
        
        accountManager.onActiveAccountUpdatePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] account in
                self?.accountName = account?.name ?? "-"
            }
            .store(in: &cancellable)
            
    }
    
    func markAllNotificationsViewed() {
        notificationService.markAllAlertsViewed()
    }
}

extension PortalHeaderViewModel {
    static func config() -> PortalHeaderViewModel {
        let accountManager = Portal.shared.accountManager
        let notificationService = Portal.shared.notificationService
        
        return PortalHeaderViewModel(
            accountManager: accountManager,
            notificationService: notificationService
        )
    }
}
