//
//  PortfolioViewModel.swift
//  Portal
//
//  Created by Farid on 19.05.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation
import Charts
import SwiftUI
import Combine

final class PortfolioViewModel: ObservableObject {
    @Published private(set) var assets: [PortfolioItem] = []
    @Published private(set) var totalValue = String()
    @Published private(set) var change = String()
    @Published private(set) var lowest = String()
    @Published private(set) var highest = String()
    @Published private(set) var bestPerforming: Coin?
    @Published private(set) var worstPerforming: Coin?
    @Published private(set) var chartDataEntries = [ChartDataEntry]()
    
    @Published var selectedTimeframe: Timeframe = .day
    @Published var state: PortalState
    @Published private var walletCurrency: Currency
    @Published var empty: Bool = true
    
    private var subscriptions = Set<AnyCancellable>()
    private var walletManager: IWalletManager
    private var adapterManager: IAdapterManager
    private var marketDataProvider: IMarketDataProvider
    private var exchangeBalances = [String: Double]()
    
    private var btcUSDPrice: Decimal {
        marketDataProvider.ticker(coin: .bitcoin())?[.usd].price ?? 1
    }
    
    private var ethUSDPrice: Decimal {
        marketDataProvider.ticker(coin: .ethereum())?[.usd].price ?? 1
    }
    
    init(
        walletManager: IWalletManager,
        adapterManager: IAdapterManager,
        marketDataProvider: IMarketDataProvider,
        state: PortalState
    ) {
        self.walletManager = walletManager
        self.adapterManager = adapterManager
        self.marketDataProvider = marketDataProvider
        self.state = state
        self.walletCurrency = state.walletCurrency
                                                        
        subscribe()
    }
    
