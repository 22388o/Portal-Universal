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
    
    init(coin: Coin, price: Decimal, alertsStorage: IPriceAlertStorage) {
        self.coin = coin
        self.worth = price.formattedString(Currency.fiat(USD))
        self.storage = alertsStorage
        self.alerts = storage.alerts.reversed()
        self.type = .worthMore(coin)
        self.value = String()
        self.canSet = false
        self.subscriptions = Set<AnyCancellable>()
        
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
        
        let model = PriceAlertModel(
            id: UUID().uuidString,
            coin: coin.code,
            timestamp: "\(Date().timeIntervalSince1970)",
            title: title.replacingOccurrences(of: "...", with: ""),
            value: value
        )
        
        storage.addAlert(model)
        
        reset()
    }
    
    func deleteAlert(_ alert: PriceAlert) {
        storage.deleteAlert(alert)
        alerts = storage.alerts.reversed()
    }
    
    private func reset() {
        value = String()
        alerts = storage.alerts.reversed()
    }
}

extension ManageAlertViewModel {
    static func config(coin: Coin) -> ManageAlertViewModel {
        let price = Portal.shared.marketDataProvider.ticker(coin: coin)?[.usd].price ?? 1
        let storage = Portal.shared.dbStorage
        
        return ManageAlertViewModel(coin: coin, price: price, alertsStorage: storage)
    }
}
