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
import Coinpaprika

struct AssetItemViewModel {
    let asset: IAsset
    let balance: String
    let totalValue: String
    let change: String
    
    var changeLabelColor: Color {
        let priceChange: Decimal?
        switch selectedTimeframe {
        case .day:
            priceChange = ticker?[.usd].percentChange24h
        case .week:
            priceChange = ticker?[.usd].percentChange7d
        case .month:
            priceChange = ticker?[.usd].percentChange30d
        case .year:
            priceChange = ticker?[.usd].percentChange1y
        }
        
        guard let pChange = priceChange else {
            return .white
        }
        
        return pChange > 0 ? Color(red: 15/255, green: 235/255, blue: 131/255, opacity: 1) : Color(red: 255/255, green: 156/255, blue: 49/255, opacity: 1)
    }
    
    private let selectedTimeframe: Timeframe
    private let ticker: Ticker?
    private let balanceProvider: IBalanceProvider
    private let marketChangeProvider: IMarketChangeProvider
    private let marketData: CoinMarketData?
    
    init(asset: IAsset, marketData: MarketDataRepository?, selectedTimeFrame: Timeframe, fiatCurrency: FiatCurrency) {
        self.asset = asset
        self.balanceProvider = asset.balanceProvider
        self.marketChangeProvider = asset.marketChangeProvider
        self.marketData = marketData?.data(coin: asset.coin)
        self.ticker = marketData?.ticker(coin: asset.coin)
        self.selectedTimeframe = selectedTimeFrame
        
        balance = balanceProvider.balanceString
        
        if let ticker = marketData?.ticker(coin: asset.coin)  {
            let currentPrice = ticker[.usd].price * Decimal(fiatCurrency.rate)
            let changeInPercents = ticker[.usd].percentChange24h
            change = "\(changeInPercents > 0 ? "+" : "-")\(fiatCurrency.symbol)\(abs(currentPrice * (changeInPercents/100)).double.rounded(toPlaces: 2)) (\(changeInPercents.double.rounded(toPlaces: 2))%)"
            totalValue = "\(fiatCurrency.symbol)" + "\((balanceProvider.balance(currency: .fiat(USD)) * ticker[.usd].price * Decimal(fiatCurrency.rate)).rounded(toPlaces: 2))"
        } else {
            change = String()
            totalValue = String()
        }
    }
    
    private func change(currentPrice: Decimal, changeInPercents: Decimal) -> String {
        "\(changeInPercents > 0 ? "+" : "-")$\(abs(currentPrice * (changeInPercents/100)).double.rounded(toPlaces: 2)) (\(changeInPercents.double.rounded(toPlaces: 2))%)"
    }
}

final class AssetViewModel: ObservableObject {
    let asset: IAsset
            
    @Published var balance = String()
    @Published var totalValue = String()
    @Published var price = String()
    @Published var change = String()
    @Published var selectedTimeframe: Timeframe = .day
    
    @Published var chartDataEntries = [ChartDataEntry]()
    @Published var currency: Currency = .fiat(USD)
    @Published var valueCurrencySwitchState: ValueCurrencySwitchState = .fiat
    @Published var isLoadingData: Bool = false
        
    private let queue = DispatchQueue.main
    private let balanceProvider: IBalanceProvider
    private let marketChangeProvider: IMarketChangeProvider
    private var subscriptions = Set<AnyCancellable>()
    
//    private var marketData: CoinMarketData {
//        marketData(for: asset.coin.code)
//    }
//
//    private var rate: Double {
//        marketRate(for: USD)
//    }
    
    private var marketData: CoinMarketData?
    private var ticker: Ticker?
    private var marketDataRepository: MarketDataRepository?
    private var fiatCurrency: FiatCurrency
    
    var dayHigh: String {
        let dayHigh: Decimal = marketData?.dayHigh ?? 0
        return "\(fiatCurrency.symbol)\((dayHigh * Decimal(fiatCurrency.rate)).double.rounded(toPlaces: 2))"
    }
    
    var dayLow: String {
        let dayLow: Decimal = marketData?.dayLow ?? 0
        return "\(fiatCurrency.symbol)\((dayLow * Decimal(fiatCurrency.rate)).double.rounded(toPlaces: 2))"
    }
    
    init(asset: IAsset, marketData: MarketDataRepository?, fiatCurrency: FiatCurrency) {
        self.asset = asset
        self.balanceProvider = asset.balanceProvider
        self.marketChangeProvider = asset.marketChangeProvider
        self.marketDataRepository = marketData
        self.ticker = marketData?.ticker(coin: asset.coin)
        self.fiatCurrency = fiatCurrency
    
//        updateValues()
        
//        queue.schedule(
//            after: queue.now,
//            interval: .seconds(10)
//        ){ [weak self] in
//            self?.updateValues()
//        }
//        .store(in: &subscriptions)
        
        $selectedTimeframe
            .delay(for: 0.1, scheduler: RunLoop.main)
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
        guard let ticker = ticker else { return }
        self.marketData = marketDataRepository?.data(coin: asset.coin)
        balance = balanceProvider.balanceString
        price = "\(fiatCurrency.symbol)" + "\((ticker[.usd].price * Decimal(fiatCurrency.rate)).double.rounded(toPlaces: 2))"
        
        let currentPrice: Decimal
        
        switch valueCurrencySwitchState {
        case .fiat:
            totalValue = "\(fiatCurrency.symbol)" + "\((balanceProvider.balance(currency: .fiat(USD)) * ticker[.usd].price * Decimal(fiatCurrency.rate)).rounded(toPlaces: 2))"
            currentPrice = ticker[.usd].price * Decimal(fiatCurrency.rate)
        case .btc:
            totalValue = "\((balanceProvider.balance(currency: .btc) * ticker[.btc].price).rounded(toPlaces: 2)) BTC"
            currentPrice = ticker[.btc].price
        case .eth:
            totalValue = "\((balanceProvider.balance(currency: .eth) * ticker[.eth].price).rounded(toPlaces: 2)) ETH"
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
            priceChange = ticker?[.usd].percentChange24h
        case .week:
            priceChange = ticker?[.usd].percentChange7d
        case .month:
            priceChange = ticker?[.usd].percentChange30d
        case .year:
            priceChange = ticker?[.usd].percentChange1y
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
            points = marketData?.dayPoints ?? []
        case .week:
            points = marketData?.weekPoints ?? []
        case .month:
            points = marketData?.monthPoints ?? []
        case .year:
            points = marketData?.yearPoints ?? []
        }
        
        let xIndexes = Array(0..<points.count).map { x in Double(x) }
        for (index, point) in points.enumerated() {
            let dataEntry = ChartDataEntry(x: xIndexes[index], y: point.double)
            chartDataEntries.append(dataEntry)
        }
        
        return chartDataEntries
    }
}
