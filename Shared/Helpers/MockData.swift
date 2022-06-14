//
//  MockData.swift
//  Portal
//
//  Created by Farid on 06.03.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation
import SwiftUI

let btcMockAddress = "1HqwV7F9hpUpJXubLFomcrNMUqPLzeTVNd"

let USD = FiatCurrency(code: "USD", name: "American Dollar", rate: 1)

import BitcoinCore

final class MockCoinKit: AbstractKit {
    func send(amount: Double) {
        print("Send coins...")
    }
}

import Coinpaprika
import Combine

struct TickerH: Decodable {
    let timestamp: String
    let price: Decimal
    let volume_24h: Decimal
    let market_cap: Decimal
}

struct MockedMarketDataUpdater: IMarketDataUpdater {
    
    func btcTickerHistoricalPriceData(timeFrame: MarketDataRange) -> (MarketDataRange, HistoricalTickerPrice) {
        let responseData = btcTickerHistoryResponse.data(using: .utf8)!
        do {
            let data = try JSONDecoder().decode([TickerH].self, from: responseData)
            return (timeFrame, ["BTC": data.map{ PricePoint(timestamp: Date(), price: $0.price) }])
        } catch {
            print("\(#function) error: \(error)")
            return (timeFrame, ["BTC": []])
        }
    }
    
    var onUpdateHistoricalPrice = PassthroughSubject<(MarketDataRange, HistoricalTickerPrice), Never>()
    
    var onUpdateHistoricalData = PassthroughSubject<(MarketDataRange, HistoricalDataResponse), Never>()
    
    var onTickersUpdate = PassthroughSubject<([Ticker]), Never>()
    
    func requestHistoricalMarketData(coin: Coin, timeframe: Timeframe) {
        switch timeframe {
        case .day:
            onUpdateHistoricalPrice.send(btcTickerHistoricalPriceData(timeFrame: .day))
        case .week:
            onUpdateHistoricalPrice.send(btcTickerHistoricalPriceData(timeFrame: .week))
        case .month:
            onUpdateHistoricalPrice.send(btcTickerHistoricalPriceData(timeFrame: .month))
        case .year:
            onUpdateHistoricalPrice.send(btcTickerHistoricalPriceData(timeFrame: .year))
        }
    }
}

import CoreData

class MockedCacheStorage: IDBCacheStorage {
    var context: NSManagedObjectContext {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main])!
        
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        } catch {
            print("Adding in-memory persistent store failed")
        }
        
        let managedObjectContext = NSManagedObjectContext.init(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        return managedObjectContext
    }
    
    var tickers: [Ticker] = []
    
    var fiatCurrencies: [FiatCurrency] = []
    
    func store(fiatCurrencies: [FiatCurrency]) {
        self.fiatCurrencies = fiatCurrencies
    }
    
    func store(tickers: [Ticker]?) {
        self.tickers = tickers ?? []
    }
    
    init() {
        let btcTickerData = CoinpaprikaBtcTickerJSON.data(using: .utf8)!
        let btcTicker = try! Ticker.decoder.decode(Ticker.self, from: btcTickerData)
        tickers = [btcTicker]
        
        let dollar: FiatCurrency = USD
        let ruble: FiatCurrency = .init(code: "RUB", name: "Russian ruble")
        
        fiatCurrencies = [dollar, ruble]
    }
}

struct MockedBalanceAdapter: IBalanceAdapter {
    var balanceStateUpdated: AnyPublisher<Void, Never> = Just(()).eraseToAnyPublisher()
    
    var balanceUpdated: AnyPublisher<Void, Never> = Just(()).eraseToAnyPublisher()
    
    var balanceState: AdapterState = .synced
        
    var balance: Decimal = 2.25
        
    init() {}
}

struct MockedTransactionAdapter: ITransactionsAdapter {
    var coin: Coin = .bitcoin()
    
    var transactionState: AdapterState = .synced
    
    var lastBlockInfo: LastBlockInfo? = nil
    
    var transactionStateUpdated: AnyPublisher<Void, Never> = Just(()).eraseToAnyPublisher()
    
    var lastBlockUpdated: AnyPublisher<LastBlockInfo?, Never> = Just(nil).eraseToAnyPublisher()
    
