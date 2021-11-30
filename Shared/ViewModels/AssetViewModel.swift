//
//  AssetViewModel.swift
//  Portal
//
//  Created by Farid on 20.05.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import SwiftUI
import Combine
import RxSwift
import Charts
import Coinpaprika

final class AssetViewModel: ObservableObject {
    @Published var timeframe: Timeframe = .day
    @Published var route: AssetViewRoute = .value
    
    @Published private(set) var balance = String()
    @Published private(set) var totalValue = String()
    @Published private(set) var change = String()
    @Published private(set) var chartDataEntries = [ChartDataEntry]()
    @Published private(set) var currency: Currency = .fiat(USD)
    @Published private(set) var canSend: Bool = false
    
    @ObservedObject private var state: PortalState
        
    private let serialQueueScheduler = SerialDispatchQueueScheduler(qos: .utility)
    private let disposeBag = DisposeBag()
    private let marketDataProvider: IMarketDataProvider
    private let walletManager: IWalletManager
    private let adapterManager: IAdapterManager
    private var subscriptions = Set<AnyCancellable>()
        
    private var marketData: CoinMarketData {
        marketDataProvider.marketData(coin: coin)
    }
    
    private var ticker: Ticker? {
        marketDataProvider.ticker(coin: coin)
    }
    
    private var btcUSDPrice: Decimal {
        marketDataProvider.ticker(coin: .bitcoin())?[.usd].price ?? 1
    }
    
    private var ethUSDPrice: Decimal {
        marketDataProvider.ticker(coin: .ethereum())?[.usd].price ?? 1
    }
    
    var coin: Coin
    var adapter: IBalanceAdapter?
    
    var rank: String {
        if let ticker = self.ticker {
            return "#\(ticker.rank)"
        } else {
            return "-"
        }
    }
    
    var totalSupply: String {
        if let ticker = self.ticker {
            return ticker.totalSupply.formattedDecimalString() + " " + coin.code
        } else {
            return "-"
        }
    }
    
    var maxSupply: String {
        if let ticker = self.ticker {
            if ticker.maxSupply > 0 {
                return ticker.maxSupply.formattedDecimalString() + " " + coin.code
            } else {
                return "Unlimited"
            }
        } else {
            return "-"
        }
    }
    
    var marketCap: String {
        if let ticker = self.ticker, let quote = ticker[.usd] {
            return quote.marketCap.formattedString(.fiat(USD))
        } else {
            return "-"
        }
    }
    
    var athPrice: String {
        if let ticker = self.ticker, let quote = ticker[.usd], let athPrice = quote.athPrice  {
            return athPrice.formattedString(.fiat(USD))
        } else {
            return "-"
        }
    }
    
    var athDate: String {
        if let ticker = self.ticker, let quote = ticker[.usd], let athPrice = quote.athDate  {
            return athPrice.timeAgoSinceDate(shortFormat: false)
        } else {
            return "-"
        }
    }
    
    var volume24h: String {
        if let ticker = self.ticker, let quote = ticker[.usd] {
            return quote.volume24h.formattedString(.fiat(USD))
        } else {
            return "-"
        }
    }
    
    var percentFromPriceAth: String {
        if let ticker = self.ticker, let quote = ticker[.usd], let percentFromPriceAth = quote.percentFromPriceAth {
            return "\(percentFromPriceAth.rounded(toPlaces: 2))%"
        } else {
            return "-"
        }
    }
            
    var highValue: String {
        let highValue: Decimal
        
        switch timeframe {
        case .day:
            highValue = marketData.dayHigh
        case .week:
            highValue = marketData.weekHigh
        case .month:
            highValue = marketData.monthHigh
        case .year:
            highValue = marketData.yearHigh
        }
        
        switch state.walletCurrency {
        case .btc:
            guard let ticker = marketDataProvider.ticker(coin: Coin.bitcoin()) else { return "-" }
            guard coin == .bitcoin() else {
                return (highValue/ticker[.usd].price).formattedString(state.walletCurrency, decimals: 4)
            }
            return "1 BTC"
        case .eth:
            guard let ticker = marketDataProvider.ticker(coin: Coin.ethereum()) else { return "-" }
            guard coin == .ethereum() else {
                return (highValue/ticker[.usd].price).formattedString(state.walletCurrency, decimals: 4)
            }
            return "1 ETH"
        case .fiat(let fiatCurrency):
            return (highValue * Decimal(fiatCurrency.rate)).formattedString(state.walletCurrency)
        }
    }
    
    var lowValue: String {
        let lowValue: Decimal
        
        switch timeframe {
        case .day:
            lowValue = marketData.dayLow
        case .week:
            lowValue = marketData.weekLow
        case .month:
            lowValue = marketData.monthLow
        case .year:
            lowValue = marketData.yearLow
        }
        
        switch state.walletCurrency {
        case .btc:
            guard let ticker = marketDataProvider.ticker(coin: Coin.bitcoin()) else { return "-" }
            guard coin == .bitcoin() else {
                return (lowValue/ticker[.usd].price).formattedString(state.walletCurrency, decimals: 4)
            }
            return "1 BTC"
        case .eth:
            guard let ticker = marketDataProvider.ticker(coin: Coin.ethereum()) else { return "-" }
            guard coin == .ethereum() else {
                return (lowValue/ticker[.usd].price).formattedString(state.walletCurrency, decimals: 4)
            }
            return "1 ETH"
        case .fiat(let fiatCurrency):
            return (lowValue * Decimal(fiatCurrency.rate)).formattedString(state.walletCurrency)
        }
    }
    
