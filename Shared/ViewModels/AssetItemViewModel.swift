//
//  AssetItemViewModel.swift
//  Portal
//
//  Created by Farid on 20.05.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

final class AssetItemViewModel: ObservableObject, IMarketData {
    let code: String
    let name: String
    let icon: UIImage
            
    @Published var balance = String()
    @Published var totalValue = String()
    @Published var price = String()
    @Published var change = String()
    @Published var selectedTimeframe: Timeframe = .hour
    
    private let asset: IAsset
    private let queue = DispatchQueue.main
    private var cancellable: Cancellable?
    
    private var marketData: CoinMarketData {
        marketData(for: code)
    }
    
    private var rate: Double {
        marketRate(for: USD)
    }
    
    init(asset: IAsset) {
        print("Init \(asset.coin.code) item view model")
        self.asset = asset
        
        code = asset.coin.code
        name = asset.coin.name
        icon = asset.coin.icon
                        
        updateValues()
        
        cancellable = queue.schedule(
            after: queue.now,
            interval: .seconds(1)
        ){ [weak self] in
            self?.updateValues()
        }
    }
    
    deinit {
        print("Deinit \(asset.coin.code) item view model")
        cancellable = nil
    }
    
    private func updateValues() {
        balance = asset.balanceProvider.balanceString
        totalValue = asset.balanceProvider.totalValueString + "\(Int.random(in: 1...8))"
        price = asset.balanceProvider.price + "\(Int.random(in: 1...8))"
        change = asset.marketChangeProvider.changeString
    }
}
