//
//  MockData.swift
//  Portal
//
//  Created by Farid on 06.03.2020.
//  Copyright © 2020 Tides Network. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

let btcMockAddress = "1HqwV7F9hpUpJXubLFomcrNMUqPLzeTVNd"

let USD = FiatCurrency(code: "USD", name: "American Dollar", rate: 1)

import BitcoinCore

final class MockCoinKit: AbstractKit {
    func send(amount: Double) {
        print("Send coins...")
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
    
    var lastBlockUpdated: AnyPublisher<Void, Never> = Just(()).eraseToAnyPublisher()
    
    var transactionRecords: AnyPublisher<[TransactionRecord], Never> {
        Future { promisse in
            promisse(.success([]))
        }
        .eraseToAnyPublisher()
    }
    
    func transactions(from: TransactionRecord?, limit: Int) -> Future<[TransactionRecord], Never> {
        Future { promisse in
            promisse(.success([]))
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
        
        md.dayPoints = [42258, 43127]
        md.weekPoints = [42290, 40600]
        md.monthPoints = [51200, 42000]
        md.yearPoints = [30000, 69000]
        
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

