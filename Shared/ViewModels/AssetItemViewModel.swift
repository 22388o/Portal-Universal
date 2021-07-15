//
//  AssetItemViewModel.swift
//  Portal
//
//  Created by Farid on 24.06.2021.
//

import SwiftUI
import Combine
import Coinpaprika
import RxSwift

final class AssetItemViewModel: ObservableObject {
    let asset: IAsset
    
    @Published private(set) var totalValue = String()
    @Published private(set) var change = String()
    @Published private(set) var balance = String()
    @Published private(set) var adapterState: AdapterState = .notSynced(error: AdapterError.wrongParameters)
    
    @Published var syncProgress: Float = 0
    
    private let serialQueueScheduler = SerialDispatchQueueScheduler(qos: .utility)
    private let disposeBag = DisposeBag()
    
    private let ticker: Ticker?
    
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
    private let fiatCurrency: FiatCurrency
    
    init(asset: IAsset, selectedTimeFrame: Timeframe, fiatCurrency: FiatCurrency, ticker: Ticker?) {
        self.asset = asset
        self.ticker = ticker
        
        self.selectedTimeframe = selectedTimeFrame
        self.fiatCurrency = fiatCurrency
        
        if let state = asset.balanceAdapter?.balanceState {
            self.adapterState = state
        }
                
        if let spendable = asset.balanceAdapter?.balance, let ticker = ticker {
            updateValues(spendable: spendable, unspendable: asset.balanceAdapter?.balanceLocked, ticker: ticker)
        }
        
        asset.balanceAdapter?.balanceStateUpdatedObservable
            .subscribeOn(serialQueueScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                if let adapter = asset.balanceAdapter, let ticker = self?.ticker {
                    self?.updateValues(spendable: adapter.balance, unspendable: adapter.balanceLocked, ticker: ticker)
                } else {
                    if let balance = asset.balanceAdapter?.balance {
                        self?.balance = "\(balance)"
                    }
                }
            })
            .disposed(by: disposeBag)
        
        
        asset.balanceAdapter?.balanceStateUpdatedObservable
            .subscribeOn(serialQueueScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                if let state = asset.balanceAdapter?.balanceState {
                    if case let .syncing(currentProgress, _) = state {
                        let progress = Float(currentProgress)/100
                        if self?.syncProgress != progress {
                            self?.syncProgress = progress
                            print("\(asset.coin.code) sync progress = \(currentProgress)")
                        }
                    }
                    if case .synced  = state {
                        print("\(asset.coin.code) is synced!")
                    }
                    self?.adapterState = state
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func updateValues(spendable: Decimal, unspendable: Decimal?, ticker: Ticker) {
        let currentPrice = ticker[.usd].price * Decimal(fiatCurrency.rate)
        let changeInPercents = ticker[.usd].percentChange24h
        
        change = "\(changeInPercents > 0 ? "+" : "-")\(fiatCurrency.symbol)\(abs(currentPrice * (changeInPercents/100)).double.rounded(toPlaces: 2)) (\(changeInPercents.double.rounded(toPlaces: 2))%)"
        
        if let unspendable = unspendable, unspendable > 0 {
            self.balance = "\(spendable) (\(unspendable))"
        } else {
            self.balance = "\(spendable)"
        }
        
        totalValue = "\(fiatCurrency.symbol)" + "\((spendable * ticker[.usd].price * Decimal(fiatCurrency.rate)).rounded(toPlaces: 2))"
    }
}
