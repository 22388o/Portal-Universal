//
//  ExchangerViewModel.swift
//  Portal
//
//  Created by Farid on 28.05.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation
import Combine
import Coinpaprika

final class ExchangerViewModel: ObservableObject {
    let coin: Coin
    let currency: Currency
    
    @Published var assetValue = String()
    @Published var fiatValue = String()
    
    private var price: Double {
        switch currency {
        case .btc:
            return ((ticker?[.usd].price ?? 0)).double
        case .eth:
            return ((ticker?[.usd].price ?? 0)).double
        case .fiat(let fiatCurrency):
            return ((ticker?[.usd].price ?? 0) * Decimal(fiatCurrency.rate)).double
        }
    }
    
    private var subscriptions = Set<AnyCancellable>()
    
    var ticker: Ticker? {
        Portal.shared.marketDataProvider.ticker(coin: coin)
    }
    
    init(coin: Coin, currency: Currency) {
        print("ExchangerViewModel init")

        self.coin = coin
        self.currency = currency
        
        $assetValue
            .removeDuplicates()
            .map { Double($0) ?? 0 }
            .map { [weak self] in
                "\(($0 * (self?.price ?? 1.0)).rounded(toPlaces: 2))"
            }
            .sink { [weak self] value in
                if value == "0.0" {
                    self?.fiatValue = "0"
                } else {
                    self?.fiatValue = value
                }
            }
            .store(in: &subscriptions)
        
        $fiatValue
            .removeDuplicates()
            .map { Double($0) ?? 0 }
            .map { [weak self] in
                "\(($0/(self?.price ?? 1.0)).rounded(toPlaces: 6))"
            }
            .sink { [weak self] value in
                if value == "0.0" {
                    self?.assetValue = "0"
                } else {
                    self?.assetValue = value
                }
            }
            .store(in: &subscriptions)
    }
    
    func reset() {
        assetValue = String()
    }
    
    deinit {
        print("ExchangerViewModel deinit")
    }
}
