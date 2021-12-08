//
//  PortfolioItem.swift
//  Portal
//
//  Created by Farid on 11/30/21.
//

import Coinpaprika
import RxSwift

class PortfolioItem: ObservableObject {
    let coin: Coin
    
    @Published private(set) var transactions: [TransactionRecord] = []
    @Published private(set) var balance: Decimal
    @Published private(set) var price: Decimal
    
    private let balanceAdapter: IBalanceAdapter
    private let marketDataProvider: IMarketDataProvider
    private var disposeBag = DisposeBag()
    
    private var btcUSDPrice: Decimal {
        marketDataProvider.ticker(coin: .bitcoin())?[.usd].price ?? 1
    }
    
    private var ethUSDPrice: Decimal {
        marketDataProvider.ticker(coin: .ethereum())?[.usd].price ?? 1
    }
    
    var balanceValue: Decimal {
        balanceAdapter.balance * (ticker?[.usd].price ?? 1)
    }
    
    var dayChange: Decimal {
        marketData.dayChange
    }
    
    var weekChange: Decimal {
        marketData.weekChange
    }
    
    var monthChange: Decimal {
        marketData.monthChange
    }
    
    var yearChange: Decimal {
        marketData.yearChange
    }
    
    var marketData: CoinMarketData {
        marketDataProvider.marketData(coin: coin)
    }
    
    var ticker: Ticker? {
        marketDataProvider.ticker(coin: coin)
    }

