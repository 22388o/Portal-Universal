//
//  AssetViewModelUnitTests.swift
//  UnitTestsMacOS
//
//  Created by farid on 1/10/22.
//

import XCTest
import SwiftUI
import Combine
@testable import Portal

class AssetViewModelUnitTests: XCTestCase {
    
    @ObservedObject private var state = PortalState()
    
    private let walletManager: IWalletManager = MockedWalletManager()
    private let adapterManager: IAdapterManager = MockedAdapterManager()
    private let marketDataProvider: IMarketDataProvider = MockedMarketDataProvider()
    
    private var sut: AssetViewModel!
    
    private var subscriptions = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = AssetViewModel.init(
            state: state,
            walletManager: walletManager,
            adapterManager: adapterManager,
            marketDataProvider: marketDataProvider
        )
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        subscriptions.removeAll()
    }
    
    func testDefaultValues() throws {
        let currency = sut.currency
        XCTAssertEqual(currency, .fiat(USD))
        
        let timeframe = sut.timeframe
        XCTAssertEqual(timeframe, .day)
        
        let route = sut.route
        XCTAssertEqual(route, .value)
        
        let balanceString = sut.balance
        XCTAssertEqual(balanceString, String())
        
        let totalValueString = sut.totalValue
        XCTAssertEqual(totalValueString, String())
        
        let changeString = sut.change
        XCTAssertEqual(changeString, String())
        
        let chartDataEntries = sut.chartDataEntries
        XCTAssertEqual(chartDataEntries, [])
        
        let canSend = sut.canSend
        XCTAssertEqual(canSend, false)
        
        let txsViewModel = sut.txsViewModel
        XCTAssertNotNil(txsViewModel)
        
        let coin = sut.coin
        XCTAssertNotNil(coin)
    }
    
    func testTotalSupplyStringIsSet() throws {
        let totalSupplyString = sut.totalSupply
        XCTAssertNotEqual(totalSupplyString, "-")
        XCTAssertEqual(totalSupplyString, "18,928,038 BTC")
    }
    
    func testMaxSupplyStringStates() throws {
        sut = AssetViewModel(state: state, walletManager: walletManager, adapterManager: adapterManager, marketDataProvider: marketDataProvider)
        
        let maxSupplyString = sut.maxSupply
        XCTAssertNotEqual(maxSupplyString, "-")
        XCTAssertEqual(maxSupplyString, "21,000,000 BTC")
        
        state.wallet.coin = Coin.ethereum()
        
        sut = AssetViewModel(state: state, walletManager: walletManager, adapterManager: adapterManager, marketDataProvider: marketDataProvider)
        
        XCTAssertEqual(sut.maxSupply, "Unlimited")
    }
    
    func testMarketCupStringIsSet() throws {
        let marketCupString = sut.marketCap
        XCTAssertNotEqual(marketCupString, "-")
        XCTAssertEqual(marketCupString, "$835,846,930,071")
    }
    
    func testAthPriceStringIsSet() throws {
        let athPriceString = sut.athPrice
        XCTAssertNotEqual(athPriceString, "-")
        XCTAssertEqual(athPriceString, "$68,692.14")
    }
    
    func testAthDateStringIsSet() throws {
        let athDateString = sut.athDate
        XCTAssertNotEqual(athDateString, "-")
        XCTAssertEqual(athDateString, "2 months ago")
    }
    
    func testVolume24hStringIsSet() throws {
        let volume24hString = sut.volume24h
        XCTAssertNotEqual(volume24hString, "-")
        XCTAssertEqual(volume24hString, "$87,854,170,605.59")
    }
    
    func testPercentFromPriceAthStringIsSet() throws {
        let percentFromPriceAthString = sut.percentFromPriceAth
        XCTAssertNotEqual(percentFromPriceAthString, "-")
        XCTAssertEqual(percentFromPriceAthString, "-35.71%")
    }
    
    func testHighValueStringStates() throws {
        state.wallet.currency = Currency.fiat(USD)

        sut = AssetViewModel(state: state, walletManager: walletManager, adapterManager: adapterManager, marketDataProvider: marketDataProvider)
        
        XCTAssertEqual(sut.highValue, "$43,127")

        state.wallet.currency = .btc
        
        sut = AssetViewModel(state: state, walletManager: walletManager, adapterManager: adapterManager, marketDataProvider: marketDataProvider)
        
        XCTAssertEqual(sut.highValue, "1 BTC")
        
        state.wallet.currency = .eth
        
        sut = AssetViewModel(state: state, walletManager: walletManager, adapterManager: adapterManager, marketDataProvider: marketDataProvider)
        
        XCTAssertEqual(sut.highValue, "12.7887 ETH")
        
        state.wallet.coin = .ethereum()
        
        sut = AssetViewModel(state: state, walletManager: walletManager, adapterManager: adapterManager, marketDataProvider: marketDataProvider)
        
        XCTAssertEqual(sut.highValue, "1 ETH")
        
        sut.timeframe = .year
        XCTAssertEqual(sut.highValue, "1 ETH")
    }
    
    func testLowValueStringStates() throws {
        state.wallet.currency = Currency.fiat(USD)

        sut = AssetViewModel(state: state, walletManager: walletManager, adapterManager: adapterManager, marketDataProvider: marketDataProvider)
        
        XCTAssertEqual(sut.lowValue, "$42,258")

        state.wallet.currency = .btc
        
        sut = AssetViewModel(state: state, walletManager: walletManager, adapterManager: adapterManager, marketDataProvider: marketDataProvider)
        
        XCTAssertEqual(sut.lowValue, "1 BTC")
        
        state.wallet.currency = .eth
        
        sut = AssetViewModel(state: state, walletManager: walletManager, adapterManager: adapterManager, marketDataProvider: marketDataProvider)
        
        XCTAssertEqual(sut.lowValue, "12.531 ETH")
        
        state.wallet.coin = .ethereum()
        
        sut = AssetViewModel(state: state, walletManager: walletManager, adapterManager: adapterManager, marketDataProvider: marketDataProvider)
        
        XCTAssertEqual(sut.lowValue, "1 ETH")
        
        sut.timeframe = .year
        XCTAssertEqual(sut.lowValue, "1 ETH")
    }
    
    func testChangeLabelColorIsCorrect() throws {
        XCTAssertEqual(sut.changeLabelColor, Color(red: 15/255, green: 235/255, blue: 131/255, opacity: 1))

        sut.timeframe = .month
        
        XCTAssertEqual(sut.changeLabelColor, Color(red: 255/255, green: 156/255, blue: 49/255, opacity: 1))
    }
    
    func testChangeStringStates() throws {
        let promise = expectation(description: "update coin")

        state.wallet.$coin
            .delay(for: .seconds(0.1), scheduler: RunLoop.main)
            .sink { _ in
                promise.fulfill()
            }
            .store(in: &subscriptions)
        
        state.wallet.coin = .ethereum()

        
        wait(for: [promise], timeout: 0.2)
        XCTAssertEqual(sut.change, "+$0.34 (0.01%)")
    }
    
    func testChangeStringForDayTimeframe() throws {
        sut.timeframe = .day
        
        let promise = expectation(description: "update timeframe: day")
        
        sut.$timeframe
            .delay(for: .seconds(0.1), scheduler: RunLoop.main)
            .sink { _ in
                promise.fulfill()
            }
            .store(in: &subscriptions)
                    
        wait(for: [promise], timeout: 0.2)
        XCTAssertEqual(sut.change, "+$362.11 (0.82%)")
    }
    
    func testChangeStringForWeekTimeframe() throws {
        let promise = expectation(description: "update timeframe: week")
        
        sut.$timeframe
            .dropFirst()
            .delay(for: .seconds(0.1), scheduler: RunLoop.main)
            .sink { _ in
                promise.fulfill()
            }
            .store(in: &subscriptions)
        
        sut.timeframe = .week
                    
        wait(for: [promise], timeout: 0.2)
        XCTAssertEqual(sut.change, "+$1,355.69 (3.07%)")
    }
    
    func testChangeStringForMonthTimeframe() throws {
        let promise = expectation(description: "update timeframe: month")
        
        sut.$timeframe
            .dropFirst()
            .delay(for: .seconds(0.1), scheduler: RunLoop.main)
            .sink { _ in
                promise.fulfill()
            }
            .store(in: &subscriptions)
        
        sut.timeframe = .month
                    
        wait(for: [promise], timeout: 0.2)
        XCTAssertEqual(sut.change, "-$2,684.88 (-6.08%)")
    }
    
    func testChangeStringForYearTimeframe() throws {
        let promise = expectation(description: "update timeframe: year")
        
        sut.$timeframe
            .dropFirst()
            .delay(for: .seconds(0.1), scheduler: RunLoop.main)
            .sink { _ in
                promise.fulfill()
            }
            .store(in: &subscriptions)
        
        sut.timeframe = .year
                    
        wait(for: [promise], timeout: 0.2)
        XCTAssertEqual(sut.change, "+$12,165.86 (27.55%)")
    }
    
    func testTotalValueString() throws {
        XCTAssertEqual(sut.totalValue, String())
        let promise = expectation(description: "wait for publisher to trigger update")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 0.2)
        XCTAssertEqual(sut.totalValue, "$44,159.2")
        
        state.wallet.currency = .fiat(FiatCurrency(code: "RUB", name: "Russian Ruble"))
        
        let promise1 = expectation(description: "wait for publisher to trigger update")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            promise1.fulfill()
        }
                
        wait(for: [promise1], timeout: 0.2)
        XCTAssertEqual(sut.totalValue, "₽44,159.2")
    }
    
    func testBalanceString() throws {
        XCTAssertEqual(sut.balance, String())
        
        let promise = expectation(description: "wait for publisher to trigger update")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 0.2)
        XCTAssertEqual(sut.balance, "2.25")
    }
    
    func testCanSendSetCorrectly() throws {
        XCTAssertEqual(sut.canSend, false)
        
        let promise = expectation(description: "wait for publisher to trigger update")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            promise.fulfill()
        }
        
        wait(for: [promise], timeout: 0.2)
        XCTAssertEqual(sut.canSend, true)
    }
    
    func testConfig() throws {
        sut = AssetViewModel.config()
        XCTAssertNotNil(sut)
    }
}
