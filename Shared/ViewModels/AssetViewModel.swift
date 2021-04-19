//
//  AssetViewModel.swift
//  Portal
//
//  Created by Farid on 20.05.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import Charts

final class AssetViewModel: ObservableObject, IMarketData {
    
    let asset: IAsset
    
    private let balanceProvider: IBalanceProvider
    private let marketChangeProvider: IMarketChangeProvider
            
    @Published var balance = String()
    @Published var totalValue = String()
    @Published var price = String()
    @Published var change = String()
    @Published var selectedTimeframe: Timeframe = .hour
    
    @Published var chartDataEntries = [ChartDataEntry]()
    @Published var currency: Currency = .fiat(USD)
    @Published var valueCurrencySwitchState: ValueCurrencySwitchState = .fiat
    
    private let queue = DispatchQueue.main
    
    private var subscriptions = Set<AnyCancellable>()
    
    private var marketData: CoinMarketData {
        marketData(for: asset.coin.code)
    }
    
    private var rate: Double {
        marketRate(for: USD)
    }
    
    init(asset: IAsset) {
        self.asset = asset
        self.balanceProvider = asset.balanceProvider
        self.marketChangeProvider = asset.marketChangeProvider
                        
        updateValues()
        
        queue.schedule(
            after: queue.now,
            interval: .seconds(10)
        ){ [weak self] in
            self?.updateValues()
        }
        .store(in: &subscriptions)
        
        $selectedTimeframe
            .removeDuplicates()
            .sink { [weak self] _ in
//                self?.selectedTimeframe = timeframe
                self?.updateValues()
            }
            .store(in: &subscriptions)
        
        $valueCurrencySwitchState.sink { state in
            switch state {
            case .fiat:
                self.totalValue = asset.balanceProvider.totalValueString
            case .btc:
                self.totalValue = "0.224 BTC"
            case .eth:
                self.totalValue = "1.62 ETH"
            }
        }
        .store(in: &subscriptions)
    }
    
    deinit {
        print("Deinit - \(asset.coin.code)")
//        cancellable = nil
    }
    
    private func updateValues() {
        balance = balanceProvider.balanceString
        totalValue = balanceProvider.totalValueString + "\(Int.random(in: 1...8))"
        price = balanceProvider.price + "\(Int.random(in: 1...8))"
        change = marketChangeProvider.changeString
        chartDataEntries = portfolioChartDataEntries()
    }
    
    private func portfolioChartDataEntries() -> [ChartDataEntry] {
        var chartDataEntries = [ChartDataEntry]()
        var points = [MarketSnapshot]()
        
        let step = 4
        
        switch selectedTimeframe {
        case .hour:
            points = marketData.hourPoints
        case .day:
            points = marketData.dayPoints
        case .week:
            points = marketData.weekPoints.enumerated().compactMap {
                $0.offset % step == 0 ? $0.element : nil
            }
        case .month:
            points = marketData.monthPoints
        case .year:
            points = marketData.yearPoints.enumerated().compactMap {
                $0.offset % step == 0 ? $0.element : nil
            }
        case .allTime:
            return []
        }
        
        let xIndexes = Array(0..<points.count).map { x in Double(x) }
        for (index, point) in points.enumerated() {
            let dataEntry = ChartDataEntry(x: xIndexes[index], y: Double(point.close))
            chartDataEntries.append(dataEntry)
        }
        
        return chartDataEntries
    }
}
