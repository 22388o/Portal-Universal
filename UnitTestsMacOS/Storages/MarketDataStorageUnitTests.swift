//
//  MarketDataStorageUnitTests.swift
//  UnitTestsMacOS
//
//  Created by farid on 1/24/22.
//

import XCTest
@testable import Portal
import Combine
import CoreData

class MarketDataStorageUnitTests: XCTestCase {
    
    private var sut: MarketDataStorage!
    private var subscriptions = Set<AnyCancellable>()
    
    private let marketDataUpdater = MockedMarketDataUpdater()
    private let fiatCurrenciesUpdater = MockedFiatCurrenciesUpdater()
    private let cacheStorage = MockedCacheStorage()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = MarketDataStorage(mdUpdater: marketDataUpdater, fcUpdater: fiatCurrenciesUpdater, cacheStorage: cacheStorage)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
    }
    
    func testRequestHistoricalDataUppdatesMarketDataSubscription() throws {
        let promisse = expectation(description: "Request historical data trigger onMarketUpdate")
                
        sut.onMarketDataUpdate
            .sink { _ in
                promisse.fulfill()
            }
            .store(in: &subscriptions)
        
        sut.requestHistoricalData(coin: .bitcoin(), timeframe: .day)
        
        wait(for: [promisse], timeout: 0.2)
    }
    
    func testRequestHistoricalData() throws {
        sut.requestHistoricalData(coin: .bitcoin(), timeframe: .day)
        
        XCTAssertEqual(sut.marketData(coin: .bitcoin()).dayPoints.isEmpty, false)
        
        sut.requestHistoricalData(coin: .bitcoin(), timeframe: .week)
        
        XCTAssertEqual(sut.marketData(coin: .bitcoin()).weekPoints.isEmpty, false)
        
        sut.requestHistoricalData(coin: .bitcoin(), timeframe: .month)
        
        XCTAssertEqual(sut.marketData(coin: .bitcoin()).monthPoints.isEmpty, false)
        
        sut.requestHistoricalData(coin: .bitcoin(), timeframe: .year)
        
        XCTAssertEqual(sut.marketData(coin: .bitcoin()).yearPoints.isEmpty, false)
    }
    
    func testMarketDataForCoin() throws {
        XCTAssertNotNil(sut.marketData(coin: .bitcoin()))
    }
    
    func testTickerForCoin() throws {
        XCTAssertNil(sut.ticker(coin: .ethereum()))
        XCTAssertNotNil(sut.ticker(coin: .bitcoin()), "Btc ticker isn't found")
    }
    
    func testOnMarketDataTickersUpdate() throws {
        XCTAssertEqual(sut.tickers?.isEmpty, false)
                        
        marketDataUpdater.onTickersUpdate.send([])
        
        let promisse = expectation(description: "wait sut tickers refresh")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            promisse.fulfill()
        }
        
        wait(for: [promisse], timeout: 0.2)
        
        XCTAssertEqual(sut.tickers?.isEmpty, true)
    }
    
    func testOnFiatCurrenciesUpdate() throws {
        XCTAssertEqual(sut.fiatCurrencies.isEmpty, false)
        XCTAssertEqual(sut.fiatCurrencies.count, 2)
        
        let dollar: FiatCurrency = USD
        let ruble: FiatCurrency = .init(code: "RUB", name: "Russian ruble")
        let euro: FiatCurrency = .init(code: "EUR", name: "Euro")
        let mocked: FiatCurrency = .init(code: "MOCK", name: "Mocked")
        
        let testArray = [dollar, ruble, euro, mocked]
        
        fiatCurrenciesUpdater.onFiatCurrenciesUpdate.send(testArray)
        
        let promisse = expectation(description: "wait sut fiat currencies refresh")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            promisse.fulfill()
        }
        
        wait(for: [promisse], timeout: 0.2)
        
        XCTAssertNotEqual(sut.fiatCurrencies.count, testArray.count)
        XCTAssertEqual(sut.fiatCurrencies.count, testArray.count - 1)
    }
}
