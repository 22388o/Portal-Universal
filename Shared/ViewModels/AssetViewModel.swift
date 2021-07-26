//
//  AssetViewModel.swift
//  Portal
//
//  Created by Farid on 20.05.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import SwiftUI
import Combine
import Charts
import Coinpaprika

final class AssetViewModel: ObservableObject {
    var coin: Coin
    
    @ObservedObject private var state: PortalState
    @Published var selectedTimeframe: Timeframe = .day
    @Published var valueCurrencySwitchState: ValueCurrencySwitchState = .fiat
    
    @Published private(set) var balance = String()
    @Published private(set) var totalValue = String()
    @Published private(set) var price = String()
    @Published private(set) var change = String()
    @Published private(set) var chartDataEntries = [ChartDataEntry]()
    @Published private(set) var currency: Currency = .fiat(USD)
    @Published var loadingData: Bool = false
        
    private let queue = DispatchQueue.main
    private var subscriptions = Set<AnyCancellable>()
    private var fiatCurrency: FiatCurrency
    
    private var marketDataProvider: IMarketDataProvider
    private let walletManager: IWalletManager
    private let adapterManager: IAdapterManager
    
    var adapter: IBalanceAdapter?
        
    var dayHigh: String {
        let dayHigh: Decimal = marketDataProvider.marketData(coin: coin).dayHigh
        return "\(fiatCurrency.symbol)\((dayHigh * Decimal(fiatCurrency.rate)).double.rounded(toPlaces: 2))"
    }
    
    var dayLow: String {
        let dayLow: Decimal = marketDataProvider.marketData(coin: coin).dayLow
        return "\(fiatCurrency.symbol)\((dayLow * Decimal(fiatCurrency.rate)).double.rounded(toPlaces: 2))"
    }
    
    init(state: PortalState, walletManager: IWalletManager, adapterManager: IAdapterManager, marketDataProvider: IMarketDataProvider) {
        self.state = state
        self.coin = state.selectedCoin
        self.walletManager = walletManager
        self.adapterManager = adapterManager
        
        if let wallet = Portal.shared.walletManager.activeWallets.first(where: { $0.coin == state.selectedCoin }),
           let adapter = Portal.shared.adapterManager.balanceAdapter(for: wallet) {
            self.adapter = adapter
        } else {
            self.adapter = nil
        }
        
        self.balance = "\(adapter?.balance ?? 0)"
        self.fiatCurrency = state.fiatCurrency
        self.marketDataProvider = marketDataProvider
        
        updateValues()
        
        $selectedTimeframe
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateValues()
            }
            .store(in: &subscriptions)
        