    private func subscribe() {
        $selectedTimeframe
            .dropFirst()
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] timeframe in
                self?.updatePortfolioData(timeframe: timeframe)
            }
            .store(in: &subscriptions)
        
        adapterManager.adapterdReadyPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
            
                self.assets = self.configuredItems()
                self.updatePortfolioData(timeframe: self.selectedTimeframe)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: {
                    self.updateCharts()
                })
            }
            .store(in: &subscriptions)
        
        state
            .$walletCurrency
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] currency in
                self?.walletCurrency = currency
                self?.updateLabels()
                self?.updateCharts()
            }
            .store(in: &subscriptions)
    }
    
    private func configuredItems() -> [PortfolioItem] {
        walletManager.activeWallets.compactMap({ wallet in
            let coin = wallet.coin
            guard
                let balanceAdapter = adapterManager.balanceAdapter(for: wallet),
                let transactionAdapterAdapter = adapterManager.transactionsAdapter(for: wallet)
            else { return nil }
            
            return PortfolioItem(
                coin: coin,
                balanceAdapter: balanceAdapter,
                transactionAdapter: transactionAdapterAdapter,
                marketDataProvider: marketDataProvider
            )
        })
    }
    
    func updatePortfolioData(timeframe: Timeframe) {
        updateLabels()
        
        for asset in assets {
            if !asset.hasChartData(timeframe: timeframe) {
                marketDataProvider.requestHistoricalData(coin: asset.coin, timeframe: timeframe)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self.updateLabels()
                    self.updateCharts()
                }
            }
        }
        
        self.updateCharts()
    }
        
    private func updateLabels() {
        totalValue = "\(assets.map{ $0.balanceValue(for: walletCurrency) }.reduce(0){ $0 + $1 }.formattedString(walletCurrency))"
        empty = assets.map{ $0.balanceValue(for: walletCurrency) }.reduce(0){ $0 + $1 } == 0
        
        change = calculateChange()
        
        let lowestHighest = lowestHighestStrings()

        lowest = lowestHighest.lowest
        highest = lowestHighest.highest

        updateBestWorstPerformingCoin()
        
        exchangeBalances.removeAll()
    }
    
    private func calculateChange() -> String {
        let balanceAtTimestamp = assets.map{ $0.balanceValue(for: walletCurrency, at: selectedTimeframe) }.reduce(0){ $0 + $1 }
        let balanceNow = assets.map{ $0.balanceValue(for: walletCurrency) }.reduce(0){ $0 + $1 }
        let change = balanceNow - balanceAtTimestamp
        let changeInPercents = balanceAtTimestamp > 0 ? (change/balanceAtTimestamp) * 100 : 100
        
        let prefix = "\(changeInPercents > 0 ? "+" : "-")"
        let percentChangeString = "(\(changeInPercents.double.rounded(toPlaces: 2))%)"
        let totalValue = assets.map{ $0.balanceValue(for: walletCurrency) }.reduce(0){ $0 + $1 }
        let priceChange = abs(totalValue * (changeInPercents/100)).formattedString(state.walletCurrency, decimals: 5)

        return "\(prefix)\(priceChange) \(percentChangeString)"
    }
    
    private func updateCharts() {
        var chartDataEntries = [ChartDataEntry]()
        var pricePoints: [[Double]]

        pricePoints = assets.map {
            $0.pricePoints(timeframe: selectedTimeframe)
        }
        
        guard let count = pricePoints.first?.count else {
            self.chartDataEntries = [ChartDataEntry]()
            return
        }

        var resultArray: [Double] = Array(0..<count).map { x in 0 }

        for points in pricePoints {
            for (index, value) in points.enumerated() {
                if resultArray.indices.contains(index) {
                    resultArray[index] = resultArray[index] + value
                }
            }
        }

        for (index, point) in resultArray.enumerated() {
            let dataEntry = ChartDataEntry(x: Double(index), y: Double(point))
            chartDataEntries.append(dataEntry)
        }

        self.chartDataEntries = chartDataEntries
    }
    
    private func lowestHighestStrings() -> (lowest: String, highest: String) {
        let lowestUSDValue = assets.map{$0.highestLowestValue(timeframe: selectedTimeframe).low * 1}.reduce(0){$0 + $1}
        let highestUSDValue = assets.map{$0.highestLowestValue(timeframe: selectedTimeframe).high * 1}.reduce(0){$0 + $1}
        
        let high: Decimal
        let low: Decimal
        
        switch state.walletCurrency {
        case .btc:
            low = lowestUSDValue/btcUSDPrice
            high = highestUSDValue/btcUSDPrice
        case .eth:
            low = lowestUSDValue/ethUSDPrice
            high = highestUSDValue/ethUSDPrice
        case .fiat(let fiatCurrency):
            low = lowestUSDValue * Decimal(fiatCurrency.rate)
            high = highestUSDValue * Decimal(fiatCurrency.rate)
        }
        
        return ("\(low.formattedString(state.walletCurrency, decimals: 4))", "\(high.formattedString(walletCurrency, decimals: 4))")
    }
    
    func updateBestWorstPerformingCoin() {
        let sortedByPerforming: [PortfolioItem]
        
        switch selectedTimeframe {
        case .day:
            sortedByPerforming = assets.filter({$0.balance > 0}).sorted(by: { $0.dayChange > $1.dayChange })
        case .week:
            sortedByPerforming = assets.filter({$0.balance > 0}).sorted(by: { $0.weekChange > $1.weekChange })
        case .month:
            sortedByPerforming = assets.filter({$0.balance > 0}).sorted(by: { $0.monthChange > $1.monthChange })
        case .year:
            sortedByPerforming = assets.filter({$0.balance > 0}).sorted(by: { $0.yearChange > $1.yearChange })
        }
        
        worstPerforming = sortedByPerforming.last?.coin
        bestPerforming = sortedByPerforming.first?.coin
    }
    
    deinit {
//        print("Portfolio view model deinit")
    }

}

extension PortfolioViewModel {
    static func config() -> PortfolioViewModel {
        let walletManager = Portal.shared.walletManager
        let adapterManager = Portal.shared.adapterManager
        let marketData = Portal.shared.marketDataProvider
        let state = Portal.shared.state
        
        return PortfolioViewModel(
            walletManager: walletManager,
            adapterManager: adapterManager,
            marketDataProvider: marketData,
            state: state
        )
    }
}