    init(
        coin: Coin,
        balanceAdapter: IBalanceAdapter,
        transactionAdapter: ITransactionsAdapter,
        marketDataProvider: IMarketDataProvider
    ) {
        self.coin = coin
        self.balanceAdapter = balanceAdapter
        self.marketDataProvider = marketDataProvider
        self.balance = balanceAdapter.balance
        self.price = marketDataProvider.ticker(coin: coin)?[.usd].price ?? 1
        
        transactionAdapter.transactionsSingle(from: nil, limit: 1000)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] records in
                self?.transactions = records
            })
            .disposed(by: disposeBag)
        
        balanceAdapter
            .balanceUpdatedObservable
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.balance = balanceAdapter.balance
            })
            .disposed(by: disposeBag)
    }
    
    private func values(timeframe: Timeframe, points: [Decimal]) -> [Double] {
        let maxIndex = points.count
        let calendar = Calendar.current
        let currentDate = currentDateInUserTimeZone()
        
        switch timeframe {
        case .day, .week:
            return points.enumerated().map{ (index, point) in
                let timestamp = calendar.date(byAdding: .hour, value: index - maxIndex, to: currentDate)?.timeIntervalSince1970
                let balanceAtTimestamp = balance(at: timestamp)
                let value = point * balanceAtTimestamp
                
                switch Portal.shared.state.wallet.currency {
                case .btc:
                    return (value/btcUSDPrice).double
                case .eth:
                    return (value/ethUSDPrice).double
                case .fiat(let fiatCurrency):
                    return value.double * fiatCurrency.rate
                }
            }
        case .month, .year:
            return points.enumerated().map{ (index, point) in
                let timestamp = calendar.date(byAdding: .day, value: index - maxIndex, to: currentDate)?.timeIntervalSince1970
                let balanceAtTimestamp = balance(at: timestamp)
                let value = point * balanceAtTimestamp
                
                switch Portal.shared.state.wallet.currency {
                case .btc:
                    return (value/btcUSDPrice).double
                case .eth:
                    return (value/ethUSDPrice).double
                case .fiat(let fiatCurrency):
                    return value.double * fiatCurrency.rate
                }
            }
        }
    }
    
    private func currentDateInUserTimeZone() -> Date {
        let currentDate = Date()
        let timezoneOffset =  TimeZone.current.secondsFromGMT()
        let epochDate = currentDate.timeIntervalSince1970
        let timezoneEpochOffset = (epochDate + Double(timezoneOffset))
        let timeZoneOffsetDate = Date(timeIntervalSince1970: timezoneEpochOffset)
        return timeZoneOffsetDate
    }
    
    private func balance(at time: TimeInterval?) -> Decimal {
        guard let timestamp = time, transactions.count > 0 else { return 0 }
        
        let txsBefoGivenDate = transactions.filter{ timestamp >= $0.date.timeIntervalSince1970 }
        let totalReceived = txsBefoGivenDate.filter{$0.type == .incoming}.map{$0.amount}.reduce(0){ $0 + $1 }
        let totalSent = txsBefoGivenDate.filter{$0.type == .outgoing}.compactMap{$0.amount + ($0.fee ?? 0)}.reduce(0){ $0 + $1 }
        let balanceByGivenDate = totalReceived - totalSent
        
        return balanceByGivenDate >= 0 ? balanceByGivenDate : abs(balanceByGivenDate)
    }
    
    private func chartDataPonts(timeframe: Timeframe) -> [Decimal] {
        switch timeframe {
        case .day:
            return marketData.dayPoints
        case .week:
            return marketData.weekPoints
        case .month:
            return marketData.monthPoints
        case .year:
            return marketData.yearPoints
        }
    }
    
    func hasChartData(timeframe: Timeframe) -> Bool {
        return !chartDataPonts(timeframe: timeframe).isEmpty
    }
    
    func highestLowestValue(timeframe: Timeframe) -> (low: Decimal, high: Decimal) {
        switch timeframe {
        case .day:
            return ((marketData.dayLow * balance), (marketData.dayHigh * balance))
        case .week:
            return ((marketData.weekLow * balance), (marketData.weekHigh * balance))
        case .month:
            return ((marketData.monthLow * balance), (marketData.monthHigh * balance))
        case .year:
            return ((marketData.yearLow * balance), (marketData.yearHigh * balance))
        }
    }
    
    func pricePoints(timeframe: Timeframe) -> [Double] {
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
        
        return values(timeframe: timeframe, points: points)
    }
    
    func balanceValue(for currency: Currency) -> Decimal {
        switch currency {
        case .btc:
            return balanceAdapter.balance * (ticker?[.btc].price ?? 1)
        case .eth:
            return balanceAdapter.balance * (ticker?[.eth].price ?? 1)
        case .fiat(let fiatCurrency):
            return balanceAdapter.balance * (ticker?[.usd].price ?? 1) * Decimal(fiatCurrency.rate)
        }
    }
    
    func balanceValue(for currency: Currency, at timeframe: Timeframe) -> Decimal {
        let calendar = Calendar.current
        let currentDate = currentDateInUserTimeZone()
        let timestamp: TimeInterval?
        let pricePont: Decimal?
        
        switch timeframe {
        case .day:
            pricePont = marketData.dayPoints.first
            timestamp = calendar.date(byAdding: .day, value: -1, to: currentDate)?.timeIntervalSince1970
        case .week:
            pricePont = marketData.weekPoints.first
            timestamp = calendar.date(byAdding: .day, value: -7, to: currentDate)?.timeIntervalSince1970
        case .month:
            pricePont = marketData.monthPoints.first
            timestamp = calendar.date(byAdding: .month, value: -1, to: currentDate)?.timeIntervalSince1970
        case .year:
            pricePont = marketData.yearPoints.first
            timestamp = calendar.date(byAdding: .year, value: -1, to: currentDate)?.timeIntervalSince1970
        }
        
        guard let price = pricePont, let timeInterval = timestamp else { return 0 }
        
        let balanceAtTimestamp = balance(at: timeInterval)
        
        switch currency {
        case .btc:
            return balanceAtTimestamp > 0 ? (balanceAtTimestamp * price)/btcUSDPrice : 0
        case .eth:
            return balanceAtTimestamp > 0 ? (balanceAtTimestamp * price)/ethUSDPrice : 0
        case .fiat(let fiatCurrency):
            return balanceAtTimestamp > 0 ? balanceAtTimestamp * price * Decimal(fiatCurrency.rate) : 0
        }
    }
}
