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
    let adapter: IBalanceAdapter
    let coin: Coin
    
    @Published private(set) var totalValueString = String()
    @Published private(set) var changeString = String()
    @Published private(set) var balanceString = String()
    @Published private(set) var adapterState: AdapterState = .notSynced(error: AdapterError.wrongParameters)
    
    @Published var syncProgress: Float = 0.01
    
    private let notificationService: NotificationService
    private let serialQueueScheduler = SerialDispatchQueueScheduler(qos: .utility)
    private let disposeBag = DisposeBag()
    private var subscriptions = Set<AnyCancellable>()
    
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
    private var fiatCurrency: FiatCurrency
    
    init(coin: Coin, adapter: IBalanceAdapter, state: PortalState, ticker: Ticker?, notificationService: NotificationService) {
        self.coin = coin
        self.adapter = adapter
        self.ticker = ticker
        self.notificationService = notificationService
        
        self.selectedTimeframe = .day
        self.fiatCurrency = state.fiatCurrency
        
        self.adapterState = adapter.balanceState
        
        updateBalance()
        
        adapter.balanceUpdatedObservable
            .subscribeOn(serialQueueScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.updateBalance()
            })
            .disposed(by: disposeBag)
        
        adapter.balanceStateUpdatedObservable
            .subscribeOn(serialQueueScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                let state = adapter.balanceState
                if case let .syncing(currentProgress, _) = state {
                    let progress = Float(currentProgress)/100
                    if self?.syncProgress != progress {
                        self?.syncProgress = progress
                        print("\(coin.code) sync progress: \(currentProgress)")
                    }
                }
                if case .synced  = state {
                    print("\(coin.code) synced")
                }
                self?.adapterState = state
            })
            .disposed(by: disposeBag)
        
        state.$fiatCurrency
            .sink { [weak self] currency in
                self?.fiatCurrency = currency
                self?.updateBalance()
            }
            .store(in: &subscriptions)
    }
    
    private func updateBalance() {
        if let ticker = ticker {
            updateValues(spendable: adapter.balance, unspendable: adapter.balanceLocked, ticker: ticker)
        } else {
            balanceString = "\(adapter.balance) \(coin.code)"
        }
    }
    
    private func updateValues(spendable: Decimal, unspendable: Decimal?, ticker: Ticker) {
        let currentPrice = ticker[.usd].price * Decimal(fiatCurrency.rate)
        let changeInPercents = ticker[.usd].percentChange24h
        let prefix = "\(changeInPercents > 0 ? "+" : "-")"
        let symbol = fiatCurrency.symbol
        let percentChangeString = "(\(changeInPercents.double.rounded(toPlaces: 2))%)"
        let priceChange = abs(currentPrice * (changeInPercents/100)).double.rounded(toPlaces: 2)
        
        changeString = "\(prefix)\(symbol)\(priceChange) \(percentChangeString)"
        
        let isInteger = spendable.rounded(toPlaces: 4).isInteger
        let updatedBalanceString: String
        
        if let unspendable = unspendable, unspendable > 0 {
            updatedBalanceString = isInteger ? "\(spendable) (\(unspendable.rounded(toPlaces: 6))) \(coin.code)" : "\(spendable.rounded(toPlaces: 6)) (\(unspendable.rounded(toPlaces: 6))) \(coin.code)"
        } else {
            updatedBalanceString = isInteger ? "\(spendable) \(coin.code)" : "\(spendable.rounded(toPlaces: 6)) \(coin.code)"
        }
        
        if balanceString != updatedBalanceString && !balanceString.isEmpty {
            balanceString = updatedBalanceString
            notificationService.notify(PNotification(message: "\(coin.code) balance updated: \(balanceString)"))
        } else {
            balanceString = updatedBalanceString
        }
        
        totalValueString = "\(symbol)\((spendable * ticker[.usd].price * Decimal(fiatCurrency.rate)).rounded(toPlaces: 2))"
    }
    
    deinit {
//        print("\(coin.code) view model deinit")
    }
}

extension AssetItemViewModel {
    static func config(coin: Coin, adapter: IBalanceAdapter) -> AssetItemViewModel {
        let state = Portal.shared.state
        let marketDataProvider = Portal.shared.marketDataProvider
        let ticker = marketDataProvider.ticker(coin: coin)
        let notificationService = Portal.shared.notificationService
        
        return AssetItemViewModel(coin: coin, adapter: adapter, state: state, ticker: ticker, notificationService: notificationService)
    }
}


