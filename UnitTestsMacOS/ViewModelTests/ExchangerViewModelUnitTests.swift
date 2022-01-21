//
//  ExchangerViewModelUnitTests.swift
//  UnitTestsMacOS
//
//  Created by farid on 1/17/22.
//

import XCTest
@testable import Portal

class ExchangerViewModelUnitTests: XCTestCase {
    
    private let coin: Coin = .bitcoin()
    private let currency: Currency = .fiat(USD)
        
    private var sut: ExchangerViewModel!
    private let marketDataProvider: IMarketDataProvider = MockedMarketDataProvider()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let ticker = marketDataProvider.ticker(coin: coin)
        
        sut = ExchangerViewModel(coin: coin, currency: currency, ticker: ticker)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
    }
    
    func testDefaultValues() throws {
        XCTAssertEqual(sut.coin, coin)
        XCTAssertEqual(sut.currency, currency)
        XCTAssertEqual(sut.assetValue, "0")
        XCTAssertEqual(sut.fiatValue, "0")
    }
    
    func testAssetValueChangesFiatValue() throws {
        sut.assetValue = "0.3"
        
        let promisse = expectation(description: "wait for publisher to trigger update")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            promisse.fulfill()
        }
        
        wait(for: [promisse], timeout: 0.2)
        XCTAssertEqual(sut.fiatValue, "13247.76")
    }
    
    func testFiatValueChangesAssetValue() throws {
        sut.fiatValue = "13247.76"
        
        let promisse = expectation(description: "wait for publisher to trigger update")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            promisse.fulfill()
        }
        
        wait(for: [promisse], timeout: 0.2)
        XCTAssertEqual(sut.assetValue, "0.3")
    }
    
    func testInitWithCryptoAsCurrency() throws {
        let ticker = marketDataProvider.ticker(coin: coin)
        sut = ExchangerViewModel(coin: coin, currency: .eth, ticker: ticker)
        sut.assetValue = "0.3"
        
        XCTAssertEqual(sut.fiatValue, "13247.76")
    }
    
    func testReset() throws {
        let testAssetValue = "0.3"
        sut.assetValue = testAssetValue
        
        XCTAssertEqual(sut.assetValue, testAssetValue)
        
        sut.reset()
        
        let promisse = expectation(description: "wait for publisher to trigger update")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            promisse.fulfill()
        }
        
        wait(for: [promisse], timeout: 0.2)
        
        XCTAssertEqual(sut.assetValue, String())
    }
}
