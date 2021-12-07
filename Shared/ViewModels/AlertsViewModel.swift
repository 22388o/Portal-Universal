//
//  AlertsViewModel.swift
//  Portal
//
//  Created by farid on 12/7/21.
//

import Foundation

final class AlertsViewModel: ObservableObject {
    let coin: Coin
    let alerts: [PriceAlert]
    
    init(coin: Coin, alerts: [PriceAlert]) {
        self.coin = coin
        self.alerts = alerts.reversed()
    }
}

extension AlertsViewModel {
    static func config(coin: Coin) -> AlertsViewModel {
        let storage = Portal.shared.dbStorage
        let accountId = Portal.shared.accountManager.activeAccount?.id
        
        guard let id = accountId else {
            fatalError("Account id is missing")
        }
        
        let alerts = storage.alerts(accountId: id, coin: coin.code)
        
        return AlertsViewModel(coin: coin, alerts: alerts)
    }
}
