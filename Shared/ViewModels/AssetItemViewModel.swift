//
//  AssetItemViewModel.swift
//  Portal
//
//  Created by Farid on 24.06.2021.
//

import SwiftUI
import Combine
import Coinpaprika

final class AssetItemViewModel: ObservableObject {
    let asset: IAsset
    
    @Published private(set) var totalValue = String()
    @Published private(set) var change = String()
    @Published private(set) var balance = String()
    @Published private(set) var kitBalanceUpdateState: KitSyncState = .notSynced(error: PError.unknow)
    @Published var syncProgress: Float = 0
    
    private var cancellable = Set<AnyCancellable>()
    
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
    
    private let selectedTimeframe: Timeframe
    private let balanceProvider: IBalanceProvider
    private let marketChangeProvider: IMarketChangeProvider
    private let fiatCurrency: FiatCurrency
    
    init(asset: IAsset, selectedTimeFrame: Timeframe, fiatCurrency: FiatCurrency) {
        self.asset = asset
        self.balanceProvider = asset.balanceProvider
        self.marketChangeProvider = asset.marketChangeProvider
        
        self.selectedTimeframe = selectedTimeFrame
        self.fiatCurrency = fiatCurrency
                
        if let spendable = asset.kit?.balance.spendable, let ticker = asset.marketDataProvider.ticker {
            updateValues(spendable: spendable, unspendable: asset.kit?.balance.unspendable, ticker: ticker)
        }
                
        asset.balanceStatePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] (state) in
                self?.kitBalanceUpdateState = state
                if case let .syncing(currentProgress, _) = state {
                    self?.syncProgress = Float(currentProgress)/100
                    print("sync progress = \(Float(currentProgress)/100)")
                }
            }
            .store(in: &cancellable)
        
        asset.balanceUpdatedSubject
            .receive(on: RunLoop.main)
            .sink { [weak self] balanceInfo in
                let balanceInSat = balanceInfo.spendable
                let coinRate = asset.coinRate
                let balance = Decimal(balanceInSat)/coinRate
                
                self?.balance = "\(balance)"
            }
            .store(in: &cancellable)
    }
    
    private func updateValues(spendable: Int, unspendable: Int?, ticker: Ticker) {
        let currentPrice = ticker[.usd].price * Decimal(fiatCurrency.rate)
        let changeInPercents = ticker[.usd].percentChange24h
        
        change = "\(changeInPercents > 0 ? "+" : "-")\(fiatCurrency.symbol)\(abs(currentPrice * (changeInPercents/100)).double.rounded(toPlaces: 2)) (\(changeInPercents.double.rounded(toPlaces: 2))%)"
        
        let balanceInSat = spendable
        let coinRate = asset.coinRate
        let balance = Decimal(balanceInSat)/coinRate
        
        if let unspendable = unspendable, unspendable > 0 {
            let unspendableBalanceInSat = unspendable
            let unspendableBalance = Decimal(unspendableBalanceInSat)/coinRate
            
            self.balance = "\(balance) (\(unspendableBalance))"
        } else {
            self.balance = "\(balance)"
        }
        
        totalValue = "\(fiatCurrency.symbol)" + "\((balance * ticker[.usd].price * Decimal(fiatCurrency.rate)).rounded(toPlaces: 2))"
    }
}
