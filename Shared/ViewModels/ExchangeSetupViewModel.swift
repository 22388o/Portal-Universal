//
//  ExchangeSetupViewModel.swift
//  Portal
//
//  Created by Farid on 16.09.2021.
//

import Foundation
import Combine

final class ExchangeSetupViewModel: ObservableObject {
    enum SetupStep {
        case first, second
        
        var description: String {
            switch self {
            case .first:
                return "1"
            case .second:
                return "2"
            }
        }
    }
    
    @Published var exchanges: [ExchangeModel]
    @Published var exchangeToSync: ExchangeModel?
    @Published var step: SetupStep = .first
    @Published var selectedExchanges: [ExchangeModel] = []
    @Published var secret: String = String()
    @Published var key: String = String()
    @Published var passphrase: String = String()
    @Published var syncButtonEnabled: Bool = false
    
    private var subscriptions = Set<AnyCancellable>()
    
    init(exchanges: [ExchangeModel]) {
        self.exchanges = exchanges
        self.exchangeToSync = exchanges.first
        
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        $secret.combineLatest($key, $passphrase).sink { [weak self] secret, key, passphrase in
            self?.syncButtonEnabled = !secret.isEmpty && !key.isEmpty && !passphrase.isEmpty
        }
        .store(in: &subscriptions)
        
        $exchangeToSync.sink { [weak self] exchange in
            self?.secret = String()
            self?.key = String()
            self?.passphrase = exchange?.id == "coinbasepro" ? String() : " "
        }
        .store(in: &subscriptions)
    }
    
    func syncExchange() {
        if let exchange = exchangeToSync, let index = selectedExchanges.firstIndex(of: exchange) {
            if selectedExchanges.indices.contains(index + 1) {
                exchangeToSync = selectedExchanges  [index + 1]
            } else {
                print("All exchanges synced!")
            }
        }
    }
}

extension ExchangeSetupViewModel {
    static func config() -> ExchangeSetupViewModel {
        let exchanges = Portal.shared.exchangeManager.exchanges
        return ExchangeSetupViewModel(exchanges: exchanges)
    }
}
