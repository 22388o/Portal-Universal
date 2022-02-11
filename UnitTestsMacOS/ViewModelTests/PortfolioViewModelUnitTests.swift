//
//  PortfolioViewModelUnitTests.swift
//  UnitTestsMacOS
//
//  Created by farid on 1/14/22.
//

import XCTest
@testable import Portal

class PortfolioViewModelUnitTests: XCTestCase {
    
    private var sut: PortfolioViewModel!
    private let walletMannager = MockedWalletManager()
    private let adapterMannager = MockedAdapterManager()
    private let marketDataProvider = MockedMarketDataProvider()
    private let reachabilityService = MockedReachabilityService()
    private let state = PortalState()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = PortfolioViewModel(
            walletManager: walletMannager,
            adapterManager: adapterMannager,
            marketDataProvider: marketDataProvider,
            reachabilityService: reachabilityService,
            state: state
        )
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
    }
    
    func testConfig() throws {
        sut = PortfolioViewModel.config()
        XCTAssertNotNil(sut)
    }
    
    func testDefaultValues() throws {
        XCTAssertEqual(sut.assets.isEmpty, true)
        XCTAssertEqual(sut.totalValue.isEmpty, true)
        XCTAssertEqual(sut.change.isEmpty, true)
        XCTAssertEqual(sut.lowest.isEmpty, true)
        XCTAssertEqual(sut.highest.isEmpty, true)
        XCTAssertEqual(sut.chartDataEntries.isEmpty, true)
        XCTAssertEqual(sut.selectedTimeframe, .day)
        XCTAssertEqual(sut.empty, true)
        XCTAssertNotNil(sut.state)
        XCTAssertNil(sut.bestPerforming)
        XCTAssertNil(sut.worstPerforming)
    }
    
    func testTimeframeSubscription() throws {
        sut.selectedTimeframe = .day
        
        let dayTimeframePromise = expectation(description: "wait for publisher to trigger update")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            dayTimeframePromise.fulfill()
        }

        wait(for: [dayTimeframePromise], timeout: 0.2)
        
        XCTAssertEqual(sut.lowest, "$95,080.5")
        XCTAssertEqual(sut.highest, "$97,035.75")
        
        sut.selectedTimeframe = .week
        
        let weekTimeframePromise = expectation(description: "wait for publisher to trigger update")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            weekTimeframePromise.fulfill()
        }

        wait(for: [weekTimeframePromise], timeout: 0.2)
        
        XCTAssertEqual(sut.lowest, "$91,350")
        XCTAssertEqual(sut.highest, "$95,152.5")
        
        sut.selectedTimeframe = .month
        
        let monthTimeframePromise = expectation(description: "wait for publisher to trigger update")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            monthTimeframePromise.fulfill()
        }

        wait(for: [monthTimeframePromise], timeout: 0.2)
        
        XCTAssertEqual(sut.lowest, "$94,500")
        XCTAssertEqual(sut.highest, "$115,200")
        
        sut.selectedTimeframe = .year
                
        let yearTimeframePromise = expectation(description: "wait for publisher to trigger update")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            yearTimeframePromise.fulfill()
        }

        wait(for: [yearTimeframePromise], timeout: 0.2)
        
        XCTAssertEqual(sut.lowest, "$67,500")
        XCTAssertEqual(sut.highest, "$155,250")
    }
    
    func testAdapterReadySubscription() throws {
        XCTAssertEqual(sut.change, String())

        adapterMannager.adapterReady.send(true)
        
        let promise = expectation(description: "wait for publisher to trigger update")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 0.4)
        XCTAssertEqual(sut.change, "+$99,358.19 (100.0%)")
    }
    
    func testCurrencySubscription() throws {
        state.wallet.currency = .eth
        
        let ethCurrencyPromise = expectation(description: "wait for publisher to trigger update")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            ethCurrencyPromise.fulfill()
        }
        
        wait(for: [ethCurrencyPromise], timeout: 0.2)
        XCTAssertEqual(sut.change, "+29.38004 ETH (100.0%)")
        
        state.wallet.currency = .btc
        
        let btcCurrencyPromise = expectation(description: "wait for publisher to trigger update")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            btcCurrencyPromise.fulfill()
        }
        
        wait(for: [btcCurrencyPromise], timeout: 0.2)
        XCTAssertEqual(sut.change, "+2.25 BTC (100.0%)")
        
        state.wallet.currency = .fiat(FiatCurrency(code: "RUB", name: "Russin rubble"))
        
        let rubleCurrencyPromise = expectation(description: "wait for publisher to trigger update")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            rubleCurrencyPromise.fulfill()
        }
        
        wait(for: [rubleCurrencyPromise], timeout: 0.2)
        XCTAssertEqual(sut.change, "+₽99,358.19 (100.0%)")
    }
    
    func testOnMarketDataUpdateSubscription() throws {
        XCTAssertEqual(sut.change, String())

        marketDataProvider.onMarketDataUpdate.send()
        
        let promise = expectation(description: "wait for publisher to trigger update")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 0.3)
        XCTAssertEqual(sut.change, "+$99,358.19 (100.0%)")
    }
    
    
}