        $valueCurrencySwitchState
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                self?.updateValues()
            }
            .store(in: &subscriptions)
        
        $loadingData
            .dropFirst()
            .sink { [weak self] loading in
                if !loading {
                    self?.chartDataEntries = self?.assetChartDataEntries() ?? []
                }
            }
            .store(in: &subscriptions)
        
        state.$fiatCurrency
            .sink { [weak self] currency in
                self?.fiatCurrency = currency
                self?.updateValues()
            }
            .store(in: &subscriptions)
        
        state.$selectedCoin
            .sink { [weak self] coin in
                self?.coin = coin
                self?.updateValues()
            }
            .store(in: &subscriptions)
    }
    
    deinit {
        print("Deinit - \(coin.code)")
    }
    
    private func updateValues() {
        guard let ticker = marketDataProvider.ticker(coin: coin) else { return }
        
        self.balance = "\(adapter?.balance ?? 0)"
        
        price = "\(fiatCurrency.symbol)" + "\((ticker[.usd].price * Decimal(fiatCurrency.rate)).double.rounded(toPlaces: 2))"
        
        let currentPrice: Decimal
        
        switch valueCurrencySwitchState {
        case .fiat:
            totalValue = "\(fiatCurrency.symbol)" + "\((ticker[.usd].price * Decimal(fiatCurrency.rate)).rounded(toPlaces: 2))"
            currentPrice = ticker[.usd].price * Decimal(fiatCurrency.rate)
        case .btc:
            totalValue = "\((ticker[.btc].price).rounded(toPlaces: 2)) BTC"
            currentPrice = ticker[.btc].price
        case .eth:
            totalValue = "\((ticker[.eth].price).rounded(toPlaces: 2)) ETH"
            currentPrice = ticker[.eth].price
        }
        let percentChange: Decimal
        
        switch selectedTimeframe {
        case .day:
            percentChange = ticker[.usd].percentChange24h
        case .week:
            percentChange = ticker[.usd].percentChange7d
        case .month:
            percentChange = ticker[.usd].percentChange30d
        case .year:
            percentChange = ticker[.usd].percentChange1y
        }
        
        change = change(currentPrice: currentPrice, changeInPercents: percentChange)
        chartDataEntries = assetChartDataEntries()
    }
    
    private func change(currentPrice: Decimal, changeInPercents: Decimal) -> String {
        switch valueCurrencySwitchState {
        case .fiat:
            return "\(changeInPercents > 0 ? "+" : "-")\(fiatCurrency.symbol)\(abs(currentPrice * (changeInPercents/100)).double.rounded(toPlaces: 2)) (\(changeInPercents.double.rounded(toPlaces: 2))%)"
        case .btc:
            return "\(changeInPercents > 0 ? "+" : "-")\(abs(currentPrice * (changeInPercents/100)).double.rounded(toPlaces: 2)) BTC (\(changeInPercents.double.rounded(toPlaces: 2))%)"
        case .eth:
            return "\(changeInPercents > 0 ? "+" : "-")\(abs(currentPrice * (changeInPercents/100)).double.rounded(toPlaces: 2)) ETH (\(changeInPercents.double.rounded(toPlaces: 2))%)"
        }
    }
    
    var changeLabelColor: Color {
        let priceChange: Decimal?
        switch selectedTimeframe {
        case .day:
            priceChange = marketDataProvider.ticker(coin: coin)?[.usd].percentChange24h
        case .week:
            priceChange = marketDataProvider.ticker(coin: coin)?[.usd].percentChange7d
        case .month:
            priceChange = marketDataProvider.ticker(coin: coin)?[.usd].percentChange30d
        case .year:
            priceChange = marketDataProvider.ticker(coin: coin)?[.usd].percentChange1y
        }
        
        guard let pChange = priceChange else {
            return .white
        }
        
        return pChange > 0 ? Color(red: 15/255, green: 235/255, blue: 131/255, opacity: 1) : Color(red: 255/255, green: 156/255, blue: 49/255, opacity: 1)
    }
    
    private func assetChartDataEntries() -> [ChartDataEntry] {
        var chartDataEntries = [ChartDataEntry]()
        var points = [Decimal]()
        
        if hasChartData(timeframe: selectedTimeframe) {
            points = chartDataPonts(timeframe: selectedTimeframe)
        } else {
            loadingData = true
            marketDataProvider.requestHistoricalData(coin: coin, timeframe: selectedTimeframe)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.loadingData = false
            }
        }
        
        let xIndexes = Array(0..<points.count).map { x in Double(x) }
        for (index, point) in points.enumerated() {
            let dataEntry = ChartDataEntry(x: xIndexes[index], y: point.double)
            chartDataEntries.append(dataEntry)
        }
        
        return chartDataEntries
    }
    
    private func hasChartData(timeframe: Timeframe) -> Bool {
        return !chartDataPonts(timeframe: timeframe).isEmpty
    }
    
    private func chartDataPonts(timeframe: Timeframe) -> [Decimal] {
        switch timeframe {
        case .day:
            return marketDataProvider.marketData(coin: coin).dayPoints
        case .week:
            return marketDataProvider.marketData(coin: coin).weekPoints
        case .month:
            return marketDataProvider.marketData(coin: coin).monthPoints
        case .year:
            return marketDataProvider.marketData(coin: coin).yearPoints
        }
    }
}

extension AssetViewModel {
    static func config() -> AssetViewModel {
        let state = Portal.shared.state
        let walletManager = Portal.shared.walletManager
        let adapterManager = Portal.shared.adapterManager
        let marketDataProvider = Portal.shared.marketDataProvider
        
        return AssetViewModel(state: state, walletManager: walletManager, adapterManager: adapterManager, marketDataProvider: marketDataProvider)
    }
}
