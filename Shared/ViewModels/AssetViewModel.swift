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
    let asset: IAsset
            
    @Published var selectedTimeframe: Timeframe = .day
    @Published var valueCurrencySwitchState: ValueCurrencySwitchState = .fiat
    
    @Published private(set) var balance = String()
    @Published private(set) var totalValue = String()
    @Published private(set) var price = String()
    @Published private(set) var change = String()
    @Published private(set) var chartDataEntries = [ChartDataEntry]()
    @Published private(set) var currency: Currency = .fiat(USD)
    @Published private(set) var isLoadingData: Bool = false
        
    private let queue = DispatchQueue.main
    private var subscriptions = Set<AnyCancellable>()
    private var fiatCurrency: FiatCurrency
    
    var dayHigh: String {
        let dayHigh: Decimal = asset.marketDataProvider.marketData?.dayHigh ?? 0
        return "\(fiatCurrency.symbol)\((dayHigh * Decimal(fiatCurrency.rate)).double.rounded(toPlaces: 2))"
    }
    
    var dayLow: String {
        let dayLow: Decimal = asset.marketDataProvider.marketData?.dayLow ?? 0
        return "\(fiatCurrency.symbol)\((dayLow * Decimal(fiatCurrency.rate)).double.rounded(toPlaces: 2))"
    }
    
    init(asset: IAsset, fiatCurrency: FiatCurrency) {
        self.asset = asset
        self.fiatCurrency = fiatCurrency
    
        updateValues()
        
//        queue.schedule(
//            after: queue.now,
//            interval: .seconds(10)
//        ){ [weak self] in
//            self?.updateValues()
//        }
//        .store(in: &subscriptions)
        
        $selectedTimeframe
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateValues()
            }
            .store(in: &subscriptions)
        
        $valueCurrencySwitchState
            .sink { [weak self] state in
                guard let self = self else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.updateValues()
                }
            }
            .store(in: &subscriptions)
        
        $isLoadingData
            .dropFirst()
            .sink { [unowned self] (isLoading) in
                if !isLoading {
                    self.updateValues()
                }
            }
            .store(in: &subscriptions)
        
        
//        MarketDataRepository.service.coinLatestOhlcv(coin: asset.coin) { (response) in
//            guard let ohlc = response else { return }
//            
//            print("Coin latest ohlc: \(ohlc)")
//        }
        
//        $ticker.sink { [weak self] (ticker) in
//            self?.updateValues()
//        }
//        .store(in: &subscriptions)
    }
    
    deinit {
        print("Deinit - \(asset.coin.code)")
//        cancellable = nil
    }
    
    private func updateValues() {
        guard let ticker = asset.marketDataProvider.ticker else { return }
        
        self.balance = "\(asset.balanceAdapter?.balance ?? 0)"
        
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
            priceChange = asset.marketDataProvider.ticker?[.usd].percentChange24h
        case .week:
            priceChange = asset.marketDataProvider.ticker?[.usd].percentChange7d
        case .month:
            priceChange = asset.marketDataProvider.ticker?[.usd].percentChange30d
        case .year:
            priceChange = asset.marketDataProvider.ticker?[.usd].percentChange1y
        }
        
        guard let pChange = priceChange else {
            return .white
        }
        
        return pChange > 0 ? Color(red: 15/255, green: 235/255, blue: 131/255, opacity: 1) : Color(red: 255/255, green: 156/255, blue: 49/255, opacity: 1)
    }
    
    private func assetChartDataEntries() -> [ChartDataEntry] {
        var chartDataEntries = [ChartDataEntry]()
        var points = [Decimal]()
        
//        let step = 4
        
        switch selectedTimeframe {
        case .day:
            points = asset.marketDataProvider.marketData?.dayPoints ?? []
        case .week:
            points = asset.marketDataProvider.marketData?.weekPoints ?? []
        case .month:
            points = asset.marketDataProvider.marketData?.monthPoints ?? []
        case .year:
            points = asset.marketDataProvider.marketData?.yearPoints ?? []
        }
        
        let xIndexes = Array(0..<points.count).map { x in Double(x) }
        for (index, point) in points.enumerated() {
            let dataEntry = ChartDataEntry(x: xIndexes[index], y: point.double)
            chartDataEntries.append(dataEntry)
        }
        
        return chartDataEntries
    }
}
