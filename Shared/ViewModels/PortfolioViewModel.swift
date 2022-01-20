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
    @Published var empty: Bool = true
    
    private var subscriptions = Set<AnyCancellable>()
    private var walletManager: IWalletManager
    private var adapterManager: IAdapterManager
    private var marketDataProvider: IMarketDataProvider
    private var reachabilityService: IReachabilityService
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
        reachabilityService: IReachabilityService,
        state: PortalState
    ) {
        self.walletManager = walletManager
        self.adapterManager = adapterManager
        self.marketDataProvider = marketDataProvider
        self.reachabilityService = reachabilityService
        self.state = state
                                                        
        subscribe()
    }
    
    private func subscribe() {
        $selectedTimeframe
            .dropFirst()
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] timeframe in
                guard let self = self else { return }
                self.updatePortfolioData(timeframe: timeframe)
            }
            .store(in: &subscriptions)
        
        adapterManager.adapterdReady
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.assets = self.configuredItems()
            }
            .store(in: &subscriptions)
        
        state.wallet.$currency
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] currency in
                guard let self = self else { return }
                self.updateLabels()
                self.updateCharts()
            }
            .store(in: &subscriptions)
        
        marketDataProvider.onMarketDataUpdate
            .debounce(for: 0.25, scheduler: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.updateLabels()
                self.updateCharts()
            }
            .store(in: &subscriptions)
        
        reachabilityService.isReachable
            .dropFirst()
            .debounce(for: 1, scheduler: RunLoop.main)
            .sink { [weak self] reachable in
                guard let self = self else { return }
                
                if reachable {
                    self.updatePortfolioData(timeframe: self.selectedTimeframe)
                }
            }
            .store(in: &subscriptions)
        
        $assets
            .delay(for: .seconds(0.1), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.updatePortfolioData(timeframe: self.selectedTimeframe)
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
    
    private func updatePortfolioData(timeframe: Timeframe) {
        for asset in assets {
            if !asset.hasChartData(timeframe: timeframe) {
                marketDataProvider.requestHistoricalData(coin: asset.coin, timeframe: timeframe)
            }
        }
        updateLabels()
        updateCharts()
    }
        
    private func updateLabels() {
        let portfolioBalanceValue = assets.map{ $0.balanceValue(for: state.wallet.currency) }.reduce(0){ $0 + $1 }
        totalValue = "\(portfolioBalanceValue.formattedString(state.wallet.currency))"
        empty = portfolioBalanceValue == 0
        
        change = calculateChange(value: portfolioBalanceValue)
        
        lowest = lowString()
        highest = highString()

        updateBestWorstPerformingCoin()
        
        exchangeBalances.removeAll()
    }
    
    private func calculateChange(value: Decimal) -> String {
        let balanceAtTimestamp = assets.map{ $0.balanceValue(for: state.wallet.currency, at: selectedTimeframe) }.reduce(0){ $0 + $1 }
        let change = value - balanceAtTimestamp
        let changeInPercents = balanceAtTimestamp > 0 ? (change/balanceAtTimestamp) * 100 : 100
        
        let prefix = "\(changeInPercents > 0 ? "+" : "-")"
        let percentChangeString = "(\(changeInPercents.double.rounded(toPlaces: 2))%)"
        let priceChange = abs(value * (changeInPercents/100)).formattedString(state.wallet.currency, decimals: 5)

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
    
    private func lowString() -> String {
        let lowUSDValue = assets.map{$0.highestLowestValue(timeframe: selectedTimeframe).low * 1}.reduce(0){$0 + $1}
        
        let low: Decimal
        
        switch state.wallet.currency {
        case .btc:
            low = lowUSDValue/btcUSDPrice
        case .eth:
            low = lowUSDValue/ethUSDPrice
        case .fiat(let fiatCurrency):
            low = lowUSDValue * Decimal(fiatCurrency.rate)
        }
        
        guard low > 0 else { return "-"}
        
        return ("\(low.formattedString(state.wallet.currency, decimals: 4))")
    }
    
    private func highString() -> String {
        let highUSDValue = assets.map{$0.highestLowestValue(timeframe: selectedTimeframe).high * 1}.reduce(0){$0 + $1}
        
        let high: Decimal
        
        switch state.wallet.currency {
        case .btc:
            high = highUSDValue/btcUSDPrice
        case .eth:
            high = highUSDValue/ethUSDPrice
        case .fiat(let fiatCurrency):
            high = highUSDValue * Decimal(fiatCurrency.rate)
        }
        
        guard high > 0 else { return "-"}
        
        return ("\(high.formattedString(state.wallet.currency, decimals: 4))")
    }
    
    private func updateBestWorstPerformingCoin() {
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
        let reachabilityService = Portal.shared.reachabilityService
        let state = Portal.shared.state
        
        return PortfolioViewModel(
            walletManager: walletManager,
            adapterManager: adapterManager,
            marketDataProvider: marketData,
            reachabilityService: reachabilityService,
            state: state
        )
    }
}
