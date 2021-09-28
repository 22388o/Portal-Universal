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
    @Published var currentExchangeIndex: Int = 0
    @Published var step: SetupStep = .first
    @Published var selectedExchanges: [ExchangeModel] = []
    
    init(exchanges: [ExchangeModel]) {
        self.exchanges = exchanges
    }
}

extension ExchangeSetupViewModel {
    static func config() -> ExchangeSetupViewModel {
        let exchanges = Portal.shared.exchangeManager.exchanges
        return ExchangeSetupViewModel(exchanges: exchanges)
    }
}
