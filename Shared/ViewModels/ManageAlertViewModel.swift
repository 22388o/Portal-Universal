//
//  ManageAlertViewModel.swift
//  Portal
//
//  Created by farid on 12/6/21.
//

import Foundation
import Combine

final class ManageAlertViewModel: ObservableObject {
    let coin: Coin
    let worth: String
    
    @Published var type: AlertType
    @Published var value: String
    @Published var canSet: Bool
    @Published var alerts: [PriceAlert]
    
    private var subscriptions: Set<AnyCancellable>
    private let storage: IPriceAlertStorage
    private let updater: PriceAlertUpdater
    private let userId: String
    private let accountId: String
    
    init(accountId: String, userId: String, coin: Coin, price: Decimal, alertsStorage: IPriceAlertStorage) {
        self.accountId = accountId
        self.userId = userId
        self.coin = coin
        self.worth = price.formattedString(Currency.fiat(USD))
        self.storage = alertsStorage
        self.alerts = storage.alerts(accountId: accountId, coin: coin.code).reversed()
        self.type = .worthMore(coin)
        self.value = String()
        self.canSet = false
        self.subscriptions = Set<AnyCancellable>()
        self.updater = PriceAlertUpdater()
        
        subscribe()
    }
    
    private func subscribe() {
        $value
            .sink { [weak self] alertTrigger in
                self?.canSet = !alertTrigger.isEmpty && alertTrigger.doubleValue > 0
            }
            .store(in: &subscriptions)
    }
    
    func setAlert() {
        let title: String
        let valueDouble = Double(value)?.formattedString(.fiat(USD)) ?? "0"
        
        switch type {
        case .worthMore, .worthLess:
            title = "\(type.description) \(valueDouble)"
        default:
            title = "\(type.description) \(value)%"
        }
        
        let alertId = UUID().uuidString
        let coinCode = coin.code
        
        updater.createAlert(devId: userId, alertId: alertId, coin: coinCode, price: value) { [unowned self] result in
            if result.contains("Success") {
                let model = PriceAlertModel(
                    accountId: accountId,
                    id: alertId,
                    coin: coinCode,
                    timestamp: "\(Date().timeIntervalSince1970)",
                    title: title.replacingOccurrences(of: "...", with: ""),
                    value: value
                )
                
                storage.addAlert(model)
                
                reset()
            } else {
                print("Cannot crete price alert: \(result)")
            }
        }
    }
    
    func deleteAlert(_ alert: PriceAlert) {
        guard let alertId = alert.id else { return }
        
        updater.deleteAlert(alertId: alertId) { [unowned self] result in
            if result.contains("Success") {
                storage.deleteAlert(alert)
                reset()
            } else {
                print("Cannot delete price alert: \(result)")
            }
        }
    }
    
    private func reset() {
        DispatchQueue.main.async {
            self.value = String()
            self.alerts = self.storage.alerts(accountId: self.accountId, coin: self.coin.code).reversed()
        }
    }
}

extension ManageAlertViewModel {
    static func config(coin: Coin) -> ManageAlertViewModel {
        let price = Portal.shared.marketDataProvider.ticker(coin: coin)?[.usd].price ?? 1
        let storage = Portal.shared.dbStorage
        let userId = Portal.shared.userId
        let accountId = Portal.shared.accountManager.activeAccount?.id
        
        guard let id = accountId else {
            fatalError("Account id is nil")
        }
        
        return ManageAlertViewModel(accountId: id, userId: userId, coin: coin, price: price, alertsStorage: storage)
    }
}
