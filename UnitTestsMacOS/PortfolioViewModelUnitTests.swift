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
    private let walletMannager: IWalletManager = MockedWalletManager()
    private let adapterMannager: IAdapterManager = MockedAdapterManager()
    private let marketDataProvider: IMarketDataProvider = MockedMarketDataProvider()
    private let reachabilityService = ReachabilityService()
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
        
        let dayTimeframePromisse = expectation(description: "wait for publisher to trigger update")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            dayTimeframePromisse.fulfill()
        }

        wait(for: [dayTimeframePromisse], timeout: 0.2)
        
        XCTAssertEqual(sut.lowest, "$95,080.5")
        XCTAssertEqual(sut.highest, "$97,035.75")
        
        sut.selectedTimeframe = .week
        
        let weekTimeframePromisse = expectation(description: "wait for publisher to trigger update")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            weekTimeframePromisse.fulfill()
        }

        wait(for: [weekTimeframePromisse], timeout: 0.2)
        
        XCTAssertEqual(sut.lowest, "$91,350")
        XCTAssertEqual(sut.highest, "$95,152.5")
        
        sut.selectedTimeframe = .month
        
        let monthTimeframePromisse = expectation(description: "wait for publisher to trigger update")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            monthTimeframePromisse.fulfill()
        }

        wait(for: [monthTimeframePromisse], timeout: 0.2)
        
        XCTAssertEqual(sut.lowest, "$94,500")
        XCTAssertEqual(sut.highest, "$115,200")
        
        sut.selectedTimeframe = .year
                
        let yearTimeframePromisse = expectation(description: "wait for publisher to trigger update")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            yearTimeframePromisse.fulfill()
        }

        wait(for: [yearTimeframePromisse], timeout: 0.2)
        
        XCTAssertEqual(sut.lowest, "$67,500")
        XCTAssertEqual(sut.highest, "$155,250")
    }
    
    func testAdapterReadySubscription() throws {
        XCTAssertEqual(sut.change, String())

        adapterMannager.adapterdReady.send(true)
        
        let promisse = expectation(description: "wait for publisher to trigger update")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            promisse.fulfill()
        }
        
        wait(for: [promisse], timeout: 0.4)
        XCTAssertEqual(sut.change, "+$99,358.19 (100.0%)")
    }
    
    func testCurrencySubscription() throws {
        state.wallet.currency = .eth
        
        let ethCurrencyPromisse = expectation(description: "wait for publisher to trigger update")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            ethCurrencyPromisse.fulfill()
        }
        
        wait(for: [ethCurrencyPromisse], timeout: 0.2)
        XCTAssertEqual(sut.change, "+29.38004 ETH (100.0%)")
        
        state.wallet.currency = .btc
        
        let btcCurrencyPromisse = expectation(description: "wait for publisher to trigger update")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            btcCurrencyPromisse.fulfill()
        }
        
        wait(for: [btcCurrencyPromisse], timeout: 0.2)
        XCTAssertEqual(sut.change, "+2.25 BTC (100.0%)")
        
        state.wallet.currency = .fiat(FiatCurrency(code: "RUB", name: "Russin rubble"))
        
        let rubleCurrencyPromisse = expectation(description: "wait for publisher to trigger update")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            rubleCurrencyPromisse.fulfill()
        }
        
        wait(for: [rubleCurrencyPromisse], timeout: 0.2)
        XCTAssertEqual(sut.change, "+₽99,358.19 (100.0%)")
    }
    
    func testOnMarketDataUpdateSubscription() throws {
        XCTAssertEqual(sut.change, String())

        marketDataProvider.onMarketDataUpdate.send()
        
        let promisse = expectation(description: "wait for publisher to trigger update")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            promisse.fulfill()
        }
        
        wait(for: [promisse], timeout: 0.3)
        XCTAssertEqual(sut.change, "+$99,358.19 (100.0%)")
    }
    
    
}