    var transactionRecords: AnyPublisher<[TransactionRecord], Never> {
        Future { promise in
            promise(.success([]))
        }
        .eraseToAnyPublisher()
    }
    
    func transactions(from: TransactionRecord?, limit: Int) -> Future<[TransactionRecord], Never> {
        Future { promise in
            promise(.success([]))
        }
    }
    
    func rawTransaction(hash: String) -> String? {
        nil
    }
    
    
}

class MockedBalanceAdapterWithUnspendable: IBalanceAdapter {
    var balanceStateUpdated: AnyPublisher<Void, Never> = Just(()).eraseToAnyPublisher()
    
    var balanceUpdated: AnyPublisher<Void, Never> = Just(()).eraseToAnyPublisher()
    
    var balanceState: AdapterState = .synced
        
    var balance: Decimal = 1.25
    var balanceLocked: Decimal? = 0.3123
        
    init() {}
}

class WalletMock: IWallet {
    var mnemonicDereviation: MnemonicDerivation = .bip44
    var walletID: UUID = UUID()
    var name: String = "Personal"
    var fiatCurrencyCode: String = "USD"
    
    var assets = [IAsset]()
    
    init() {
        let btc = Coin(type: .bitcoin, code: "BTC", name: "Bitcoin", decimal: 18, iconUrl: String())
//        let bch = Coin(code: "BCH", name: "Bitcoin Cash", color: Color.gray, icon: Image("iconBch"))
        let eth = Coin(type: .ethereum, code: "ETH", name: "Ethereum", decimal: 18, iconUrl: String())
//        let xlm = Coin(code: "XLM", name: "Stellar Lumens", color: Color.blue, icon: Image("iconXlm"))
//        let xtz = Coin(code: "XTZ", name: "Tezos", color: Color.red, icon: Image("iconXtz"))
        
        self.assets = [
            Asset(account: MockedAccount(), coin: btc),
            Asset(account: MockedAccount(), coin: eth),
        ]
    }
    
    func setup() {}
    func stop() {}
    func start() {}
    func addTx(coin: Coin, amount: Decimal, receiverAddress: String, memo: String?) {}
    func updateFiatCurrency(_ fiatCurrency: FiatCurrency) {}
}

import Coinpaprika
import Combine

class MockedMarketDataProvider: IMarketDataProvider {
    var onMarketDataUpdate = PassthroughSubject<Void, Never>()
    
    var fiatCurrencies: [FiatCurrency] = []
    
    var tickers: [Ticker]?
    
    func ticker(coin: Coin) -> Ticker? {
        tickers?.first(where: { $0.symbol == coin.code })
    }
    
    func marketData(coin: Coin) -> CoinMarketData {
        var md = CoinMarketData()
        
        md.dayPoints = [PricePoint(timestamp: Date(), price: 42258), PricePoint(timestamp: Date(), price: 43127)]
        md.weekPoints = [PricePoint(timestamp: Date(), price: 42290), PricePoint(timestamp: Date(), price: 40600)]
        md.monthPoints = [PricePoint(timestamp: Date(), price: 51200), PricePoint(timestamp: Date(), price: 42000)]
        md.yearPoints = [PricePoint(timestamp: Date(), price: 30000), PricePoint(timestamp: Date(), price: 69000)]
        
        return md
    }
    
    func requestHistoricalData(coin: Coin, timeframe: Timeframe) {
        
    }
    
    init() {
        let btcTickerData = CoinpaprikaBtcTickerJSON.data(using: .utf8)!
        
        let btcTicker = try! Ticker.decoder.decode(Ticker.self, from: btcTickerData)

        let ethTickerData = CoinpaprikaEthTickerJSON.data(using: .utf8)!
        let ethTicker = try! Ticker.decoder.decode(Ticker.self, from: ethTickerData)
        
        let mockCoinTickerData = MockCoinTickerJSON.data(using: .utf8)!
        let mockCoinTicker = try! Ticker.decoder.decode(Ticker.self, from: mockCoinTickerData)
        
        tickers = [btcTicker, ethTicker, mockCoinTicker]
    }
}

