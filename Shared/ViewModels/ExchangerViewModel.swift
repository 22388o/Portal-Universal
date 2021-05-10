//
//  ExchangerViewModel.swift
//  Portal
//
//  Created by Farid on 28.05.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation
import Combine

final class ExchangerViewModel: ObservableObject, IMarketData {
    let asset: Coin
    let fiat: FiatCurrency
    
    @Published var assetValue = String()
    @Published var fiatValue = String()
    
    private var marketData: CoinMarketData {
        marketData(for: asset.code)
    }
    
    private var price: Double {
        9320.24//marketData.priceData?.price ?? 9320.24
    }
    
    private var rate: Double {
        marketRate(for: USD)
    }
    
    private var subscriptions = Set<AnyCancellable>()
    
    init(asset: Coin, fiat: FiatCurrency) {
        print("ExchangerViewModel init")

        self.asset = asset
        self.fiat = fiat
        
        $assetValue
            .removeDuplicates()
            .map { Double($0) ?? 0 }
            .map { [weak self] in "\(($0 * (self?.price ?? 1.0)).rounded(toPlaces: 2))" }
            .sink { [weak self] in self?.fiatValue = $0 }
            .store(in: &subscriptions)
        
        $fiatValue
            .removeDuplicates()
            .map { Double($0) ?? 0 }
            .map { [weak self] in "\(($0/(self?.price ?? 1.0)).rounded(toPlaces: 6))" }
            .sink { [weak self] in
                print($0)
                self?.assetValue = $0
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