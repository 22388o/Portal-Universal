//
//  PortfolioItem.swift
//  Portal
//
//  Created by Farid on 11/30/21.
//

import Coinpaprika
import Combine
import Foundation

class PortfolioItem: ObservableObject {
    let coin: Coin
    
    @Published private(set) var transactions: [TransactionRecord] = []
    @Published private(set) var balance: Decimal
    @Published private(set) var price: Decimal
    
    private let balanceAdapter: IBalanceAdapter
    private let marketDataProvider: IMarketDataProvider
    private var subscriptions = Set<AnyCancellable>()
    
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
        
        transactionAdapter.transactions(from: nil, limit: 1000)
            .receive(on: RunLoop.main)
            .sink { [weak self] records in
                self?.transactions = records
            }
            .store(in: &subscriptions)

        balanceAdapter.balanceUpdated
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] _ in
                self?.balance = balanceAdapter.balance
            })
            .store(in: &subscriptions)
    }
    
    private func values(timeframe: Timeframe, points: [PricePoint]) -> [Double] {
        return points.enumerated().map{ (index, point) in
            let adjustedDate: Date

            switch timeframe {
            case .day:
                adjustedDate = Calendar.current.date(byAdding: .hour, value: 10, to: point.timestamp) ?? point.timestamp
            case .week:
                adjustedDate = Calendar.current.date(byAdding: .hour, value: 28, to: point.timestamp) ?? point.timestamp
            case .month:
                adjustedDate = Calendar.current.date(byAdding: .day, value: 4, to: point.timestamp) ?? point.timestamp
            case .year:
                adjustedDate = Calendar.current.date(byAdding: .month, value: 1, to: point.timestamp) ?? point.timestamp
            }

            let balanceAtTimestamp = balance(at: adjustedDate.timeIntervalSince1970)
            let value = point.price * balanceAtTimestamp

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
    
    private func balance(at time: TimeInterval?) -> Decimal {
        guard let timestamp = time, transactions.count > 0 else { return 0 }
        
        let txsBefoGivenDate = transactions.filter{ timestamp >= $0.date.timeIntervalSince1970 }
        let totalReceived = txsBefoGivenDate.filter{$0.type == .incoming}.map{$0.amount}.reduce(0){ $0 + $1 }
        let totalSent = txsBefoGivenDate.filter{$0.type == .outgoing}.compactMap{$0.amount + ($0.fee ?? 0)}.reduce(0){ $0 + $1 }
        let balanceByGivenDate = totalReceived - totalSent
        
        return balanceByGivenDate //>= 0 ? balanceByGivenDate : abs(balanceByGivenDate)
    }
    
    private func chartDataPonts(timeframe: Timeframe) -> [PricePoint] {
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
        let points: [PricePoint]
        
        switch timeframe {
        case .day:
            points = marketData.dayPoints.enumerated().filter { $0.offset.isMultiple(of: 4) }.map { $0.element }
        case .week:
            points = marketData.weekPoints.enumerated().filter { $0.offset.isMultiple(of: 5) }.map { $0.element }
        case .month:
            points = marketData.monthPoints.enumerated().filter { $0.offset.isMultiple(of: 3) }.map { $0.element }
        case .year:
            points = marketData.yearPoints.enumerated().filter { $0.offset.isMultiple(of: 4) }.map { $0.element }
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
        let pricePont: PricePoint?
        
        switch timeframe {
        case .day:
            pricePont = marketData.dayPoints.last
        case .week:
            pricePont = marketData.weekPoints.last
        case .month:
            pricePont = marketData.monthPoints.last
        case .year:
            pricePont = marketData.yearPoints.last
        }
                
        guard
            let price = pricePont?.price,
            let timeInterval = pricePont?.timestamp.timeIntervalSince1970
        else {
            return 0
        }
        
        let balanceAtTimestamp = balance(at: timeInterval)
        
        switch currency {
        case .btc:
            return balanceAtTimestamp > 0 ? (balanceAtTimestamp * price)/btcUSDPrice : 0
        case .eth:
            return balanceAtTimestamp > 0 ? (balanceAtTimestamp * price)/ethUSDPrice : 0
        case .fiat(let fiatCurrency):
            return balanceAtTimestamp > 0 ? (balanceAtTimestamp * price) * Decimal(fiatCurrency.rate) : 0
        }
    }
}

extension PortfolioItem: Equatable {
    static func == (lhs: PortfolioItem, rhs: PortfolioItem) -> Bool {
        lhs.coin == rhs.coin
    }
}
