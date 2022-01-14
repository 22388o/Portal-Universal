//
//  AssetItemViewModelTests.swift
//  UnitTestsMacOS
//
//  Created by farid on 1/12/22.
//

import XCTest
import SwiftUI
import Combine
@testable import Portal

class AssetItemViewModelTests: XCTestCase {
    
    @ObservedObject private var state = PortalState()
    
    private let coin: Coin = .bitcoin()
    private let balanceAdapter: IBalanceAdapter = MockedBalanceAdapter()
    private let notificationService = NotificationService(accountManager: MockedAccountManager())
    private let marketDataProvider: IMarketDataProvider = MockedMarketDataProvider()
    
    private var sut: AssetItemViewModel!
    private var subscriptions = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = AssetItemViewModel.init(
            coin: coin,
            adapter: balanceAdapter,
            state: state,
            notificationService: notificationService,
            marketDataProvider: marketDataProvider
        )
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
    }
        
    func testSelectedValueUpdates() throws {
        XCTAssertEqual(sut.selected, true)

        state.wallet.coin = .ethereum()
        
        let promisse = expectation(description: "wait for publisher to trigger update")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            promisse.fulfill()
        }
        
        wait(for: [promisse], timeout: 0.2)
        XCTAssertEqual(sut.selected, false)
    }
    
    func testCurrencyValueUpdates() throws {
        XCTAssertEqual(sut.totalValueString, "$99,358.19")

        state.wallet.currency = .btc
        
        let promisse = expectation(description: "wait for publisher to trigger update")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            promisse.fulfill()
        }
        
        wait(for: [promisse], timeout: 0.2)
        XCTAssertEqual(sut.totalValueString, "2.25 BTC")
    }
    
    func testTotalValueStringStates() throws {
        XCTAssertEqual(sut.totalValueString, "$99,358.19")
        
        state.wallet.currency = .eth
        
        let promisse = expectation(description: "wait for publisher to trigger update")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            promisse.fulfill()
        }
        
        wait(for: [promisse], timeout: 0.2)
        XCTAssertEqual(sut.totalValueString, "29.380043 ETH")
        
        state.wallet.currency = .fiat(FiatCurrency.init(code: "RUB", name: "Russian ruble"))
        
        let promisse1 = expectation(description: "wait for publisher to trigger update")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            promisse1.fulfill()
        }
        
        wait(for: [promisse1], timeout: 0.2)
        XCTAssertEqual(sut.totalValueString, "₽99,358.19")
    }
    
    func testChangeLabelColorIsCorrect() throws {
        XCTAssertEqual(sut.changeLabelColor, Color(red: 15/255, green: 235/255, blue: 131/255, opacity: 1))
    }
    
    func testBalanceStringWitoutTicker() throws {
        sut = AssetItemViewModel.init(
            coin: Coin.init(type: .erc20(address: ""), code: "MOCK", name: "Mocked Coin", decimal: 18, iconUrl: String()),
            adapter: balanceAdapter,
            state: state,
            notificationService: notificationService,
            marketDataProvider: marketDataProvider
        )
        
        XCTAssertEqual(sut.balanceString, "2.25 MOCK")
    }
    
    func testBalanceStringWithUnspendableValue() throws {
        XCTAssertEqual(sut.balanceString, "2.25 BTC")
        
        let adapter = MockedBalanceAdapterWithUnspendable()

        sut = AssetItemViewModel.init(
            coin: coin,
            adapter: adapter,
            state: state,
            notificationService: notificationService,
            marketDataProvider: marketDataProvider
        )
        
        XCTAssertEqual(sut.balanceString, "1.25 (0.3123) BTC")
        
        adapter.balance = 1.5
        adapter.balanceStateUpdated = Just(()).eraseToAnyPublisher()
        adapter.balanceState = .syncing(progress: 90, lastBlockDate: nil)
        
        let promisse = expectation(description: "wait for publisher to trigger update")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            promisse.fulfill()
        }
        
        wait(for: [promisse], timeout: 0.2)
        XCTAssertEqual(sut.syncProgress, 0.9)
    }
    
    func testConfig() throws {
        sut = AssetItemViewModel.config(coin: coin, adapter: balanceAdapter)
        XCTAssertNotNil(sut)
    }

}
