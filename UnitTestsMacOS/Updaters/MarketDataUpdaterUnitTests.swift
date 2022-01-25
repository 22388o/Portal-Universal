//
//  MarketDataUpdaterUnitTests.swift
//  UnitTestsMacOS
//
//  Created by farid on 1/24/22.
//

import XCTest
@testable import Portal
import Coinpaprika
import Combine

class MarketDataUpdaterUnitTests: XCTestCase {
    
    private var sut: MarketDataUpdater!
    private let reachabilityService = MockedReachabilityService()
    private var subscriptions = Set<AnyCancellable>()
    
    private lazy var cachedTickers: [Ticker] = {
        let btcTickerData = CoinpaprikaBtcTickerJSON.data(using: .utf8)!
        let btcTicker = try! Ticker.decoder.decode(Ticker.self, from: btcTickerData)

        let ethTickerData = CoinpaprikaEthTickerJSON.data(using: .utf8)!
        let ethTicker = try! Ticker.decoder.decode(Ticker.self, from: ethTickerData)
        
        return [btcTicker, ethTicker]
    }()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        sut = MarketDataUpdater(cachedTickers: cachedTickers, reachability: reachabilityService)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        subscriptions.removeAll()
    }
    
    func testInitialTickers() throws {
        XCTAssertEqual(sut.tickers.isEmpty, false)
        XCTAssertEqual(sut.tickers, cachedTickers)
    }
    
    func testOnTickersUpdateSubscription() throws {
        XCTAssertEqual(sut.tickers.count, cachedTickers.count)

        let promisse = expectation(description: "Tickers updated")
        var updatedTickers: [Ticker] = []

        sut.onTickersUpdate
            .sink { tickers in
                updatedTickers = tickers
                promisse.fulfill()
            }
            .store(in: &subscriptions)

        wait(for: [promisse], timeout: 20)
        
        XCTAssertEqual(sut.tickers, updatedTickers)
    }
}