    var changeLabelColor: Color {
        let priceChange: Decimal?
        let quote: Ticker.Quote?
        
        switch state.walletCurrency {
        case .btc:
            quote = ticker?[.btc]
        case .eth:
            quote = ticker?[.eth]
        case .fiat:
            quote = ticker?[.usd]
        }
        
        switch timeframe {
        case .day:
            priceChange = quote?.percentChange24h
        case .week:
            priceChange = quote?.percentChange7d
        case .month:
            priceChange = quote?.percentChange30d
        case .year:
            priceChange = quote?.percentChange1y
        }
        
        guard let pChange = priceChange else {
            return .white
        }
        
        return pChange > 0 ? Color(red: 15/255, green: 235/255, blue: 131/255, opacity: 1) : Color(red: 255/255, green: 156/255, blue: 49/255, opacity: 1)
    }
        
    init(
        state: PortalState,
        walletManager: IWalletManager,
        adapterManager: IAdapterManager,
        marketDataProvider: IMarketDataProvider
    ) {
        self.state = state
        self.coin = state.selectedCoin
        self.walletManager = walletManager
        self.adapterManager = adapterManager
        self.marketDataProvider = marketDataProvider
        self.subscribeForUpdates()
    }
    
    deinit {
//        print("Deinit - \(coin.code)")
    }
    
    private func subscribeForUpdates() {
        $timeframe
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.update()
            }
            .store(in: &subscriptions)
        
        state.$walletCurrency
            .receive(on: RunLoop.main)
            .sink { [weak self] currency in
                self?.update()
            }
            .store(in: &subscriptions)
        
        state.$selectedCoin
            .receive(on: RunLoop.main)
            .sink { [weak self] coin in
                self?.route = .value
                self?.coin = coin
                self?.updateAdapter()
                self?.update()
            }
            .store(in: &subscriptions)
    }
    
    private func updateAdapter() {
        if let wallet = walletManager.activeWallets.first(where: { $0.coin == self.coin }),
           let adapter = adapterManager.balanceAdapter(for: wallet) {
            self.adapter = adapter
            canSend = adapter.balance > 0
        } else {
            adapter = nil
        }
        
        adapter?.balanceUpdatedObservable
            .subscribeOn(serialQueueScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.update()
            })
            .disposed(by: disposeBag)
    }
    
    private func update() {
        guard let ticker = self.ticker else { return }
        
        let currentPrice: Decimal
        
        switch state.walletCurrency {
        case .btc:
            currentPrice = ticker[.btc].price
        case .eth:
            currentPrice = ticker[.eth].price
        case .fiat(let fiatCurrency):
            currentPrice = ticker[.usd].price * Decimal(fiatCurrency.rate)
        }
        
        totalValue = currentPrice.formattedString(state.walletCurrency, decimals: 4)
                
        let isInteger = adapter?.balance.rounded(toPlaces: 6).isInteger ?? true
        
        if isInteger {
            balance = "\(adapter?.balance ?? 0)"
        } else {
            balance = "\(adapter?.balance.rounded(toPlaces: 6) ?? 0)"
        }
        
        let percentChange: Decimal
        
        switch timeframe {
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
        switch state.walletCurrency {
        case .btc:
            guard coin == .bitcoin() else {
                return "\(changeInPercents > 0 ? "+" : "-")\(abs(currentPrice * (changeInPercents/100)).formattedString(state.walletCurrency, decimals: 3)) (\(changeInPercents.double.roundToDecimal(2))%)"
            }
            return " "
        case .eth:
            guard coin == .ethereum() else {
                return "\(changeInPercents > 0 ? "+" : "-")\(abs(currentPrice * (changeInPercents/100)).formattedString(state.walletCurrency, decimals: 3)) (\(changeInPercents.double.roundToDecimal(2))%)"
            }
            return " "
        case .fiat:
            return "\(changeInPercents > 0 ? "+" : "-")\(abs(currentPrice * (changeInPercents/100)).formattedString(state.walletCurrency, decimals: 3)) (\(changeInPercents.double.roundToDecimal(2))%)"
        }
    }
    
    private func assetChartDataEntries() -> [ChartDataEntry] {
        guard Portal.shared.reachabilityService.isReachable else { return [] }
        
        var chartDataEntries = [ChartDataEntry]()
        var points = [Decimal]()
        
        if hasChartData(timeframe: timeframe) {
            points = chartDataPonts(timeframe: timeframe)
        } else {
            marketDataProvider.requestHistoricalData(coin: coin, timeframe: timeframe)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.chartDataEntries = self.assetChartDataEntries()
            }
        }
        
        for (index, point) in points.enumerated() {
            let dataEntry = ChartDataEntry(x: Double(index), y: point.double)
            chartDataEntries.append(dataEntry)
        }
        
        return chartDataEntries
    }
    
    private func hasChartData(timeframe: Timeframe) -> Bool {
        return !chartDataPonts(timeframe: timeframe).isEmpty
    }
    
    private func chartDataPonts(timeframe: Timeframe) -> [Decimal] {
        let points: [Decimal]
        
        switch timeframe {
        case .day:
            points = marketData.dayPoints
        case .week:
            points = marketData.weekPoints
        case .month:
            points = marketData.monthPoints
        case .year:
            points = marketData.yearPoints
        }
        
        switch state.walletCurrency {
        case .btc:
            return points.map{ $0/btcUSDPrice }
        case .eth:
            return points.map{ $0/ethUSDPrice }
        case .fiat(let fiatCurrency):
            return points.map{ $0 * Decimal(fiatCurrency.rate) }
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
